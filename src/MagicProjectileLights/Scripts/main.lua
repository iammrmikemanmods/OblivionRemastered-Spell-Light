-- Spell Light Dynamic Shadows 1.1.0-STABLE-LUA-DEV1
-- One shadow-casting bulb per supported live magic visual, not per particle.
-- BEGIN SHARED PROFILE TABLE (source: light_profiles.lua)
local Profiles = (function()
-- Shared visual profiles, not lists of named spells. Colors are art-direction
-- defaults informed by effect families; exact cooked colors are not claimed.
local M = { Classes = {}, Excluded = {
    BPCI_Spell_Armor_MythicDawn_Dissolve_Body_C = "body dissolve, not a separate bulb",
    BPCI_Spell_Reanimate_AeraEffect_Decal_C = "decal; avoid a duplicate area light",
} }

M.Phases = {
    Projectile = { lumens = 1.0, radius = 1.0, sourceRadius = 3, lifetime = 10.0, priority = 4 },
    Casting = { lumens = 0.008, radius = 0.12, sourceRadius = 5, lifetime = 0.45, fade = 0.25, priority = 1 },
    AreaEffect = { lumens = 0.15, radius = 0.45, sourceRadius = 10, lifetime = 0.40, fade = 0.30, priority = 3 },
    HitEffect = { lumens = 0.08, radius = 0.35, sourceRadius = 6, lifetime = 0.25, fade = 0.20, priority = 2 },
}

local function color(r, g, b) return { R=r, G=g, B=b, A=1.0 } end
local purple = color(0.75, 0.62, 1.0)
local green = color(0.62, 1.0, 0.70)
local gold = color(1.0, 0.86, 0.58)
local blue = color(0.62, 0.81, 1.0)
local pink = color(1.0, 0.64, 0.82)
local warm = color(1.0, 0.40, 0.10)
M.Families = {
    Absorb={color=purple}, Armor_MythicDawn={color=warm}, Burden={color=purple},
    Chameleon={color=green}, Charm={color=pink}, Clairvoyance={color=blue},
    Damage={color=color(1.0,0.60,0.56)}, Detect={color=purple},
    Disintegrate={color=gold}, Dispel={color=blue}, Drain={color=purple},
    Feather={color=blue}, FireDamage={color=warm,lumens=6000,radius=1000},
    FireShield={color=warm,lumens=4500,radius=1000},
    Fortify={color=gold}, Frenzy={color=pink},
    FrostDamage={color=blue,lumens=4000,radius=950}, FrostShield={color=blue},
    Illusion={color=purple}, OpenLock={color=gold}, Paralyze={color=green},
    Reanimate={color=color(0.65,0.83,1.0)}, Reflect={color=blue}, Resist={color=blue},
    Restore={color=green}, Shield={color=gold},
    ShockDamage={color=color(0.78,0.72,1.0),lumens=5000,radius=1000},
    ShockShield={color=color(0.78,0.72,1.0)}, SoulTrap={color=purple},
    SpellAbsorbtion={color=purple}, SummonDaedra={color=purple}, SummonGhost={color=blue},
    Telekinesis={color=purple}, TurnUndead={color=gold}, WaterBreathing={color=blue},
    WaterWalking={color=blue}, Weakness={color=purple}, Bound={color=purple},
}

local projectiles = {
    "Burden","Charm","Damage","Disintegrate","Dispel","Drain","Feather",
    "FireDamage","FireShield","Fortify","Frenzy","FrostDamage","FrostShield",
    "Illusion","OpenLock","Paralyze","Reanimate","Reflect","Resist","Restore",
    "Shield","ShockDamage","ShockShield","SoulTrap","SpellAbsorbtion",
    "Telekinesis","TurnUndead","WaterBreathing","WaterWalking","Weakness",
}
local casting = {
    "Absorb","Armor_MythicDawn","Burden","Chameleon","Charm","Clairvoyance",
    "Damage","Detect","Disintegrate","Dispel","Drain","Feather","FireDamage",
    "FireShield","Fortify","Frenzy","FrostDamage","FrostShield","Illusion",
    "OpenLock","Paralyze","Reanimate","Reflect","Resist","Restore","Shield",
    "ShockDamage","ShockShield","SoulTrap","SpellAbsorbtion","SummonDaedra",
    "SummonGhost","Telekinesis","TurnUndead","WaterBreathing","WaterWalking","Weakness",
}
local hits = {
    "Absorb","Burden","Chameleon","Charm","Damage","Detect","Disintegrate",
    "Dispel","Drain","Feather","FireShield","Fortify","Frenzy","FrostShield",
    "Illusion","Paralyze","Reflect","Resist","Restore","Shield","ShockShield",
    "SoulTrap","SpellAbsorbtion","TurnUndead","WaterBreathing","WaterWalking","Weakness",
}

local function add(families, phase)
    for _, family in ipairs(families) do
        local spelling = family == "WaterWalking" and phase == "Casting" and "WaterWalkig" or family
        local suffix = family == "Drain" and "_01" or ""
        local name = "BPCI_Spell_" .. spelling .. "_" .. phase .. suffix .. "_C"
        M.Classes[name] = { family=family, phase=phase }
    end
end
add(projectiles, "Projectile")
add(projectiles, "AreaEffect")
add(casting, "Casting")
add(hits, "HitEffect")
M.Classes.BPCI_Spell_ShockDamage_HitEfffect_C = {family="ShockDamage",phase="HitEffect"}
-- These generic bound actors must also be instances of VMagicSpellVFXBlueprint
-- at runtime; the generic gameplay-spell blueprints are deliberately not matched.
M.Classes.BP_Spell_Bound_Casting_C = {family="Bound",phase="Casting"}
M.Classes.BP_Spell_Bound_HitEffect_C = {family="Bound",phase="HitEffect"}

function M.resolve(className)
    local entry = M.Classes[className]
    if not entry then return nil end
    local family, phase = M.Families[entry.family], M.Phases[entry.phase]
    return {
        family=entry.family, phase=entry.phase, color=family.color,
        lumens=(family.lumens or 5000) * phase.lumens,
        radius=(family.radius or 1000) * phase.radius,
        lifetime=phase.lifetime, fade=phase.fade or 0, priority=phase.priority,
        sourceRadius=phase.sourceRadius,
    }
end

return M


end)()
-- END SHARED PROFILE TABLE

