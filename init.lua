if not core.register_on_receiving_chat_message then
	core.register_on_receiving_chat_message = core.register_on_receiving_chat_messages
end

core.register_on_receiving_chat_message(function(line)
	local myname_l = "~[CAPS£"
	if minetest.localplayer then
		myname_l = minetest.localplayer:get_name():lower()
	end

	local prefix
	local chat_line = false
	local name, message = line:match("^%<(%S+)%> (.*)")
	if message then
		-- To keep the <Name> notation
		chat_line = true
	else
		prefix, name, message = line:match("^(%*+ )(%S+) (.*)")
	end
	if not message then
		name, message = "", (line:match("^%s*(.*)") or line)
	end
	prefix = prefix or ""

	if name ~= "" then
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
			name = "<" .. name .. ">"
		end
		name = minetest.colorize(string.format("#%X%X%X", R, G, B), name)
	end

	if (chat_line or prefix == "* ")
			and message:lower():find(myname_l) then
		prefix = minetest.colorize("#F33", "[!] " .. prefix)
	end

	return minetest.display_chat_message(prefix .. name .. " " .. message)
end)