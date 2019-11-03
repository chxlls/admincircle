AddCSLuaFile()

net.Receive( "SendRankData", function()
ccontable = net.ReadTable()
end)

net.Receive( "SendWeaponData", function()
wweapon = net.ReadString()
end)

hook.Add( "PrePlayerDraw", "AdminCircle", function( ply )
if ( !ply:Alive()) then return end
if ( !ply:IsValid()) then return end
if ( ply:InVehicle()) then return end
if ccontable[ply:GetUserGroup()] == nil then return end
if not (ply:HasWeapon(wweapon) and ply:GetActiveWeapon():GetClass() == (wweapon)) then return end
local plyradius = ccontable[ply:GetUserGroup()].radius
local rainbowcol = ccontable[ply:GetUserGroup()].rainbow and HSVToColor(CurTime() % 6 * 60, 1, 1) or team.GetColor( ply:Team() )
local colour = rainbowcol
local plypulse = ccontable[ply:GetUserGroup()].pulse and math.sin(CurTime() * 3) * 10 or 0
local radius = ply:GetModelScale() * plyradius + plypulse

local CircleMat = Material( "sgm/playercircle" )
local trace = {}
trace.start = ply:GetPos() + Vector(0,0,51)
trace.endpos = trace.start + Vector(0,0,-130)
trace.filter = ply
local tr = util.TraceLine( trace )
if !tr.HitWorld then
  tr.HitPos = ply:GetPos()
end
render.SetMaterial( CircleMat )
render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, radius, radius, colour )

end )