AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
local math = math
ENT.Model = Model("models/weapons/w_c4_planted.mdl")

function ENT:Initialize()
	self.Boom = false
	self:SetModel(self.Model)
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	
	timer.Create("c4beep",1,0,function()
	if IsValid(self) then
		self:EmitSound(Sound("weapons/c4/c4_beep1.wav"),45,100,1,CHAN_WEAPON) else
		timer.Destroy("c4beep")
	end
	
	end)
end

function ENT:Think()
	if self.Boom and SERVER then
		local ent = ents.Create( "env_explosion" )
		ent:SetPos( self:GetPos() )
		ent:SetOwner( self:GetOwner() )
		ent:SetPhysicsAttacker( self )
		ent:Spawn()
		ent:SetKeyValue( "iMagnitude", "0" )
		ent:Fire( "Explode", 0, 0 )
		self:SphereDamage(self:GetOwner(), self:GetPos(), 200)
		-- Phantom139: Tweaked to 1/1 as to such the entity explodes, but does not affect damage improperly.
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 1, 1 ) 
		self:Remove()
	end
end

--Copied function of normal C4
function ENT:SphereDamage(dmgowner, center, radius)
	-- It seems intuitive to use FindInSphere here, but that will find all ents
	-- in the radius, whereas there exist only ~16 players. Hence it is more
	-- efficient to cycle through all those players and do a Lua-side distance
	-- check.

	local r = radius ^ 2 -- square so we can compare with dotproduct directly


	-- pre-declare to avoid realloc
	local d = 0.0
	local diff = nil
	local dmg = 0
	for _, ent in pairs(player.GetAll()) do
		if IsValid(ent) and ent:Team() == TEAM_TERROR then

			-- dot of the difference with itself is distance squared
			diff = center - ent:GetPos()
			d = diff:DotProduct(diff)

			if d < r then
				-- deadly up to a certain range, then a quick falloff within 100 units
				d = math.max(0, math.sqrt(d) - 490)
				dmg = -0.01 * (d^2) + 75

				local dmginfo = DamageInfo()
				dmginfo:SetDamage(dmg)
				dmginfo:SetAttacker(dmgowner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_BLAST)
				dmginfo:SetDamageForce(center - ent:GetPos())
				dmginfo:SetDamagePosition(ent:GetPos())

				ent:TakeDamageInfo(dmginfo)
			end
		end
	end
end
