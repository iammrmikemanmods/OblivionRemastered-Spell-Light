local hooks, events, calls, logs = {}, {}, {}, {}
local beginCb, endCb, mapCb = nil, nil, nil
local function assertion(value,message) assert(value,message) end
function print(s) logs[#logs+1] = tostring(s) end
local ids=0
local function object(name)
    ids=ids+1
    return { name=name, addr=ids,
       IsValid=function(self) return not self.destroyed end,
       GetAddress=function(self) return self.addr end,
       GetFullName=function(self) return self.name end,
    }
end
local class=object('/Script/Altar.VMagicSpellVFXBlueprint')
local pointClass=object('/Script/Engine.PointLightComponent')
local niagaraClass=object('/Script/Niagara.NiagaraComponent')
function StaticFindObject(path)
   if path=='/Script/Engine.PointLightComponent' then return pointClass end
   if path=='/Script/Niagara.NiagaraComponent' then return niagaraClass end
   return nil
end
function FindFirstOf() return nil end
function FName(name) return name end
Key={F8=119,F7=118,F6=117,F10=121}
ModifierKey={CONTROL=17}
function RegisterKeyBind(key,mods,cb) calls['key'..key]=cb end
function RegisterHook(path,pre,post)
 hooks[path]={pre=pre,post=post};return 1,2
end
function RegisterCustomEvent(name,fn) events[name]=fn end
function RegisterBeginPlayPostHook(fn) beginCb=fn end
function RegisterEndPlayPreHook(fn) endCb=fn end
function RegisterLoadMapPreHook(fn) mapCb=fn end
function ExecuteInGameThread(fn) fn() end

local function makeClass(name)
    local c=object('Class '..name)
    function c:GetFName() return {ToString=function() return name end} end
    function c:GetSuperStruct() return nil end
    return c
end
local root=object('VisualRoot')
function root:GetNumChildrenComponents() return 0 end
function root:GetAttachParent() return nil end
local fireClass=makeClass('BPCI_Spell_FireDamage_Projectile_C')
local frostClass=makeClass('BPCI_Spell_FrostDamage_Projectile_C')
local castClass=makeClass('BPCI_Spell_FireDamage_Casting_C')
local playerClass=makeClass('BP_OblivionPlayerCharacter_C')
local componentQueries=0
local lightSerial=0
local function makeLight()
    lightSerial=lightSerial+1
    local l=object('PointLight_'..lightSerial)
    function l:SetMobility(v) self.Mobility=v end
    function l:SetVisibility(v) self.visible=v end
    function l:SetIntensityUnits(v) self.units=v end
    function l:SetIntensity(v) self.Intensity=v end
    function l:SetLightColor(v) self.LightColor=v end
    function l:SetAttenuationRadius(v) self.AttenuationRadius=v end
    function l:SetCastShadows(v) self.CastShadows=v end
    function l:K2_AttachToComponent(p) self.parent=p;return true end
    function l:GetAttachParent() return self.parent end
    function l:SetHiddenInGame(v) self.hidden=v end
    function l:K2_DestroyComponent() self.destroyed=true end
    return l
end
local visualSerial=0
local function makeVisual(c)
    visualSerial=visualSerial+1
    local a=object('/Game/Map.Map:PersistentLevel.Visual_'..visualSerial)
    a.RootComponent=root
    a.cls=c
    a.bHidden=false
    a.lights={}
    a.OnStartPlay=object('Function /Game/Art/FX/Test.'..c.name..':OnStartPlay')
    a.OnStopPlay=object('Function /Game/Art/FX/Test.'..c.name..':OnStopPlay')
    function a:GetClass() return self.cls end
    function a:HasAnyFlags() return false end
    function a:IsA(v) return v=='/Script/Altar.VMagicSpellVFXBlueprint' end
    function a:IsActorBeingDestroyed() return false end
    function a:GetComponentsByClass() componentQueries=componentQueries+1; return {} end
    function a:AddComponentByClass(cls,manual,transform,finish)
        assertion(cls==pointClass,'point class')
        assertion(transform and transform.Rotation and transform.Scale3D,'FTransform passed')
        local l=makeLight()
        table.insert(self.lights,l)
        return l
    end
    function a:FinishAddComponent(light,manual,transform) light.finished=true end
    return a
end

-- native FName is callable userdata on the real loader. A table with __call
-- represents the same Lua call semantics in this harness.
FName=setmetatable({}, {__call=function(_,name) return name end})
local ok,err=pcall(dofile,MOD_PATH)
assertion(ok,'module load failed: '..tostring(err))
assertion(events.OnStartPlay~=nil,'OnStartPlay custom event registered at startup')
assertion(events.OnStopPlay~=nil,'OnStopPlay event registered')
assertion(endCb~=nil and mapCb~=nil,'lifecycle subscriptions')

local fire=makeVisual(fireClass)
events.OnStartPlay(fire)
assertion(#fire.lights==1,'FIRST CAST must create light synchronously')
assertion(fire.lights[1].Intensity==6000,'original fire intensity preserved')
assertion(fire.lights[1].AttenuationRadius==1000,'original fire radius preserved')
assertion(fire.lights[1].CastShadows==true and fire.lights[1].CastDynamicShadows==true,'shadows preserved')
assertion(fire.lights[1].finished and fire.lights[1].parent==root,'component registered and attached')
events.OnStartPlay(fire)
assertion(#fire.lights==1,'duplicate OnStartPlay must not duplicate component')
assertion(table.concat(logs,'\n'):find('FIRST_LIGHT_CREATED',1,true),'first-light evidence')

events.OnStopPlay(fire)
assertion(fire.lights[1].destroyed==true,'OnStopPlay cleanup')
local frost=makeVisual(frostClass)
events.OnStartPlay(frost)
assertion(frost.lights[1].Intensity==4000 and frost.lights[1].AttenuationRadius==950,'frost parity')

local player=object('/Game/...Player_1')
player.cls=playerClass
function player:GetClass() return self.cls end
player.ReceiveTick=object('Function /Game/Dev/PlayerBlueprints/BP_OblivionPlayerCharacter.BP_OblivionPlayerCharacter_C:ReceiveTick')
local controller=object('PlayerController')
controller.Pawn=player
local restart=hooks['/Script/Engine.PlayerController:ClientRestart']
assertion(restart and restart.post,'client restart bootstraps player tick')
restart.post(controller)
local tick=hooks['/Game/Dev/PlayerBlueprints/BP_OblivionPlayerCharacter.BP_OblivionPlayerCharacter_C:ReceiveTick']
assertion(tick and tick.pre,'player tick hook installed')
local oldLight=frost.lights[1]
local beforeTicks = componentQueries
for n=1,45 do tick.pre(player,0.25) end
assertion(oldLight.destroyed==true,'projectile expires without actor scan')
assertion(#frost.lights==1,'tick does not manufacture light')
assertion(componentQueries==beforeTicks,'idle/live tick never enumerates components')

local casting=makeVisual(castClass)
events.OnStartPlay(casting)
assertion(casting.lights[1].Intensity==48,'original casting intensity (6000*0.008)')
for n=1,8 do tick.pre(player,0.05) end
assertion(casting.lights[1].Intensity < 48,'casting fade advances')
for n=1,3 do tick.pre(player,0.05) end
assertion(casting.lights[1].destroyed==true,'casting light expires')

local after=makeVisual(fireClass)
events.OnStartPlay(after)
endCb(after)
assertion(after.lights[1].destroyed,'EndPlay removes light before memory is reused')
local another=makeVisual(fireClass)
events.OnStartPlay(another)
mapCb()
assertion(another.lights[1].destroyed,'map pre hook cleans up')

for _,log in ipairs(logs) do
   assertion(not log:find('DISABLED: required STABLE API missing: FName',1,true),'startup regression')
end
-- Independently verify the per-UFunction fallback registered by BeginPlay.
-- This remains available if another mod claimed STABLE's shared short-name event.
local fallback=makeVisual(fireClass)
beginCb(fallback)
assertion(#fallback.lights==1,'BeginPlay fallback creates first light')
local startPath=fallback.OnStartPlay:GetFullName():gsub('^Function ','')
assertion(hooks[startPath]~=nil,'per-class OnStartPlay hook registered')
local originalEvent=events.OnStartPlay
events.OnStartPlay=nil
hooks[startPath].pre(fallback)
assertion(#fallback.lights==1,'per-class hook does not duplicate first light')
events.OnStartPlay=originalEvent
assertion(lightSerial==6,'expected 6 components total; got '..lightSerial)
assertion(startEventCount==nil,'source locals should not leak as globals')
print('PASS all scenarios')
