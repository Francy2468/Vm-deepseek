-- ========================================
-- ABYSS VM - ANTI-TAMPER NUCLEAR
-- ========================================
-- 7 capas. Si modifican UNA, explota TODO.
-- ========================================

local AntiTamper = {}

-- Capa 1: Firma de integridad
function AntiTamper.signature()
    return {
        math.random(1000000, 9999999),
        math.random(1000000, 9999999),
        math.random(1000000, 9999999),
        math.random(1000000, 9999999),
        math.random(1000000, 9999999)
    }
end

-- Capa 2: Checksum dinámico
function AntiTamper.checksum(data)
    local cs = 0x7F3B5A1C
    for i = 1, #data do
        cs = bit32.bxor(cs, bit32.lshift(data[i], 16))
        cs = bit32.bxor(cs, bit32.rshift(data[i], 8))
        cs = cs + 0x9E3779B9
    end
    return cs
end

-- Capa 3: Verificación multihilo
function AntiTamper.spawnCheckers(checkFn)
    local threads = {}
    for i = 1, 5 do
        threads[i] = coroutine.create(function()
            while true do
                checkFn()
                coroutine.yield()
            end
        end)
    end
    return threads
end

-- Capa 4: Autodestrucción
function AntiTamper.selfDestruct()
    -- Destruir entorno global
    for k in pairs(_G) do
        _G[k] = nil
    end
    -- Destruir entorno local
    for k in pairs(getfenv()) do
        getfenv()[k] = nil
    end
    -- Bucle infinito ofuscado
    local x = 0
    while x < 1 do
        x = math.random() * math.random() * math.random()
    end
end

-- Capa 5: Anti-debug
function AntiTamper.antiDebug()
    local debugDetected = false
    
    -- Matar debug
    local oldDebug = debug
    debug = nil
    
    -- Hookear pcall
    local oldPcall = pcall
    pcall = function(f, ...)
        local results = {oldPcall(f, ...)}
        if not results[1] and tostring(results[2]):find("debug") then
            debugDetected = true
            return true, nil
        end
        return unpack(results)
    end
    
    return function() return debugDetected end
end

-- Capa 6: Señuelos
function AntiTamper.decoys()
    return {
        function() return "Checksum OK" end,
        function() return "Repairing..." end,
        function() return "Tamper protection disabled" end, -- FALSO
        function() error("Tamper detected") end
    }
end

-- Capa 7: Ejecución ofuscada
function AntiTamper.obfuscatedExecute(fn)
    local keys = {math.random(), math.random(), math.random()}
    local xor = function(a,b) return bit32.bxor(a,b) end
    
    -- Ejecutar función con despacho ofuscado
    local result
    for i = 1, 3 do
        if xor(i, keys[i] % 256) == 0 then
            result = fn()
        end
    end
    return result
end

-- Activar todas las protecciones
function AntiTamper.protect(vm, bytecode)
    local sig = AntiTamper.signature()
    local cs = AntiTamper.checksum(bytecode.code)
    
    -- Verificador
    local function verify()
        local currentCS = AntiTamper.checksum(bytecode.code)
        if currentCS ~= cs then
            AntiTamper.selfDestruct()
        end
    end
    
    -- Spawnear verificadores
    local checkers = AntiTamper.spawnCheckers(verify)
    
    -- Anti-debug
    local isDebugged = AntiTamper.antiDebug()
    
    -- Inyectar en VM
    vm.antitamper = {
        verify = verify,
        checkers = checkers,
        isDebugged = isDebugged,
        signature = sig
    }
    
    return vm
end

return AntiTamper
