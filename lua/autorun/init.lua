local _, folders = file.Find("modules/*", "LUA")
for _, folder in pairs(folders) do
    local path = "modules/" .. folder .. "/"
    local serverFiles = file.Find(path .. "sv_*.lua", "LUA")
    local sharedFiles = file.Find(path .. "sh_*.lua", "LUA")
    local clientFiles = file.Find(path .. "cl_*.lua", "LUA")
    if SERVER then
        for _, svFile in pairs(serverFiles) do
            include(path .. svFile)
        end

        for _, shFile in pairs(sharedFiles) do
            include(path .. shFile)
            AddCSLuaFile(path .. shFile)
        end

        for _, clFile in pairs(clientFiles) do
            AddCSLuaFile(path .. clFile)
        end
    else
        for _, shFile in pairs(sharedFiles) do
            include(path .. shFile)
        end

        for _, clFile in pairs(clientFiles) do
            include(path .. clFile)
        end
    end
end