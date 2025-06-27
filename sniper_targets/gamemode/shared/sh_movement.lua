hook.Add("SetupMove", "DisableMovement", function(ply, mv, cmd)
	if not ply:IsOnGround() then return end
	local blockedButtons = IN_JUMP + IN_DUCK
	cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(blockedButtons)))
	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
	
	--print("movement blocked")
end)

hook.Add("StartCommand", "DisableMovement", function(ply, cmd)
	if ( ply:IsBot() or !ply:Alive() ) then return end
    -- Define which buttons to block (e.g., movement, jump, duck)
    local blocked = IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT + IN_JUMP + IN_DUCK

    -- Remove those keys from the current command
    cmd:RemoveKey(blocked)
end)