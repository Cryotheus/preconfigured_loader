--Cryotheum#4096

--change the following six local variables how ever you like

--[[
	how to use the config
	we use bits here to determine if the function is run, up to 16 bits are supported here
	the first 3 digits are used to tell the loader what to do with the file
		0b000 = 0d0 = do nothing
		0b001 = 0d1 = include on client
		0b010 = 0d2 = include on server
		0b100 = 0d4 = AddCSLuaFile

	anything above 7 (0b111) is the priority, lower values = higher priority
	priority 1 and below should be reserved for required and deathly important files, or files that are just AddCSLuaFile'd

	the following is just an example and does not point to any scripts
	note that this is all local to the lua folder
]]

local config = {
	important_client_script = 4,	--0 100
	important_server_script = 2,	--0 010
	
	some_folder = {
		some_client_script = 13,	--1 101
		some_server_script = 10,	--1 010
		some_shared_script = 15		--1 111
	},
	
	some_other_folder = {
		some_other_client_script = 21,	--10 101
		some_other_server_script = 13	--10 010
	}
}

--what do we say we are when we load up?
local branding = "Cryotheum's Preconfigured Loader"

--maximum amount of folders it may go down in the config tree
local max_depth = 4

--reload command
local reload_command = "loader_reload"

--should the file self-include for command reloads instead of loading with the source's path as a prefix
--instead of true, you can put a string for the include function to use
local self_include_reload = true

--colors
local color_generic = Color(255, 255, 255)
local color_significant = Color(0, 255, 0)

--end of configurable variables



----local variables, don't change
	local fl_bit_band = bit.band
	local fl_bit_rshift = bit.rshift
	local highest_priority = 0
	local load_order = {}
	local load_functions = {
		[1] = function(path) if CLIENT then include(path) end end,
		[2] = function(path) if SERVER then include(path) end end,
		[4] = function(path) if SERVER then AddCSLuaFile(path) end end
	}
	
	local load_function_shift = table.Count(load_functions)

--local functions
local function construct_order(config_table, depth, path)
	local tabs = " ]" .. string.rep("    ", depth)
	
	for key, value in pairs(config_table) do
		if istable(value) then
			MsgC(color_generic, tabs .. key .. ":\n")
			
			if depth < max_depth then construct_order(value, depth + 1, path .. key .. "/")
			else MsgC(color_significant, tabs .. "    !!! MAX DEPTH !!!\n") end
		else
			MsgC(color_generic, tabs .. key .. " = 0d" .. value .. "\n")
			
			local priority = fl_bit_rshift(value, load_function_shift)
			local script_path = path .. key
			
			if priority > highest_priority then highest_priority = priority end
			if load_order[priority] then load_order[priority][script_path] = fl_bit_band(value, 7)
			else load_order[priority] = {[script_path] = fl_bit_band(value, 7)} end
		end
	end
end

local function load_by_order(prefix_directory)
	for priority = 0, highest_priority do
		local script_paths = load_order[priority]
		
		if script_paths then
			if priority == 0 then MsgC(color_generic, " Loading scripts at level 0...\n")
			else MsgC(color_generic, "\n Loading scripts at level " .. priority .. "...\n") end
			
			for script_path, bits in pairs(script_paths) do
				local script_path_extension = script_path .. ".lua"
				
				MsgC(color_generic, " ]    0d" .. bits .. "	" .. script_path_extension .. "\n")
				
				for bit_flag, func in pairs(load_functions) do if fl_bit_band(bits, bit_flag) > 0 then func(prefix_directory .. script_path_extension) end end
			end
		else MsgC(color_significant, "Skipping level " .. priority .. " as it contains no scripts.\n") end
	end
end

local function load_scripts(command_reload)
	MsgC(color_generic, "\n\\\\\\ ", color_significant, branding, color_generic, " ///\n\n", color_significant, "Constructing load order...\n")
	construct_order(config, 1, "")
	MsgC(color_significant, "\nConstructed load order.\n\nLoading scripts by load order...\n")
	
	if command_reload then
		local full_path = debug.getinfo(1, "S").short_src
		
		MsgC(color_generic, "\n!!! ", color_significant, "PRECONFIGURED LOADER NOTE", color_generic, " !!!\nAs the load was requested using command, the source file for the loader be used as a prefix for the following includes. You may experience issues with scripts loaded using this command that do not persist when the file is loaded by an include. If that happens, try making the file include itself instead of executing the load_scripts function in the reload command. You can do this by setting self_include_reload to true (attempts to automatically grab the file's path) or the full path of the loader.\n||| ", color_significant, "PRECONFIGURED LOADER NOTE", color_generic, " |||\n\n")
		load_by_order(string.GetPathFromFilename(string.sub(full_path, select(2, string.find(full_path, "lua/", 1, true)) + 1)))
	else load_by_order("") end
	
	MsgC(color_significant, "\nLoaded scripts.\n\n", color_generic, "/// ", color_significant, "All scripts loaded.", color_generic, " \\\\\\\n\n")
end

--concommands
concommand.Add(reload_command, function(ply)
	if CLIENT or not IsValid(ply) or ply:IsSuperAdmin() then
		if self_include_reload then
			if isstring(self_include_reload) then include(self_include_reload)
			else
				local full_path = debug.getinfo(1, "S").short_src
				
				include(string.sub(full_path, select(2, string.find(full_path, "lua/", 1, true)) + 1))
			end
		else load_scripts(true) end
	end
end, nil, "Reload all " .. branding .. " scripts.")

--post function setup
load_scripts(false)