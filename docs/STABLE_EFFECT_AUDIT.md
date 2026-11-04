# UE4SS STABLE — every effect audited

**Original NEW 1.0 vs Lua STABLE:** 38 spell families and 127 visual-class mappings: casting 38, projectile 30, area 30, hit 29. The shared profile table was retained verbatim, checked against SHA-256 `7bcc3c345d480d018b438a8f5643e77a4889872c27011155a3a944eb3d178210`.

**Live gameplay evidence:** On 4 November 2026, supplied STABLE `UE4SS(5).log` confirms FireDamage casting (48 lm/120 cm), projectile (6,000 lm/1,000 cm), and area (900 lm/450 cm), each with CastShadows=true and CastDynamicShadows=true. Other families have not been individually tested live.

| Spell family | Cast | Projectile | Area | Hit | Audit notes |
|---|:---:|:---:|:---:|:---:|---|
| Absorb | ✓ | — | — | ✓ | Code-path parity; in-game testing pending |
| Armor_MythicDawn | ✓ | — | — | — | Dissolve helper deliberately excluded |
| Bound | ✓ | — | — | ✓ | Requires VMagicSpellVFXBlueprint inheritance |
| Burden | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Chameleon | ✓ | — | — | ✓ | Code-path parity; in-game testing pending |
| Charm | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Clairvoyance | ✓ | — | — | — | Code-path parity; in-game testing pending |
| Damage | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Detect | ✓ | — | — | ✓ | Code-path parity; in-game testing pending |
| Disintegrate | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Dispel | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Drain | ✓ | ✓ | ✓ | ✓ | Original `_01` class suffix |
| Feather | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| FireDamage | ✓ | ✓ | ✓ | — | Fire cast/projectile/area verified in STABLE live log |
| FireShield | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Fortify | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Frenzy | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| FrostDamage | ✓ | ✓ | ✓ | — | Code-path parity; in-game testing pending |
| FrostShield | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Illusion | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| OpenLock | ✓ | ✓ | ✓ | — | Code-path parity; in-game testing pending |
| Paralyze | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Reanimate | ✓ | ✓ | ✓ | — | Decal deliberately excluded |
| Reflect | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Resist | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Restore | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| Shield | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| ShockDamage | ✓ | ✓ | ✓ | ✓ | Original `HitEfffect` hit class spelling |
| ShockShield | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| SoulTrap | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| SpellAbsorbtion | ✓ | ✓ | ✓ | ✓ | Original spelling retained |
| SummonDaedra | ✓ | — | — | — | Casting only by original design |
| SummonGhost | ✓ | — | — | — | Casting only by original design |
| Telekinesis | ✓ | ✓ | ✓ | — | Code-path parity; in-game testing pending |
| TurnUndead | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| WaterBreathing | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |
| WaterWalking | ✓ | ✓ | ✓ | ✓ | Original `WaterWalkig` casting class spelling |
| Weakness | ✓ | ✓ | ✓ | ✓ | Code-path parity; in-game testing pending |

All mapped visual classes use the same `OnStartPlay` handler, profile resolver, point-light configuration and attachment path already proven for fire. Simulated execution of **all 127 classes** asserts intensity, radius, source radius, colour, shadow flags, duplicate suppression and cleanup. This is *conceptual/code parity*, **not a guarantee every corresponding visual is dispatched in Oblivion**.

### Deliberate exceptions and risks

- `BPCI_Spell_Armor_MythicDawn_Dissolve_Body_C` and `BPCI_Spell_Reanimate_AeraEffect_Decal_C` are excluded, unchanged from NEW.
- `WaterWalkig`, `SpellAbsorbtion`, `Drain..._01`, and `ShockDamage_HitEfffect` are the source's original spellings. Class presence and triggering still require gameplay tests.
- `Bound` visuals are accepted only if they inherit `/Script/Altar.VMagicSpellVFXBlueprint`, as in NEW.
- STABLE lifetimes use bounded gameplay `ReceiveTick` DeltaSeconds; original NEW uses steady-clock timer deadlines. Pauses/hitches can change timing.
- Default debug is **OFF**; per-cast diagnostics require Ctrl+F7. Errors remain bounded. A 10-Hz check monitors only at-most-eight active owner lights and four accents; no world-object polling.
- No measured frame times, long-session memory comparison or mod-stack compatibility results have been supplied. No claim of performance parity is made.

See `README_STABLE.md` for Nexus/Vortex installation and `CHANGELOG_STABLE.md` for the compatibility differences.
