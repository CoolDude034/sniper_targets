SetGlobal2String("current_objective", "ELIMINATE THE TARGET")
SetGlobal2Int("server_time", 350) --150
SetGlobal2Bool("round_over", false)
SetGlobal2Bool("civs_alerted", false)
--SetGlobal2Vector("lobby_cam_pos", Vector(157.3, -875.9, 1190.6))

function GM:PlayerCanPickupWeapon(ply, wep)
    if wep:IsFlagSet(FL_DISSOLVING) then
        return false
    end
	
	if ( wep:GetClass() == "weapon_hitmansniper" ) then -- REPLACE weapon_crossbow with your own SWEP!
		return true
	end
	
    return false
end

-- noclip is disabled, and doesn't work due to the no movement thing
function GM:PlayerNoClip(ply)
	--if (game.SinglePlayer()) then return true end
	return false
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	-- Prevent friendly fire
	if (IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply) then return false end
	
	return true
end

function GM:GetFallDamage(ply, speed)
	return math.max( 0, math.ceil( 0.2418 * speed - 141.75 ) )
end

function GM:Initialize()
	if not game.SinglePlayer() then
		-- Tune network settings
		RunConsoleCommand("cl_cmdrate", "66")
		RunConsoleCommand("cl_updaterate", "66")
		RunConsoleCommand("rate", "196608")
		RunConsoleCommand("cl_interp", "1")
		RunConsoleCommand("cl_interp_npcs", "0.25")
		RunConsoleCommand("cl_interp_ratio", "1")
		-- Tune game stuff
		RunConsoleCommand("sv_rollangle", "0")
		RunConsoleCommand("gmod_maxammo", "0")
		RunConsoleCommand("gmod_sneak_attack", "1")
		RunConsoleCommand("gmod_suit", "0")
		
		RunConsoleCommand("sv_allowcslua", "0")
		RunConsoleCommand("sv_playerpickupallowed", "0")
		
		RunConsoleCommand("maxplayers", "2") -- set max players to 2
	end
end

function GM:InitPostEntity()
	if game.GetMap() ~= "gm_construct" then return end
	for _,v in ipairs(ents.FindByClass("info_player_start")) do v:Remove() end
	local sp = ents.Create("info_player_start")
	sp:SetPos(Vector(737.7, -1706.1, 1136))
	sp:SetAngles(Angle(0,180,0))
	sp:Spawn()
	
	local sp = ents.Create("info_player_start")
	sp:SetPos(Vector(736.9, -1452, 1136))
	sp:SetAngles(Angle(0,180,0))
	sp:Spawn()
end

hook.Add("PlayerInitialSpawn", "onPlayerInitialSpawn", function(ply)
	--ply:SetTeam(1)
	--print(ply:Nick() .. " joined team " .. ply:Team())
end)

hook.Add("PlayerSpawn", "onPlayerSpawn", function(ply)
	ply:SetSuppressPickupNotices(true)
	ply:Give( "weapon_hitmansniper" )
	ply:GiveAmmo(255, "XBowBolt", true)
	
	if game.SinglePlayer() then
		ply:SetModel("models/player.mdl")
	else
		-- TODO: DO CUSTOM PLAYER MODELS HERE
		--ply:SetModel("models/player/gman_high.mdl")
		ply:SetModel( GetConVar("player_model_override"):GetString() )
	end
end)

