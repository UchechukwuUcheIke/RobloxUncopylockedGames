local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, gameName)
	local gameFolder = false;
	for each, folder in pairs(workspace.Games.Slots:GetChildren()) do
		if folder.Name == gameName then
			gameFolder = folder;
			break;
		end
	end
	if not gameFolder then
		for each, folder in pairs(workspace.Games.Tables:GetChildren()) do
			if folder.Name == gameName then
				gameFolder = folder;
				break;
			end
		end
	end
	
	if gameFolder then
		local character = context.Executor.Character;
		local head = character and character:FindFirstChild("Head");
		if head then
			local closestDistance;
			local closestGame;
			for each, casinoGame in pairs(gameFolder:GetChildren()) do
				local cframe, vector3 = casinoGame:GetBoundingBox();
				local distance = (head.Position - cframe.Position).Magnitude;
				if not closestDistance or distance < closestDistance then
					closestDistance = distance;
					closestGame = casinoGame;
				end
			end
			if closestGame then
				context:Reply("----- Attributes for "..gameName.." -----");
				
				context:Reply(" ");
				for name, value in closestGame:GetAttributes() do
					context:Reply(name..": "..tostring(value));
				end
				
				context:Reply(" ");
				return "End of attributes for "..gameName..".";
			end
			return "Unable to view attributes, closest game for "..gameName.." doesn't exist."
		end
		return "Unable to view attributes, head/character for "..context.Executor.Name.." doesn't exist."
	end
	return "Unable to view attributes, game "..gameName.." doesn't exist."
end