
AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = false

if (CLIENT) then return end

local tmp_vec = Vector()
local tmp_ang = Angle()

ENT.WeaponData = {
	Model = "models/weapons/w_smg1.mdl",
	StandOffset = Vector(4.5,-0.5,3.7),
	CrouchOffset = Vector(3.5,-0.5,3.7),
	ShootDelay = 0.25,
	MaxAmmo = 30,
	Sounds = {
		Fire = "Weapon_SMG1.NPC_Single"
	}
}

ENT.AIData = {
	IsStationary = false,
	IsCrouching = false,
	IsPersistent = false
}

ENT.Models = {
	-- MALES
	"models/Humans/Group03/male_01.mdl",
	"models/Humans/Group03/male_02.mdl",
	"models/Humans/Group03/male_03.mdl",
	"models/Humans/Group03/male_04.mdl",
	"models/Humans/Group03/male_05.mdl",
	"models/Humans/Group03/male_06.mdl",
	"models/Humans/Group03/male_07.mdl",
	"models/Humans/Group03/male_08.mdl",
	"models/Humans/Group03/male_09.mdl",
	
	-- FEMALES
	"models/Humans/Group03/female_01.mdl",
	"models/Humans/Group03/female_02.mdl",
	"models/Humans/Group03/female_03.mdl",
	"models/Humans/Group03/female_04.mdl",
	"models/Humans/Group03/female_06.mdl",
	"models/Humans/Group03/female_07.mdl",
}

function ENT:Initialize()

	self:SetModel( table.Random(self.Models) )
	
	local propGun = ents.Create("prop_dynamic")
	propGun:SetKeyValue("model", self.WeaponData.Model)
	propGun:SetParent(self, self:LookupAttachment("anim_attachment_RH"))
	propGun:SetLocalPos(tmp_vec + self.WeaponData.StandOffset)
	propGun:SetLocalAngles(tmp_ang)
	propGun:Spawn()
	
	self.propGun = propGun
	self.shootTime = CurTime() + self.WeaponData.ShootDelay
	self.currentAmmo = self.WeaponData.MaxAmmo

end

function ENT:KeyValue(key,value)
	if key == "stationary" then
		self.AIData.IsStationary = value == "1"
	end
	if key == "persistent" then
		self.AIData.IsPersistent = value == "1"
	end
end

function ENT:OnKilled(dmginfo)
	if IsValid(self.propGun) then
		local spawn_offset = Vector(0,5,0)
		if self.propGun:GetModel() == "models/weapons/w_smg1.mdl" then
			local wep = ents.Create("weapon_smg1")
			wep:SetPos(self:GetPos() + spawn_offset)
			wep:Spawn()
		elseif self.propGun:GetModel() == "models/weapons/w_pistol.mdl" then
			local wep = ents.Create("weapon_pistol")
			wep:SetPos(self:GetPos() + spawn_offset)
			wep:Spawn()
		end
		self.propGun:Remove()
		self.propGun = nil
	end
	
	if ( self.AIData.IsPersistent ) then
		local body = ents.Create( "prop_ragdoll" )
		body:SetPos( self:GetPos() )
		body:SetAngles( self:GetAngles() )
		body:SetModel( self:GetModel() )
		body:SetKeyValue("spawnflags", "4")
		body:Spawn()
		self:Remove()
	else
		self:BecomeRagdoll( dmginfo )
	end
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
		--[[
		if target:Health() <= 0 then
			print("Target died")
			self:SetEnemy(nil)
			return
		end
		]]
		local tarAng = target:GetAngles()
		local ang = Angle( tarAng.pitch,tarAng.yaw + 180,tarAng.roll )
		self:SetAngles( ang )
		
		if IsValid(self.propGun) then
			local offset = self.AIData.IsCrouching and self.WeaponData.CrouchOffset or self.WeaponData.StandOffset
			self.propGun:SetLocalPos(tmp_vec + offset)
			if self.currentAmmo <= 0 then
				return
			else
				if CurTime() < self.shootTime then
				else
					local effectdata = EffectData()
					effectdata:SetOrigin( self.propGun:GetPos() )
					util.Effect( "MuzzleEffect", effectdata )
					util.Effect( "RifleShellEject", effectdata )
					self.propGun:EmitSound( self.WeaponData.Sounds.Fire )
					self.currentAmmo = self.currentAmmo - 1
					
					local tr = util.TraceLine({
						start = self.propGun:GetPos(),
						endpos = self.propGun:GetPos() + self.propGun:GetAngles():Forward() * 10000
					})
					if tr.HitEntity and IsValid(tr.HitEntity) then
						if tr.HitEntity:IsNPC() or tr.HitEntity:IsPlayer() or tr.HitEntity:IsNextBot() then
							tr.HitEntity:SetHealth( tr.HitEntity:GetHealth() - 1 )
						end
					end
					self.shootTime = CurTime() + self.WeaponData.ShootDelay
				end
			end
		end
	else
		for _,v in ipairs( ents.FindInSphere( self:GetPos(), 1000 ) ) do
			if v ~= self and v:GetClass() ~= self:GetClass() and v:IsPlayer() then
				self:SetEnemy( v )
			end
		end
	end
end

function ENT:RunBehaviour()

	while ( true ) do
		
		if (self.currentAmmo <= 0) then
			self:StartActivity( ACT_IDLE )
			self:PlaySequenceAndWait("reload_smg1")
			self.currentAmmo = self.WeaponData.MaxAmmo
		end
		
		local target = self:GetEnemy()
		if (IsValid(target)) then
		
			if ( self.AIData.IsStationary ) then
				self:StartActivity( ACT_IDLE )
				self:SetSequence("crouch_aim_smg1")
				self.AIData.IsCrouching = true
			else
				self:StartActivity( ACT_RUN )
				self:SetSequence("run_aiming_all")
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
				self:SetSequence("Idle_SMG1_Aim")
				self.AIData.IsCrouching = false
				--self:PlaySequenceAndWait( "Idle_SMG1_Aim" )
			end
		
		else
			self:StartActivity( ACT_IDLE )
			self:SetSequence("Idle_SMG1_Aim")
			self.AIData.IsCrouching = false
		end

		coroutine.yield()

	end


end
