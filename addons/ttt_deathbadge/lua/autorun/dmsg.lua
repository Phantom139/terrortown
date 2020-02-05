if SERVER then
	util.AddNetworkString("DMSG.NetMessage")
	AddCSLuaFile("autorun/dmsg.lua")
	hook.Add("PlayerDeath", "DMSG.SV", function(vic, wep, att)
		if wep == att and att == vic then --suicide
			vic.DMSGDamageCounter = nil
		end
		if GetRoundState() == ROUND_ACTIVE then
			timer.Simple(.1, function()
				net.Start("DMSG.NetMessage")
					net.WriteEntity(att)
					if att:IsPlayer() then
						net.WriteInt(att:GetRole(), 8)
					else
						net.WriteInt(-1, 8)
					end
					if vic.DMSGDamageCounter then
						net.WriteInt(vic.DMSGDamageCounter[2], 8)
						net.WriteInt(math.Round(vic.DMSGDamageCounter[3]), 16)
					else
						net.WriteInt(-1, 8)
						net.WriteInt(-1, 16)
					end
				net.Send(vic)
				vic.DMSGDamageCounter = nil
			end)
		end
	end)

	hook.Add("EntityTakeDamage", "DMSG.DamageCounter", function(ply, dmg)
		ply.DMSGDamageCounter = ply.DMSGDamageCounter or {NULL, 0, 0}
		if dmg:GetAttacker():IsPlayer() then
			if ply.DMSGDamageCounter[1] == dmg:GetAttacker() then
				ply.DMSGDamageCounter[2] = ply.DMSGDamageCounter[2] + 1
				ply.DMSGDamageCounter[3] = ply.DMSGDamageCounter[3] + dmg:GetDamage()
			else
				ply.DMSGDamageCounter[1] = dmg:GetAttacker()
				ply.DMSGDamageCounter[2] = 1
				ply.DMSGDamageCounter[3] = dmg:GetDamage()
			end
		else
			ply.DMSGDamageCounter[1] = NULL
			ply.DMSGDamageCounter[2] = 1
			ply.DMSGDamageCounter[3] = dmg:GetDamage()
		end
	end) 

else

CreateClientConVar("ttt_dmsg_seconds", 5, FCVAR_ARCHIVE)

local index = {
    [-1] = {Color(237, 179, 34), Color(171, 130, 25), "The World"},
	[0] = {Color(33, 177, 33), Color(27, 146, 27), "Innocent"},
	[1] = {Color(226, 43, 43), Color(178, 34, 34), "Traitor"},
	[2] = {Color(9, 101, 203), Color(14, 69, 148), "Detective"},
	[3] = {Color(237, 179, 34), Color(171, 130, 25), "Ghost"},
}

