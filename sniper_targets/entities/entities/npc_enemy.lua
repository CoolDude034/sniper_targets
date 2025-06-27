
AddCSLuaFile()

ENT.Base = "npc_civilian"
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
	},
	Sequences = {
		ReloadSeq = "reload_smg1",
		CrouchAim = "crouch_aim_smg1",
		IdleSeq = "Idle_SMG1_Aim",
		RunSeq = "run_aiming_all"
	}
}

ENT.AIData = {
	IsStationary = false,
	IsCrouching = false,
	IsAlerted = false,
}

ENT.ModelList = {
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

ENT.AnimationList = {}

function ENT:Initialize()

	if not self.overrideModel then
		self:SetModel( table.Random(self.ModelList) )
	else
		self:SetModel( self.overrideModel )
	end
	if not self.currentAnimation and #self.AnimationList > 0 then
		self.currentAnimation = table.Random(self.AnimationList)
	end
	if self.currentWeapon then
		if self.currentWeapon == "weapon_smg1" then
			self.WeaponData.Model = "models/weapons/w_smg1.mdl"
			self.WeaponData.StandOffset = Vector(4.5,-0.5,3.7)
			self.WeaponData.CrouchOffset = Vector(3.5,-0.5,3.7)
			self.WeaponData.ShootDelay = 0.25
			self.WeaponData.MaxAmmo = 30
			self.WeaponData.Sounds = {
				Fire = "Weapon_SMG1.NPC_Single"
			}
			self.WeaponData.Sequences.ReloadSeq = "reload_smg1"
			self.WeaponData.Sequences.CrouchAim = "crouch_aim_smg1"
			self.WeaponData.Sequences.IdleSeq = "Idle_SMG1_Aim"
			self.WeaponData.Sequences.RunSeq = "run_aiming_all"
		elseif self.currentWeapon == "weapon_pistol" then
			self.WeaponData.Model = "models/weapons/w_pistol.mdl"
			self.WeaponData.StandOffset = Vector(4.5,-0.5,3.7)
			self.WeaponData.CrouchOffset = Vector(3.5,-0.5,3.7)
			self.WeaponData.ShootDelay = 0.35
			self.WeaponData.MaxAmmo = 8
			self.WeaponData.Sounds = {
				Fire = "Weapon_Pistol.NPC_Single"
			}
			self.WeaponData.Sequences.ReloadSeq = "reload_pistol"
			self.WeaponData.Sequences.CrouchAim = "Crouch_idle_pistol"
			self.WeaponData.Sequences.IdleSeq = "pistolidle1"
			self.WeaponData.Sequences.RunSeq = nil
		end
	end
	
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

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:KeyValue(key,value)
	if key == "stationary" then
		self.AIData.IsStationary = value == "1"
	end
	if key == "spawn_unalerted" then
		self.AIData.IsAlerted = value == "1"
	end
	if key == "model" then
		self.overrideModel = value
	end
	if key == "animation" then
		self.currentAnimation = value
	end
	if key == "additionalequipment" then
		self.currentWeapon = value
	end
	if key == "is_target" then
		self:SetIsTarget(value == "1" and true or false)
	end
	if key == "keep_corpse" then
		self.keepCorpse = value == "1"
	end
	if key == "scripted_point" then
		for _,v in ipairs(ents.FindByClass("path_corner")) do
			if v:GetName() == value then
				self.gotoPath = v:GetPos()
			end
		end
	end
end

function ENT:ConvertModelToRealGun()
	if self.propGun:GetModel() == "models/weapons/w_smg1.mdl" then
		return "weapon_smg1"
	end
	if self.propGun:GetModel() == "models/weapons/w_pistol.mdl" then
		return "weapon_pistol"
	end
	
	return "none"
end

local g_hasWarnedAboutInnocentKills = false

function ENT:OnKilled(dmginfo)
	local score = team.GetScore(TEAM_UNASSIGNED)
	if self:GetIsTarget() then
		team.AddScore( TEAM_UNASSIGNED, 1 )
	else
		if score > 0 then
			team.AddScore( TEAM_UNASSIGNED, -1 )
		end
		if not g_hasWarnedAboutInnocentKills then
			g_hasWarnedAboutInnocentKills = true
			PrintMessage(HUD_PRINTTALK, "[TIP] Killing non-targets reduce your overall score")
		end
	end
	
	if IsValid(self.propGun) then
		local spawn_offset = Vector(0,5,0)
		local weaponClass = self:ConvertModelToRealGun()
		if weaponClass ~= "none" then
			local wep = ents.Create(weaponClass)
			wep:SetPos(self:GetPos() + spawn_offset)
			wep:Spawn()
		end
		self.propGun:Remove()
		self.propGun = nil
	end
	
	if ( self.keepCorpse ) then
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
	if not self.AIData.IsAlerted then return end
	local target = self:GetEnemy()
	if IsValid(target) then
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

function ENT:ForceAlert()
	if self.AIData.IsAlerted then return end
	self.AIData.IsAlerted = true
	
	self.currentAnimation = nil
end

function ENT:RunNavigationCode()
	if (self.currentAmmo <= 0) then
		self:StartActivity( ACT_IDLE )
		if (self.WeaponData.Sequences.ReloadSeq) then
			self:PlaySequenceAndWait( self.WeaponData.Sequences.ReloadSeq )
		end
		self.currentAmmo = self.WeaponData.MaxAmmo
	end
	local target = self:GetEnemy()
	if (IsValid(target) and self.AIData.IsAlerted) then
	
		if ( self.AIData.IsStationary ) then
			self:StartActivity( ACT_IDLE )
			if (self.WeaponData.Sequences.CrouchAim) then
				self:SetSequence( self.WeaponData.Sequences.CrouchAim )
			end
			self.AIData.IsCrouching = true
		else
			self:StartActivity( ACT_RUN )
			if (self.WeaponData.Sequences.RunSeq) then
				self:SetSequence( self.WeaponData.Sequences.RunSeq )
			end
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
			if (self.WeaponData.Sequences.IdleSeq) then
				self:SetSequence( self.WeaponData.Sequences.IdleSeq )
			end
			self.AIData.IsCrouching = false
		end
	
	else
		self:StartActivity( ACT_IDLE )
		if (self.WeaponData.Sequences.IdleSeq) then
			self:SetSequence( self.WeaponData.Sequences.IdleSeq )
		end
		self.AIData.IsCrouching = false
	end
end

function ENT:RunAnimationCode()
	if self.currentAnimation == "AI_AmbientWander" then -- not a npc_citizen animation, special code
		self:WanderRandomly()
	elseif self.currentAnimation == "AI_ScriptIdle" then -- special code for making npcs stand idle without playing anims
		self:StartActivity( ACT_IDLE )
	elseif self.currentAnimation == "AI_ScriptWander" then -- special code to make npcs go to a scripted position
		self:WalkToScriptedPath()
	else
		self:StartActivity( ACT_IDLE )
		self:SetSequence( self.currentAnimation )
	end
end

function ENT:RunBehaviour()

	while ( true ) do
		if (self.currentAnimation) then
			self:RunAnimationCode()
		else
			self:RunNavigationCode()
		end
		coroutine.yield()
	end


end
