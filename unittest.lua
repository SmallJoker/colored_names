core = {}
minetest = core

local callback

function core.colorize(x, text)
	return "\x1b(c@" .. x .. ")" .. text .. "\x1b(c@#ffffff)"
end
function core.get_color_escape_sequence(x)
	return "\x1b(c@" .. x .. ")"
end
function core.display_chat_message(msg)
	print("Out: " .. msg)
end
function core.register_on_receiving_chat_message(func)
	callback = func
end
function core.strip_colors(msg)
	return (msg:gsub("\x1b%([bc]@[^)]+%)", ""))
end

dofile("init.lua")

local test_table = {
	"*** singleplayer joined the game",
	"* singleplayer needs action like a true survivor",
	"<singleplayer> buzz baz",
	"\x1b(c@#abcdef)[Admin] <singleplayer> foo bar\x1b(c@#ffffff)",
	"\x1b(c@#FF0000)<singleplayer>\x1b(c@#ffffff) not modified",
	"\x1b(c@#FF4444)<singleplayer> \x1b(c@#ffffff)CTF format"
}

for i, v in pairs(test_table) do
	print("In:  " .. v)
	callback(v)
end
