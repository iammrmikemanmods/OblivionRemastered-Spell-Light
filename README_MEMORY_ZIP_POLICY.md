# ZIP integrity & rollback policy

Official Vortex packaging is rooted at `Mods/MagicProjectileLights/` relative to the UE4SS directory. The archive includes the real `Scripts/main.lua`, `enabled.txt`, install/verification docs and SHA256SUMS.txt. It must not contain a loader DLL, other native binaries, placeholders, or modified UE4SS settings.

Always back up the previous complete mod folder outside the game. Never install two versions simultaneously. On failure, disable/uninstall this package in Vortex, deploy changes and restore the backup. Archive integrity is verified separately from in-game functionality.
