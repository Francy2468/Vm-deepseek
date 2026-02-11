# ========================================
# ABYSS VM - MAKEFILE
# ========================================
# Un comando: make && make install
# ========================================

CC = gcc
CFLAGS = -O3 -shared -fPIC
LUA_INC = /usr/include/lua5.4
LUA_LIB = /usr/lib/x86_64-linux-gnu/liblua5.4.so

all: vm/vm_core.so

vm/vm_core.so: vm/vm_core.c
	$(CC) $(CFLAGS) -I$(LUA_INC) -o $@ $<

install:
	@echo "📦 Instalando dependencias..."
	@npm install --silent
	@luarocks install luasocket
	@echo "✅ Listo."

clean:
	rm -f vm/*.so
	rm -rf node_modules
	@echo "🧹 Limpio."

test:
	lua test/test_vm.lua

run:
	node bot/index.js

.PHONY: all install clean test run
