# Spell Light Dynamic Shadows — UE4SS STABLE Lua Port

**Status:** `1.1.0-STABLE-LUA-DEV1` — offline-tested development candidate. **Not verified in Oblivion. Do not merge or release publicly yet.**

**Target:** UE4SS `v3.0.1 Beta #0`, Git `437a8ff` from the supplied STABLE installation. **Lua only**: no C++ DLL, loader edits, asset changes or extra engine dependencies. The source lives in `src/MagicProjectileLights/Scripts/main.lua`.

## Controlled installation

1. Exit Oblivion Remastered and back up the entire existing `MagicProjectileLights` folder outside the game.
2. Use the supplied **STABLE UE4SS**, not NEW. Ensure just one active copy of this mod.
3. Download the DEV1 ZIP attached to the development handoff and extract it into the Oblivion game root, preserving:
   `OblivionRemastered/Binaries/Win64/ue4ss/Mods/MagicProjectileLights/Scripts/main.lua`
   and sibling `enabled.txt`.
4. Load the same dim interior used to test original 1.0 and cast a standard **FireDamage projectile** into a wall, then frost and shock.
5. Exit normally and preserve `ue4ss/UE4SS.log` before reopening the game.

The log needs `EVENT_REGISTRATION_REQUESTED OnStartPlay`, `VISUAL_START`, `CREATE_ATTEMPT`, and most importantly `FIRST_LIGHT_CREATED` for a real projectile. **An event registration log alone is not proof of working lights.** If creation fails, `ERROR add ...` should identify the failed step.

`Ctrl+F6`: status; `Ctrl+F7`: verbose logging; `Ctrl+F8`: toggle lights; `Ctrl+F10`: toggle shadows for diagnostic comparison.

## What changed from 1.0

- Original 1.0 `Profiles` table retained verbatim: fire 6,000 lumens / 1,000 cm; frost 4,000 / 950; shock 5,000 / 1,000; same colours, phases, priority, shadows, source radii, exclusions and 8+4 light budget.
- Light is built **directly from the live `OnStartPlay` actor**. No STABLE-incompatible runtime full-path recovery, no repeated `GetAllActorsOfClass` or global actor enumeration.
- STABLE `GetComponentsByClass` result is handled as a normal Lua table, with a TArray userdata fallback.
- `OnStopPlay`, `EndPlay` and map-pre callbacks perform cleanup. Exact class UFunction hooks are a fallback for STABLE's first-registrant custom-event behaviour.
- The NEW-only delayed game-thread scheduler is replaced with **bounded state-based lifetimes/fades advanced by player `ReceiveTick` DeltaSeconds**. This follows gameplay time, unlike 1.0's steady-clock deadlines. Exact pause-timing parity is not claimed.
- Input callbacks schedule engine operations via STABLE `ExecuteInGameThread`.

## Evidence limitations and release gate

Offline Lua 5.4 mocked tests pass for first-cast creation, profile values, duplicate suppression, fade/expiry, stop, EndPlay, map cleanup and hook fallback. They **cannot** confirm native callback delivery, FTransform marshalling, actual light/shadow rendering, crash safety or frame time.

A public release requires **a live `FIRST_LIGHT_CREATED`**, readback of settings and attachment, matched first/third-person screenshots, save/load & streamed world cleanup, and acceptable frame times versus STABLE with this mod disabled. Any missing light or new stutter blocks release.

**Rollback:** Remove this development copy of `MagicProjectileLights` and restore your prior backed-up folder. Do not mix RC1–RC3 scripts with DEV1.
