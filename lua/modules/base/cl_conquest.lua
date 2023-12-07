-- Create original font
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

-- Create larger font
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

-- HUDPaint hook for leveling system and experience gain notification
local notifications = {}
hook.Add(
    "HUDPaint",
    "HUDPaint_LevelingSystem",
    function()
        local player = LocalPlayer()
        local level = player:GetNWInt("ConquestLevel", -1)
        local exp = player:GetNWInt("ConquestEXP", -1)
        local nextLevelExp = level == 100 and 0 or (conquest.baseExp * level * conquest.levelModifier)
        -- Calculate bar dimensions and position
        local barWidth = conquest.barWidth or 300
        local barHeight = conquest.barHeight or 20
        local barX = conquest.barX or (ScrW() / 2 - barWidth / 2)
        local barY = conquest.barY or (ScrH() - barHeight - 10)
        -- Calculate text dimensions and position
        local levelText = "Level: " .. level
        local expText = "XP: " .. exp .. "/" .. nextLevelExp
        surface.SetFont(font)
        local levelTextX = conquest.levelTextX or barX
        local levelTextY = conquest.levelTextY or barY
        local expTextX = conquest.expTextX
        local expTextY = conquest.expTextY
        -- Draw text
        draw.SimpleTextOutlined(levelText, font, levelTextX, levelTextY, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(expText, font, expTextX, expTextY, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        -- Draw bar
        draw.RoundedBox(2, barX, barY, barWidth, barHeight, Color(0, 0, 0, 200))
        draw.RoundedBox(4, barX + 10, barY + 5, barWidth - 20, barHeight / 2, Color(255, 255, 255, 200))
        -- Calculate target progress
        local targetProgress = level == 100 and 0 or (exp / nextLevelExp)
        -- Get current progress
        local currentProgress = player:GetNWFloat("ConquestProgress", 0)
        -- Define smoothing factor
        local smoothingFactor = conquest.smoothingAmount
        -- Smoothly interpolate between current progress and target progress
        local smoothedProgress = Lerp(smoothingFactor, currentProgress, targetProgress)
        -- Set smoothed progress
        player:SetNWFloat("ConquestProgress", smoothedProgress)
        -- Draw progress
        draw.RoundedBox(2, barX + 10, barY + 5, (barWidth - 20) * smoothedProgress, barHeight / 2, Color(0, 84, 119, 255))
        -- Experience gain and level up notifications
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

-- Receive notification of player gain
net.Receive(
    "NotifyPlayerGain",
    function(len)
        local amount = net.ReadInt(32)
        local type = net.ReadString()
        if conquest.defaultNotify then
            local typeText = type == "exp" and "EXP" or "level"
            notification.AddLegacy("You gained " .. amount .. " " .. typeText, NOTIFY_HINT, conquest.notifyLifeTime)
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
        end
    end
)