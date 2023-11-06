qw = dofile "qwerty.lua"
dv = dofile "dvorak.lua"

-- Find the Dvorak keycode that matches a sym and return it, or 0 if not
-- found.
function dv_keycode_from_sym(sym)
    for keycode,syms in pairs(dv) do
        if syms[1] == sym then return keycode end
    end
    return 0
end

-- Print a table to convert from keycodes to keycodes
for keycode,syms in pairs(qw) do
    local dv_syms = dv[keycode]
    if syms[1] ~= dv_syms[1] then
        local dv_keycode = dv_keycode_from_sym(syms[1])
        if dv_keycode ~= 0 then
            print(string.format("  [%d] = %d,  -- %s %s",
                keycode, dv_keycode, syms[1], syms[2]))
        end
    end
end
