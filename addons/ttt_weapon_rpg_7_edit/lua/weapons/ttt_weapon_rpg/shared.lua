-- This script and all files associated with it and the name 'StraySwordsman' are protected by copyright infringement laws.
--   Paranoia Instinctive ®2013 StraySwordsman 2012®
--   You must ask the permission of StraySwordsman for use of this script.
--   By using this script with my permission, you acknowledge that I may take your permission back at any time rendering you to be unable to use it.
-- Let the script begin.

-- Some edits by Render.

if SERVER then
	resource.AddFile("materials/vgui/ttt/ren_rpg_icon")
end

if SERVER then
	AddCSLuaFile ( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName = "RPG"
	SWEP.Slot	   = 6 -- + 1 for slot hotkey
	SWEP.Icon	   = "vgui/ttt/ren_rpg_icon"
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = false -- true = right hand holds gun
   
   SWEP.EquipMenuData = {
      type = "Shoots explosive rockets.",
      desc = "Launches a rocket propelled grenade\nComes with a single rocket."
    };
end

SWEP.Base = "weapon_tttbase"

---Standard GMod Values, feel free to add more
SWEP.HoldType			= "rpg"
SWEP.Primary.Delay		= 0.15
SWEP.Primary.Recoil		= 10
SWEP.Primary.Automatic	= false
SWEP.Primary.Damage		= 125
SWEP.Primary.Cone		= 0.01
SWEP.Primary.Ammo		= "RPG_Round"
SWEP.HeadshotMultiplier = 1
SWEP.DrawCrosshair 		= false
SWEP.XHair				= false

-- Ammo: How to:
SWEP.Primary.Empty			= Sound( "Weapon_Shotgun.Empty" )
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.ClipMax 		= 1
SWEP.Primary.Round 			= ("ammo_ren_rpg_missle") -- This is the entity that's created upon fire.
SWEP.Primary.RPM 			= 14.2 -- Rounds per minute
SWEP.IronSightsPos			= Vector(-7.778, -7.24, -3)
SWEP.IronSightsAng			= Vector(2.71, -1.8, -3.8)
SWEP.ViewModel  			= "models/weapons/rend_rpg/v_model/v_rend_rpg.mdl"
SWEP.WorldModel 			= "models/weapons/rend_rpg/w_model/w_rend_rpg.mdl"

--- TTT Values, proceed with caution ---

SWEP.Kind 			= WEAPON_EQUIP1 -- EQUIP1 is the primary bought weapon slot
SWEP.AutoSpawnable 	= false -- true = spawns around the map
SWEP.AmmEnt 		= "none" -- Entity treated as ammo
SWEP.CanBuy 		= { ROLE_TRAITOR } -- ROLE_TRAITOR and ROLE_DETECTIVE are usable, ROLE_INNOCENT is untested
SWEP.InLoadoutFor 	= nil -- Role that automatically spawns with this, like the DNA Scanner or Body Armor
SWEP.LimitedStock 	= true -- true = can only buy once
SWEP.AllowDrop 		= true -- true = allowed to drop weapon with drop hotkey
SWEP.IsSilent 		= false -- true = victim makes no sound on death, knife for example
SWEP.NoSights 		= false -- Confused...
-- Custom input functions --

function SWEP:OnRemove() -- Removes timer on weapon removal (IE. Round restart.)
	timer.Destroy("rpgIdle")
end

if CLIENT then
	function SWEP:AdjustMouseSensitivity()
		return (self:GetIronsights() and 0.5) or nil
	end
end

function SWEP:Idle() -- Timer function for idle.
local rpg_vm = self.Owner:GetViewModel()
	if IsValid(self.Owner) then
	timer.Destroy("rpgIdle")
		timer.Create("rpgIdle", 4.5, 0, function()
			self:idleChoose();
		end)
	else
		timer.Destroy("rpgIdle")
	end
end

function SWEP:idleChoose() -- Check ammo, chooses Idle animation.
--	print (self.Owner:IsValid())
	if IsValid(self.Owner) then
	local rpg_vm = self.Owner:GetViewModel()
		if self.Owner:GetActiveWeapon():Clip1() == 0 then 
			rpg_vm:SetSequence(rpg_vm:LookupSequence("idle_empty")) 
		end
		if self.Owner:GetActiveWeapon():Clip1() > 0 then 
			rpg_vm:SetSequence(rpg_vm:LookupSequence("idle")) 
		end
	else
		timer.Destroy("rpgIdle")
	end
end

function SWEP:DrawHUD() -- No Crosshair.
end

function SWEP:PrimaryAttack() -- Attack hook.
	if self:CanPrimaryAttack() and not self.Owner:KeyPressed(IN_SPEED) then
		timer.Destroy("rpgIdle"); -- Kills timer to stop it from calling idle animation in the middle of fire anim.
		local rpg_vm = self.Owner:GetViewModel()
		local pos2 = self.Owner:GetShootPos()
		self:FireRocket()
		self.Weapon:EmitSound("weapons/rpg/ren_rpg_fire.wav")
		util.ScreenShake(pos2, 10, 2, 0.1, 200)
		self.Weapon:TakePrimaryAmmo(1)
		rpg_vm:SetSequence(rpg_vm:LookupSequence("shoot1"))
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:MuzzleFlash()
		self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/70))
		self:Idle() -- Runs timer for idle anims.
	end
