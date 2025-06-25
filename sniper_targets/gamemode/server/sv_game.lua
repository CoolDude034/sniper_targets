function GM:PlayerCanPickupWeapon(ply, wep)
    if wep:IsFlagSet(FL_DISSOLVING) then
        return false
    end
	
	if ( wep:GetClass() == "weapon_smg1" ) then -- REPLACE weapon_smg1 with your own SWEP!
		return true
	end
	
    return false
end

-- noclip is disabled, uncomment the first line below for testing purposes, but be sure to comment it back
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
end

function GM:InitPostEntity()
	for _,v in ipairs(ents.FindByClass("info_player_start")) do v:Remove() end
	local sp = ents.Create("info_player_start")
	sp:SetPos(Vector(729.1, -1684.1, 1136))
	sp:Spawn()
	
	local sp = ents.Create("info_player_start")
	sp:SetPos(Vector(719, -1474.1, 1136))
	sp:Spawn()
end

hook.Add("PlayerInitialSpawn", "onPlayerInitialSpawn", function(ply)
	if not game.SinglePlayer() then
		-- Tune network settings
		RunConsoleCommand("cl_cmdrate", "66")
		RunConsoleCommand("cl_updaterate", "66")
		RunConsoleCommand("rate", "196608")
		RunConsoleCommand("cl_interp", "0")
		RunConsoleCommand("cl_interp_npcs", "0.25")
		RunConsoleCommand("cl_interp_ratio", "1")
		-- Tune game stuff
		RunConsoleCommand("sv_rollangle", "3")
		RunConsoleCommand("gmod_maxammo", "0")
		RunConsoleCommand("gmod_sneak_attack", "1")
		RunConsoleCommand("gmod_suit", "0")
		
		RunConsoleCommand("sv_allowcslua", "0")
		RunConsoleCommand("sv_playerpickupallowed", "0")
		
		RunConsoleCommand("maxplayers", "2") -- set max players to 2
		
		-- Ragdolls sleep after 2s
		RunConsoleCommand("ragdoll_sleepaftertime", "2.0")
	end
end)

hook.Add("PlayerSpawn", "onPlayerSpawn", function(ply)
	ply:SetSuppressPickupNotices(true)
	
	if game.SinglePlayer() then
		ply:SetModel("models/player.mdl")
	else
		-- TODO: DO CUSTOM PLAYER MODELS HERE
		ply:SetModel("models/player/gman_high.mdl")
	end
end)

hook.Add("InitPostEntity", "addNPCs", function()
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
end)
