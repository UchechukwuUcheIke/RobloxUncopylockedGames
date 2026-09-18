--[[
	This script respawns the player at their checkpoint when they touch the lava.
--]]
script.Parent.Touched:connect(function(hit) --Activates whenever something touches the lava
	if hit.Parent:FindFirstChild("Humanoid") then --Check if it was a player who touched the lava
		hit.Parent.Humanoid.Health = 0
	end
	wait() --This prevent lags
end)