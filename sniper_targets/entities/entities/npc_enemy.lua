
AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = false

function ENT:Initialize()

	self:SetModel( "models/Humans/Group01/male_07.mdl" )

end

function ENT:GetEnemy()
	if self.m_Enemy ~= nil then
		return self.m_Enemy
	end
end

function ENT:SetEnemy(newTarget)
	if IsValid(newTarget) then
		self.m_Enemy = newTarget
	end
end

function ENT:Think()
	local target = self:GetEnemy()
	if IsValid(target) then
		local tarAng = target:GetAngles()
		local ang = Angle( tarAng.pitch,tarAng.yaw + 180,tarAng.roll )
		self:SetAngles( ang )
	end
end

function ENT:RunBehaviour()

	while ( true ) do

		if ( !IsValid(self:GetEnemy()) ) then
			local plr = Entity(1)
			if IsValid(plr) then
				self:SetEnemy( plr )
			end
		end
		
		local target = self:GetEnemy()
		
		self:StartActivity( ACT_RUN )
		self.loco:SetDesiredSpeed( 200 )
		
		-- Choose a random location within 400 units of our position
		local targetPos = target:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400

		-- Search for walkable space there, or nearby
		local area = navmesh.GetNearestNavArea( targetPos )
		
		-- We found walkable space, get the closest point on that area to where we want to be
		if ( IsValid( area ) ) then targetPos = area:GetClosestPointOnArea( targetPos ) end
		
		-- walk to the target place (yielding)
		self:MoveToPos( targetPos )

		self:StartActivity( ACT_IDLE ) -- revert to idle activity
		
		self:PlaySequenceAndWait( "Idle_SMG1_Aim" )
		coroutine.wait(3)

		coroutine.yield()

	end


end