local Settings = {
    Enabled = true,
    CastShadows = true,
    Phases = { Projectile=true, Casting=true, HitEffect=true, AreaEffect=true },
    MaxActiveLights = 8, -- limit bulbs; never silently turn off their shadows
    EmberAccents = true, -- only actual separate ember/spark Niagara components
    MaxEmberAccents = 4,
    Debug = false, -- public default; Ctrl+F7 enables event-driven diagnostics
}

local TAG = "[MagicProjectileLights] "
local active, tickPaths, bootPaths, byAddress = {}, {}, {}, {}
local accents = {}
local bootstrapPlayerAddress, heartbeatReady = nil, false
local startEventCount, startAttemptCount, firstLightLogged = 0, 0, false
local profileCache, describedClasses = {}, {}
local pointClass = nil
local niagaraClass = nil
local enabled = Settings.Enabled
local shadowsEnabled = Settings.CastShadows -- Ctrl+F10 is an explicit shadow-only TEST
local diagnosedRenderer = false
local created, removed, errors = 0, 0, 0
local serial = 0
local debugEnabled = Settings.Debug
local lastError = "none"
local displayedErrors = 0

local function log(message)
    print(TAG .. message .. "\n")
end

local function debugLog(message)
    if debugEnabled then log(message) end
end

local function status()
    local count = 0
    for _ in pairs(active) do count = count + 1 end
    local accentCount = 0
    for _ in pairs(accents) do accentCount = accentCount + 1 end
    log(string.format("STATUS light=%s debug=%s shadowTest=%s active=%d accents=%d created=%d removed=%d errors=%d lastError=%s",
        enabled and "ON" or "OFF", debugEnabled and "ON" or "OFF",
        shadowsEnabled and "ON" or "OFF", count, accentCount, created, removed, errors, lastError))
end

local function valid(object)
    if object == nil then return false end
    -- A native callback can hand back an expired/inaccessible wrapper. Even
    -- looking up IsValid can throw in this loader; never let that escape.
    local ok, result = pcall(function() return object:IsValid() end)
    return ok and result == true
end

local function unwrap(value)
    -- Native hook contexts are RemoteUnrealParam; construction callbacks are UObject.
    local ok, object = pcall(function() return value:get() end)
    if ok then return object end
    return value
end

local function identityTransform()
    return {
        Rotation = { X = 0.0, Y = 0.0, Z = 0.0, W = 1.0 },
        Translation = { X = 0.0, Y = 0.0, Z = 0.0 },
        Scale3D = { X = 1.0, Y = 1.0, Z = 1.0 },
    }
