local timerPanel = vgui.Create( "DPanel" )
timerPanel:SetSize( 200, 100 )
timerPanel:SetPos( 0, 400 )
timerPanel:SetPaintBackground( true )
timerPanel:SetBackgroundColor( Color( 255, 255, 255, 255 ) )
timerPanel:SetVisible( true )

local timerStatus = vgui.Create( "DLabel", timerPanel )
timerStatus:SetText( "TIME LEFT: N/A" )
timerStatus:SetPos( 0, 0 )
timerStatus:SizeToContents()
timerStatus:SetTextColor( Color(0,0,0) )

hook.Add("Think", "timerUpdate", function()
	if IsValid(timerStatus) then
		timerStatus:SetText( "TIME LEFT: " .. GetGlobal2Int("server_time") )
	end
end)