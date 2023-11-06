-- An experiment to create Linux console (and maybe X) keymaps via Lua.

-- These are optimized for a Chromebook - they only include 10 Function
-- keys, include a mapping for the Search (magnifying glass) key, and
-- ignore all the missing keypad keys.

-- What follows is the project/keymap that inspired me to do this. I found
-- it in the kbd/share/keymaps/i386/qwerty directory on my NixOS machine.
-- It's on your machine somewhere as well; it's also on GitHub:
--   https://github.com/legionus/kbd/data/keymaps/i386/qwerty/hypermap.m4

-- I've removed the Hyper key definitions as well as the dead- and compose-
-- key definitions. I've essentially "converted" his m4 macros to Lua, and
-- I used many of his key definitions verbatim.

--[[
#
# hypermap.map 1994/11/11
# Michael Shields <shields@tembel.org>
#
# A keymap redesigned for sanity.
#

#
# This keymap is a ground-up reimplementation of the keyboard map,
# intended to be consistent and rational.  It uses an m4 metalanguage to
# declare the key mappings.  Usage is `m4 hypermap.map | loadkeys'.
#
# The modifier flags used are `shift' (1), `control' (4), and `alt' (8).
# Left and right modifiers are not distinguished.
#
# In general, Meta is always distinguished, and M-S-KEY is distinct from
# M-KEY.  This is good news for Emacs users.  C-S-KEY is consistently
# folded into C-KEY.
#
# Shift is more loosely interpreted than the other modifiers; usually if
# S-KEY has no special meaning, the action will be the same as KEY.
# However, if M-KEY or H-KEY is undefined, nothing happens.
#
# Function keys work as marked, unless with Alt, in which case they
# switch to the console with the same number.  Shift adds 12. Control is
# ignored, for consistency with X.
]]

-- The m4 macros are pretty readable. Even so, I'm never using m4 again!
-- In case you're curious where I started from, here are his macros:

