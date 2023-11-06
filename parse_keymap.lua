-- keycode   2 = one              exclam

print "return {"

for l in io.lines() do
    keycode, sym1, sym2 = l:match "^keycode%s+(%d+)%s+=%s+%+?(%S+)%s+%+?(%S+)"
    if keycode and sym1 ~= "VoidSymbol" and sym1 ~= "nul" then
        print(string.format("  [%d] = { %q, %q },", keycode, sym1, sym2))
    end
end

print "}"
