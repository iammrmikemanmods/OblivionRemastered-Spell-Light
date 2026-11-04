# Spell Light 1.1.0 — UE4SS STABLE Lua port

- Based on original NEW 1.0, not failed RC1–RC3.
- Exact original 38-family/127-visual profile parity; original light intensity, colour, attenuation, source radius and dynamic shadow flags preserved.
- Confirmed live fire casting/projectile/area lights on STABLE v3.0.1-394-g437a8ff.
- Uses the live OnStartPlay actor. Removed repeated world discovery and unreliable actor pathname re-resolution.
- STABLE Lua table-compatible component discovery; game-thread bounded fade and lifecycle.
- Debug logging off by default; Ctrl+F7 explicitly enables verbose event/light readback; errors remain bounded.
- Bounded 10-Hz owned-actor/emitter validation while effects are active; no full-world scans, idle light-maintenance loop returns immediately.
- Exhaustive offline scenario checks for every one of 127 visual profiles, exclusions, duplicate handling, shadows, hidden cleanup, and activation.
- Nexus/Vortex-friendly UE4SS-relative layout: Mods/MagicProjectileLights/ .

**Remaining validation:** non-fire live gameplay coverage, frame-time benchmarking, reload/streaming stress, full mod-stack compatibility. STABLE gameplay-clock timing differs from NEW steady-clock timing.
