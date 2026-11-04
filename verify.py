#!/usr/bin/env python3
"""Offline STABLE gate; does not verify game rendering."""
from pathlib import Path
import hashlib
root=Path(__file__).resolve().parent
script=root/'src/MagicProjectileLights/Scripts/main.lua'
s=script.read_text(encoding='utf-8')
a=s[s.index('-- BEGIN SHARED PROFILE TABLE'):s.index('-- END SHARED PROFILE TABLE')+len('-- END SHARED PROFILE TABLE')]
expected='7bcc3c345d480d018b438a8f5643e77a4889872c27011155a3a944eb3d178210'
assert hashlib.sha256(a.encode('utf-8')).hexdigest()==expected,'Original profile table changed'
for bad in ('GetAllActorsOfClass', 'LoopInGameThreadWithDelay(', 'ExecuteInGameThreadWithDelay(', 'StaticFindObject(nil', 'FindObjects('):
    assert bad not in s,'Forbidden STABLE/periodic API: '+bad
for required in ('FIRST_LIGHT_CREATED','RegisterCustomEvent','RegisterEndPlayPreHook','RegisterLoadMapPreHook'):
    assert required in s,'Missing required mechanism: '+required
assert '    Debug = false,' in s,'Debug is not OFF by default'
assert 'if debugEnabled and startEventCount <= maxLoggedStarts then' in s,'Unconditional spell-start logs'
assert 'if debugEnabled and startAttemptCount <= maxLoggedCreates then' in s,'Unconditional creation attempts'
assert 'if debugEnabled and (not firstLightLogged or created <= maxLoggedCreates) then' in s,'Unconditional light-success logs'
assert 'local inspectOwners = validationAccumulator >= 0.10' in s,'Bounded owner validation missing'
print('Original profile integrity, debug-off, bounded lifecycle and STABLE API checks PASS')
print('Source SHA256:',hashlib.sha256(script.read_bytes()).hexdigest())
