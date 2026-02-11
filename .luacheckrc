-- ========================================
-- ABYSS VM - LUACHECK CONFIG
-- ========================================
-- Para los que les gusta el orden.
-- ========================================

std = "lua5.4"
ignore = {
    "211", -- Variable global
    "212", -- Variable no usada
    "213", -- Variable redefinida
    "311", -- Valor asignado no usado
}
globals = {
    "bit32",
    "AbyssVM",
    "_G"
}
