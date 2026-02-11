-- ========================================
-- ABYSS OBFUSCATOR - POLIMORFISMO
-- ========================================
-- Cada ejecución produce código DIFERENTE.
-- 1,000,000+ combinaciones posibles.
-- ========================================

local Polymorph = {}
Polymorph.__index = Polymorph

function Polymorph.new(seed)
    local self = setmetatable({}, Polymorph)
    self.seed = seed or math.random(1000, 9999)
    self.mutations = {}
    self:registerMutations()
    return self
end

-- Registrar técnicas de mutación
function Polymorph:registerMutations()
    -- Mutación 1: Renombrado ofuscado
    self.mutations[1] = function(code)
        local vars = {}
        local counter = 0
        return (code:gsub("local%s+([a-zA-Z_][a-zA-Z0-9_]*)", function(var)
            counter = counter + 1
            local new = "_" .. string.char(math.random(65,90)) .. 
                       string.char(math.random(65,90)) .. 
                       string.format("%04x", counter + self.seed)
            vars[var] = new
            return "local " .. new
        end):gsub("([^%.])%s*([a-zA-Z_][a-zA-Z0-9_]*)", function(pre, var)
            if vars[var] then
                return pre .. " " .. vars[var]
            end
            return pre .. " " .. var
        end))
    end
    
    -- Mutación 2: Reordenar líneas NO críticas
    self.mutations[2] = function(code)
        local lines = {}
        local important = {}
        
        for line in code:gmatch("[^\r\n]+") do
            if line:match("^function") or line:match("^if") or line:match("^while") or line:match("^for") then
                table.insert(important, line)
            else
                table.insert(lines, line)
            end
        end
        
        -- Barajar líneas no importantes
        for i = #lines, 2, -1 do
            local j = math.random(i)
            lines[i], lines[j] = lines[j], lines[i]
        end
        
        -- Reconstruir
        local result = table.concat(important, "\n") .. "\n"
        result = result .. table.concat(lines, "\n")
        return result
    end
    
    -- Mutación 3: Insertar comentarios aleatorios
    self.mutations[3] = function(code)
        local comments = {
            "-- Abyss VM",
            "-- Elite protection",
            "-- Do not decompile",
            "-- " .. string.char(math.random(65,90)) .. string.char(math.random(65,90)) .. string.char(math.random(65,90)),
            "-- Seed: " .. self.seed,
            "-- " .. os.date("%H:%M:%S")
        }
        local comment = comments[math.random(#comments)]
        return comment .. "\n" .. code
    end
    
    -- Mutación 4: Ofuscar espacios y tabs
    self.mutations[4] = function(code)
        return code:gsub("  ", function()
            return math.random() > 0.5 and "    " or "\t"
        end)
    end
    
    -- Mutación 5: Dividir strings largos
    self.mutations[5] = function(code)
        return code:gsub('("[^"]-")', function(str)
            if #str > 10 then
                return str .. ' .. ""'
            end
            return str
        end)
    end
end

-- Aplicar mutaciones aleatorias
function Polymorph:mutate(code, intensity)
    intensity = intensity or 3
    local result = code
    local applied = {}
    
    for i = 1, intensity do
        local m = math.random(#self.mutations)
        if not applied[m] or math.random() > 0.7 then
            result = self.mutations[m](result)
            applied[m] = true
        end
    end
    
    return result
end

return Polymorph