local function spawnEntities()
	if game.GetMap() ~= "gm_construct" then return end
	local path = ents.Create("path_corner")
	path:SetName("civ_path")
	path:SetPos(Vector(-973.1, -1815.3, -144))
	path:Spawn()
	
	local npc = ents.Create("npc_civilian")
	npc:SetPos(Vector(-961.2, -1162.9, -144))
	npc:SetKeyValue("scripted_point", "civ_path")
	npc:Spawn()
	
	local npc = ents.Create("npc_civilian")
	npc:SetPos(Vector(-1079.3, -981, -144))
	npc:SetKeyValue("animation", "Lying_Down")
	npc:Spawn()
	
	local npc = ents.Create("npc_civilian")
	npc:SetPos(Vector(-1639.4, -2948.2, 1024))
	npc:SetKeyValue("model", "models/breen.mdl")
	npc:SetKeyValue("is_target", "1")
	npc:Spawn()
	
	local watcher = ents.Create("npc_enemy")
	watcher:SetPos(Vector(-1630.6, -2605, 1280))
	watcher:SetKeyValue("spawn_unalerted", "1")
	watcher:SetKeyValue("stationary", "1")
	watcher:SetKeyValue("is_target", "1")
	watcher:Spawn()
	
	local npc = ents.Create("npc_civilian")
	npc:SetPos(Vector(-1862.5, -1691.3, -144))
	npc:Spawn()
	
	local npc = ents.Create("npc_civilian")
	npc:SetPos(Vector(-1208.5, -1987.2, 256))
	npc:Spawn()
	
	-- Arrest sequence
	local arrest_npc = ents.Create("npc_civilian")
	arrest_npc:SetPos(Vector(-1677.1, -2201.6, 256))
	arrest_npc:SetKeyValue("model", "models/Humans/Group01/male_07.mdl")
	arrest_npc:SetKeyValue("animation", "arrestidle")
	arrest_npc:Spawn()
	
	local arrest_cop = ents.Create("npc_enemy")
	arrest_cop:SetPos(Vector(-1676.2, -2175.3, 256))
	arrest_cop:SetAngles(Angle(0,180,0))
	arrest_cop:SetKeyValue("animation", "arrestpreidle")
	arrest_cop:SetKeyValue("model", "models/police.mdl")
	arrest_cop:SetKeyValue("additionalequipment", "weapon_pistol")
	arrest_cop:SetKeyValue("stationary", "1")
	arrest_cop:SetKeyValue("spawn_unalerted", "1")
	arrest_cop:Spawn()
	
	local balcony_civ = ents.Create("npc_civilian")
	balcony_civ:SetPos(Vector(-1628.1, -2618.7, 768))
	balcony_civ:SetKeyValue("animation", "d1_town05_Leon_Lean_Table_Posture_Idle")
	balcony_civ:SetKeyValue("model", "models/Humans/Group01/male_08.mdl")
	balcony_civ:Spawn()
end

hook.Add("InitPostEntity", "addNPCs", function()
	spawnEntities()
end)

local function resetRound()
	if game.SinglePlayer() then
		RunConsoleCommand("reload")
	else
		team.SetScore(TEAM_UNASSIGNED, 0)
		
		for _, ply in ipairs(player.GetAll()) do
			ply:StripWeapons()
			ply:Spawn()
		end
		
		game.CleanUpMap()
		spawnEntities()
		
		for _, ply in ipairs(player.GetAll()) do
			plr:ScreenFade(2, color_black, 2, 5)
		end
	end
end

local tickDelay = 0
local isGameEnding = false
hook.Add("Think", "timerThink", function()
	if CurTime() < tickDelay then return end
	if (GetGlobal2Int("server_time") <= 0) then
		if not isGameEnding then
			isGameEnding = true
			
			PrintMessage(HUD_PRINTTALK, "[Server] Time's out! Game is restarting.")
			for _,plr in ipairs( player.GetHumans() ) do
				plr:ScreenFade(8, color_black, 2, 9999)
			end
			
			timer.Simple(2, function()
				RunConsoleCommand(game.SinglePlayer() and "reload" or "disconnect")
			end)
		end
	else
		SetGlobal2Int("server_time", GetGlobal2Int("server_time") - 1)
	end
	tickDelay = CurTime() + 1
end)

local function getNumberOfTargets()
	local count = 0
	for _,v in ipairs(ents.FindByClass("npc_civilian")) do
		if v:GetIsTarget() then
			count = count + 1
		end
	end
	for _,v in ipairs(ents.FindByClass("npc_enemy")) do
		if v:GetIsTarget() then
			count = count + 1
		end
	end
	return count
end

hook.Add("Think", "checkWinConditions", function()
	local score = team.GetScore(TEAM_UNASSIGNED)
	if score > getNumberOfTargets() then
		if not isGameEnding then
			isGameEnding = true
			SetGlobal2Bool("round_over", true)
			PrintMessage(HUD_PRINTTALK, "[Server] Mission complete! Total score: " .. score)
			for _,plr in ipairs( player.GetHumans() ) do
				plr:ScreenFade(8, color_black, 2, 9999)
			end
			
			timer.Simple(2, function()
				RunConsoleCommand(game.SinglePlayer() and "reload" or "disconnect")
			end)
		end
	end
end)