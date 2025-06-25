
AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = false

if (CLIENT) then return end

ENT.AnimationList = {
	--"injured1postidle",
	--"Lying_Down", -- use these with animation keyvalue
	"AI_ScriptIdle",
	"AI_ScriptWander"
}

ENT.ModelList = {
	-- MALES
	"models/Humans/Group01/male_01.mdl",
	"models/Humans/Group01/male_02.mdl",
	"models/Humans/Group01/male_03.mdl",
	"models/Humans/Group01/male_04.mdl",
	"models/Humans/Group01/male_05.mdl",
	"models/Humans/Group01/male_06.mdl",
	"models/Humans/Group01/male_07.mdl",
	"models/Humans/Group01/male_08.mdl",
	"models/Humans/Group01/male_09.mdl",
	
	-- FEMALES
	"models/Humans/Group01/female_01.mdl",
	"models/Humans/Group01/female_02.mdl",
	"models/Humans/Group01/female_03.mdl",
	"models/Humans/Group01/female_04.mdl",
	"models/Humans/Group01/female_06.mdl",
	"models/Humans/Group01/female_07.mdl",
}


ENT.WAIT_TIME = 8
ENT.WANDER_SPEED = 100

function ENT:Initialize()
	
	if not self.overrideModel then
		self:SetModel( table.Random(self.ModelList) )
	else
		self:SetModel( self.overrideModel )
	end
	if not self.currentAnimation then
		self.currentAnimation = table.Random(self.AnimationList)
	end
	if self.gotoPath then
		self.currentAnimation = "walkScriptedPath"
		self.rememberSpawnPoint = self:GetPos()
	end

end

function ENT:KeyValue(key,value)
	if key == "model" then
		self.overrideModel = value
	end
	if key == "animation" then
		self.currentAnimation = value
	end
	if key == "scripted_point" then
		for _,v in ipairs(ents.FindByClass("path_corner")) do
			if v:GetName() == value then
				self.gotoPath = v:GetPos()
			end
		end
	end
end

function ENT:WanderRandomly()
	self:StartActivity( ACT_WALK )
	self.loco:SetDesiredSpeed( self.WANDER_SPEED )
	
	-- Choose a random location within 400 units of our position
	local targetPos = self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400

	-- Search for walkable space there, or nearby
	local area = navmesh.GetNearestNavArea( targetPos )
	
	-- We found walkable space, get the closest point on that area to where we want to be
	if ( IsValid( area ) ) then targetPos = area:GetClosestPointOnArea( targetPos ) end
	
	-- walk to the target place (yielding)
	self:MoveToPos( targetPos )

	self:StartActivity( ACT_IDLE ) -- revert to idle activity
	coroutine.wait( self.WAIT_TIME )
end

function ENT:WalkToScriptedPath()
	self:StartActivity( ACT_WALK )
	self.loco:SetDesiredSpeed( self.WANDER_SPEED )
	
	-- Head straight to the scripted point
	local targetPos = self.gotoPath

	-- Search for walkable space there, or nearby
	local area = navmesh.GetNearestNavArea( targetPos )
	
	-- We found walkable space, get the closest point on that area to where we want to be
	if ( IsValid( area ) ) then targetPos = area:GetClosestPointOnArea( targetPos ) end
	
	-- walk to the target place (yielding)
	self:MoveToPos( targetPos )

	self:StartActivity( ACT_IDLE ) -- revert to idle activity
	
	coroutine.wait( self.WAIT_TIME )
	
	self:StartActivity( ACT_WALK )
	self.loco:SetDesiredSpeed( self.WANDER_SPEED )
	
	local targetPos = self.rememberSpawnPoint
	local area = navmesh.GetNearestNavArea( targetPos )
	if ( IsValid( area ) ) then targetPos = area:GetClosestPointOnArea( targetPos ) end
	self:MoveToPos( targetPos )
	self:StartActivity( ACT_IDLE )
	
	coroutine.wait( self.WAIT_TIME )
end

function ENT:RunBehaviour()

	while ( true ) do

		if self.currentAnimation == "AI_ScriptWander" then -- not a npc_citizen animation, special code
			self:WanderRandomly()
		elseif self.currentAnimation == "AI_ScriptIdle" then -- special code for making npcs stand idle without playing anims
			self:StartActivity( ACT_IDLE )
		elseif self.currentAnimation == "walkScriptedPath" then
			self:WalkToScriptedPath()
		else
			self:StartActivity( ACT_IDLE )
			self:SetSequence( self.currentAnimation )
		end

		coroutine.yield()

	end


end
