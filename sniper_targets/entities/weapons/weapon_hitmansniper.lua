AddCSLuaFile()
SWEP.PrintName="Sniper Rifle"
SWEP.Slot=1
SWEP.SlotPos=4
SWEP.Author="Willi"
SWEP.ViewModel="models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel="models/weapons/w_snip_awp.mdl"
SWEP.UseHands=true
SWEP.Spawnable=true
SWEP.CSMuzzleFlashes=true
SWEP.Primary.ClipSize=-1
SWEP.Primary.DefaultClip=-1
SWEP.Primary.Automatic=false
SWEP.Primary.Ammo="none"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=false
SWEP.Secondary.Ammo="none"
function SWEP:Initialize()
self:SetHoldType("rpg")
self.isAiming=false
end
function SWEP:PrimaryAttack()
if GetGlobal2Bool("round_over") then return end
self:SetNextPrimaryFire(CurTime()+1.5)
self:EmitSound("Weapon_357.Single")
local owner=self:GetOwner()
local bullet={}
bullet.Num=1
bullet.Src=owner:GetShootPos()
bullet.Dir=owner:GetAimVector()
bullet.Spread=Vector(0,0,0)
bullet.Tracer=1
bullet.Force=1
bullet.Damage=5
bullet.AmmoType="357"
owner:FireBullets(bullet)
self:ShootEffects()
if not self.isAiming then
util.ParticleTracer("muzzle_rifles", self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector(), true)
end

--alert civs/guards
if not GetGlobal2Bool("civs_alerted") and SERVER then
SetGlobal2Bool("civs_alerted", true)
for _,v in ipairs( ents.FindByClass("npc_civilian") ) do
	if IsValid(v) then
		v:ForceAlert()
	end
end
for _,v in ipairs( ents.FindByClass("npc_enemy") ) do
	if IsValid(v) then
		v:ForceAlert()
	end
end

end
end
function SWEP:SecondaryAttack()
	self.isAiming = not self.isAiming
	if not self.isAiming then
	self:GetOwner():SetFOV(20)
	else
	self:GetOwner():SetFOV(0)
	end
end

