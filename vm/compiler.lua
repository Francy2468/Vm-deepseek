-- ========================================
-- ABYSS VM - COMPILADOR LUAU
-- ========================================
-- Convierte código Luau a bytecode Abyss.
-- Soporta: variables, operadores, prints, funciones.
-- ========================================

local Compiler = {}
Compiler.__index = Compiler

function Compiler.new()
    local self = setmetatable({}, Compiler)
    self.bytecode = {}
    self.constants = {}
    self.strings = {}
    self.functions = {}
    self.labels = {}
    self.regCounter = 0
    return self
end

-- Generar nuevo registro temporal
function Compiler:newReg()
    self.regCounter = self.regCounter + 1
    return self.regCounter
end

-- Agregar constante
function Compiler:addConstant(val)
    table.insert(self.constants, val)
    return #self.constants
end

-- Agregar string
function Compiler:addString(str)
    table.insert(self.strings, str)
    return #self.strings
end

-- Emitir instrucción
function Compiler:emit(op, ...)
    table.insert(self.bytecode, op)
    for _, arg in ipairs({...}) do
        table.insert(self.bytecode, arg)
    end
end

-- Compilar expresión
function Compiler:compileExpression(expr)
    if type(expr) == "string" then
        -- String literal
        local strIdx = self:addString(expr)
        local reg = self:newReg()
        self:emit(0x1C, reg, strIdx) -- LOADSTR
        return reg
    elseif type(expr) == "number" then
        -- Number literal
        local constIdx = self:addConstant(expr)
        local reg = self:newReg()
        self:emit(0x1B, reg, constIdx) -- LOADK
        return reg
    elseif type(expr) == "table" and expr.type == "binary" then
        -- Operación binaria
        local left = self:compileExpression(expr.left)
        local right = self:compileExpression(expr.right)
        local dst = self:newReg()
        
        if expr.op == "+" then
            self:emit(0x03, dst, left, right) -- ADD
        elseif expr.op == "-" then
            self:emit(0x04, dst, left, right) -- SUB
        elseif expr.op == "*" then
            self:emit(0x05, dst, left, right) -- MUL
        elseif expr.op == "/" then
            self:emit(0x06, dst, left, right) -- DIV
        elseif expr.op == "%" then
            self:emit(0x07, dst, left, right) -- MOD
        elseif expr.op == ".." then
            self:emit(0x1F, dst, left, right) -- CONCAT (simplificado)
        end
        return dst
    end
    return 0
end

-- Compilar statement
function Compiler:compileStatement(stmt)
    if stmt.type == "print" then
        local reg = self:compileExpression(stmt.value)
        self:emit(0x17, reg) -- PRINT
    elseif stmt.type == "assign" then
        -- Asignación a variable local
        local val = self:compileExpression(stmt.value)
        self:emit(0x01, stmt.reg, val) -- LOAD
    elseif stmt.type == "function" then
        -- Declaración de función
        local startAddr = #self.bytecode + 1
        for _, s in ipairs(stmt.body) do
            self:compileStatement(s)
        end
        self:emit(0x16) -- RET
        table.insert(self.functions, {
            name = stmt.name,
            start = startAddr,
            end = #self.bytecode
        })
    elseif stmt.type == "call" then
        -- Llamada a función
        self:emit(0x15, stmt.addr) -- CALL
    end
end

-- Compilar programa completo
function Compiler:compile(source)
    self.bytecode = {}
    self.constants = {}
    self.strings = {}
    self.regCounter = 0
    
    -- Parseo simplificado
    local lines = {}
    for line in source:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    for _, line in ipairs(lines) do
        if line:match("^print%s*%(") then
            local str = line:match('"([^"]-)"') or line:match("'([^']-)'") or ""
            self:compileStatement({
                type = "print",
                value = str
            })
        elseif line:match("^local%s+([a-zA-Z_][a-zA-Z0-9_]*)%s*=%s*(%d+)") then
            local var, num = line:match("^local%s+([a-zA-Z_][a-zA-Z0-9_]*)%s*=%s*(%d+)")
            -- Simplificado: asumimos registro fijo
            self:compileStatement({
                type = "assign",
                reg = 1,
                value = tonumber(num)
            })
        end
    end
    
    -- Calcular checksum
    local checksum = 0
    for i = 1, #self.bytecode do
        checksum = checksum + self.bytecode[i]
    end
    
    return {
        code = self.bytecode,
        constants = self.constants,
        strings = self.strings,
        functions = self.functions,
        entry = 1,
        checksum = checksum
    }
end

return Compiler
