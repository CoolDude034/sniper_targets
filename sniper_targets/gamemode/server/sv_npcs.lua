hook.Add( "KeyPress", "markEnemies", function(ply, key)
	if not GetGlobal2Bool("isStealth") then return end
	if key == IN_USE then
		for _,v in ipairs(ents.FindByClass( "npc_*" )) do
			if not v:IsNPC() or v:GetNW2Bool("isMarked") then continue end
			
			if v:Disposition(ply) ~= D_LI and ply:IsLineOfSightClear(v) then
				v:SetNW2Bool("isMarked", true)
				
				timer.Simple(10, function()
					if not IsValid(v) then return end
					
					v:SetNW2Bool("isMarked", nil)
				end)
			end
		end
	end
end)

function GM:GetDeathNoticeEntityName( ent )

	-- Some specific HL2 NPCs, just for fun
	-- TODO: Localization strings?
	if ( ent:GetClass() == "npc_citizen" ) then
		if ( ent:GetName() == "griggs" ) then return "Griggs" end
		if ( ent:GetName() == "sheckley" ) then return "Sheckley" end
		if ( ent:GetName() == "tobias" ) then return "Laszlo" end
		if ( ent:GetName() == "stanley" ) then return "Sandy" end
		if ( ent:GetModel() == "models/odessa.mdl" ) then return "C. Odessa Cubbage" end
	end
	
	if ( ent:GetClass() == "npc_metropolice" and ent:GetModel() == "models/elite_police.mdl" ) then return "Elite Metropolice" end
	
	if ( ent:GetClass() == "npc_citizen" and string.find(ent:GetModel(), "group03") and !ent:HasSpawnFlags( SF_CITIZEN_MEDIC ) ) then return "Rebel Medic" end
	if ( ent:GetClass() == "npc_citizen" and string.find(ent:GetModel(), "group03m") and ent:HasSpawnFlags( SF_CITIZEN_MEDIC ) ) then return "Rebel" end
	
	-- Unfortunately the code above still doesn't work for Antlion Workers, because they change their classname..
	if ( ent:GetClass() == "npc_antlion" and ent:GetModel() == "models/antlion_worker.mdl" ) then
		return "Antlion Worker"
	end

	-- Fallback to old behavior
	return "#" .. ent:GetClass()

end
