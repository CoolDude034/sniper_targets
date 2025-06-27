if ( SERVER ) then -- SERVER REALM
	util.AddNetworkString( "ServerMessage" )
end

if ( CLIENT ) then -- CLIENT REALM

	local function onServerMessage()
		local ply = net.ReadEntity()
		if not ply:IsValid() then return end
		local text = net.ReadString()
		chat.AddText( ply, color_white, "[Server] ", text )
	end
	net.Receive( "ServerMessage", onServerMessage)

end