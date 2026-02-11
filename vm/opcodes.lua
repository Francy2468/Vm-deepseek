-- ========================================
-- ABYSS VM - OPCODES
-- ========================================
-- 256 instrucciones posibles.
-- Solo nosotros conocemos el mapeo real.
-- ========================================

return function(vm)
    local op = vm.opcodes
    
    -- NOP
    op[0x00] = function() end
    
    -- LOAD: Cargar constante en registro
    op[0x01] = function(self, bc)
        local val = bc.code[self.pc]; self.pc = self.pc + 1
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[reg] = val
    end
    
    -- MOVE: Mover valor entre registros
    op[0x02] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local src = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = self.reg[src]
    end
    
    -- ADD: Suma
    op[0x03] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = self.reg[a] + self.reg[b]
    end
    
    -- SUB: Resta
    op[0x04] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = self.reg[a] - self.reg[b]
    end
    
    -- MUL: Multiplicación
    op[0x05] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = self.reg[a] * self.reg[b]
    end
    
    -- DIV: División
    op[0x06] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        if self.reg[b] ~= 0 then
            self.reg[dst] = self.reg[a] / self.reg[b]
        end
    end
    
    -- MOD: Módulo
    op[0x07] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        if self.reg[b] ~= 0 then
            self.reg[dst] = self.reg[a] % self.reg[b]
        end
    end
    
    -- AND: Bitwise AND
    op[0x08] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.band(self.reg[a], self.reg[b])
    end
    
    -- OR: Bitwise OR
    op[0x09] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.bor(self.reg[a], self.reg[b])
    end
    
    -- XOR: Bitwise XOR
    op[0x0A] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.bxor(self.reg[a], self.reg[b])
    end
    
    -- SHL: Shift left
    op[0x0B] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.lshift(self.reg[a], self.reg[b])
    end
    
    -- SHR: Shift right
    op[0x0C] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.rshift(self.reg[a], self.reg[b])
    end
    
    -- CMP: Comparar
    op[0x0D] = function(self, bc)
        local a = bc.code[self.pc]; self.pc = self.pc + 1
        local b = bc.code[self.pc]; self.pc = self.pc + 1
        local va = self.reg[a] or 0
        local vb = self.reg[b] or 0
        self.flags.Z = va == vb and 1 or 0
        self.flags.C = va < vb and 1 or 0
        self.flags.S = va > vb and 1 or 0
    end
    
    -- JMP: Salto incondicional
    op[0x0E] = function(self, bc)
        local addr = bc.code[self.pc]; self.pc = self.pc + 1
        self.pc = addr
    end
    
    -- JE: Salto si igual
    op[0x0F] = function(self, bc)
        local addr = bc.code[self.pc]; self.pc = self.pc + 1
        if self.flags.Z == 1 then
            self.pc = addr
        end
    end
    
    -- JNE: Salto si no igual
    op[0x10] = function(self, bc)
        local addr = bc.code[self.pc]; self.pc = self.pc + 1
        if self.flags.Z == 0 then
            self.pc = addr
        end
    end
    
    -- JL: Salto si menor
    op[0x11] = function(self, bc)
        local addr = bc.code[self.pc]; self.pc = self.pc + 1
        if self.flags.C == 1 then
            self.pc = addr
        end
    end
    
    -- JG: Salto si mayor
    op[0x12] = function(self, bc)
        local addr = bc.code[self.pc]; self.pc = self.pc + 1
        if self.flags.S == 1 then
            self.pc = addr
        end
    end
    
    -- PUSH: Apilar registro
    op[0x13] = function(self, bc)
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        self.stack[self.sp] = self.reg[reg]
        self.sp = self.sp + 1
    end
    
    -- POP: Desapilar a registro
    op[0x14] = function(self, bc)
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        self.sp = self.sp - 1
        self.reg[reg] = self.stack[self.sp]
    end
    
    -- CALL: Llamar función
    op[0x15] = function(self, bc)
        local addr = bc.code[self.pc]; self.pc = self.pc + 1
        self.stack[self.sp] = self.pc + 1
        self.sp = self.sp + 1
        self.pc = addr
    end
    
    -- RET: Retornar
    op[0x16] = function(self)
        self.sp = self.sp - 1
        self.pc = self.stack[self.sp]
    end
    
    -- PRINT: Imprimir
    op[0x17] = function(self, bc)
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        print(self.reg[reg] or tostring(self.reg[reg]))
    end
    
    -- HALT: Detener ejecución
    op[0x18] = function(self)
        self.pc = -1
    end
    
    -- ENCRYPT: Encriptar registro
    op[0x19] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local src = bc.code[self.pc]; self.pc = self.pc + 1
        local key = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.bxor(self.reg[src], self.reg[key])
    end
    
    -- DECRYPT: Desencriptar registro
    op[0x1A] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local src = bc.code[self.pc]; self.pc = self.pc + 1
        local key = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = bit32.bxor(self.reg[src], self.reg[key])
    end
    
    -- LOADK: Cargar constante de tabla
    op[0x1B] = function(self, bc)
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        local constIdx = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[reg] = bc.constants[constIdx]
    end
    
    -- LOADSTR: Cargar string
    op[0x1C] = function(self, bc)
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        local strIdx = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[reg] = bc.strings[strIdx]
    end
    
    -- NEWTABLE: Crear tabla
    op[0x1D] = function(self, bc)
        local reg = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[reg] = {}
    end
    
    -- SETTABLE: Setear campo de tabla
    op[0x1E] = function(self, bc)
        local tbl = bc.code[self.pc]; self.pc = self.pc + 1
        local key = bc.code[self.pc]; self.pc = self.pc + 1
        local val = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[tbl][self.reg[key]] = self.reg[val]
    end
    
    -- GETTABLE: Obtener campo de tabla
    op[0x1F] = function(self, bc)
        local dst = bc.code[self.pc]; self.pc = self.pc + 1
        local tbl = bc.code[self.pc]; self.pc = self.pc + 1
        local key = bc.code[self.pc]; self.pc = self.pc + 1
        self.reg[dst] = self.reg[tbl][self.reg[key]]
    end
end
