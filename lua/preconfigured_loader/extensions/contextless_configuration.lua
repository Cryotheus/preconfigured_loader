--this script will always be run on SERVER
--treat this as a lua script, and always make sure you return an empty table at minimum
return {
	extension_loaded_folder = {
		extension_loaded_client_script = 5,
		extension_loaded_server_script = 2
	},
	
	extension_loaded_script = 37
}, true --put false or omit the second return entirely if you dont want this script AddCSLuaFile'd