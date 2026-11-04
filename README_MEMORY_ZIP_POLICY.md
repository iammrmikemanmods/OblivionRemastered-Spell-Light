# Memory & ZIP integrity policy

This is a private **unverified** STABLE test candidate. The game-root archive contains the real `OblivionRemastered/Binaries/Win64/ue4ss/Mods/MagicProjectileLights/Scripts/main.lua` and `enabled.txt`. It does not replace UE4SS.dll, game assets or other mods. Back up original 1.0 outside the game before testing. Extract and inspect its source and SHA256 digest before release.

An offline Lua mock is NOT proof of in-game compatibility. Missing first-cast lights, altered appearance, failed cleanup, crashes or frame-time regression reject this candidate. Never merge to main or publish a Nexus version until those checks are satisfied in Oblivion.
