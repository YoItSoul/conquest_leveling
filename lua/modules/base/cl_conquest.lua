local font = "Montserrat"
local fontSize = conquest.hudFontSize
surface.CreateFont(
    font,
    {
        size = fontSize,
        weight = 500,
        antialias = true
    }
)

local largeFont = "MontserratLarge"
local largeFontSize = conquest.notifyFontSize
surface.CreateFont(
    largeFont,
    {
        size = largeFontSize,
        weight = 500,
        antialias = true
    }
)

local notifications = {}
hook.Add(
    "HUDPaint",
    "HUDPaint_LevelingSystem",
    function()
        local player = LocalPlayer()
        local level = player:GetNWInt("ConquestLevel", -1)
        local exp = player:GetNWInt("ConquestEXP", -1)
        local nextLevelExp = level == 100 and 0 or (conquest.baseExp * level * conquest.levelModifier)
        local barWidth = conquest.barWidth or 300
        local barHeight = conquest.barHeight or 20
        local barX = conquest.barX or (ScrW() / 2 - barWidth / 2)
        local barY = conquest.barY or (ScrH() - barHeight - 10)
        local levelText = "Level: " .. level
        local expText = "XP: " .. exp .. "/" .. nextLevelExp
        surface.SetFont(font)
        local levelTextX = conquest.levelTextX or barX
        local levelTextY = conquest.levelTextY or barY
        local expTextX = conquest.expTextX
        local expTextY = conquest.expTextY
        draw.SimpleTextOutlined(levelText, font, levelTextX, levelTextY, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(expText, font, expTextX, expTextY, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.RoundedBox(2, barX, barY, barWidth, barHeight, Color(0, 0, 0, 200))
        draw.RoundedBox(4, barX + 10, barY + 5, barWidth - 20, barHeight / 2, Color(255, 255, 255, 200))
        local targetProgress = level == 100 and 0 or (exp / nextLevelExp)
        local currentProgress = player:GetNWFloat("ConquestProgress", 0)
        local smoothingFactor = conquest.smoothingAmount
        local smoothedProgress = Lerp(smoothingFactor, currentProgress, targetProgress)
        player:SetNWFloat("ConquestProgress", smoothedProgress)
        draw.RoundedBox(2, barX + 10, barY + 5, (barWidth - 20) * smoothedProgress, barHeight / 2, Color(0, 84, 119, 255))
        local yOffset = conquest.notifyBottom and ScrH() - conquest.notifyYOffset or conquest.notifyYOffset
        for i, notification in ipairs(notifications) do
            local alpha = math.Clamp((1 - (SysTime() - notification.start) / notification.lifetime) * 255, 0, 255)
            if alpha == 0 then
                table.remove(notifications, i)
            else
                draw.SimpleTextOutlined(notification.text, "MontserratLarge", ScrW() / 2, yOffset - (i - 1) * 30, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
            end
        end
    end
)

net.Receive(
    "NotifyPlayerGain",
    function(len)
        local amount = net.ReadInt(32)
        local type = net.ReadString()
        if conquest.defaultNotify then
            local typeText = type == "exp" and "EXP" or "level"
            notification.AddLegacy("You gained " .. amount .. " " .. typeText, NOTIFY_HINT, conquest.notifyLifeTime)
            if type == "level" then
                if conquest.playLevelUpSound then
                surface.PlaySound(conquest.levelUpSound)
                end
            end
        else
            local text = type == "exp" and "+" .. amount .. " XP" or "Level Up"
            table.insert(
                notifications,
                1,
                {
                    text = text,
                    start = SysTime(),
                    lifetime = conquest.notifyLifeTime
                }
            )
            if type == "level" then
                surface.PlaySound("path/to/level_up_sound.wav")
            end
        end
    end
)