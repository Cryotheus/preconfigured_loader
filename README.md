# Preconfigured Loader
Loader for GMod addons that is easy to configure and supports subfolders.

This was originally designed for my gamemode [Minge Defense](https://github.com/Cryotheus/minge_defense) but after copying into a fourth project I decided to give it its own repository so I can consolidate the best features into a single file.

A guide on how to use this is in the [loader.lua](https://github.com/Cryotheus/preconfigured_loader/blob/main/lua/preconfigured_loader/loader.lua) script.  
Information on implementing extensions are available in files in the [extensions](https://github.com/Cryotheus/preconfigured_loader/tree/main/lua/preconfigured_loader/extensions) directory. Please note that the returned table is merged with the config table in [loader.lua](https://github.com/Cryotheus/preconfigured_loader/blob/main/lua/preconfigured_loader/loader.lua#L25L40).
