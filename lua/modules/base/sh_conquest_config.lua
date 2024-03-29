conquest = {}
if SERVER then
	print("Conquest config loading.")
end

conquest.enable = true -- Enables or disables the base module
conquest.debug = false -- Enables or disables debug messages
conquest.baseExp = 100
conquest.maxLevel = 100
conquest.levelModifier = 1.15
--conquest.formula = expneeded = baseexp * (level ^ (levelmodifier))

conquest.grantKillExpPVP = true -- Enables or disables exp gain from kills on players
conquest.killExpPVP = 250 -- How much exp is earned on kill?
conquest.grantKillExpPVE = true -- Enables or disables exp gain from kills on entities (like zombies or combine)
conquest.killExpPVE = 25 -- How much exp is earned on kill?
conquest.headshotBonus = true -- Enables or disables headshot bonus exp
conquest.headshotExp = 2 -- Multiplier of exp earned on headshot
conquest.loseExpOnDeath = false -- Enables or disables exp loss on death
conquest.deathExpLoss = 0.10 -- How much exp is lost on death? (0.10 = 10% of current exp)

if CLIENT then
-- Client / HUD / Notifications
conquest.notify = true -- Enables or disables notifications when a player gains exp or levels up
conquest.defaultNotify = false -- Enables or disables the default garrysmod notification system (It's really boring, but less flashy)
conquest.notifyLifeTime = 1 -- How long the notification stays on screen (in seconds)
-- settings below are only used if conquest.defaultNotify is set to false
conquest.playLevelUpSound = true -- Play sound when a player levels up?
conquest.levelUpSound = "levelglassting.wav" -- Sound that plays when a player levels up
conquest.notifyBottom = true -- Enables or disables the notification system to be at the bottom of the screen
conquest.notifyYOffset = 50 -- Used in the custom notification system to adjust the Y position of the notification
conquest.smoothingAmount = 0.05 -- the lower the number, the slower the bar animation will be
conquest.hudFontSize = 20 -- Font size of the text
conquest.notifyFontSize = 20 -- Font size of the text
conquest.barWidth = 300 -- Width of the exp bar
conquest.barHeight = 20
conquest.fontSize = 20 -- Font size of the text
conquest.barX = ScrW() / 2 - conquest.barWidth / 2
conquest.barY = ScrH() - conquest.barHeight - 10
conquest.levelTextX = conquest.barX - 80
conquest.levelTextY = conquest.barY
conquest.expTextX = conquest.barX + conquest.barWidth + 10
conquest.expTextY = conquest.barY
end

-- DO NOT EDIT BELOW THIS LINE
-- MODULES WILL NOT LOAD IF YOU DO
conquest.modules = conquest.modules or {}
local _, moduleFolders = file.Find("conquest/modules/*", "LUA")
for _, folderName in pairs(moduleFolders) do
	local files, _ = file.Find("conquest/modules/" .. folderName .. "/*", "LUA")
	for _, fileName in pairs(files) do
		if string.find(fileName, "config") then
			table.insert(
				conquest.modules,
				{
					folder = folderName,
					file = fileName
				}
			)
		end
	end
end