end

local function profileFor(actor)
    if not valid(actor) then return nil end
    local class = actor:GetClass()
    local className = class:GetFName():ToString()
    local cacheKey = class:GetFullName()
    if profileCache[cacheKey] ~= nil then return profileCache[cacheKey] or nil end
    local profile = Profiles.resolve(className)
    -- A mod subclass reusing a vanilla visual inherits its family profile.
    for _ = 1, 12 do
        if profile then break end
        local ok, parent = pcall(function() return class:GetSuperStruct() end)
        if not ok or not valid(parent) then break end
        class = parent
        profile = Profiles.resolve(class:GetFName():ToString())
    end
    profileCache[cacheKey] = profile or false
    return profile
end

local function isTarget(actor)
    return profileFor(actor) ~= nil
end

local function read(object, member)
    local ok, value = pcall(function() return object[member] end)
    return ok and tostring(value) or "unavailable"
end

local function objectName(object)
    return valid(object) and object:GetFullName() or "none"
end

local function parentOf(component)
    local ok, parent = pcall(function() return component:GetAttachParent() end)
    return ok and objectName(parent) or "unavailable"
end

local function colorReadback(light)
    local ok, result = pcall(function()
        local c = light.LightColor
        return tostring(c.R) .. "," .. tostring(c.G) .. "," .. tostring(c.B)
    end)
    return ok and result or "unavailable"
end

