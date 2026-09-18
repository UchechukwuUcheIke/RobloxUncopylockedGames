local Players = game:GetService("Players");
local BadgeService = game:GetService("BadgeService");
local ServerStorage = game:GetService("ServerStorage");
local InsertService = game:GetService("InsertService");
local MarketplaceService = game:GetService("MarketplaceService");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local ProfileStore = ProfileManager:GetProfileStore();
local remoteCooldowns = {};
local playerIDCache = {};
local playerNameCache = {};
local CommonFunctions = {};

function CommonFunctions:GetDaysBetweenTimes(time1, time2)
	return math.ceil(math.abs(time1 - time2)/86400)
end

function CommonFunctions:GetDateFromTime(time1)
	local date = os.date("!*t", time1);
	local formatter = "%02i";
	return formatter:format(date.month).."/"..formatter:format(date.day).."/"..date.year.." | "..formatter:format(date.hour)..":"..formatter:format(date.min)..":"..formatter:format(date.sec).." UTC"
end

function CommonFunctions:GetPlayerInGameWithPlayerID(playerID)
	for _, player in pairs(Players:GetPlayers()) do
		if player.UserId == playerID then
			return player;
		end
	end
end

function CommonFunctions:GetPlayerIDFromPlayerName(playerName)
	if playerIDCache[playerName] then
		return playerIDCache[playerName]
	end
	
	local userID;
	local success, err = pcall(function()
		userID = Players:GetUserIdFromNameAsync(playerName);
	end)
	
	if success then
		playerIDCache[playerName] = userID;
		return userID;
	end
end

function CommonFunctions:GetPlayerNameFromPlayerID(playerID)
	if playerNameCache[playerID] then
		return playerNameCache[playerID]
	end

	local username;
	local success, err = pcall(function()
		username = Players:GetNameFromUserIdAsync(playerID);
	end)

	if success then
		playerNameCache[playerID] = username;
		return username;
	end
end

function CommonFunctions:CheckGamepassOwnership(userID, gamepassID)
	local hasPass = false;
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(userID, gamepassID);
	end)

	if not success then
		warn("Error while checking if player has gamepass: "..message);
	end
	return hasPass;
end

function CommonFunctions:CheckBadgeOwnership(userID, badgeID)
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(userID, badgeID);
	end)
	
	if not success then
		warn("Error while checking player badge ownership: "..hasBadge);
		return true;
	end
	return hasBadge;
end

function CommonFunctions:AwardBadge(player, badgeID, publicServerOnly)
	if not publicServerOnly or (publicServerOnly and game.PrivateServerOwnerId == 0) then
		local success, message = pcall(function()
			BadgeService:AwardBadge(player.UserId, badgeID);
		end)
		
		if not success then
			warn("Error while rewarding player badge: "..message);
			return message
		end
		return true
	end
end

function CommonFunctions:FindToolOnPlayer(player, toolName)
	if player.Character then
		if player.Character:FindFirstChild(toolName) and player.Character:FindFirstChild("Humanoid") then
			return player.Character[toolName];
		end

		if player.Backpack:FindFirstChild(toolName) then
			return player.Backpack[toolName];
		end

		if player.StarterGear:FindFirstChild(toolName) then
			return player.StarterGear[toolName];
		end
	end
end

function CommonFunctions:GiveToolToPlayer(player, toolName, permanent)
	if ServerStorage.Tools:FindFirstChild(toolName) then
		ServerStorage.Tools[toolName]:Clone().Parent = player.Backpack;
		if permanent and not player.StarterGear:FindFirstChild(toolName) then
			ServerStorage.Tools[toolName]:Clone().Parent = player.StarterGear;
		end
	end
end

function CommonFunctions:TakeToolFromPlayer(player, toolName, removePermanency)
	if player.Character and player.Character:FindFirstChild(toolName) and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid:UnequipTools();
		player.Backpack:WaitForChild(toolName):Destroy();
	end
	
	if player.Backpack:FindFirstChild(toolName) then
		player.Backpack[toolName]:Destroy();
	end
	
	if removePermanency and player.StarterGear:FindFirstChild(toolName) then
		player.StarterGear[toolName]:Destroy();
	end
end

function CommonFunctions:ClearPlayerStarterGear(player)
	for each, thing in pairs(player.StarterGear:GetChildren()) do
		if thing:IsA("Tool") then
			thing:Destroy();
		end
	end
end

function CommonFunctions:CheckPlayerRemoteSafety(player, input, types)
	if player:IsDescendantOf(Players) and input == input then
		if typeof(types) == "table" then
			for each, _type in pairs(types) do
				if typeof(input) == _type then
					return true;
				end
			end
		elseif typeof(input) == types then
			return true;
		end
	end
end

function CommonFunctions:CheckPlayerRemoteCooldown(player, cooldownType, cooldownTime)
	if not remoteCooldowns[player] then
		remoteCooldowns[player] = {};
	end

	if not remoteCooldowns[player][cooldownType] then
		remoteCooldowns[player][cooldownType] = os.time();
		return true;
	elseif os.time() - remoteCooldowns[player][cooldownType] >= cooldownTime then
		remoteCooldowns[player][cooldownType] = os.time();
		return true;
	end
end

-- require(game.ServerStorage.Modules.CommonFunctions):DeleteAllPlayerData(42921866)
-- CAN ONLY BE USED IN GAME
function CommonFunctions:DeleteAllPlayerData(playerID)
	print("CommonFunctions: Wiping player data(s), please wait...");
	
	if typeof(playerID) == "number" then
		ProfileStore:WipeProfileAsync(tostring(playerID));
	elseif typeof(playerID) == "table" then
		for each, ID in pairs(playerID) do
			ProfileStore:WipeProfileAsync(tostring(ID));
			task.wait();
		end
	end
	
	print("CommonFunctions: Done wiping player data(s)!");
end

function CommonFunctions:ReplaceAsset(assetID, location, replace)
	local model = InsertService:LoadAsset(assetID);
	for each, thing in pairs(model:GetChildren()) do
		if location:FindFirstChild(thing.Name) and replace then
			location[thing.Name]:Destroy();
		end
		thing.Parent = location;
	end
	model:Destroy();
end

return CommonFunctions;