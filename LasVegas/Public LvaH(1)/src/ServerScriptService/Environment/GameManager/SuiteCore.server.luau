local ServerScriptService = game:GetService("ServerScriptService");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local suite = script.Parent;
local remotes = suite.Remotes;
local functional = suite.Functional
local decoration = suite.Decoration;
local placeables = suite.Placeables;

local overlapParams = OverlapParams.new();
overlapParams.FilterType = Enum.RaycastFilterType.Exclude;
overlapParams.FilterDescendantsInstances = {workspace.Games, workspace.Map, workspace.Suites};
local whitelistNames = {};

local function getTimeRemaining(secondsLeft)
	local hours = math.floor(secondsLeft / 3600);
	local remainingSeconds = secondsLeft % 3600;
	local minutes = math.floor(remainingSeconds / 60);
	remainingSeconds = remainingSeconds % 60;
	return hours, minutes, remainingSeconds;
end

suite:GetAttributeChangedSignal("Color_Wall"):Connect(function()
	for each, part in pairs(decoration:GetChildren()) do
		if part.Name == "Wall" then
			part.Color = suite:GetAttribute("Color_Wall");
		end
	end
end)
suite:GetAttributeChangedSignal("Color_Roof"):Connect(function()
	for each, part in pairs(decoration:GetChildren()) do
		if part.Name == "Roof" then
			part.Color = suite:GetAttribute("Color_Roof");
		end
	end
end)
suite:GetAttributeChangedSignal("DoorOpen"):Connect(function()
	functional.Door.Transparency = suite:GetAttribute("DoorOpen") and 1 or 0;
	functional.Door.CanCollide = not suite:GetAttribute("DoorOpen");
end)
suite:GetAttributeChangedSignal("WindowOpen"):Connect(function()
	for each, part in pairs(functional:GetChildren()) do
		if part.Name == "Curtain" then
			part.Transparency = suite:GetAttribute("WindowOpen") and 1 or 0;
			part.CanCollide = not suite:GetAttribute("WindowOpen");
		elseif part.Name == "CurtainTop" then
			part.Transparency = suite:GetAttribute("WindowOpen") and 0 or 1;
			part.CanCollide = suite:GetAttribute("WindowOpen");
		end
	end
end)
suite:GetAttributeChangedSignal("OwnerName"):Connect(function()
	functional.Purchase.SurfaceGui.Enabled = suite:GetAttribute("OwnerName") == "";
	functional.UserDisplay.SurfaceGui.OwnerName.Text = suite:GetAttribute("OwnerName");
	functional.TimeDisplay.SurfaceGui.TimeLeft.Text = "";

	if suite:GetAttribute("OwnerName") ~= "" then
		whitelistNames = {suite:GetAttribute("OwnerName")};
	else
		whitelistNames = {};
		suite:SetAttribute("Color_Wall", Color3.fromRGB(107, 79, 79));
		suite:SetAttribute("Color_Roof", Color3.fromRGB(53, 28, 28));
		suite:SetAttribute("DoorOpen", false);
		suite:SetAttribute("WindowOpen", true);
	end

	while suite:GetAttribute("OwnerName") ~= "" do
		local player = Players:FindFirstChild(suite:GetAttribute("OwnerName"));
		if player then 
			local profile = ProfileManager.Profiles[player];
			if profile then
				local hoursLeft, minutesLeft, secondsLeft = getTimeRemaining(profile.Data.Suite.SecondsRemaining);
				local hourString = hoursLeft == 1 and hoursLeft.." hour" or hoursLeft.." hours";
				local minuteString = minutesLeft == 1 and minutesLeft.." minute" or minutesLeft.." minutes";
				local secondString = secondsLeft == 1 and secondsLeft.." second" or secondsLeft.." seconds";
				functional.TimeDisplay.SurfaceGui.TimeLeft.Text = "Remaining - "..hourString..", "..minuteString..", "..secondString;
			end
		end

		task.wait(1);
	end
end)

