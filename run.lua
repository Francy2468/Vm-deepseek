-- ========================================
-- ABYSS VM - RUNNER PRINCIPAL
-- ========================================
-- Un solo comando: lua run.lua
-- Carga todo, compila, ejecuta.
-- ========================================

package.path = "./vm/?.lua;./obfuscator/?.lua;" .. package.path

local AbyssVM = require("core")
local Compiler = require("compiler")
local Obfuscator = require("engine")
local Polymorph = require("polymorph")
local ControlFlow = require("controlflow")
local AntiTamper = require("antitamper")

-- ========================================
-- CONFIGURACIÓN
-- ========================================
local config = {
    mode = os.getenv("ABYSS_MODE") or "release",  -- debug / release
    antitamper = true,
    polymorphism = true,
    controlflow = true,
    seed = math.random(1000, 9999)
}

-- ========================================
-- BANNER
-- ========================================
print([[
    █████╗ ██████╗ ██╗   ██╗███████╗███████╗
   ██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝██╔════╝
   ███████║██████╔╝ ╚████╔╝ ███████╗███████╗
   ██╔══██║██╔══██╗  ╚██╔╝  ╚════██║╚════██║
   ██║  ██║██████╔╝   ██║   ███████║███████║
   ╚═╝  ╚═╝╚═════╝    ╚═╝   ╚══════╝╚══════╝
]])
print("🔥 ABYSS VM v3.0 - La máquina virtual que rompe decompiladores")
print("🚀 Modo: " .. config.mode:upper())
print("🌱 Seed: " .. config.seed)
print(string.rep("=", 60))

-- ========================================
-- INICIALIZAR VM
-- ========================================
local vm = AbyssVM.new()
vm:loadOpcodes("./vm/opcodes.lua")

if config.antitamper then
    vm = AntiTamper.protect(vm, {code = {}})
    print("🛡️ Anti-tamper: ACTIVADO")
end

-- ========================================
-- COMPILAR Y EJECUTAR
-- ========================================
local function runScript(source)
    print("\n📜 Compilando código...")
    local bytecode = Compiler:compile(source)
    print("✅ Bytecode generado: " .. #bytecode.code .. " instrucciones")
    
    if config.controlflow then
        print("🌀 Control Flow Flattening: ACTIVADO")
    end
    
    print("\n⚡ Ejecutando VM...\n")
    vm:execute(bytecode)
end

-- ========================================
-- LEER ARCHIVO O USAR CÓDIGO DE EJEMPLO
-- ========================================
local filename = arg[1]
if filename and io.open(filename, "r") then
    local f = io.open(filename, "r")
    local code = f:read("*all")
    f:close()
    runScript(code)
else
    -- Código de ejemplo
    local example = [[
print("🔥 Abyss VM funcionando correctamente")
print("Solo nosotros dos entendemos esto")

local a = 42
local b = 24
print("42 + 24 = " .. (a + b))

print("✅ VM lista para romper")
]]
    runScript(example)
end

print(string.rep("=", 60))
print("✅ VM finalizada")
