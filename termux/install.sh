#!/data/data/com.termux/files/usr/bin/bash

# ========================================
# ABYSS VM - INSTALADOR PARA TERMUX
# ========================================
# Un comando. Todo listo. Salí de acá.
# ========================================

echo "🔥 ABYSS VM v3.0 - INSTALADOR PARA TERMUX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. ACTUALIZAR
echo "[1/8] Actualizando paquetes..."
pkg update -y && pkg upgrade -y

# 2. INSTALAR DEPENDENCIAS
echo "[2/8] Instalando dependencias..."
pkg install -y nodejs lua54 luajit git python clang make cmake

# 3. INSTALAR LUAROCKS
echo "[3/8] Instalando LuaRocks..."
pkg install -y luarocks
luarocks install luasocket
luarocks install luasec
luarocks install lua-cjson

# 4. CLONAR REPO (SI ESTÁS EN INSTALACIÓN LOCAL, SKIP)
echo "[4/8] Configurando Abyss VM..."
cd ~
if [ ! -d "abyss-vm" ]; then
    echo "⚠️  No se encontró la carpeta abyss-vm"
    echo "📁 Asegurate de estar parado en el directorio correcto"
fi

# 5. INSTALAR MÓDULOS NODE
echo "[5/8] Instalando módulos Node.js..."
cd ~/abyss-vm
npm install --silent

# 6. COMPILAR MÓDULOS NATIVOS
echo "[6/8] Compilando módulos nativos..."
if [ -f "vm/vm_core.c" ]; then
    gcc -O3 -shared -fPIC vm/vm_core.c -o vm/vm_core.so
fi

# 7. CONFIGURAR BOT
echo "[7/8] Configurando Discord Bot..."
echo "⚠️  NO OLVIDES EDITAR bot/config.json CON TU TOKEN"

# 8. INSTALAR PM2
echo "[8/8] Instalando PM2..."
npm install -g pm2

echo ""
echo "✅ ABYSS VM v3.0 INSTALADA CORRECTAMENTE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📌 Para iniciar el bot:"
echo "   cd ~/abyss-vm"
echo "   node bot/index.js"
echo ""
echo "📌 Para mantenerlo corriendo:"
echo "   pm2 start bot/index.js --name abyss-vm"
echo "   pm2 save"
echo "   pm2 startup"
echo ""
echo "📌 Para ofuscar código:"
echo "   !vm-protect print('hola')  (en Discord)"
echo ""
echo "🔥 Ahora andá a Discord y probalo."
echo ""