local function rendererDiagnostic()
    if not debugEnabled then return end
    local ok, err = pcall(function()
        local ksl = StaticFindObject("/Script/Engine.Default__KismetSystemLibrary")
        if not valid(ksl) then error("KismetSystemLibrary unavailable") end
        local values = {}
        for _, name in ipairs({"r.ShadowQuality", "r.Shadow.Virtual.Enable",
            "r.AllowPointLightCubemapShadows", "r.SupportPointLightWholeSceneShadows"}) do
            values[#values+1] = name .. "=" .. tostring(ksl:GetConsoleVariableIntValue(name))
        end
        debugLog("RENDERER " .. table.concat(values, " | ") .. " | read-only; 0 can also mean unavailable")
    end)
    if not ok then debugLog("RENDERER unavailable: " .. tostring(err)) end
end

local function visualComponents(actor)
    -- Use the existing emitter hierarchy, so hand/hit sockets and local offsets
    -- already chosen by the game's Blueprint are preserved. Never use caster feet.
    if not valid(niagaraClass) then niagaraClass = StaticFindObject("/Script/Niagara.NiagaraComponent") end
    local found, seen = {}, {}
    local function accept(component)
        if not valid(component) then return end
        local name = objectName(component)
        if not seen[name] then seen[name] = true; found[#found+1] = component end
    end
    -- STABLE returns an ordinary Lua table from a UFunction TArray result.
    -- NEW can return userdata with ForEach. Never perform a world scan.
    if valid(niagaraClass) then
        local ok, result = pcall(function() return actor:GetComponentsByClass(niagaraClass) end)
        if ok and result then
            if type(result) == "table" then
                for _, value in ipairs(result) do accept(unwrap(value)) end
            else
                pcall(function()
                    result:ForEach(function(_, value) accept(unwrap(value)) end)
                end)
            end
        elseif not ok then
            debugLog("COMPONENT_QUERY_ERROR " .. tostring(result))
        end
    end
    -- SpawnSystemAttached can produce components owned by a manager instead of
    -- this actor. Follow this visual's descendants without scanning the world.
    local queue, index = { actor.RootComponent }, 1
    while index <= #queue and index <= 32 do
        local component = queue[index]; index = index + 1
        pcall(function()
            if not valid(component) then return end
            if valid(niagaraClass) and component:IsA(niagaraClass) then accept(component) end
            local count = math.min(component:GetNumChildrenComponents(), 12)
            for childIndex = 0, count - 1 do
                if #queue < 32 then queue[#queue+1] = component:GetChildComponent(childIndex) end
            end
        end)
    end
    return found
end

local function attachmentFor(actor)
    for _, component in ipairs(visualComponents(actor)) do
        local ok, isActive = pcall(function() return component:IsActive() end)
        if ok and isActive then return component end
    end
    return actor.RootComponent
end

local function describeVisual(actor, profile, startParameters)
    if not debugEnabled then return end
    local className = actor:GetClass():GetFName():ToString()
    local descriptionKey = className .. (startParameters and ":started" or ":fallback")
    if describedClasses[descriptionKey] then return end
    describedClasses[descriptionKey] = true
    local ok, err = pcall(function()
        local root = actor.RootComponent
        local socket = root:GetAttachSocketName():ToString()
        local location = root:K2_GetComponentLocation()
        debugLog(string.format("VISUAL family=%s phase=%s | %s | root=%s | parent=%s socket=%s | rootXYZ=%.1f,%.1f,%.1f | bulbParent=%s",
            profile.family, profile.phase, className, objectName(root), parentOf(root), socket,
            location.X, location.Y, location.Z, objectName(attachmentFor(actor))))
        local components = visualComponents(actor)
        debugLog("NIAGARA components=" .. tostring(#components) .. " | " .. className)
        for i = 1, math.min(#components, 8) do
            local component = components[i]
            local assetOK, asset = pcall(function() return objectName(component.Asset) end)
            debugLog("NIAGARA component=" .. objectName(component) .. " asset=" .. (assetOK and asset or "unavailable") .. " parent=" .. parentOf(component))
        end
        if startParameters then
            local p = unwrap(startParameters)
            debugLog(string.format("PARAMETERS %s | size=%s offset=%s,%s,%s | inspect original offset; not applied twice",
                className, tostring(p.Size), tostring(p.Offset.X), tostring(p.Offset.Y), tostring(p.Offset.Z)))
        end
    end)
    if not ok then debugLog("VISUAL " .. className .. " partial/unavailable: " .. tostring(err)) end
end

local function reportError(stage, message)
    errors = errors + 1
    lastError = stage .. ": " .. tostring(message)
    -- Keep diagnostics useful without flooding the log on every object/tick.
    if displayedErrors < 12 then
        displayedErrors = displayedErrors + 1
        log("ERROR " .. lastError)
    end
end

-- STABLE-specific event and lifecycle implementation. No native plugin or DLL.
-- Avoids paths used as object locators and all periodic actor enumeration.
local accentCount, liveCount = 0, 0
local scopedVisualHooks = {}
local elapsedTicks, diagnosticStarts = 0, 0
local maxLoggedStarts, maxLoggedCreates = 12, 12

local function ownerAddress(actor)
    local ok, address = pcall(function() return actor:GetAddress() end)
    if ok and type(address) == "number" and address ~= 0 then return address end
    return nil
end

local function removeAccent(key, reason)
    local entry = accents[key]
    if not entry then return end
    accents[key] = nil
    accentCount = accentCount - 1
    local ok, err = pcall(function()
        if valid(entry.light) then
            entry.light:SetVisibility(false, false)
            if valid(entry.actor) then entry.light:K2_DestroyComponent(entry.actor) end
        end
    end)
    if not ok then reportError("accent remove", err) end
    debugLog("EMBER_REMOVE " .. reason .. " | " .. key)
end

local function removeAccentsForOwner(ownerKey, reason)
    local keys = {}
    for key, entry in pairs(accents) do
        if entry.ownerKey == ownerKey then keys[#keys + 1] = key end
    end
    for _, key in ipairs(keys) do removeAccent(key, reason) end
end

local function remove(key, reason)
    removeAccentsForOwner(key, reason)
    local entry = active[key]
    if not entry then return end
    active[key] = nil
    liveCount = liveCount - 1
    if entry.address and byAddress[entry.address] == key then
        byAddress[entry.address] = nil
    end
    local ok, err = pcall(function()
        if valid(entry.light) then
            entry.light:SetVisibility(false, false)
            if valid(entry.actor) then entry.light:K2_DestroyComponent(entry.actor) end
        end
    end)
    if not ok then reportError("remove", err) end
    removed = removed + 1
    debugLog("REMOVE " .. reason .. " | " .. key)
end

local function removeAll(reason)
    local keys = {}
    for key in pairs(active) do keys[#keys + 1] = key end
    for _, key in ipairs(keys) do remove(key, reason) end
    keys = {}
    for key in pairs(accents) do keys[#keys + 1] = key end
    for _, key in ipairs(keys) do removeAccent(key, reason) end
end

-- No delay action captures an actor or component. Timers are stored *inside*
-- the bounded live-light entries and advanced by the already-running player
-- script tick on the game thread. There are no background Lua threads.
local function armLifetime(entry)
    entry.elapsed = 0
    entry.fadeStep = 0
end

local function addAccents(actor, profile, ownerKey)
    if not enabled or not Settings.EmberAccents then return end
    if accentCount >= Settings.MaxEmberAccents then return end
    for _, component in ipairs(visualComponents(actor)) do
        if accentCount >= Settings.MaxEmberAccents then break end
        local ok, err = pcall(function()
            if not component:IsActive() then return end
            local key = objectName(component)
            if accents[key] then return end
            local assetOK, assetName = pcall(function() return objectName(component.Asset) end)
            local label = (key .. " " .. (assetOK and assetName or "")):lower()
            if not label:find("ember", 1, true) and not label:find("spark", 1, true) then return end
            local light = actor:AddComponentByClass(pointClass, false, identityTransform(), true)
            if not valid(light) then error("No accent light component returned") end
            local entry = {actor=actor, source=component, light=light,
                           ownerKey=ownerKey, elapsed=0, fadeStep=0}
            accents[key] = entry
            accentCount = accentCount + 1
            local good, why = pcall(function()
                light:SetMobility(2)
                light:SetVisibility(false, false)
                light.bUseInverseSquaredFalloff = true
                light:SetIntensityUnits(2)
                light:SetIntensity(0.03)
                light:SetAttenuationRadius(18.0)
                light:SetLightColor(profile.color, true)
                light.SourceRadius = 0.15
                light.CastDynamicShadows = false
                light.CastStaticShadows = false
                light:SetCastShadows(false)
                light:SetIndirectLightingIntensity(0.0)
                light:SetVolumetricScatteringIntensity(0.0)
                light.bAffectTranslucentLighting = false
                actor:FinishAddComponent(light, false, identityTransform())
                if not light:K2_AttachToComponent(component, FName("None"), 2, 2, 1, false) then
                    error("Accent attachment rejected")
                end
                light:SetHiddenInGame(false, false)
                light:SetVisibility(true, false)
            end)
            if not good then removeAccent(key, "setup failed"); error(why) end
            debugLog("EMBER_ADD radius=18 intensity=0.03 shadow=false | " .. key)
        end)
        if not ok then reportError("accent setup", err) end
    end
end

-- Keep original optical parameters, native component lifecycle and all
-- original family/phase profiles. This is a direct port of v1.0's add path.
local function add(actor, startParameters)
    local profile = profileFor(actor)
    if not profile then return end
    if not actor:IsA("/Script/Altar.VMagicSpellVFXBlueprint") then return end
    if actor:HasAnyFlags(0x30) then return end
    if not Settings.Phases[profile.phase] or not enabled then return end
    local key = actor:GetFullName()  -- ID only, never fed to StaticFindObject.
    local address = ownerAddress(actor)
    if not address then error("owner address unavailable") end
    if active[key] then
        -- Duplicate BeginPlay and OnStartPlay callbacks must not add a second bulb.
        if startParameters then
            local parent = attachmentFor(actor)
            local light = active[key].light
            if valid(parent) and valid(light) and parentOf(light) ~= objectName(parent) then
                if not light:K2_AttachToComponent(parent, FName("None"), 2, 2, 1, false) then
                    error("Emitter reattachment rejected")
                end
            end
            addAccents(actor, profile, key)
        end
        return
    end
    if actor:IsActorBeingDestroyed() or actor.bHidden then return end
    if not valid(actor.RootComponent) then
        if diagnosticStarts < maxLoggedStarts then log("CREATE_SKIPPED no root | " .. key) end
        return
    end
    local parent = attachmentFor(actor)
    if not valid(parent) then return end
    if byAddress[address] and byAddress[address] ~= key then
        remove(byAddress[address], "address reused")
    end
    if liveCount >= Settings.MaxActiveLights then
        local victimKey, victim = nil, nil
        for candidate, entry in pairs(active) do
            if not victim or entry.profile.priority < victim.profile.priority or
                (entry.profile.priority == victim.profile.priority and entry.serial < victim.serial) then
                victimKey, victim = candidate, entry
            end
        end
        if victim and victim.profile.priority <= profile.priority then
            remove(victimKey, "light budget")
        else
            debugLog("SKIP light budget " .. key)
            return
        end
    end
    if not valid(pointClass) then pointClass = StaticFindObject("/Script/Engine.PointLightComponent") end
    if not valid(pointClass) then error("PointLightComponent class unavailable") end
    startAttemptCount = startAttemptCount + 1
    if startAttemptCount <= maxLoggedCreates then
        log(string.format("CREATE_ATTEMPT family=%s phase=%s intensity=%.3f radius=%.3f",
            profile.family, profile.phase, profile.lumens, profile.radius))
    end
    local light = actor:AddComponentByClass(pointClass, false, identityTransform(), true)
    if not valid(light) then error("AddComponentByClass returned no component") end
    serial = serial + 1
    local entry = { actor=actor, light=light, profile=profile, serial=serial, address=address }
    active[key], byAddress[address] = entry, key
    liveCount = liveCount + 1
    armLifetime(entry)
    local ok, err = pcall(function()
        light:SetMobility(2)
        light:SetVisibility(false, false)
        light.bUseInverseSquaredFalloff = true
        light:SetIntensityUnits(2)
        light:SetIntensity(profile.lumens)
        light:SetLightColor(profile.color, true)
        light:SetAttenuationRadius(profile.radius)
        light.SourceRadius = profile.sourceRadius
        light.CastDynamicShadows = shadowsEnabled
        light.CastStaticShadows = shadowsEnabled
        light:SetCastShadows(shadowsEnabled)
        actor:FinishAddComponent(light, false, identityTransform())
        if not light:K2_AttachToComponent(parent, FName("None"), 2, 2, 1, false) then
            error("Light attachment rejected")
        end
        light:SetHiddenInGame(false, false)
        if shadowsEnabled and (not light.CastShadows or not light.CastDynamicShadows) then
            error("Shadow flags did not survive registration")
        end
        light:SetVisibility(true, false)
    end)
    if not ok then remove(key, "creation failed"); error(err) end
    created = created + 1
    if not firstLightLogged or created <= maxLoggedCreates then
        log(string.format("FIRST_LIGHT_CREATED family=%s phase=%s intensity=%s radius=%s cast=%s dynamic=%s parent=%s",
            profile.family, profile.phase, read(light,"Intensity"),
            read(light,"AttenuationRadius"), read(light,"CastShadows"),
            read(light,"CastDynamicShadows"), parentOf(light)))
        firstLightLogged = true
    end
    debugLog("CREATE_SUCCESS " .. key)
    if not diagnosedRenderer then diagnosedRenderer = true; rendererDiagnostic() end
    addAccents(actor, profile, key)
end

local function safelyAdd(actor, parameters)
    local ok, err = pcall(add, actor, parameters)
    if not ok then reportError("add", err) end
end

local function started(context, parameters, source)
    local actor = unwrap(context)
    local ok, err = pcall(function()
        local profile = profileFor(actor)
        if not profile then return end
        startEventCount = startEventCount + 1
        if startEventCount <= maxLoggedStarts then
            log("VISUAL_START source=" .. source .. " family=" .. profile.family ..
                " phase=" .. profile.phase .. " | " .. actor:GetFullName())
        end
        safelyAdd(actor, parameters)
    end)
    if not ok then reportError("visual " .. source, err) end
end

local function stopped(context, reason)
    local actor = unwrap(context)
    local ok, err = pcall(function()
        local address = ownerAddress(actor)
        local key = address and byAddress[address]
        if key then remove(key, reason) end
    end)
    if not ok then reportError("stop " .. reason, err) end
end

local function maintenance(dt)
    -- Bounded at 8+4 entries; no object/class lookup, enumeration or logging
    -- on an idle frame. DeltaSeconds comes from actual player ReceiveTick.
    if liveCount == 0 and accentCount == 0 then return end
    dt = math.max(0, math.min(tonumber(dt) or 0, 0.25))
    if dt <= 0 then return end
    local expired = {}
    for key, entry in pairs(active) do
        entry.elapsed = entry.elapsed + dt
        local profile = entry.profile
        local fade = profile.fade or 0
        if fade > 0 then
            while entry.fadeStep < 4 do
                local nextStep = entry.fadeStep + 1
                local threshold = profile.lifetime - fade + (fade * nextStep/4)
                if entry.elapsed < threshold then break end
                entry.fadeStep = nextStep
                local ok, err = pcall(function()
                    if valid(entry.light) then
                        entry.light:SetIntensity(profile.lumens * (1 - nextStep/4))
                    end
                end)
                if not ok then reportError("fade", err) end
            end
        end
        if entry.elapsed >= profile.lifetime then expired[#expired + 1] = key end
    end
    for _, key in ipairs(expired) do remove(key, "lifetime deadline") end
    expired = {}
    for key, entry in pairs(accents) do
        entry.elapsed = entry.elapsed + dt
        while entry.fadeStep < 4 do
            local nextStep = entry.fadeStep + 1
            if entry.elapsed < 0.04 + 0.16*nextStep/4 then break end
            entry.fadeStep = nextStep
            local ok, err = pcall(function()
                if valid(entry.light) then
                    entry.light:SetIntensity(0.03 * (1 - nextStep/4))
                end
            end)
            if not ok then reportError("accent fade", err) end
        end
        if entry.elapsed >= 0.2 then expired[#expired + 1] = key end
    end
    for _, key in ipairs(expired) do removeAccent(key, "accent deadline") end
end

local function getPawn(controller)
    if not valid(controller) then return nil end
    local ok, pawn = pcall(function() return controller.Pawn end)
    if not ok or not valid(pawn) then
        ok, pawn = pcall(function() return controller:GetPawn() end)
    end
    return ok and valid(pawn) and pawn or nil
end

local function setupTick(pawn, source)
    local ok, err = pcall(function()
        if not valid(pawn) then return end
        local name = pawn:GetClass():GetFName():ToString()
        if not name:find("OblivionPlayerCharacter", 1, true) then return end
        local playerAddress = ownerAddress(pawn)
        if not playerAddress then return end
        bootstrapPlayerAddress = playerAddress
        local fn = pawn.ReceiveTick
        if not valid(fn) then error("player ReceiveTick not exposed") end
        local path = fn:GetFullName():gsub("^Function ", "")
        if tickPaths[path] then return end
        local preId, postId = RegisterHook(path, function(context, delta)
            local actor = unwrap(context)
            if ownerAddress(actor) ~= bootstrapPlayerAddress then return end
            local okDelta, actualDelta = pcall(function() return unwrap(delta) end)
            if not okDelta or type(actualDelta) ~= "number" then
                if not tickPaths[path .. "_warned"] then
                    tickPaths[path .. "_warned"] = true
                    log("TICK_DELTA_UNAVAILABLE | expected float RemoteUnrealParam")
                end
                return
            end
            elapsedTicks = elapsedTicks + 1
            maintenance(actualDelta)
        end)
        tickPaths[path] = {preId,postId}
        heartbeatReady = true
        log("STABLE_TICK_HOOK_INSTALLED " .. path .. " via " .. source)
    end)
    if not ok then reportError("tick hook " .. source, err) end
end

local function controllerReady(context, source)
    local controller = unwrap(context)
    local pawn = getPawn(controller)
    if pawn then setupTick(pawn, source) end
end

local function installControllerBootstrap(path)
    local ok, err = pcall(function()
        -- Post hook: pawn assignment may not be complete at native pre hook.
        local preId, postId = RegisterHook(path,
            function() end,
            function(context) controllerReady(context, path) end)
        bootPaths[path] = {preId,postId}
        log("BOOTSTRAP_HOOK " .. path)
    end)
    if not ok then reportError("bootstrap hook " .. path, err) end
end

-- Most important: event registered BEFORE any visual is created. STABLE's
-- ProcessLocalScriptFunction callback receives the actual live actor here,
-- no NotifyOnNewObject or pathname re-resolution is necessary.
local function registerEvent(name, fn)
    local ok, err = pcall(function() RegisterCustomEvent(name, fn) end)
    if ok then log("EVENT_REGISTRATION_REQUESTED " .. name)
    else reportError("event " .. name, err) end
end
registerEvent("OnStartPlay", function(context, params)
    started(context, params, "OnStartPlay")
end)
registerEvent("OnStopPlay", function(context)
    stopped(context, "OnStopPlay")
end)
registerEvent("OnChangeLevel", function(context)
    stopped(context, "OnChangeLevel")
end)

-- Per-class fallback: if another mod has already claimed STABLE's single
-- RegisterCustomEvent slot for a common name, an exact UFunction hook still
-- reaches this visual. Installed once per actual class, never from a world scan.
local function hookVisualFunction(actor, eventName, callback)
    local ok, functionObject = pcall(function() return actor[eventName] end)
    if not ok or not valid(functionObject) then return end
    local path = functionObject:GetFullName():gsub("^Function ", "")
    if scopedVisualHooks[path] then return end
    local hookOk, preId, postId = pcall(RegisterHook, path, function(context, first)
        callback(context, first)
    end)
    if hookOk then
        scopedVisualHooks[path] = {preId, postId}
        debugLog("VISUAL_HOOK " .. path)
    else
        reportError("visual hook " .. eventName, preId)
    end
end

local beginOk, beginErr = pcall(function()
    RegisterBeginPlayPostHook(function(context)
        local actor = unwrap(context)
        local ok, err = pcall(function()
            if not valid(actor) then return end
            local className = actor:GetClass():GetFName():ToString()
            if className:find("OblivionPlayerCharacter",1,true) then
                setupTick(actor, "BeginPlay")
            elseif Profiles.Classes[className] then
                hookVisualFunction(actor, "OnStartPlay", function(ctx, params)
                    started(ctx, params, "OnStartPlay class hook")
                end)
                hookVisualFunction(actor, "OnStopPlay", function(ctx)
                    stopped(ctx, "OnStopPlay class hook")
                end)
                -- BeginPlay can happen before an effect creates its emitter;
                -- its later OnStartPlay event reattaches the same light.
                started(actor, nil, "BeginPlay")
            end
        end)
        if not ok then reportError("BeginPlay", err) end
    end)
end)
if not beginOk then reportError("BeginPlay subscription", beginErr) end

-- EndPlay executes before an actor's memory can be recycled. Quick address
-- membership check avoids inspecting other actors' classes on this hot hook.
local endOk, endErr = pcall(function()
    RegisterEndPlayPreHook(function(context)
        stopped(context, "EndPlay")
    end)
end)
if not endOk then reportError("EndPlay subscription", endErr) end

local mapOk, mapErr = pcall(function()
    RegisterLoadMapPreHook(function()
        removeAll("map transition")
        bootstrapPlayerAddress = nil
    end)
end)
if not mapOk then reportError("map pre subscription", mapErr) end

installControllerBootstrap("/Script/Engine.PlayerController:ClientRestart")
installControllerBootstrap("/Script/Engine.PlayerController:ClientSetHUD")
installControllerBootstrap("/Script/Engine.Controller:Possess")

-- One-shot recovery of a save loaded before the mod starts. No repeat scan.
local scanOk, scanErr = pcall(function()
    ExecuteInGameThread(function()
        local ok, pawn = pcall(function() return FindFirstOf("BP_OblivionPlayerCharacter_C") end)
        if ok and valid(pawn) then setupTick(pawn, "one-shot recovery") end
    end)
end)
if not scanOk then reportError("player recovery", scanErr) end

-- Input callbacks may come from outside the game thread in this UE4SS build;
-- always dispatch engine mutation via ExecuteInGameThread.
local function dispatch(label, callback)
    local ok, err = pcall(function()
        ExecuteInGameThread(function()
            local good, why = pcall(callback)
            if not good then reportError(label, why) end
        end)
    end)
    if not ok then reportError("key dispatch " .. label, err) end
end

local function registerControl(key, label, callback)
    local ok, err = pcall(function()
        RegisterKeyBind(key, {ModifierKey.CONTROL}, function()
            dispatch(label, callback)
        end)
    end)
    if not ok then reportError("key " .. label, err) end
end
registerControl(Key.F8, "enabled", function()
    enabled = not enabled
    if not enabled then removeAll("disabled") end
    status()
end)
registerControl(Key.F7, "debug", function()
    debugEnabled = not debugEnabled
    log("DEBUG " .. (debugEnabled and "ON" or "OFF"))
    status()
end)
registerControl(Key.F6, "status", function()
    status()
    log(string.format("EVENT_STATUS starts=%d creates=%d tickInstalled=%s ticks=%d lastError=%s",
        startEventCount, created, tostring(heartbeatReady), elapsedTicks, lastError))
    rendererDiagnostic()
end)
registerControl(Key.F10, "shadow comparison", function()
    shadowsEnabled = not shadowsEnabled
    for _, entry in pairs(active) do
        local ok, err = pcall(function()
            if valid(entry.light) then
                entry.light.CastDynamicShadows = shadowsEnabled
                entry.light.CastStaticShadows = shadowsEnabled
                entry.light:SetCastShadows(shadowsEnabled)
            end
        end)
        if not ok then reportError("shadow compare", err) end
    end
    log("SHADOW COMPARISON " .. (shadowsEnabled and "ON" or "OFF"))
    status()
end)

log("Spell Light Dynamic Shadows 1.1.0-STABLE-LUA-DEV1 | event-only visual tracking, no world polling")
log("Ctrl+F8 light / Ctrl+F7 debug / Ctrl+F6 status / Ctrl+F10 shadow comparison")
