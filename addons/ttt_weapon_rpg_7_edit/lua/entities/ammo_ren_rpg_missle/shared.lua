ENT.Type = "anim"
ENT.PrintName = ""
ENT.Author = ""
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""

ENT.Spawnable = ""
ENT.AdminSpawnable = false

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
self.flightvector = self.Entity:GetForward() * ((115*52.5)/66)
self.timeleft = CurTime() + 20
self.Owner = self:GetOwner()
self.Entity:SetModel("models/entities/rend_grenade/w_model/w_rend_grenade.mdl")
self.Entity:PhysicsInit(SOLID_VPHYSICS)
self.Entity:SetMoveType(MOVETYPE_NONE)
self.Entity:SetSolid(SOLID_VPHYSICS)
--self.Entity:SetMaterial("models/debug/debugwhite.vmt")
self.Entity:SetColor(Color(55,67,44,255))

Glow = ents.Create("env_sprite")
Glow:SetKeyValue("model","orangecore2.vmt")
Glow:SetKeyValue("rendercolor","255 150 100")
Glow:SetKeyValue("scale","1.2")
Glow:SetPos(self.Entity:GetPos())
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()
self.Entity:SetNWBool("smoke", true)
end

function ENT:Think()	
if self.timeleft < CurTime() then
	self.Entity:Remove()
end		
Table = {}
Table[1] = self.Owner		//Person holding the cap
Table[2] = self.Entity		//The cap	
local trace = {}
trace.start = self.Entity:GetPos()
trace.endpos = self.Entity:GetPos() + self.flightvector
trace.filter = Table
local tr = util.TraceLine( trace )
local explodeDamageInner = 75
local explodeDamageOuter = 50
local explodeRadiusInner = 175	
local explodeRadiusOuter = 500
if tr.HitSky then
	self.Entity:Remove()
	return true
end
	if tr.Hit then
		self.Entity:EmitSound("weapons/rpg/ren_rpg_explode.wav", 225, 105)
		util.BlastDamage(self.Entity, self.Owner, tr.HitPos, explodeRadiusInner, explodeDamageInner)
		util.BlastDamage(self.Entity, self.Owner, tr.HitPos, explodeRadiusOuter, explodeDamageOuter)
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
		effectdata:SetEntity(self.Entity)
		effectdata:SetScale(10)
		effectdata:SetRadius(5)
		effectdata:SetMagnitude(120)
		util.Effect("Explosion", effectdata)
		util.ScreenShake(tr.HitPos, 10, 5, 1, 3000)
		util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self.Entity:SetNWBool("smoke", false)
		self.Entity:Remove()
	else
		self.Entity:EmitSound("weapons/rpg/ren_rpg_flight.wav", 70, 90)
		self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
		self.flightvector = self.flightvector - self.flightvector/((147*39.37)/66) + self.Entity:GetForward()*2 + Vector(math.Rand(-0.3,0.3), math.Rand(-0.3,0.3), math.Rand(-0.1,0.1)) + Vector(0,0,-0.111)
		self.Entity:SetAngles(self.flightvector:Angle() + Angle(0,0,0))
		self.Entity:NextThink(CurTime())
	end		
return true
end
end

if CLIENT then
	function ENT:Draw()
	self.Entity:DrawModel()
	end

	function ENT:Initialize()
	pos = self:GetPos()
	self.emitter = ParticleEmitter(pos)
	end
	
	function ENT:Think()
		if (self.Entity:GetNWBool("smoke")) then
			pos = self:GetPos()
			for i = 1, 7 do
				local particle = self.emitter:Add( "particles/ren_rpg_smoke.vmf"..math.random(1,9), pos + (self:GetForward() * -15 * i))
				if(particle) then
					particle:SetVelocity((self:GetForward() * -50))
					particle:SetDieTime(math.Rand(5,8))
					particle:SetStartAlpha(math.Rand(200,230))
					particle:SetEndAlpha(0)
					particle:SetStartSize(math.Rand(12,22))
					particle:SetEndSize(math.Rand(30,45))
					particle:SetRoll(math.Rand(0,360))
					particle:SetRollDelta(math.Rand(-1,1))
					particle:SetColor(40,40,40)
					particle:SetAirResistance(200)
					particle:SetGravity(Vector(28,0,0))
				end
			end
		end
	end
end
