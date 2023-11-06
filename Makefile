all: qwerty.map dvorak.map

qwerty.map: keymap.lua
	lua keymap.lua > $@

dvorak.map: keymap.lua
	lua keymap.lua dvorak > $@

# This is how I figured out the keycode mapping from Qwerty to Dvorak.
keycode_xlate.txt: parse_keymap.lua qwerty_to_dvorak.lua default_full.map dvorak_full.map
	lua parse_keymap.lua < default_full.map > qwerty.lua
	lua parse_keymap.lua < dvorak_full.map > dvorak.lua
	lua qwerty_to_dvorak.lua > $@

qwerty.lua: parse_keymap.lua default_full.map
	lua parse_keymap.lua < default_full.map > $@

dvorak.lua: parse_keymap.lua dvorak_full.map
	lua parse_keymap.lua < dvorak_full.map > $@

# Because it loads keymaps, this target must be run with write permissions to
# /dev/console. But because it's loading and printing out two pretty much
# unchanging keymaps that come with Linux, it only needs to be run once. ;-)
default_full.map dvorak_full.map:
	dumpkeys -f > saved_full.map
	loadkeys --default
	dumpkeys -f > default_full.map
	loadkeys dvorak
	dumpkeys -f > dvorak_full.map
	loadkeys ./saved_full.map
	rm -f saved_full.map

PHONY: clean
clean:
	rm -f qwerty.map dvorak.map qwerty.lua dvorak.lua keycode_xlate.txt
