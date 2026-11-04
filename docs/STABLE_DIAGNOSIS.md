# Technical diagnosis: why the RC series failed

These findings are based on the supplied STABLE loader, prior user logs and UE4SS source revision `437a8ff`. They do **not** prove that DEV1 works in-game.

- **RC1** rejected STABLE's valid callable native `FName` because it was not an ordinary Lua function.
- **RC2** started but did not install the required player-tick hook in the logged test.
- **RC3** installed the pump and detected a FireDamage projectile but never reported a successfully created point light. Its runtime actor resolution used full names such as `Map:PersistentLevel.Projectile_123`. The STABLE uncached resolver mishandles nested object names, making this lookup unreliable.
- **RC3 stutter risk:** repeated `GetAllActorsOfClass` outparam calls on the supplied STABLE revision retain Lua registry table references. Repeated global actor discovery and path resolution also add work. This is evidence of regression mechanisms, not a measured attribution of user FPS loss.
- Earlier mock tests exercised only simulated APIs; they did not reproduce actual STABLE object lookup, callback routing or rendering.

This build instead uses event-provided live objects immediately, no full path re-resolution and no world enumeration. If `FIRST_LIGHT_CREATED` is absent, investigate the live event bridge and creation stack; do not inflate brightness to conceal inactive lights.

Sources: [STABLE LuaMod.cpp](https://github.com/UE4SS-RE/RE-UE4SS/blob/437a8ff/UE4SS/src/Mod/LuaMod.cpp), [STABLE LuaUObject.cpp](https://github.com/UE4SS-RE/RE-UE4SS/blob/437a8ff/UE4SS/src/LuaType/LuaUObject.cpp), [NEW timer implementation PR](https://github.com/UE4SS-RE/RE-UE4SS/pull/1128).
