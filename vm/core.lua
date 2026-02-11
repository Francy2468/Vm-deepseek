-- ========================================
-- ABYSS VM v3.0 - NÚCLEO
-- ========================================
-- Solo nosotros dos entendemos esto.
-- Si estás leyendo y no sos nosotros, retírate.
-- ========================================

local AbyssVM = {}
AbyssVM.__index = AbyssVM

-- Registros internos (solo la VM sabe qué son)
local REGISTERS = {
    R0 = 0, R1 = 0, R2 = 0, R3 = 0,
    R4 = 0, R5 = 0, R6 = 0, R7 = 0,
    R8 = 0, R9 = 0, R10 = 0, R11 = 0,
    R12 = 0, R13 = 0, R14 = 0, R15 = 0
}

-- Flags de estado
local FLAGS = {
    Z = 0,  -- Zero
    C = 0,  -- Carry
    O = 0,  -- Overflow
    S = 0   -- Sign
}

-- PC, SP, FP, BP
local PC = 1
local SP = 16
local FP = 0
local BP = 0

-- Tabla de opcodes
local OPCODES = {}

function AbyssVM.new()
    local self = setmetatable({}, AbyssVM)
    self.reg = REGISTERS
    self.flags = FLAGS
    self.pc = PC
    self.sp = SP
    self.fp = FP
    self.bp = BP
    self.opcodes = OPCODES
    self.memory = {}
    self.stack = {}
    return self
end

-- Cargar opcodes desde archivo externo
function AbyssVM:loadOpcodes(path)
    local f = assert(loadfile(path))
    f(self)
end

-- Compilar código Luau a bytecode
function AbyssVM:compile(source)
    -- Acá va el compilador completo (vm/compiler.lua)
    -- Por ahora, stub
    return {code = {}, entry = 1}
end

-- Ejecutar bytecode
function AbyssVM:execute(bytecode)
    self.pc = bytecode.entry or 1
    
    while self.pc > 0 and self.pc <= #bytecode.code do
        local op = bytecode.code[self.pc]
        self.pc = self.pc + 1
        
        if self.opcodes[op] then
            self.opcodes[op](self, bytecode)
        end
    end
end

-- Reset VM
function AbyssVM:reset()
    self.reg = REGISTERS
    self.flags = FLAGS
    self.pc = 1
    self.sp = 16
    self.fp = 0
    self.bp = 0
    self.memory = {}
    self.stack = {}
end

return AbyssVM
