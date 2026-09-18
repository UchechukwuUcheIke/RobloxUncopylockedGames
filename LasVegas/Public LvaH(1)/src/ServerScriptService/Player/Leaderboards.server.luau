local Players = game:GetService("Players");
local DataStoreService = game:GetService("DataStoreService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local ServerStorage = game:GetService("ServerStorage");
local GroupService = game:GetService("GroupService");
local CashOrderedStore = DataStoreService:GetOrderedDataStore("Cash");
local PlaytimeOrderedStore = DataStoreService:GetOrderedDataStore("Playtime");
local CreditsOrderedStore = DataStoreService:GetOrderedDataStore("Credits");
local TicketsOrderedStore = DataStoreService:GetOrderedDataStore("Tickets");
local TournamentsOrderedStore = DataStoreService:GetOrderedDataStore("Tournaments2");
local BetterChat = ServerScriptService:WaitForChild("BetterChat V3");
local ServerModules = ServerStorage:WaitForChild("Modules");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local ProfileManager = require(ServerModules.ProfileService.PlayerData.ProfileManager);
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local GameDataModule = require(ReplicatedModules:WaitForChild("GameData"));
local NPCs = require(ServerModules:WaitForChild("NPCs"));
local BetterChatConfig = require(BetterChat:WaitForChild("Config"));
local Leaderboards = workspace.Map.Leaderboards;
local GlobalPlayerData = {}; --[userId] = {playerName, playerHeadshot, playerHasGoldClub}
local ProfileStore = ProfileManager:GetProfileStore();

local function getPlaceFromRank(rank)
	local str = tostring(rank);
	local var = "th"
	
	if #str == 2 then
		if rank > 20 then
			local sec = string.sub(str,2,2)
			if sec == "1" then
				var = "st"
			elseif sec == "2" then
				var = "nd"
			elseif sec == "3" then
				var = "rd"
			end
		end
	else
		if str == "1" then
			var = "st"
		elseif str == "2" then
			var = "nd"
		elseif str == "3" then
			var = "rd"
		end
	end
	
	return str..var
end

local function getNameFromUserId(userID)
	local success, username = pcall(function()
		return Players:GetNameFromUserIdAsync(userID);
	end)
	if success then
		return username;
	end
	return "[UNKNOWN]";
end

local function getPictureFromUserId(userID)
	local success, thumbnail = pcall(function()
		return Players:GetUserThumbnailAsync(userID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
	end)
	if success then
		return thumbnail;
	end
	return "rbxassetid://113252732";
end

local function getPlayerProfile(userID)
	local profile = ProfileStore:ViewProfileAsync(tostring(userID));
	if profile then
		return profile.Data.OwnsGoldClub, profile.Data.Moderations.IsPermBanned;
	end
end

local function getPlayerData(userID)
	if userID then
		if not GlobalPlayerData[userID] then
			local ownsGoldClub, isPermBanned = getPlayerProfile(userID);
			GlobalPlayerData[userID] = {
				getNameFromUserId(userID), 
				getPictureFromUserId(userID),
				ownsGoldClub,
				isPermBanned,
				userID
			}
		end
		return GlobalPlayerData[userID];
	end
end

local function getGroupRankFromUserId(userId, groupId)
	local success, rank = pcall(function()
		local UserGroups = GroupService:GetGroupsAsync(userId);
		for _,v in ipairs(UserGroups) do
			if v.Id == groupId then
				return v.Rank 
			end
		end
	end)

	if success then
		return rank;
	end
	warn("Failed to check rank for UserID:", userId, " issue: "..rank);
end

local function getPlayerRoleColor(userID)
	local groupRank = getGroupRankFromUserId(userID, ReplicatedStorage:GetAttribute("GroupID"));
	local groupRole = BetterChatConfig.Permissions.Groups[ReplicatedStorage:GetAttribute("GroupID")][groupRank];
	local chatRank = 1;
	for rank, role in pairs(BetterChatConfig.Permissions.Ranks) do
		if role == groupRole then
			chatRank = rank;
			break;
		end
	end
	return BetterChatConfig.ChatTags.Ranks[chatRank][1]["Color"];
end

local function updateLeaderboard(board, topFifty, boardName)
	local scrollingFrame = board.Leaderboard.Backing.ScrollingFrame;
	
	for rank, data in pairs(topFifty) do
		local playerData = getPlayerData(data.key);
		if data.value and data.value > 0 and playerData then
			if not playerData[4] then
				local template = scrollingFrame.UIGridLayout.Player:Clone();
				template.Name = playerData[1];
				template.Username.Text = playerData[1];
				template.Headshot.Image = playerData[2];
				template.Currency.Text = boardName == "Cash" and "$"..GameDataModule:AddCommasToNumber(data.value) or GameDataModule:AddCommasToNumber(data.value);
				template.Place.Text = getPlaceFromRank(rank);
				template.Username.TextColor3 = getPlayerRoleColor(playerData[5]);
				template.Parent = board.Leaderboard.Backing.ScrollingFrame;
				NPCs:AddPlayerToAllNPCs(playerData[1]);
			else
				print("Wiping cash and playtime for permanently banned player: "..playerData[1].."");
				local profile = ProfileStore:LoadProfileAsync(tostring(playerData[5]));
				if profile then
					profile.Data.Cash = 0;
					profile.Data.Playtime = 0;
					profile:Release();
				else
					warn("Failed to wipe cash and playtime due to no profile: "..playerData[1].."");
				end
			end
		end
	end
	
	local totalSlots = #scrollingFrame:GetChildren() - 1;
	local slotSize = scrollingFrame.UIGridLayout.CellSize.Y.Offset + scrollingFrame.UIGridLayout.CellPadding.Y.Offset;
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalSlots * slotSize);
end

local function saveData(player, profile, saveType)
	local Attempts = 1 -- Attempt Counter
	local Success, Error -- do not mess with these, this is so we can access the pcall within the loop
	
	repeat
		if saveType == "Cash" then
			Success, Error = pcall(CashOrderedStore.SetAsync, CashOrderedStore, player.UserId, math.floor(profile.Data.Cash)) -- this is apparently the "better" way
		elseif saveType == "Playtime" then
			Success, Error = pcall(PlaytimeOrderedStore.SetAsync, PlaytimeOrderedStore, player.UserId, math.floor(profile.Data.Playtime)) -- this is apparently the "better" way
		elseif saveType == "Tickets" then
			Success, Error = pcall(TicketsOrderedStore.SetAsync, TicketsOrderedStore, player.UserId, math.floor(profile.Data.Tickets)) -- this is apparently the "better" way
		elseif saveType == "Credits" then
			Success, Error = pcall(CreditsOrderedStore.SetAsync, CreditsOrderedStore, player.UserId, math.floor(profile.Data.Credits)) -- this is apparently the "better" way
		elseif saveType == "Tournaments" then
			Success, Error = pcall(TournamentsOrderedStore.SetAsync, TournamentsOrderedStore, player.UserId, math.floor(profile.Data.TournamentWins)) -- this is apparently the "better" way
		end
		
		Attempts += 1 -- Adds Attempt
		if not Success then task.wait(10) end -- if failed, waits to try again (firing very fast can cause a queue)
	until Success or Attempts > 3 -- Conditions to Break upon

	if not Success then
		warn("Failed to Save Data: '" .. Error .. "'")	
	end
end

local function getData(saveType)
	local Attempts = 1 -- Attempt Counter
	local Success, Error -- do not mess with these, this is so we can access the pcall within the loop
	local Data;

	repeat
		if saveType == "Cash" then
			Success, Error = pcall(function()
				Data = CashOrderedStore:GetSortedAsync(false, 50);
			end)
		elseif saveType == "Playtime" then
			Success, Error = pcall(function()
				Data = PlaytimeOrderedStore:GetSortedAsync(false, 50);
			end)
		elseif saveType == "Tickets" then
			Success, Error = pcall(function()
				Data = TicketsOrderedStore:GetSortedAsync(false, 50);
			end)
		elseif saveType == "Credits" then
			Success, Error = pcall(function()
				Data = CreditsOrderedStore:GetSortedAsync(false, 50);
			end)
		elseif saveType == "Tournaments" then
			Success, Error = pcall(function()
				Data = TournamentsOrderedStore:GetSortedAsync(false, 50);
			end)
		end

		Attempts += 1 -- Adds Attempt
		if not Success then task.wait(5) end -- if failed, waits to try again (firing very fast can cause a queue)
	until Success or Attempts > 3 -- Conditions to Break upon

	if Success then
		return Data;
	else
		warn("Failed to Load Data: '" .. Error .. "'")	
	end
end

local function initialize()
	while true do
		local cashStore = getData("Cash");
		local playtimeStore = getData("Playtime");
		local ticketStore = getData("Tickets");
		local creditStore = getData("Credits");
		local tournamentStore = getData("Tournaments");
		local cashTopFifty;
		local playtimeTopFifty;
		local ticketTopFifty;
		local creditTopFifty;
		local tournamentTopFifty;
		
		if cashStore then
			cashTopFifty = cashStore:GetCurrentPage();
		end
		if playtimeStore then
			playtimeTopFifty = playtimeStore:GetCurrentPage();
		end
		if ticketStore then
			ticketTopFifty = ticketStore:GetCurrentPage();
		end
		if creditStore then
			creditTopFifty = creditStore:GetCurrentPage();
		end
		if tournamentStore then
			tournamentTopFifty = tournamentStore:GetCurrentPage();
		end
		
		for each, board in pairs(Leaderboards:GetChildren()) do
			for each, slot in pairs(board.Leaderboard.Backing.ScrollingFrame:GetChildren()) do
				if slot:IsA("Frame") then
					slot:Destroy();
				end
			end
			
			if board.Name == "Cash" and cashTopFifty then
				updateLeaderboard(board, cashTopFifty, board.Name);
			elseif board.Name == "Playtime" and playtimeTopFifty then
				updateLeaderboard(board, playtimeTopFifty, board.Name);
			elseif board.Name == "Tickets" and ticketTopFifty then
				updateLeaderboard(board, ticketTopFifty, board.Name);
			elseif board.Name == "Credits" and creditTopFifty then
				updateLeaderboard(board, creditTopFifty, board.Name);
			elseif board.Name == "Tournament" and tournamentTopFifty then
				updateLeaderboard(board, tournamentTopFifty, board.Name);
			end
		end
		
		for each, player in pairs(Players:GetPlayers()) do
			local profile = ProfileManager.Profiles[player];
			if profile then
				saveData(player, profile, "Cash");
				saveData(player, profile, "Playtime");
				saveData(player, profile, "Tickets");
				saveData(player, profile, "Credits");
				saveData(player, profile, "Tournaments");
			end
		end
		
		task.wait(60 * 5);
	end
end
initialize();