--[[
dnl General usage of these macros is MACRO(KEYCODE, UNSHIFTED, SHIFTED).

dnl We first undefine `shift', which only causes problems.
undefine(`shift')

define(`SIMPLE', `keycode $1 = $2 $2')

define(`KEY',
`			keycode $1 = $2 VoidSymbol
shift			keycode $1 = $3
		alt	keycode $1 = Meta_$2
shift		alt	keycode $1 = Meta_$3')

dnl This macro adds Control variations to a key.
define(`CONTROL',
`	control		keycode $1 = $2
shift	control		keycode $1 = $2
	control	alt	keycode $1 = Meta_$2
shift	control	alt	keycode $1 = Meta_$2')

dnl Add Hyper variations to a key.
define(`HYPER', ifdef(`hyper',
`			hyper	keycode $1 = $2
shift			hyper	keycode $1 = $2'))
define(`CONTROLHYPER', ifdef(`hyper',
`	control		hyper	keycode $1 = $2
shift	control		hyper	keycode $1 = $2'))
define(`METAHYPER', ifdef(`hyper',
`		alt	hyper	keycode $1 = $2
shift		alt	hyper	keycode $1 = $2'))
define(`CONTROLMETAHYPER', ifdef(`hyper', dnl Ludicrous.
`	control	alt	hyper	keycode $1 = $2
shift	control	alt	hyper	keycode $1 = $2'))

dnl Special case for letters.  Best to be explicit.
define(`LETTER',
`			keycode $1 = `+'$2 VoidSymbol
shift			keycode $1 = `+'translit($2, `a-z', `A-Z')
		alt	keycode $1 = `Meta_'$2
shift		alt	keycode $1 = `Meta_'translit($2, `a-z', `A-Z')
CONTROL($1, Control_$2)')

dnl For function keys.  Call here is FUNCTION(KEYCODE, FKEYNUM).
define(`BANKSIZE', 12)
define(`FUNCTION',
`			keycode $1 = `F'$2 VoidSymbol
shift			keycode $1 = `F'eval($2 + BANKSIZE)
	hyper		keycode $1 = `F'eval($2 + BANKSIZE * 2)
shift	hyper		keycode $1 = `F'eval($2 + BANKSIZE * 3)
		alt	keycode $1 = `Console_'$2
shift		alt	keycode $1 = `Console_'eval($2 + BANKSIZE)
	hyper	alt	keycode $1 = `Console_'eval($2 + BANKSIZE * 2)
shift	hyper	alt	keycode $1 = `Console_'eval($2 + BANKSIZE * 3)')

dnl For the keypad digits.  KPDIGIT(KEYCODE, DIGIT).
define(`KPDIGIT',
`			keycode $1 = KP_$2 VoidSymbol
shift			keycode $1 = KP_$2
		alt	keycode $1 = Ascii_$2
shift		alt	keycode $1 = Ascii_$2
METAHYPER($1, Ascii_$2)')
]]

-- I'd like to be able to generate both Qwerty and Dvorak maps, but instead
-- of doing everything *twice*, let's just create a Qwerty map (that's what
-- Michael's code that I cribbed does, after all) and then apply to it only
-- the *changes* between the Qwerty and Dvorak layouts.

-- To do that, we need to know what those changes are! If you're curious
-- about the process that I used, run
--
--     make keycode_xlate.txt
--
-- and look at it. It should look identical to the map below. The idea is
-- simple: load the generic (Qwerty) map; dump it as a text file; load the
-- existing Dvorak map; dump it as a text file, and then carefully consider
-- the differences. The code to do that is all here, in parse_keymap.lua
-- and qwerty_to_dvorak.lua.

-- If we're generating a Dvorak map, let's map Qwerty keycodes to Dvorak
-- keycodes. We could also map keysyms to keysyms, but that doesn't work as
-- well: letters have different semantics than other keys, and some Qwerty
-- letters map to Dvorak keysyms and vice versa.

-- The only disadvantage to mapping keycodes to keycodes is that the
-- keycode *order* will be messed up for Dvorak keymaps. The Qwerty keymap
-- is defined in the order of the keyboard layout; the sequence of Qwerty
-- keycodes is left-to-right, top-to-bottom.

-- 33 keys are different!
qwerty_to_dvorak = {
  [12] = 40,  -- minus underscore
  [13] = 27,  -- equal plus
  [16] = 45,  -- q Q
  [17] = 51,  -- w W
  [18] = 32,  -- e E
  [19] = 24,  -- r R
  [20] = 37,  -- t T
  [21] = 20,  -- y Y
  [22] = 33,  -- u U
  [23] = 34,  -- i I
  [24] = 31,  -- o O
  [25] = 19,  -- p P
  [26] = 12,  -- bracketleft braceleft
  [27] = 13,  -- bracketright braceright
  [31] = 39,  -- s S
  [32] = 35,  -- d D
  [33] = 21,  -- f F
  [34] = 22,  -- g G
  [35] = 36,  -- h H
  [36] = 46,  -- j J
  [37] = 47,  -- k K
  [38] = 25,  -- l L
  [39] = 44,  -- semicolon colon
  [40] = 16,  -- apostrophe quotedbl
  [44] = 53,  -- z Z
  [45] = 48,  -- x X
  [46] = 23,  -- c C
  [47] = 52,  -- v V
  [48] = 49,  -- b B
  [49] = 38,  -- n N
  [51] = 17,  -- comma less
  [52] = 18,  -- period greater
  [53] = 26,  -- slash question
}

if arg[1] == "dvorak" then
    xlat = function(keycode) return qwerty_to_dvorak[keycode] or keycode end
else
    xlat = function(keycode) return keycode end
end

function fmt(format, ...)
    print(sttring.format(format, ...))
end

function ignore(...) end

function simple(keycode, s)
    fmt("			keycode %d = %s", keycode, s)
end

-- NOTE: c should already have Control_ prefix
function control(keycode, c)
    local x_keycode = xlat(keycode)
    fmt("	control		keycode %d = %s", x_keycode, c)
    fmt("shift	control		keycode %d = %s", x_keycode, c)
    fmt("	control	alt	keycode %d = Meta_%s", x_keycode, c)
    fmt("shift	control	alt	keycode %d = Meta_%s", x_keycode, c)
end

-- XXX should this be called alt()?
-- NOTE: m and shifted_m should already have Meta_ prefix, if desired
function meta(keycode, m, shifted_m)
    local x_keycode = xlat(keycode)
    fmt("		alt	keycode %d = %s", x_keycode, m)
    fmt("shift		alt	keycode %d = %s", x_keycode, shifted_m)
end

-- This has *one* purpose. Can you guess?
function meta_control(keycode, sym)
    fmt("	control	alt	keycode %d = %s", keycode, sym)
end

function key(keycode, k, shifted_k)
    local x_keycode = xlat(keycode)
    fmt("			keycode %d = %s", x_keycode, k)
    fmt("shift			keycode %d = %s", x_keycode, shifted_k)
    meta(keycode, "Meta_"..k, "Meta_"..shifted_k)
end

-- This is for keysyms that we want to act "letter-like" wrt CapsLock.
-- Don't automagically generate the Control versions. For non-letters,
-- Control is usually the *shifted* version; for letters, it's the
-- non-shifted one!
function letter_like(keycode, l, shifted_l)
    local x_keycode = xlat(keycode)
    fmt("			keycode %d = +%s", x_keycode, l)
    fmt("shift			keycode %d = +%s", x_keycode, shifted_l)
    meta(keycode, "Meta_"..l, "Meta_"..shifted_l)
end

function letter(keycode, l)
    letter_like(keycode, l, l:upper())
    control(keycode, "Control_"..l)
end

function func_key(keycode, n)
    fmt("			keycode %d = F%d", keycode, n)
    fmt("shift			keycode %d = F%d", keycode, n + 12)
    fmt("		alt	keycode %d = Console_%d", keycode, n)
    fmt("shift		alt	keycode %d = Console_%d", keycode, n + 12)
end

function fn_string(n, s)
    fmt("			string F%d = %q", n, s)
end

function modifier(keycode, m, comment)
    simple(keycode, m)
end

function prelude()
    local layout = (arg[1] == "dvorak") and "Dvorak" or "Qwerty"
    fmt([[
# This file is a Linux console keymap, generated by
#    https://github.com/nimblemachines/chromebook-keymap-generator
#
# This is a basic %s layout.
#
# It is "optimized" for a Chromebook:
#   * it leaves out all the keys that don't appear on a Chromebook keyboard;
#   * the "Search" key (keycode 125) is a Control key;
#   * the left Control key (keycode 29) is Caps_Lock;
#   * eventually it might have "interesting" strings attached to the
#     Function keys - eg, for display brightness or volume control.

keymaps 0,1,4,5,8,9,12,13
strings as usual
]], layout)
end

-- For compat with hyperkey.map and to suggest "macros", let's rename our
-- functions with the Caps_Lock key on:
SIMPLE = simple
KEY = key
LETTER = letter
LETTERLIKE = letter_like
CONTROL = control
META = meta
METACONTROL = meta_control
FUNCTION = func_key
STRING = fn_string
MODIFIER = modifier

-- We are ignoring these:
HYPER = ignore
METAHYPER = ignore


-- One trick I would like to use, since there are very many symbolic names
-- used in keymaps, and I don't want to type them as strings (with the
-- double quotes), my idea is to put an __index into the _ENV metatable to
-- turn any undefined identifier into a string! Let's try that first.

-- For some reason "p" is a function value. A shortcut name for print()?
_ENV.p = nil

-- After this line, Lua is going to behave strangely! So make sure to write
-- all code *before* setting the _ENV metatable. What follows after this
-- should be only the key definitions.

setmetatable(_ENV, { __index = function(t, key) return rawget(t, key) or key end } )

-- Let's generate a keymap!

prelude()

-- Row 1
KEY(1, Escape, Escape)

FUNCTION(59, 1)
FUNCTION(60, 2)
FUNCTION(61, 3)
FUNCTION(62, 4)
FUNCTION(63, 5)
FUNCTION(64, 6)
FUNCTION(65, 7)
FUNCTION(66, 8)
FUNCTION(67, 9)
FUNCTION(68, 10)

-- Row 2
KEY(41, grave, asciitilde)
    HYPER(41, dead_grave)
KEY(2, one, exclam)
    HYPER(2, exclamdown)
    METAHYPER(2, Hex_1)
KEY(3, two, at)
    CONTROL(3, nul)
    METAHYPER(3, Hex_2)
KEY(4, three, numbersign)
    HYPER(4, pound)
    METAHYPER(4, Hex_3)
KEY(5, four, dollar)
    HYPER(5, currency)
    METAHYPER(5, Hex_4)
KEY(6, five, percent)
    HYPER(6, division)
    METAHYPER(6, Hex_5)
KEY(7, six, asciicircum)
    CONTROL(7, Control_asciicircum)
    HYPER(7, dead_circumflex)
    METAHYPER(7, Hex_6)
KEY(8, seven, ampersand)
    METAHYPER(8, Hex_7)
KEY(9, eight, asterisk)
    METAHYPER(9, Hex_8)
KEY(10, nine, parenleft)
    METAHYPER(10, Hex_9)
KEY(11, zero, parenright)
    HYPER(11, degree)
    METAHYPER(11, Hex_0)
LETTERLIKE(12, minus, underscore)
    CONTROL(12, Control_underscore)
    HYPER(12, hyphen)
KEY(13, equal, plus)
    HYPER(13, macron)
KEY(14, Delete, Delete)
    CONTROL(14, BackSpace)
    METACONTROL(14, Boot)

-- Row 3
KEY(15, Tab, Tab)
    HYPER(15, Caps_Lock)
LETTER(16, q)
    HYPER(16, onequarter)
LETTER(17, w)
    HYPER(17, onehalf)
LETTER(18, e)
    HYPER(18, threequarters)
    METAHYPER(18, Hex_E)
LETTER(19, r)
    HYPER(19, registered)
LETTER(20, t)
    HYPER(20, dead_tilde)
LETTER(21, y)
    HYPER(21, yen)
LETTER(22, u)
    HYPER(22, mu)
LETTER(23, i)
LETTER(24, o)
    HYPER(24, masculine)
LETTER(25, p)
    HYPER(25, 182)
KEY(26, bracketleft, braceleft)
    CONTROL(26, Escape)
    HYPER(26, plusminus)
KEY(27, bracketright, braceright)
    CONTROL(27, Control_bracketright)
    HYPER(27, notsign)
KEY(43, backslash, bar)
    CONTROL(43, Control_backslash)
    HYPER(43, brokenbar)

-- Row 4
MODIFIER(125, Control)

LETTER(30, a)
    HYPER(30, ordfeminine)
    METAHYPER(30, Hex_A)
LETTER(31, s)
    HYPER(31, section)
LETTER(32, d)
    HYPER(32, dead_diaeresis)
    METAHYPER(32, Hex_D)
LETTER(33, f)
    METAHYPER(33, Hex_F)
LETTER(34, g)
LETTER(35, h)
    HYPER(35, cent)
LETTER(36, j)
    HYPER(36, onesuperior)
LETTER(37, k)
    HYPER(37, twosuperior)
LETTER(38, l)
    HYPER(38, threesuperior)
KEY(39, semicolon, colon)
    HYPER(39, periodcentered)
KEY(40, apostrophe, quotedbl)
    HYPER(40, dead_acute)
KEY(28, Return, Return)

-- Row 5
MODIFIER(42, Shift)

LETTER(44, z)
LETTER(45, x)
    HYPER(45, multiplication)
LETTER(46, c)
    HYPER(46, copyright)
    METAHYPER(46, Hex_C)
LETTER(47, v)
LETTER(48, b)
    METAHYPER(48, Hex_B)
LETTER(49, n)
LETTER(50, m)
KEY(51, comma, less)
    HYPER(51, guillemotleft)
KEY(52, period, greater)
    HYPER(52, guillemotright)
KEY(53, slash, question)
    HYPER(53, questiondown)

MODIFIER(54, Shift)

-- Row 6

MODIFIER(29, Caps_Lock)
MODIFIER(56, Alt)

KEY(57, space, space)
    CONTROL(57, nul)
    HYPER(57, nobreakspace)

MODIFIER(100, Alt)
MODIFIER(97, Control)

SIMPLE(105, Left)
    META(105, Decr_Console, Decr_Console)

SIMPLE(103, Up)
SIMPLE(108, Down)

SIMPLE(106, Right)
    META(106, Incr_Console, Incr_Console)
