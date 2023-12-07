--include("addons/conquest_leveling/modules/base/your_file.lua")

if SERVER then
    include("modules/base/conquest_config.lua")
    include("modules/base/sv_conquest.lua")
    AddCSLuaFile("modules/base/conquest_config.lua")
    AddCSLuaFile("modules/base/cl_conquest.lua")
else
    include("modules/base/conquest_config.lua")
    include("modules/base/cl_conquest.lua")
end

