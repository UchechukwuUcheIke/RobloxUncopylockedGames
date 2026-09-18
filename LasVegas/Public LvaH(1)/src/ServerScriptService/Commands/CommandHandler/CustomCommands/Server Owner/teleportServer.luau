return function (context, players, targetPlayer)
	local targetCharacter = targetPlayer.Character;
	local targetPart = targetCharacter:FindFirstChild("HumanoidRootPart");
	
	if targetPart then
		for _, player in pairs(players) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = targetPart.CFrame;
			end
		end
		
		return "Teleported all players with a character model to "..targetPlayer.Name..".";
	end
	
	return "Unable to teleport to "..targetPlayer.Name.." because they have no character model.";
end