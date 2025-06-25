
AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = false

if (CLIENT) then return end

ENT.AnimationList = {
	--"injured1postidle",
	"Lying_Down",
	"wanderRandomly"
}

ENT.ModelList = {
	"models/Humans/Group01/male_07.mdl"
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

		if self.currentAnimation == "wanderRandomly" then -- not a npc_citizen animation, special code
			self:WanderRandomly()
		elseif self.currentAnimation == "walkScriptedPath" then
			self:WalkToScriptedPath()
		else
			self:StartActivity( ACT_IDLE )
			self:PlaySequenceAndWait( self.currentAnimation )
		end

		coroutine.yield()

	end


end
