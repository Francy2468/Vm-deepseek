-- ========================================
-- ABYSS OBFUSCATOR - CONTROL FLOW FLATTENING
-- ========================================
-- Convierte código lineal en un dispatcher
-- con estados. Ilegible para decompiladores.
-- ========================================

local ControlFlow = {}
ControlFlow.__index = ControlFlow

function ControlFlow.new()
    local self = setmetatable({}, ControlFlow)
    self.blockId = 0
    self.blocks = {}
    return self
end

-- Dividir código en bloques básicos
function ControlFlow:splitBlocks(code)
    local blocks = {}
    local currentBlock = {}
    local blockId = 1
    
    for line in code:gmatch("[^\r\n]+") do
        -- Detectar puntos de decisión
        if line:match("^if%s+") or 
           line:match("^while%s+") or 
           line:match("^for%s+") or 
           line:match("^function%s+") or
           line:match("^repeat") or
           line:match("^until") then
           
            -- Guardar bloque anterior
            if #currentBlock > 0 then
                blocks[blockId] = table.concat(currentBlock, "\n")
                blockId = blockId + 1
                currentBlock = {}
            end
        end
        table.insert(currentBlock, line)
    end
    
    -- Último bloque
    if #currentBlock > 0 then
        blocks[blockId] = table.concat(currentBlock, "\n")
    end
    
    return blocks
end

-- Generar dispatcher polimórfico
function ControlFlow:generateDispatcher(blocks)
    local dispatcherType = math.random(1, 4)
    
    if dispatcherType == 1 then
        -- Dispatcher tipo 1: Tabla de funciones
        local disp = "local __dispatch = {\n"
        for i = 1, #blocks do
            disp = disp .. string.format("  [%d] = function()\n    %s\n  end,\n", i, blocks[i]:gsub("\n", "\n    "))
        end
        disp = disp .. "}\nlocal __state = 1\nwhile __state do\n  __state = __dispatch[__state]()\nend\n"
        return disp
        
    elseif dispatcherType == 2 then
        -- Dispatcher tipo 2: Switch ofuscado
        local keys = {}
        for i = 1, #blocks do
            keys[i] = math.random(10000, 99999)
        end
        
        local disp = "local __keys = {"
        for i = 1, #keys do
            disp = disp .. string.format("[%d]=%d,", i, keys[i])
        end
        disp = disp .. "}\nlocal __state = __keys[1]\nwhile __state do\n"
        
        for i = 1, #blocks do
            disp = disp .. string.format("  if __state == %d then\n    %s\n    __state = __keys[%d]\n  end\n", 
                keys[i], blocks[i]:gsub("\n", "\n    "), i + 1)
        end
        disp = disp .. "end\n"
        return disp
        
    elseif dispatcherType == 3 then
        -- Dispatcher tipo 3: Corrutinas
        local disp = "local __co = coroutine.create(function()\n"
        for i = 1, #blocks do
            disp = disp .. blocks[i] .. "\ncoroutine.yield(" .. i .. ")\n"
        end
        disp = disp .. "end)\nlocal __state = 1\nwhile coroutine.status(__co) ~= 'dead' do\n  __state = coroutine.resume(__co)\nend\n"
        return disp
        
    else
        -- Dispatcher tipo 4: Metatables ofuscadas
        local disp = "local __dispatch = setmetatable({}, {__index = function(t,k)\n"
        for i = 1, #blocks do
            disp = disp .. string.format("  if k == %d then return function()\n    %s\n  end end\n", i, blocks[i]:gsub("\n", "\n    "))
        end
        disp = disp .. "end})\nlocal __state = 1\nwhile __state do\n  __state = __dispatch[__state]()\nend\n"
        return disp
    end
end

-- Aplicar control flow flattening
function ControlFlow:flatten(code)
    local blocks = self:splitBlocks(code)
    if #blocks <= 1 then
        return code -- No hay suficiente código para aplanar
    end
    
    return self:generateDispatcher(blocks)
end

return ControlFlow
