local Players = game:GetService("Players");

script.Parent.Touched:Connect(function(hit)
	local character = hit.Parent;
	local humanoid = character:FindFirstChild("Humanoid");
	if humanoid and not character:GetAttribute("TeleportCooldown") then
		character:SetAttribute("TeleportCooldown", true);
		
		local player = Players:FindFirstChild(character.Name);
		if not player:GetAttribute("ObbyCount") then
			player:SetAttribute("ObbyCount", 1);
		else
			player:SetAttribute("ObbyCount", player:GetAttribute("ObbyCount") + 1);
		end
		
		character.Head.RankGui.Obby.Text = player:GetAttribute("ObbyCount");
		character:SetPrimaryPartCFrame(script.Parent.Parent.Start.CFrame * CFrame.new(0, 5, 0));
		
		task.wait(0.5);
		character:SetAttribute("TeleportCooldown", false);
	end
end)