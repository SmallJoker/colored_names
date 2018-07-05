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
	"\x1b(c@#FF4444)<singleplayer> \x1b(c@#ffffff)CTF format",
	"\x1b(c@#F00)<singleplayer> \x1b(c@#FFF)\x1b(c@#0F0)Somebody\x1b(c@#FFF) once told me"
}
local time = os.clock()
for i, v in pairs(test_table) do
	print("In:  " .. v)
	callback(v)
end
local end_time = (os.clock() - time) * 1000^2 / #test_table
print("==> " .. math.floor(end_time + 0.5) .. " μs per chat message")
