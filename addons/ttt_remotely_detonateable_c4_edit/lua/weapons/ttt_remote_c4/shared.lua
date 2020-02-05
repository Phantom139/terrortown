
AddCSLuaFile()

SWEP.PrintName = "C4 Charge"
SWEP.Slot = 7
SWEP.SlotPos = 1

SWEP.EquipMenuData = {
	type = "item_weapon",
	name = "Remotely detonateable C4",
	desc = "Plant an remote detonateable bomb!\nLeft Click: Plant Bomb\nRight Click: Explode Bomb"
}

SWEP.Icon = "vgui/remotely_detonateable_c4.png"


SWEP.Author = "Darkrael"
SWEP.Purpose = ""
SWEP.Instructions = "Plant an remote detonateable bomb!\nLeft Click: Plant Bomb\nRight Click: Explode Bomb"


SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "normal"
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true
SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.Category = "TTT Remotely Detonateable C4"
SWEP.UseHands = true
SWEP.Weight = 5
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.NoSights = true


function SWEP:Initialize()
	if CLIENT and engine.ActiveGamemode() == "terrortown" then
		self:AddHUDHelp("Press MOUSE1 to plant the C4",false)
	end
end

--Mostly replecating the C4 bomb stick
function SWEP:PrimaryAttack()
	if SERVER then
		local ply = self.Owner
		if not IsValid(ply) then return end

		local ignore = {ply, self}
		local spos = ply:GetShootPos()
		local epos = spos + ply:GetAimVector() * 100
		local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})

		if tr.HitWorld then
			local bomb = ents.Create("remotec4")
			if IsValid(bomb) then
				bomb:PointAtEntity(ply)

				local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, bomb)

				if tr_ent.HitWorld then

					local ang = tr_ent.HitNormal:Angle()
					ang:RotateAroundAxis(ang:Right(), -90)
					ang:RotateAroundAxis(ang:Up(), 180)

					bomb:SetPos(tr_ent.HitPos)
					bomb:SetAngles(ang)
					bomb:SetOwner(ply)
					bomb:Spawn()

					bomb.fingerprints = self.fingerprints
					local i = 0
					for k, v in pairs( ents.FindByClass( "remotec4" ) ) do
						i = i + 1
					end
					bomb.affiliation = i

					local phys = bomb:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
					end
					--Switch out for the detonator
					self.Owner:DropWeapon(self.Owner:GetActiveWeapon())
					local detonator = ply:Give("ttt_remote_detonator")
					detonator.affiliation = i
					timer.Create("switchtodetonator",0.2,1,function() ply:SelectWeapon("ttt_remote_detonator") end)
					self:Remove()
				end
			end
        ply:SetAnimation( PLAYER_ATTACK1 )
		end
	end
end

function SWEP:Reload() return false end

function SWEP:OnRemove()
	if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
		RunConsoleCommand("lastinv")
	end
end
