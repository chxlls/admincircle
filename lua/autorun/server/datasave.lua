util.AddNetworkString( "SendRankData" )
util.AddNetworkString( "SendWeaponData" )

local function createdir()
  local defaultval = {
    moderator = {radius = 50, rainbow = true, pulse = false},
    admin = {radius = 75, rainbow = true, pulse = false},
    superadmin = {radius = 100, rainbow = true, pulse = true},
    owner = {radius = 150, rainbow = true, pulse = true}
  }
  local defaultweapon = "admin_stick"
  if not file.IsDir("admincircle", "DATA") then
    file.CreateDir( "admincircle", "DATA" )
    print("Created directory garrysmod/data/admincircle")
  end
  if not file.Exists( "admincircle/rankvalues.txt", "DATA" ) then
    writedata(defaultval, "rankvalues", "admincircle")
    print("Created rankvalues.txt file in garrysmod/data/admincircle")
  end
  if not file.Exists( "admincircle/circleweapon.txt", "DATA" ) then
    writedata(defaultweapon, "circleweapon", "admincircle")
    print("Created circleweapon.txt file in garrysmod/data/admincircle")
  end
  contable = util.JSONToTable(file.Read("admincircle/rankvalues.txt", "DATA"))
  admincircleweapon = file.Read("admincircle/circleweapon.txt", "DATA")
  print("Admincircle data has been loaded!")
end

hook.Add( "PlayerInitialSpawn", "updatetbls", function()
if not file.Exists( "admincircle/rankvalues.txt", "DATA" ) then print("admincircle/rankvalues.txt does not exist. Restart the server to fix this issue.") return end
if not file.Exists( "admincircle/circleweapon.txt", "DATA" ) then return print("admincircle/circleweapon.txt does not exist. Restart the server to fix this issue.") end
sendtbl(contable)
sendwpn(admincircleweapon)
end)

function sendwpn(wpn)
  net.Start( "SendWeaponData" )
  net.WriteString( wpn )
  net.Broadcast()
end

function writedata(tbl, filename, filepath)
  local data = type(tbl) == "table" and util.TableToJSON( tbl ) or tostring(tbl)
  file.Write( filepath .. "/" .. filename .. ".txt", data )
end

function sendtbl(tbl)
  net.Start( "SendRankData" )
  net.WriteTable( tbl )
  net.Broadcast()
end

function refreshcircle(ply)
  writedata(contable, "rankvalues", "admincircle")
  admincircleweapon = file.Read("admincircle/circleweapon.txt", "DATA")
  sendtbl(tbl)
  sendwpn(admincircleweapon)
  ply:PrintMessage(HUD_PRINTCONSOLE, "Everything has been refreshed!" )
end

concommand.Add("admincircle", function(ply, cmd, args)
if not ply:IsValid() then return print("Um, you aren't a player...") end
if not file.Exists( "admincircle/rankvalues.txt", "DATA" ) then return ply:PrintMessage(HUD_PRINTCONSOLE, "garrysmod/data/rankvalues.txt does not exist." ) end
if not file.Exists( "admincircle/circleweapon.txt", "DATA" ) then return ply:PrintMessage(HUD_PRINTCONSOLE, "garrysmod/data/circleweapon.txt does not exist." ) end
if ply:IsSuperAdmin() then
  local helpmsg = "Commands: \nadmincircle add [rank] [radius] [rainbow (true or false)] [pulse (true or false)] \nadmincircle remove [rank] \nadmincircle weapon [classname] \nadmincircle reload"
  if args[1] == nil then return ply:PrintMessage(HUD_PRINTCONSOLE, helpmsg ) end
  local arg1 = string.Trim(args[1])
  if arg1 == "add" then
    if #args >5 or #args <5 then return ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguements. Use admincircle add [rank] [radius] [rainbow (bool)] [pulse (bool)]") end
    local arg2 = string.Trim(args[2])
    local arg3 = tonumber(string.Trim(args[3]))
    local arg4 = tobool(string.Trim(args[4]))
    local arg5 = tobool(string.Trim(args[5]))
    if arg3 == nil then return ply:PrintMessage(HUD_PRINTCONSOLE, "Argument 3 must be a number" ) end
    if arg4 == nil  then return ply:PrintMessage(HUD_PRINTCONSOLE, "Argument 4 must be a boolean (true or false)" ) end
    if arg5 == nil  then return ply:PrintMessage(HUD_PRINTCONSOLE, "Argument 5 must be a boolean (true or false)" ) end
    addranks(arg2,arg3,arg4,arg5,ply)
  else
    if arg1 == "remove" then
      if #args >2 or #args <2 then return ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguements. Use admincircle remove [rank]" ) end
      local arg2 = string.Trim(args[2])
      removeranks(arg2, ply)
    else
      if arg1 == "weapon" then
        if #args >2 or #args <2 then return ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguements. Use admincircle weapon [classname]" ) end
        local arg2 = string.Trim(args[2])
        updateweapon(arg2)
      else
        if arg1 == "reload" then
          if #args >1 or #args <1 then return ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguements. Use admincircle reload" ) end
          refreshcircle(ply)
        else
          ply:PrintMessage(HUD_PRINTCONSOLE, helpmsg )
        end
      end
    end
  end
end
end)

function removeranks(rank, pPlayer)
  if contable[tostring(rank)] == nil then return pPlayer:PrintMessage(HUD_PRINTCONSOLE, rank .. " does not exist!" ) end
  contable[tostring(rank)] = nil
  writedata(contable, "rankvalues", "admincircle")
  sendtbl(contable)
  pPlayer:PrintMessage(HUD_PRINTCONSOLE, rank .. " has been removed!" )
end

function updateweapon(wpn)
  writedata(wpn, "circleweapon", "admincircle")
  sendwpn(wpn)
end

function addranks(rank, cirad, rain, cpulse, pPlayer)
  local newvalues = {
    [rank] = {radius = cirad, rainbow = rain, pulse = cpulse}
  }
  table.Merge( contable, newvalues )
  writedata(contable, "rankvalues", "admincircle")
  sendtbl(contable)
  pPlayer:PrintMessage(HUD_PRINTCONSOLE, rank .. " has been added with a radius of " .. cirad .. ", rainbow = " .. tostring(rain) .. " and pulse = " .. tostring(cpulse) )
end


hook.Add("Initialize", "createdir", createdir)