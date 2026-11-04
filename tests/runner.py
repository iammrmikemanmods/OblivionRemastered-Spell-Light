#!/usr/bin/env python3
"""Executes the real Lua script with simulated Unreal objects (not an in-game test)."""
from __future__ import annotations
import ctypes,ctypes.util,pathlib,sys
root=pathlib.Path(__file__).resolve().parent.parent
lib=ctypes.CDLL(ctypes.util.find_library('lua5.4'))
proto={
 'luaL_newstate':([],ctypes.c_void_p),
 'luaL_openlibs':([ctypes.c_void_p],None),
 'lua_close':([ctypes.c_void_p],None),
 'luaL_loadbufferx':([ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_char_p],ctypes.c_int),
 'lua_pcallk':([ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_ssize_t,ctypes.c_void_p],ctypes.c_int),
 'lua_tolstring':([ctypes.c_void_p,ctypes.c_int,ctypes.POINTER(ctypes.c_size_t)],ctypes.c_void_p),
}
for name,(args,ret) in proto.items():
 f=getattr(lib,name); f.argtypes=args;f.restype=ret
L=lib.luaL_newstate();lib.luaL_openlibs(L)
def error():
 n=ctypes.c_size_t()
 ptr=lib.lua_tolstring(L,-1,ctypes.byref(n))
 return ctypes.string_at(ptr,n.value).decode(errors='replace') if ptr else '<nonstring>'
try:
 code=(root/'tests/scenarios.lua').read_bytes()
 # Test harness locates the loaded mod by absolute path and executes it in Lua.
 mod=(root/'src/MagicProjectileLights/Scripts/main.lua').as_posix()
 code=('MOD_PATH = '+repr(mod)+'\n').encode()+code
 rc=lib.luaL_loadbufferx(L,code,len(code),b'@scenarios.lua',b't')
 if rc: raise RuntimeError('Lua syntax: '+error())
 rc=lib.lua_pcallk(L,0,0,0,0,None)
 if rc: raise RuntimeError('Lua runtime/test: '+error())
 print('Lua mock scenarios PASS')
finally:lib.lua_close(L)
