local color_enemy = Color( 255, 21, 0 )
local color_vital = Color( 235, 137, 19 )

local function getHighlightedEnemiesDuringStealth()
	local enemies = {}
	for _,v in ipairs(ents.FindByClass( "npc_civilian" )) do
		if not v:IsNPC() then continue end
		if v:GetName() ~= "target" then continue end
		
		table.insert(enemies, v)
	end
	return enemies
end

hook.Add( "PreDrawHalos", "RenderOutlines", function()
	halo.Add( getHighlightedEnemiesDuringStealth(), color_enemy, 5, 5, 2 )
end)