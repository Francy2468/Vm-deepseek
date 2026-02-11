-- ========================================
-- ABYSS OBFUSCATOR - MOTOR PRINCIPAL
-- ========================================
-- Transforma código Luau en código ILEGIBLE.
-- ========================================

local Obfuscator = {}
Obfuscator.__index = Obfuscator

function Obfuscator.new()
    local self = setmetatable({}, Obfuscator)
    self.seed = math.random(1000, 9999)
    self.vars = {}
    self.counter = 0
    return self
end

-- Generar nombre de variable ILEGIBLE
function Obfuscator:genVar()
    self.counter = self.counter + 1
    local patterns = {
        "_" .. string.char(math.random(65,90)) .. self.counter,
        "__" .. string.format("%04x", self.counter + self.seed),
        "v" .. string.char(math.random(97,122)) .. self.counter,
        "x" .. string.char(math.random(65,90)) .. string.char(math.random(97,122)) .. self.counter
    }
    return patterns[math.random(#patterns)]
end

-- Ofuscar strings
function Obfuscator:obfuscateString(str)
    local key = math.random(1, 255)
    local enc = {}
    for i = 1, #str do
        enc[i] = string.format("\\x%02x", bit32.bxor(string.byte(str, i), key))
    end
    return string.format('(function()local k=%d local s="%s" local t={}for i=1,#s do t[i]=string.char(bit32.bxor(string.byte(s,i),k))end return table.concat(t)end)()', 
        key, table.concat(enc))
end

-- Ofuscar números
function Obfuscator:obfuscateNumber(n)
    local methods = {
        function() return string.format("(%d+%d-%d)", n, math.random(10,100), math.random(10,100)) end,
        function() return string.format("bit32.bxor(%d,%d)", n, 0) end,
        function() return string.format("tonumber('%x',16)", n) end,
        function() return string.format("math.floor(%f)", n + 0.1) end,
        function() return string.format("(%d*%d/%d)", n, math.random(2,10), math.random(2,10)) end
    }
    return methods[math.random(#methods)]()
end

-- Renombrar variables locales
function Obfuscator:renameVars(code)
    local vars = {}
    local result = code:gsub("local%s+([a-zA-Z_][a-zA-Z0-9_]*)", function(var)
        local new = self:genVar()
        vars[var] = new
        return "local " .. new
    end)
    
    result = result:gsub("([^%.])%s*([a-zA-Z_][a-zA-Z0-9_]*)", function(pre, var)
        if vars[var] then
            return pre .. " " .. vars[var]
        end
        return pre .. " " .. var
    end)
    
    return result
end

-- Inyectar código muerto
function Obfuscator:injectDeadCode()
    local dead = {
        'local _=string.char(42,42,42)',
        'local __=math.sin(math.cos(math.tan(1)))',
        'local ___=table.pack(1,2,3,4,5)[1]',
        'local ____=bit32.bxor(1234,5678)',
        'local _____=("a"):rep(10):len()',
        'do local a=1;local b=2;local c=a+b;local d=c*a;end',
        'local ______={};for i=1,5 do ______[i]=i*i end',
        'local _______=string.reverse("deadcode")'
    }
    return dead[math.random(#dead)]
end

-- Ofuscar flujo (básico)
function Obfuscator:obfuscateControlFlow(code)
    -- Versión simplificada, expandible
    return code
end

-- Ofuscar script completo
function Obfuscator:obfuscate(code, level)
    level = level or "max"
    local result = "-- Abyss Obfuscator v3.0\n"
    result = result .. "-- Modo: " .. level:upper() .. "\n"
    result = result .. "-- Seed: " .. self.seed .. "\n\n"
    
    -- Procesar línea por línea
    for line in code:gmatch("[^\r\n]+") do
        if not line:match("^%-%-") then
            local processed = line
            
            -- Ofuscar strings
            processed = processed:gsub('"([^"]-)"', function(s)
                return self:obfuscateString(s)
            end)
            processed = processed:gsub("'([^']-)'", function(s)
                return self:obfuscateString(s)
            end)
            
            -- Ofuscar números
            processed = processed:gsub("(%d+)", function(n)
                if #n < 5 and math.random() > 0.6 then
                    return self:obfuscateNumber(tonumber(n))
                else
                    return n
                end
            end)
            
            -- Inyectar código muerto
            if math.random() > 0.7 then
                processed = self:injectDeadCode() .. "\n" .. processed
            end
            
            -- Renombrar variables (solo si es nivel máximo)
            if level == "max" then
                processed = self:renameVars(processed)
            end
            
            result = result .. processed .. "\n"
        end
    end
    
    return result
end

return Obfuscator
