# 🔥 ABYSS VM - MANUAL OFICIAL

**Solo para los que entienden. Si preguntás, no entendés.**

---

## 🧠 FILOSOFÍA

Abyss VM no es un ofuscador. Es una **máquina virtual personalizada** que ejecuta **bytecode propio**, no Lua, no Luau, no nada que exista.

Nadie puede decompilar lo que no existe.

---

## ⚙️ ARQUITECTURA

---

## 🛡️ ANTI-TAMPER (7 CAPAS)

### CAPA 1: Integridad de bytecode
Cada bloque de bytecode tiene un checksum. Si cambia UN byte, explota.

### CAPA 2: Autodestrucción
Si detecta modificación, destruye el entorno global y entra en bucle infinito.

### CAPA 3: Verificación multihilo
5 hilos verificando constantemente la integridad. Si uno falla, todos fallan.

### CAPA 4: Anti-debug
Mata la tabla `debug`. Hookea `pcall`. Si detecta debugger, miente.

### CAPA 5: Checksums dinámicos
Los checksums se recalculan en tiempo de ejecución. No son estáticos.

### CAPA 6: Señuelos
Funciones falsas de "reparación" que en realidad son trampas.

### CAPA 7: Ejecución ofuscada
Las instrucciones se ejecutan con despacho ofuscado. Imposible de seguir.

---

## 📦 BYTECODE (SOLO NOSOTROS SABEMOS)

| Opcode | Nombre | Descripción |
|--------|--------|-------------|
| 0x01 | LOAD | Carga constante en registro |
| 0x02 | MOVE | Mueve valor entre registros |
| 0x03 | ADD | Suma |
| 0x04 | SUB | Resta |
| ... | ... | ... |
| 0x17 | PRINT | Imprime registro |
| 0x18 | HALT | Detiene VM |

**Los opcodes completos están en `vm/opcodes.lua`. Pero vos ya lo sabés.**

---

## 🤖 BOT DE DISCORD

### Instalación

```bash
git clone https://github.com/TU_USER/abyss-vm
cd abyss-vm
npm install
# Editá bot/config.json con tu token
node bot/index.js
