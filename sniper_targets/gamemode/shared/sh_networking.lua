util.AddNetworkString( "ServerMessage" )

if ( CLIENT ) then

local function onServerMessage()
	local ply = net.ReadEntity()
	if not ply:IsValid() then return end
	local text = net.ReadString()
	chat.AddText( ply, color_white, "[Server] ", text )
end
net.Receive( "ServerMessage", onServerMessage)

end