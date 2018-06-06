if not core.register_on_receiving_chat_message then
	core.register_on_receiving_chat_message = core.register_on_receiving_chat_messages
end

local color_reset = "\x1b(c@#FFF)"
local c_pattern = "\x1b%(c@#[0-9a-fA-F]+%)"

core.register_on_receiving_chat_message(function(line)
	local myname_l = "~[CAPS£"
	if core.localplayer then
		myname_l = core.localplayer:get_name():lower()
	end

	-- Detect color to still do the name mentioning effect
	local color, line_nc = line:match("^(" .. c_pattern .. ")(.*)")
	line = line_nc or line

	local prefix
	local chat_line = false
	local name, message = line:match("^%<(%S+)%> (.*)")
	if message then
		-- To keep the <Name> notation
		chat_line = true
	else
		-- Server messages, actions
		prefix, name, message = line:match("^(%*+ )(%S+) (.*)")
	end
	if not message then
		-- Colored prefix
		prefix, name, message = line:match("^(.* )%<(%S+)%> (.*)")
		if color and message and prefix:len() > 0 then
			prefix = color .. prefix .. color_reset
			color = nil
		end
		chat_line = true
	end
	if not message then
		-- Skip unknown chat line
		return
	end

	prefix = prefix or ""
	local name_wrap = name

	-- No color yet? We need color.
	if not color then
		local nick_color = 0
		for i = 1, #name do
			local c = name:sub(i, i):byte()
			nick_color = nick_color + c * 2^(i - 1)
		end
		local B = nick_color % 0x10
		local G = math.floor((nick_color % 0x100 ) / 0x10)
		local R = math.floor((nick_color % 0x1000) / 0x100)
		if R + G + B < 24 then
			R = 15 - R
			G = 15 - G
			B = 15 - B
		end
		if chat_line then
			name_wrap = "<" .. name .. ">"
		end
		name_wrap = minetest.colorize(string.format("#%X%X%X", R, G, B), name_wrap)
	elseif chat_line then
		name_wrap = "<" .. name .. ">"
	end

	if (chat_line or prefix == "* ") and name:lower() ~= myname_l
			and message:lower():find(myname_l) then
		prefix = minetest.colorize("#F33", "[!] ") .. prefix
	end

	return minetest.display_chat_message(prefix .. (color or "")
		.. name_wrap .. " " .. minetest.strip_colors(message))
end)