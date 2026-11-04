# Spell Light Dynamic Shadows

An Oblivion Remastered spell-lighting mod by [iammrmikemanmods](https://github.com/iammrmikemanmods).

## Branch: UE4SS STABLE Lua-only rebuild (development)

**This branch is experimental and NOT verified in-game.** Do not merge it to `main` or advertise it as a fixed public release until first-cast rendering and performance are checked in Oblivion.

- **Actual Lua source:** [src/MagicProjectileLights/Scripts/main.lua](src/MagicProjectileLights/Scripts/main.lua)
- **STABLE install and test plan:** [README_STABLE.md](README_STABLE.md)
- **Changes:** [CHANGELOG_STABLE.md](CHANGELOG_STABLE.md)
- **Why RC1–RC3 failed:** [docs/STABLE_DIAGNOSIS.md](docs/STABLE_DIAGNOSIS.md)
- **Regression mock tests:** [tests/scenarios.lua](tests/scenarios.lua)
- **Offline verification:** [verify.py](verify.py) and [GitHub Actions](.github/workflows/stable-lua-ci.yml)

**Target UE4SS:** supplied STABLE 3.0.1 Beta #0, Git `437a8ff`. The mod itself is plain Lua and needs **no native DLL or compiled helper**.

This branch reuses the original v1.0 light profiles with no brightness/radius changes, creates lights from live `OnStartPlay` events, and avoids repeated global actor discovery or full-path recovery. Only a real game run can establish whether STABLE delivers those events and creates correctly rendered lights.

### Build test ZIP

When the `stable-lua-ci` GitHub Actions workflow succeeds, its **UNVERIFIED** artifact contains a drag-and-drop game-root ZIP. The offline tests and build are useful checks, **not** game validation. For the direct handoff, a matching ZIP is also supplied in the development conversation. The archive must contain `OblivionRemastered/Binaries/Win64/ue4ss/Mods/MagicProjectileLights/Scripts/main.lua`.

### Existing media

The original `assets/v1.0.0` GIFs remain available. They demonstrate the original mod on the NEW UE4SS loader and are the visual reference, not evidence of STABLE compatibility. The `main` branch has not been changed by this development work.
