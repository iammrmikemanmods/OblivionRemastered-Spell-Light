# Spell Light Dynamic Shadows — STABLE development changelog

## 1.1.0-STABLE-LUA-DEV1 — offline tested, gameplay unverified

- Rebuilt from the original working 1.0; **not** based on RC1, RC2 or RC3.
- Kept the original profile data and visual light configuration unchanged.
- Added STABLE short-name `RegisterCustomEvent` callbacks for `OnStartPlay`, `OnStopPlay` and `OnChangeLevel`.
- Added one-time controller/player bootstrapping, per-class BeginPlay fallback, EndPlay and map cleanup.
- Replaced NEW-only delayed APIs with bounded game-thread Lua light maintenance. Timing uses gameplay DeltaSeconds; this is an intentional documented difference from NEW.
- Removed recurring world actor scans, full actor pathname re-lookup and RC3 discovery loops.
- Adapted local component queries to STABLE's Lua table return.
- Added explicit first-light creation and settings readback logs.
- Offline mocks and profile parity checks pass. **Native STABLE delivery, shadows, in-game behavior and frame times still need testing.**
