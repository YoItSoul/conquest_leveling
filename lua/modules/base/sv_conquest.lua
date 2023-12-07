local function InitializeConquest(ply)
    local basedir = "conquest_leveling/"
    local playerdir = basedir .. "players/"
    local playeruniquefile = ply:SteamID64()
    local playerPath = playerdir .. playeruniquefile
    local files = {
        exp = {
            path = playerPath .. "/exp.txt",
            default = "0"
        },
        level = {
            path = playerPath .. "/level.txt",
            default = "1"
        }
    }

    if not file.Exists(basedir, "DATA") then
        if conquest.debug then
            print("Conquest leveling: Base directory not found, creating...")
        end

        file.CreateDir(basedir)
        file.CreateDir(playerdir)
        file.CreateDir(playerPath)
    elseif not file.Exists(playerdir, "DATA") then
        if conquest.debug then
            print("Conquest leveling: Player directory not found, creating...")
        end

        file.CreateDir(playerdir)
        file.CreateDir(playerPath)
    elseif not file.Exists(playerPath, "DATA") then
        if conquest.debug then
            print("Conquest leveling: Player directory not found, creating...")
        end

        file.CreateDir(playerPath)
    end

    for key, fileInfo in pairs(files) do
        if not file.Exists(fileInfo.path, "DATA") then
            if conquest.debug then
                print("Conquest leveling: Player conquest files were not found, creating...")
            end

            file.Write(fileInfo.path, fileInfo.default)
        end

        local value = file.Read(fileInfo.path, "DATA")
        if value then
            ply:SetNWInt("Conquest" .. key, value)
        else
            if conquest.debug then
                print("Conquest leveling: Something went wrong with the networking. Report this error to the developer.")
            end
        end
    end
end

local function SaveConquest(ply)
    local basedir = "conquest_leveling/"
    local playerdir = basedir .. "players/"
    local playeruniquefile = ply:SteamID64()
    local playerPath = playerdir .. playeruniquefile
    local files = {
        exp = ply:GetNWInt("ConquestExp"),
        level = ply:GetNWInt("ConquestLevel"),
    }

    for key, value in pairs(files) do
        file.Write(playerPath .. "/" .. key .. ".txt", value)
    end

    if conquest.debug then
        print("Conquest leveling: Saving player data...")
    end
end

hook.Add("PlayerInitialSpawn", "ConquestCheckPlayerFile", InitializeConquest)
timer.Create(
    "ConquestSaveTimer",
    900,
    0,
    function()
        for _, v in pairs(player.GetAll()) do
            SaveConquest(v)
        end
    end
)

hook.Add("PlayerDisconnected", "ConquestSavePlayerFile", SaveConquest)
function NotifyPlayerGain(ply, amount, type)
    util.AddNetworkString("NotifyPlayerGain")
    net.Start("NotifyPlayerGain")
    net.WriteInt(amount, 32)
    net.WriteString(type)
    net.Send(ply)
end

local function SetAttribute(ply, attribute, amount)
    if conquest.debug then
        print("Conquest leveling: Setting " .. ply:Nick() .. "'s " .. attribute .. " to " .. amount .. "...")
    end

    ply:SetNWInt("Conquest" .. attribute, amount)
end

local function AddLevel(ply, amount)
    local oldlevel = ply:GetNWInt("ConquestLevel")
    ply:SetNWInt("ConquestLevel", math.min(oldlevel + amount, conquest.maxLevel))
    NotifyPlayerGain(ply, amount, "level")
end

local function AddExp(ply, amount)
    local oldexp = ply:GetNWInt("ConquestExp")
    local newexp = oldexp + amount
    local level = ply:GetNWInt("ConquestLevel")
    local maxexp = conquest.baseExp * (level * conquest.levelModifier)
    local overkill = newexp - maxexp
    if tonumber(level) >= conquest.maxLevel then
        newexp = 0
    end

    if overkill >= 1 then
        AddLevel(ply, 1)
        SetAttribute(ply, "Exp", 0)
        AddExp(ply, overkill)
        --NotifyPlayerGain(ply, overkill, "exp")
    else
        ply:SetNWInt("ConquestExp", newexp)
        NotifyPlayerGain(ply, amount, "exp")
        SaveConquest(ply)
    end
end

local function findPlayerByNick(nick)
    for _, v in ipairs(player.GetAll()) do
        if v:Nick() == nick then return v end
    end

    return nil
end

concommand.Add(
    "conquest_setlevel",
    function(ply, cmd, args)
        if ply:IsAdmin() then
            local targetNick = args[1]
            local amount = tonumber(args[2])
            local target = findPlayerByNick(targetNick)
            if target and IsValid(target) then
                SetAttribute(target, "Level", amount)
                SetAttribute(target, "Exp", 0)
            else
                if conquest.debug then
                    print("Conquest leveling: No player found with the nickname " .. targetNick)
                end
            end
        else
            print("Conquest leveling: You do not have permission to use this command.")
        end
    end
)

concommand.Add(
    "conquest_addexp",
    function(ply, cmd, args)
        if ply:IsAdmin() then
            local targetNick = args[1]
            local amount = tonumber(args[2])
            local target = findPlayerByNick(targetNick)
            if target and IsValid(target) then
                AddExp(target, amount)
            else
                if conquest.debug then
                    print("Conquest leveling: No player found with the nickname " .. targetNick)
                end
            end
        else
            print("Conquest leveling: You do not have permission to use this command.")
        end
    end
)

-- Store whether the last hit was a headshot
hook.Add(
    "ScalePlayerDamage",
    "ConquestHeadshotCheck",
    function(ply, hitgroup, dmginfo)
        ply.LastHitWasHeadshot = hitgroup == HITGROUP_HEAD
    end
)

hook.Add(
    "PlayerDeath",
    "ConquestKillExpPVP",
    function(victim, inflictor, attacker)
        if conquest.grantKillExpPVP and attacker ~= victim and attacker:IsPlayer() then
            local exp = conquest.killExpPVP
            -- Apply headshot bonus
            if conquest.headshotBonus and victim.LastHitWasHeadshot then
                exp = exp * conquest.headshotExp
            end

            AddExp(attacker, exp)
        end

        if conquest.loseExpOnDeath then
            local oldexp = victim:GetNWInt("ConquestExp")
            local calculateloss = math.Round(oldexp * conquest.deathExpLoss)
            local newexp = oldexp - calculateloss
            SetAttribute(victim, "Exp", newexp)
        end
    end
)

hook.Add(
    "OnNPCKilled",
    "ConquestKillExpPVE",
    function(victim, attacker, inflictor)
        if conquest.grantKillExpPVE and attacker:IsPlayer() then
            AddExp(attacker, conquest.killExpPVE)
        end
    end
)