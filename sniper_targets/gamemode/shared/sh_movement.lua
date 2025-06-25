hook.Add("SetupMove", "DisableMovement", function(ply, mvd, cmd)
	cmd:ClearMovement()
	cmd:ClearButtons()
end)

--function GM:Move( ply, mv )
--	return true
--end