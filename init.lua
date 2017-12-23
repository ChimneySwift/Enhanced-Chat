local modstorage = minetest.get_mod_storage()
local dColor = "#00FF00"

local chatSource = function(msg) -- Find out who was talking to us
	if string.sub(msg, 1, 1) == "<" then -- Normal messages
		local parts = string.split(msg, ">") -- Split it at the closing >
		return string.sub(parts[1], 2, string.len(parts[1])) -- Return the first part minus the first character
	elseif string.sub(msg, 1, 2) == "* " or string.sub(msg, 1, 4) == "*** " then -- /me messages or join/leave messages
		local parts = string.split(msg, " ") -- Split the message before and after the name
		return parts[2]
	end
	return false -- If nothing else returned, return false
end

minetest.register_chatcommand("setcolor", { -- Assign a colour to chat messages from a specific person
	params = "<name> <color>",
	description = "Colourize a specified player's chat messages",
	func = function(param)
		local args = string.split(param, " ") -- Split up the arguments
		local key = "player_" .. args[1] -- The setting name to set
		local color = args[2]
		if not color then color = dcolor end-- If a colour was not specified, use the default colour.
		modstorage:set_string(key, color)
		minetest.display_chat_message("Player color set sucessfully!")
	end
})

minetest.register_chatcommand("delcolor", {
	params = "<name>",
	description = "Set a specified player's chat messages to the default colour",
	func = function(param)
		local key = "player_" .. param
		modstorage:set_string(key, nil) -- Delete the key
		minetest.display_chat_message("Player color set sucessfully!")
	end
})

minetest.register_chatcommand("listcolors", {
	params = "",
	description = "List player/colour pairs",
	func = function(param)
		local list = modstorage:to_table().fields
		for key,value in pairs(list) do -- Get key and value for all pairs
			if string.sub(key, 1, 7) == "player_" then -- Might prevent future problems
				key = string.sub(key, 8, string.len(key)) -- Isolate the player name
			end
			minetest.display_chat_message(key .. ", " .. minetest.colorize(value, value))
		end
	end
})

minetest.register_on_connect(function()
	minetest.register_on_receiving_chat_messages(function(message)
		local msgPlain = minetest.strip_colors(message)
		local sender = chatSource(msgPlain)
		
		if string.sub(msgPlain, 1, 2) == "# " then -- /status message
			local list = modstorage:to_table().fields
			for key,value in pairs(list) do -- Get key and value for all pairs
				if string.sub(key, 1, 7) == "player_" then -- Might prevent future problems
					key = string.sub(key, 8, string.len(key)) -- Isolate the player name
					msgPlain = string.gsub(msgPlain, key, minetest.colorize(value, key)) -- Replace plain name with coloured version
				end
			end
			minetest.display_chat_message(msgPlain)
			return true
		elseif sender then -- Normal player messages
			local setKey = "player_" .. sender -- The setting name
			local color = modstorage:get_string(setKey) -- Get the desired colour
			if color == "" then return end -- If no colour, set to default
			message = minetest.colorize(color, msgPlain)
			minetest.display_chat_message(message)
			return true
		end
	end)
end)
