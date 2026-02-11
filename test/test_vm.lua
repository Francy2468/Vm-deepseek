-- ========================================
-- ABYSS VM - PRUEBAS UNITARIAS
-- ========================================
-- Corré esto para verificar que TODO anda.
-- ========================================

package.path = "./vm/?.lua;./obfuscator/?.lua;" .. package.path

local AbyssVM = require("core")
local Compiler = require("compiler")
local Obfuscator = require("engine")
local Polymorph = require("polymorph")
local ControlFlow = require("controlflow")
local AntiTamper = require("antitamper")

local tests = {
    passed = 0,
    failed = 0
}

function assertEqual(a, b, msg)
    if a == b then
        tests.passed = tests.passed + 1
        io.write("✅ " .. msg .. "\n")
    else
        tests.failed = tests.failed + 1
        io.write("❌ " .. msg .. " - Esperado: " .. tostring(b) .. ", Recibido: " .. tostring(a) .. "\n")
    end
end

-- Test 1: VM básica
do
    local vm = AbyssVM.new()
    vm:loadOpcodes("./vm/opcodes.lua")
    local bytecode = Compiler:compile([[
        print("test")
    ]])
    local success, err = pcall(function() vm:execute(bytecode) end)
    assertEqual(success, true, "VM ejecuta código básico")
end

-- Test 2: Compilador
do
    local compiler = Compiler.new()
    local bc = compiler:compile([[
        local a = 42
        print(a)
    ]])
    assertEqual(type(bc.code) == "table", true, "Compilador genera bytecode")
end

-- Test 3: Ofuscador
do
    local obf = Obfuscator.new()
    local result = obf:ofuscate([[print("test")]], "normal")
    assertEqual(type(result) == "string", true, "Ofuscador genera string")
end

-- Test 4: Polimorfismo
do
    local poly = Polymorph.new(1234)
    local code = [[print("hola")]]
    local r1 = poly:mutate(code, 2)
    local r2 = poly:mutate(code, 2)
    assertEqual(r1 ~= r2, true, "Polimorfismo genera código diferente")
end

-- Test 5: Control Flow
do
    local cf = ControlFlow.new()
    local code = [[
print("uno")
print("dos")
print("tres")
]]
    local flattened = cf:flatten(code)
    assertEqual(#flattened > #code, true, "Control Flow Flattening alarga el código")
end

-- Test 6: Anti-tamper
do
    local at = AntiTamper
    local cs = at.checksum({1,2,3,4,5})
    assertEqual(type(cs) == "number", true, "Anti-tamper genera checksum")
end

-- Resultados
print("\n" .. string.rep("=", 50))
print("📊 RESULTADOS DE PRUEBAS")
print(string.rep("=", 50))
print("✅ Pasadas: " .. tests.passed)
print("❌ Falladas: " .. tests.failed)
print(string.rep("=", 50))

if tests.failed == 0 then
    print("\n🔥 TODO OK - Abyss VM está lista para romper.")
else
    print("\n⚠️  Hay fallos. Revisá los tests.")
end