remotes.Purchase.OnServerEvent:Connect(function(player, currency)
	if suite:GetAttribute("CanPurchase") and suite:GetAttribute("OwnerName") == "" and suite:GetAttribute("PendingOwnerName") == "" then
		local alreadyOwner = false;
		
		for each, suite in pairs(suite.Parent:GetChildren()) do
			if suite:GetAttribute("OwnerName") == player.Name or suite:GetAttribute("PendingOwnerName") == player.Name then
				alreadyOwner = true;
			end
		end
		
		if not alreadyOwner then
			local profile = ProfileManager.Profiles[player];
			if profile then
				if profile.Data.Suite.SecondsRemaining > 0 then
					suite:SetAttribute("PendingOwnerName", player.Name);
					ServerScriptService.Player.ProductProcess.PurchaseSuite:Fire(player, false, true);
				elseif currency == "Cash" then
					suite:SetAttribute("PendingOwnerName", player.Name);
					ServerScriptService.Player.ProductProcess.PurchaseSuite:Fire(player, true, false);
				end
			end
		end
	end
end)
remotes.Action.OnServerInvoke = function(player, action, data)
	if suite:GetAttribute("OwnerName") == player.Name then
		if action == "Door" then
			suite:SetAttribute("DoorOpen", not suite:GetAttribute("DoorOpen"));
			return suite:GetAttribute("DoorOpen");
		elseif action == "Windows" then
			suite:SetAttribute("WindowOpen", not suite:GetAttribute("WindowOpen"));
			return suite:GetAttribute("WindowOpen");
		elseif action == "AddWhitelist" then
			local foundPlayer = Players:FindFirstChild(data[1]);
			if foundPlayer and player ~= foundPlayer then
				if not table.find(whitelistNames, foundPlayer.Name) then
					table.insert(whitelistNames, foundPlayer.Name);
				end
				return true;
			end
		elseif action == "RemoveWhitelist" then
			if data[1] ~= player.Name then
				local index = table.find(whitelistNames, data[1]);
				if index then
					table.remove(whitelistNames, index);
				end
				return true;
			end
		elseif action == "RoofCustomColor" then
			local red = math.clamp(math.floor(data[1]), 25, 100);
			local green = math.clamp(math.floor(data[2]), 25, 100);
			local blue = math.clamp(math.floor(data[3]), 25, 100);
			suite:SetAttribute("Color_Roof", Color3.fromRGB(red, green, blue));
			return true;
		elseif action == "WallCustomColor" then
			local red = math.clamp(math.floor(data[1]), 25, 100);
			local green = math.clamp(math.floor(data[2]), 25, 100);
			local blue = math.clamp(math.floor(data[3]), 25, 100);
			suite:SetAttribute("Color_Wall", Color3.fromRGB(red, green, blue));
			return true;
		elseif action == "WallColor" then
			suite:SetAttribute("Color_Wall", data[1]);
			return true;
		elseif action == "RoofColor" then
			suite:SetAttribute("Color_Roof", data[1]);
			return true;
		elseif action == "Revoke" then
			suite:SetAttribute("OwnerName", "");
			suite.Remotes.Purchase:FireClient(player, "expired");
		end
	end
end

coroutine.wrap(function()
	while true do
		local characterPartsInArea = workspace:GetPartsInPart(functional.SuiteArea, overlapParams);
		local checkedCharacterParts = {};

		if characterPartsInArea then
			for each, part in pairs(characterPartsInArea) do
				if not table.find(checkedCharacterParts, part) then
					local character = part.Parent;
					for each, characterPart in pairs(character:GetChildren()) do
						if table.find(characterPartsInArea, characterPart) then
							table.insert(checkedCharacterParts, characterPart);
						end
					end

					local player = Players:GetPlayerFromCharacter(character);
					if player and not table.find(whitelistNames, player.Name) then
						if character.Humanoid.Sit then
							character.Humanoid.Jump = true;
						end
						character:SetPrimaryPartCFrame(functional.Teleport.CFrame);
					end
				end
			end
		end

		wait(3);
	end
end)()

--[[if not game:GetService("RunService"):IsStudio() then
	suite:SetAttribute("CanPurchase", false);
end--]]