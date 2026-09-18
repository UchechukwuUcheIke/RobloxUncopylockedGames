local player = game.Players.LocalPlayer
local tool = script.Parent
local settings = require(tool:WaitForChild("Settings"))

tool.Equipped:connect(function(mouse)
	mouse.Move:connect(function()
		mouse.Icon = "http://www.roblox.com/asset/?id="..settings.cursorneutral
		local hit = mouse.Target
		if hit then
			local human = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
			if human then
				local torso = human.Parent:FindFirstChild("Torso")
				if torso and human.Health > 0 then
					local target = game.Players:FindFirstChild(human.Parent.Name)
					if target then
						if game.Players:FindFirstChild(human.Parent.Name).TeamColor == player.TeamColor then
							mouse.Icon = "http://www.roblox.com/asset/?id="..settings.cursorfriendly
						else
							mouse.Icon = "http://www.roblox.com/asset/?id="..settings.cursorenemy
						end
					end
				end
			end
		end
	end)
end)

tool.Unequipped:connect(function()
	
end)