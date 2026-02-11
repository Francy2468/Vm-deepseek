// ========================================
// ABYSS VM - CORE NATIVO (C)
// ========================================
// Compilá con: gcc -O3 -shared -fPIC vm_core.c -o vm_core.so
// Esto acelera la VM 10x. Si no compilás, igual funciona en Lua puro.
// ========================================

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdint.h>
#include <string.h>

// XOR acelerado en C
static int abyss_xor(lua_State *L) {
    const char *str = luaL_checkstring(L, 1);
    int key = luaL_checkinteger(L, 2);
    size_t len = strlen(str);
    
    luaL_Buffer b;
    luaL_buffinit(L, &b);
    
    for (size_t i = 0; i < len; i++) {
        char c = str[i] ^ (key & 0xFF);
        luaL_addchar(&b, c);
    }
    
    luaL_pushresult(&b);
    return 1;
}

// Checksum rápido
static int abyss_checksum(lua_State *L) {
    const char *data = luaL_checkstring(L, 1);
    size_t len = strlen(data);
    uint32_t hash = 0x7F3B5A1C;
    
    for (size_t i = 0; i < len; i++) {
        hash ^= (hash << 5) + (hash >> 2) + data[i];
    }
    
    lua_pushinteger(L, hash);
    return 1;
}

// Registro de funciones
static const luaL_Reg abyss_lib[] = {
    {"xor", abyss_xor},
    {"checksum", abyss_checksum},
    {NULL, NULL}
};

int luaopen_vm_core(lua_State *L) {
    luaL_newlib(L, abyss_lib);
    return 1;
}
