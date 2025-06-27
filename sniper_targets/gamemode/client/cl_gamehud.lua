local HUD_COLOR_BLACK = Color(0,0,0, 150)
local HUD_COLOR_BACKGROUND = Color(255, 255, 255)

hook.Add("HUDPaint", "TeamScoreDisplay", function()
	if GetGlobal2Bool("round_over") then return end
	local score = team.GetScore(TEAM_UNASSIGNED)

	draw.RoundedBox(8, 20, 20, 160, 40, HUD_COLOR_BLACK)
	draw.SimpleText("Score: " .. score, "DermaLarge", 30, 25, HUD_COLOR_BACKGROUND, TEXT_ALIGN_LEFT)
end)

hook.Add("HUDPaint", "TimerDisplay", function()
	if GetGlobal2Bool("round_over") then return end
	local yPos = 70
	draw.RoundedBox(8, 20, yPos, 200, 40, HUD_COLOR_BLACK)
	draw.SimpleText("Time Left: " .. GetGlobal2Int("server_time"), "DermaLarge", 30, 75, HUD_COLOR_BACKGROUND, TEXT_ALIGN_LEFT)
end)

hook.Add("HUDPaint", "UnsupportedMap", function()
    if game.GetMap() == "gm_construct" then return end

    local boxW, boxH = 160, 40
    local x = (ScrW() - boxW) / 2
    local y = (ScrH() - boxH) / 2

    draw.RoundedBox(8, x, y, boxW, boxH, HUD_COLOR_BLACK)
    draw.SimpleText("Unsupported Map! Only gm_construct is supported", "DermaLarge", x + 10, y + 5, HUD_COLOR_BACKGROUND, TEXT_ALIGN_CENTER)
end)

local defaultHud = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "hideDefaultHUD", function(name)
	if defaultHud[name] then
		return false
	end
end)