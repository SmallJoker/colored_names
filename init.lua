local color_reset = "\x1b(c@#FFF)"
local c_pattern = "\x1b%(c@#?[0-9a-fA-F]+%)"
local c_namepat = "[A-z0-9-_]+"

core.register_on_receiving_chat_message(function(line)
	local myname_l = "~[CAPS£"
	if core.localplayer then
		myname_l = core.localplayer:get_name():lower()
	end

	-- Detect color to still do the name mentioning effect
	local color, line_nc = line:match("^(" .. c_pattern .. ")(.*)")
	line = line_nc or line

	local prefix                  -- Anything that comes before the player name
	local is_chat_msg = false     -- Whether to add "<", ">" around the name
	local message_separator = " " -- What to add between the player name and the message

	-- Chat message where the color starts after "<Name>" (no space)
	local name, color_end, message = line:match("^%<(" .. c_namepat .. ")%>%s*(" .. c_pattern .. ")%s*(.*)")
	if not message then
		name, message = line:match("^%<(" .. c_namepat .. ")%> (.*)")
		if name then
			name = name:gsub(c_pattern, "")
		end
		is_chat_msg = (message ~= nil)
	end

	if not message then
		-- Translated server messages, actions
		prefix, name, message = line:match("^(.*\x1bF)(".. c_namepat .. ")(\x1bE.*)")
		if message then
			message_separator = ""
		end
	end
	if not message then
		-- Server messages, actions
		prefix, name, message = line:match("^(%*+ )(" .. c_namepat .. ") (.*)")
	end
	if not message then
		-- Colored prefix
		prefix, name, message = line:match("^(.* )%<(" .. c_namepat .. ")%> (.*)")
		if color and message and #prefix > 0 then
			prefix = color .. prefix .. color_reset
			color = nil
		end
		is_chat_msg = (message ~= nil)
	end
	if not message then
		-- "Name: Message", or IRC notation (seen on some servers)
		name, message = line:match("^(" .. c_namepat .. "): (.*)")
		prefix = nil
		is_chat_msg = (message ~= nil)
	end
	if not message then
		-- Skip unknown chat line: Do not manipulate.
		return
	end

	prefix = prefix or ""
	local name_wrap = name

	-- No color yet? We need color.
	if not color then
		local color = core.sha1(name, true)
		local R = color:byte( 1) % 0x10
		local G = color:byte(10) % 0x10
		local B = color:byte(20) % 0x10
		if R + G + B < 24 then
			R = 15 - R
			G = 15 - G
			B = 15 - B
		end
		if is_chat_msg then
			name_wrap = "<" .. name .. ">"
		end
		name_wrap = core.colorize(string.format("#%X%X%X", R, G, B), name_wrap)
	elseif is_chat_msg then
		name_wrap = "<" .. name .. ">"
	end

	-- Highlight messages that mention the current player name
	if (is_chat_msg or prefix == "* ") and name:lower() ~= myname_l
			and message:lower():find(myname_l) then
		prefix = core.colorize("#F33", "[!] ") .. prefix
	end

	return core.display_chat_message(prefix .. (color or "")
		.. name_wrap .. (color_end or "") .. message_separator .. message)
end)