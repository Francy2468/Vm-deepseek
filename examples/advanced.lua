-- ========================================
-- ABYSS VM - EJEMPLO AVANZADO
-- ========================================

-- Función recursiva
local function factorial(n)
    if n <= 1 then
        return 1
    else
        return n * factorial(n - 1)
    end
end

print("Factorial de 5 = " .. factorial(5))

-- Tablas
local data = {
    name = "Abyss VM",
    version = "3.0.0",
    features = {"VM", "Obfuscator", "Anti-tamper", "Polymorphism"}
}

for k, v in pairs(data) do
    print(k .. ": " .. tostring(v))
end

-- Anti-tamper demo
print("Si modificás este bytecode, la VM explota.")
print("Pero como no lo modificaste, todo bien.")