hook.Add("InitPostEntity", "CreateFontsDMSG", function()

surface.CreateFont( "BebasNeue", {
	font = "Bebas Neue",
	size = 30,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

surface.CreateFont( "BebasNeue2", {
	font = "Bebas Neue",
	size = 42,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

surface.CreateFont( "BebasNeue3", {
	font = "Bebas Neue",
	size = 100,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

surface.CreateFont( "BebasNeue4", {
	font = "Tahoma",
	size = 16,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

local HOLDER = {}

function HOLDER:Paint(w, h)
	surface.SetDrawColor(Color(20, 20, 20, 200))
	surface.DrawRect(0, 0, w, h - 24)
	if self.times ~= -1 then
		surface.SetDrawColor(Color(20, 20, 20, 240))
		surface.DrawRect(0, h - 24, w, h)
		surface.SetTextColor(color_white)
		surface.SetFont("BebasNeue4")
		surface.SetTextPos(4, h - 20)
		surface.DrawText("Damage Taken: ")
		local textw = surface.GetTextSize("Damage Taken: ")
		surface.SetFont("BebasNeue4")
		surface.SetTextColor(index[self.role][1])
		local textw2 = surface.GetTextSize(self.dmg .. " ")
		surface.SetTextPos(4 + textw, h - 20)
		surface.DrawText(self.dmg)
		surface.SetFont("BebasNeue4")
		surface.SetTextColor(color_white)
		surface.SetTextPos(4 + textw + textw2, h - 20)
		surface.DrawText("in ")
		local textw3 = surface.GetTextSize("in ")
		surface.SetFont("BebasNeue4")
		surface.SetTextColor(index[self.role][1])
		surface.SetTextPos(4 + textw + textw2 + textw3, h - 20)
		surface.DrawText(self.times .. " hits")
	end
end

function HOLDER:SetDmg(role, times, dmg)
	self.role = role
	self.times = times
	self.dmg = dmg
end

vgui.Register("DMSG.Holder", HOLDER, "Panel")

local GRAD = {}

function GRAD:Init()
	self.mat = Material("gui/cgradient.png")
end

function GRAD:Paint(w, h)
	surface.SetMaterial(self.mat)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("DMSG.Gradient", GRAD, "Panel")

local TXT = {}
	
function TXT:Init()
	self.FirstColor = color_white
	self.SecondColor = self.FirstColor
	self.Text = ""
	self.Font = "BebasNeue"
end

function TXT:SetFont(font)
	self.Font = font
end

function TXT:SetText(txt)
	self.Text = txt
	surface.SetFont(self.Font)
	local _, h = surface.GetTextSize("A")
	local w, _ = surface.GetTextSize(txt)
	self:SetSize(w, h)
end

function TXT:SetFirstColor(col)
	self.FirstColor = col
end

function TXT:SetSecondColor(col)
	self.SecondColor = col
end

function TXT:Paint(w, h)
	surface.SetFont(self.Font)
	surface.SetTextColor(self.SecondColor)
	surface.SetTextPos(0, 0)
	surface.DrawText(self.Text)
	local x, y = self:LocalToScreen(0, 0)
	render.SetScissorRect(x, y, x + w, y + h / 2, true)
	surface.SetTextColor(self.FirstColor)
	surface.SetTextPos(0, 0)
	surface.DrawText(self.Text)
	render.SetScissorRect(x, y, x + w, y + h, false)
end

vgui.Register("DMSG.Label", TXT, "Panel")
end)

function MakeDMSG(ply, role, times, dmg)
	DMSGBadge = vgui.Create("DMSG.Holder")
	DMSGBadge:SetPos(ScrW() / 2 - (ScrW() / 3) / 2 , ScrH() - 260)
	DMSGBadge:SetSize(530, 187)
	DMSGBadge:SetVisible(true)
	DMSGBadge.RemoveOn = CurTime() + GetConVar("ttt_dmsg_seconds"):GetFloat()
	DMSGBadge:SetDmg(role, times, dmg)
	
	local lbl = vgui.Create("DMSG.Label", DMSGBadge)
	lbl:SetPos(4, 0)
	lbl:SetFirstColor(Color(230, 230, 230))
	lbl:SetSecondColor(Color(180, 180, 180))
	lbl:SetText("You were killed by")
	lbl:SetVisible(true)
	
	
	local grad = vgui.Create("DMSG.Gradient", DMSGBadge)
	grad:SetPos(8, lbl:GetTall() - 2)
	grad:SetSize(128, 128)
	
	local avatar = vgui.Create("AvatarImage", grad)
	avatar:SetPos(0, 0)
	if !ply:IsPlayer() or ply:IsBot() then
		avatar:SetSize(128, 128)
		avatar:SetPlayer(LocalPlayer(), 128)
	else 
		avatar:SetSize(128, 128)
		avatar:SetPlayer(ply, 128)
	end
	
	--local grad2 = vgui.Create("DMSG.Gradient", grad)
	--grad2:SetPos(0, 0)
	--grad2:SetSize(128, 128)
	--grad2:SetVisible(true)
	
	if ply:IsPlayer() then
		local lbl2 = vgui.Create("DMSG.Label", DMSGBadge)
		lbl2:SetPos(16 + grad:GetWide(), lbl:GetTall() - 9)
		lbl2:SetFont("BebasNeue2")
		lbl2:SetFirstColor(Color(237, 179, 34))
		lbl2:SetSecondColor(Color(171, 130, 25) )
		--lbl2:SetText(ply == LocalPlayer() and "Yourself" or (ply:IsValid() and ply:Nick() or ""))
		lbl2:SetText(ply == LocalPlayer() and "Yourself" or ply:Nick())
		lbl2:SetVisible(true)
	end
	
	local lbl3 = vgui.Create("DMSG.Label", DMSGBadge)
	lbl3:SetPos(15 + grad:GetWide(), role == -1 and lbl:GetTall() - 18 or lbl:GetTall() - 2 + 128 - 75)
	lbl3:SetFont("BebasNeue3")
	if !ply:IsValid() then
		lbl3:SetFirstColor(index[-1][1])
		lbl3:SetSecondColor(index[-1][2] )
		lbl3:SetText(index[-1][3])
	else
		lbl3:SetFirstColor(index[role][1])
		lbl3:SetSecondColor(index[role][2] )
		lbl3:SetText(index[role][3])
	end
	lbl3:SetVisible(true)
	
	if ply:IsPlayer() then
		Msg("You were killed by " .. ply:Nick() .. ", he was a " .. index[role][3]:upper() .. ".\n")
	else
		Msg("You were killed by the world.\n")
	end
	
end

hook.Add("Think", "RemoveBadge", function()
	if DMSGBadge then
		if CurTime() >= DMSGBadge.RemoveOn then
			DMSGBadge:Remove()
			DMSGBadge = nil
		end
	end
end)

net.Receive("DMSG.NetMessage", function()
	if DMSGBadge and DMSGBadge:IsValid() then
		DMSGBadge:Remove()
	end	
	MakeDMSG(net.ReadEntity(), net.ReadInt(8), net.ReadInt(8), net.ReadInt(16)) 
end)

end
	
