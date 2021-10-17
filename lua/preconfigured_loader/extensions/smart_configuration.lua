--treat this as a lua script, and always make sure you return an empty table at minimum
if game.GetMap() == "gm_bigcity" and engine.ActiveGamemode() == "sandbox" and not game.SinglePlayer() then
	--true to AddCSLuaFile this file
	return {smart_extension_loaded_script = 23}, true
end

return {}