end

function SWEP:FireRocket() -- Rocket spawn function, refers to outside lua ent (self.primary.round).
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() + side * 6 + up * -5
	
if SERVER then
	local rocket = ents.Create(self.Primary.Round)
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle()+Angle(0,0,0))
		rocket:SetPos(pos)
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:Activate()
	end
end

function SWEP:SecondaryAttack() -- Ironsight function.
	if not self.IronSightsPos then return end
	if self.Weapon:GetNextSecondaryFire() > CurTime() then return end	
	bIronsights = not self:GetIronsights()	
	self:SetIronsights( bIronsights )	
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop() -- Remove ironsights before drop.
	self:SetIronsights(false)	
	return self.BaseClass.PreDrop(self)
end

function SWEP:Reload() -- Checks ammo and clip before reloading.
	if self.Owner:GetAmmoCount(self.Primary.Ammo) != 0 && self.Owner:GetActiveWeapon():Clip1() != 1 then
		timer.Destroy("rpgIdle");
		local rpg_vm = self.Owner:GetViewModel()
		self.Weapon:DefaultReload( ACT_VM_RELOAD )
		self.Weapon:EmitSound("weapons/rpg/ren_rpg_reload.wav")
		rpg_vm:SetSequence(rpg_vm:LookupSequence("reload"))
		self:SetIronsights(false)
		self:Idle()
	end	
end

function SWEP:Deploy() -- Checks ammo and clip to choose draw sequence.
	local rpg_vm = self.Owner:GetViewModel()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.4)
	self:SetIronsights(false)
	self.Weapon:EmitSound("weapons/rpg/ren_rpg_draw.wav")	
	self:Idle()
		if self.Owner:GetActiveWeapon():Clip1() == 0 then
			rpg_vm:SetPlaybackRate( 0.84 )
			rpg_vm:SetSequence(rpg_vm:LookupSequence("draw_empty"))
		end
		if self.Owner:GetActiveWeapon():Clip1() > 0 then
			rpg_vm:SetPlaybackRate( 0.84 )
			rpg_vm:SetSequence(rpg_vm:LookupSequence("draw"))
		end
	return true
end

function SWEP:Holster() -- Kills idle function timer to stop it from malfunctioning when swapping weapon quickly.
	self:SetIronsights(false)
	timer.Destroy("rpgIdle");
	return true
end

function SWEP:WasBought(rpg_buyer) -- Adds primary ammo, leaves clip empty. Names the player who bought the weapon 'rpg_buyer'.
   if IsValid(rpg_buyer) then
      --rpg_buyer:GiveAmmo( 1, "RPG_Round", false )
	  self.Weapon:SetNextPrimaryFire(0)
   end
end




