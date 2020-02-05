
AddCSLuaFile()

SWEP.PrintName = "C4 Detonator"
SWEP.Slot = 7
SWEP.SlotPos = 1


SWEP.Icon = "icon/ttt_icon.png"
   
   
SWEP.Author = "Darkrael"
SWEP.Purpose = ""
SWEP.Instructions = "Plant an remote detonateable bomb!\nLeft Click: Plant Bomb\nRight Click: Explode Bomb"

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {} 
SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.HoldType = "normal"
SWEP.UseHands = true
SWEP.Weight = 5
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.NoSights = true


function SWEP:Initialize()
	if CLIENT and engine.ActiveGamemode() == "terrortown" then
		self:AddHUDHelp("Press MOUSE2 to explode the C4",false)
	end
end

function SWEP:PrimaryAttack()
	return false                         --Get rid of the annoying click
end

function SWEP:SecondaryAttack()
	for k, v in pairs( ents.FindByClass( "remotec4" ) ) do
		if v.affiliation == self.affiliation then
			v.Boom = true
		end
	end
	if SERVER then self:Remove() end
end

function SWEP:Reload() return false end

function SWEP:OnRemove()
	if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
		RunConsoleCommand("lastinv")
	end
end
