# Spell Light Dynamic Shadows — UE4SS STABLE (Lua only)

**Target:** UE4SS v3.0.1 Beta #0, Git SHA `437a8ff` (the supplied STABLE variant). No DLL, source compilation or loader replacement required.

## Install using Vortex (Nexus)

In the Oblivion Remastered game profile, install the provided `...UE4SS_STABLE_Vortex.zip` through **Install From File**, enable it and **Deploy**. Ensure UE4SS STABLE is already installed and only **one** `MagicProjectileLights` mod is enabled. The Oblivion Remastered Vortex extension detects `Mods/MagicProjectileLights/Scripts/main.lua` and installs into its detected UE4SS directory.

**Manual:** the ZIP is rooted at the **UE4SS folder**, not the game root. Extract its `Mods` directory into:
`OblivionRemastered/Binaries/Win64/ue4ss/` (or the corresponding WinGDK UE4SS location for Game Pass). Result: `ue4ss/Mods/MagicProjectileLights/Scripts/main.lua` and `enabled.txt`.

## What is supported?

Identical original NEW 1.0 profile table: **38 magic families, 127 visual classes (30 projectile / 38 casting / 30 area / 29 hit)**, unchanged colour, intensity, radius, source radius, priority and phase rules. Each primary light requests dynamic shadows. Maximum **eight** primary and **four** optional small non-shadow-casting emitter accents.

STABLE implementation creates directly from the live `OnStartPlay` actor and uses bounded game-thread ownership/lifetime maintenance. No RC3-style repeated full-world scans or actor pathname lookup. `Settings.Debug=false`: no per-cast spam by default, Ctrl+F7 enables event diagnostics; Ctrl+F6 status, Ctrl+F8 lights toggle, Ctrl+F10 shadow diagnostic toggle.

## Evidence and limitations

**Confirmed live:** FireDamage casting, projectile and area-effect light creation, with expected values and dynamic-shadow flags, in the supplied 2026-11-04 STABLE log. **Offline-only:** all 127 source mappings create/attach/clean up with correct settings under Lua mocks. Remaining families (especially Bound, Drain, WaterWalking, spell hit effects), visual parity under matched scenes, FPS/frame-time behaviour and long-session stability **are not yet fully tested in the game**.

Lifetime/fade deadlines on STABLE use player gameplay DeltaSeconds; NEW's steady-clock scheduler cannot run on STABLE and pause timing may differ. See `docs/STABLE_EFFECT_AUDIT.md`.

**Rollback:** disable this mod in Vortex, deploy, then restore a backup of the prior `MagicProjectileLights` folder. Do not combine with RC1–RC3 or NEW script. No shared game or UE4SS settings are altered.
