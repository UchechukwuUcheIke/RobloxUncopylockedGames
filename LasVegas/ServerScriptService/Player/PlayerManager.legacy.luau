local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local GroupService = game:GetService("GroupService");
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local ProfileService = require(ServerStorage.Modules.ProfileService);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Template = require(ServerStorage.Modules.ProfileService.PlayerData.Template);
local RankGun = require(ServerStorage.Modules.RankGun);
local BetterChatConfig = require(script.Parent.Parent["BetterChat V3"].Config);
local RankGunBot = RankGun.Bot.new("", 8974);
local ProfileStore = ProfileManager:GetProfileStore();
local Votekick = ReplicatedStorage.Remotes:WaitForChild("Votekick");
local SaveSetting = ReplicatedStorage.Remotes:WaitForChild("SaveSetting");
local FetchSetting = ReplicatedStorage.Remotes:WaitForChild("FetchSetting");
local PlayersListPlus = require(ReplicatedStorage:WaitForChild("PlayersListPlus"));
local Welcome = ReplicatedStorage.Remotes:WaitForChild("Welcome");
local ServerBan = script.ServerBan;
local serverBanned = {};
local votekicked = {};
local votekicks = {};

local function updateGamepasses(player, profile)
	if not profile.Data.OwnsGoldClub then
		profile.Data.OwnsGoldClub = CommonFunctions:CheckGamepassOwnership(player.UserId, ReplicatedStorage:GetAttribute("GoldClubPassID"));
	end
	if not profile.Data.OwnsFasterSpins then
		profile.Data.OwnsFasterSpins = CommonFunctions:CheckGamepassOwnership(player.UserId, ReplicatedStorage:GetAttribute("FasterSpinsPassID"));
	end
	if not profile.Data.OwnsDoubleSpins then
		profile.Data.OwnsDoubleSpins = CommonFunctions:CheckGamepassOwnership(player.UserId, ReplicatedStorage:GetAttribute("DoubleSpinsPassID"));
	end
	if not profile.Data.OwnsCheaperSuite then
		profile.Data.OwnsCheaperSuite = CommonFunctions:CheckGamepassOwnership(player.UserId, ReplicatedStorage:GetAttribute("CheaperSuitePassID"));
	end
end

local function givePlayerAttributes(player, profile)
	if game.PrivateServerOwnerId == 0 then
		profile.Data.Tokens = 0;
	end
	
	player:SetAttribute("Cash", profile.Data.Cash);
	player:SetAttribute("Playtime", profile.Data.Playtime);
	player:SetAttribute("Tokens", profile.Data.Tokens);
	player:SetAttribute("MinutesOnline", profile.Data.MinutesOnline);
	player:SetAttribute("OwnsGoldClub", profile.Data.OwnsGoldClub);
	player:SetAttribute("OwnsFasterSpins", profile.Data.OwnsFasterSpins);
	player:SetAttribute("OwnsDoubleSpins", profile.Data.OwnsDoubleSpins);
	player:SetAttribute("OwnsCheaperSuite", profile.Data.OwnsCheaperSuite);
	player:SetAttribute("CashRegenLevel", profile.Data.CashRegenLevel);
	player:SetAttribute("SecondsRemaining", profile.Data.Suite.SecondsRemaining);
	player:SetAttribute("OnBreak", false);
end

local function updateSuiteTimeLeft(profile)
	local secondsOffline = os.time() - profile.Data.LastOnline;
	if secondsOffline >= profile.Data.Suite.SecondsRemaining then
		profile.Data.Suite.SecondsRemaining = 0;
	else
		profile.Data.Suite.SecondsRemaining -= secondsOffline;
	end
end

local function givePlayerLeaderstats(player, profile)
	local leaderstats = Instance.new("Folder");
	leaderstats.Name = "leaderstats";
	leaderstats.Parent = player;
	local cash = Instance.new("IntValue");
	cash.Name = "Cash";
	cash.Value = profile.Data.Cash;
	cash.Parent = leaderstats;
	local playtime = Instance.new("IntValue");
	playtime.Name = "Playtime";
	playtime.Value = profile.Data.Playtime;
	playtime.Parent = leaderstats;
end

local function givePlayerListColor(player)
	local groupRank = Permissions:GetPlayerGroupRank(player);
	local groupRole = BetterChatConfig.Permissions.Groups[ReplicatedStorage:GetAttribute("GroupID")][groupRank];
	local chatRank = 1;
	for rank, role in pairs(BetterChatConfig.Permissions.Ranks) do
		if role == groupRole then
			chatRank = rank;
			break;
		end
	end
	local roleColor = BetterChatConfig.ChatTags.Ranks[chatRank][1]["Color"];
	PlayersListPlus.ChangeColorPlayer(player, roleColor or Color3.fromRGB(255, 255, 255));
end

local function giveStats(player)
	local profile = ProfileManager.Profiles[player];
	if not profile then return; end
	
	updateGamepasses(player, profile);
	updateSuiteTimeLeft(profile);
	givePlayerAttributes(player, profile);
	givePlayerLeaderstats(player, profile);
	givePlayerListColor(player);
end

local function startCurrencyClocks(player)
	coroutine.wrap(function()
		while true do
			task.wait(60);
			
			local profile = ProfileManager.Profiles[player];
			if not profile then continue; end

			ProfileManager.AdjustCurrency(player, "Playtime", 1);
			
			local playerGroupRank = Permissions:GetPlayerGroupRank(player);
			if playerGroupRank > 0 and playerGroupRank < 101 then
				if profile.Data.Playtime >= script:GetAttribute("HoursForGoldClub") * 60 then
					if profile.Data.Cash >= 15000000 then
						if playerGroupRank < 101 then
							RankGunBot:setRank(player.UserId, 101);
						end
					end
				elseif profile.Data.Playtime >= script:GetAttribute("HoursForAddict") * 60 then
					if playerGroupRank < 5 then
						RankGunBot:setRank(player.UserId, 5);
					end
				elseif profile.Data.Playtime >= script:GetAttribute("HoursForDedicated") * 60 then
					if playerGroupRank < 4 then
						RankGunBot:setRank(player.UserId, 4);
					end
				elseif profile.Data.Playtime >= script:GetAttribute("HoursForRegular") * 60 then
					if playerGroupRank < 3 then
						RankGunBot:setRank(player.UserId, 3);
					end
				end
			end
		end
	end)()
	
	coroutine.wrap(function()
		while true do
			task.wait(1);

			local profile = ProfileManager.Profiles[player];
			if not profile then continue; end
			
			if profile.Data.Suite.SecondsRemaining > 0 then
				profile.Data.Suite.SecondsRemaining -= 1;
				
				if profile.Data.Suite.SecondsRemaining == 0 then
					for each, suite in pairs(workspace.Suites:GetChildren()) do
						if suite:GetAttribute("OwnerName") == player.Name then
							suite:SetAttribute("OwnerName", "");
							suite.Remotes.Purchase:FireClient(player, "expired");
						end
					end
				end
				
				player:SetAttribute("SecondsRemaining", profile.Data.Suite.SecondsRemaining);
			end
			
			profile.Data.LastOnline = os.time();
		end
	end)()
	
	coroutine.wrap(function()
		while true do
			task.wait(60);

			local profile = ProfileManager.Profiles[player];
			if not profile then continue; end

			if not player:GetAttribute("OnBreak") and profile.Data.MinutesOnline < ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes") then
				profile.Data.MinutesOnline += 1;
			end
			player:SetAttribute("MinutesOnline", profile.Data.MinutesOnline);
			
			if profile.Data.MinutesOnline >= ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes") then
				player:Kick("You reached the playtime limit of "..ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes").." total minutes. You must take a break of "..ReplicatedStorage:GetAttribute("BreaktimeLengthInMinutes").." minutes to fully reset your playtime cooldown.");
			end
		end
	end)()
end

local function handleLockedUpdate(profile, update)
	if update[2].UpdateType == "unban" then
		profile.Data.Moderations.IsBanned = false;
		profile.Data.Moderations.IsPermBanned = false;
		profile.Data.Moderations.CurrentBanReason = "";
		profile.Data.Moderations.CurrentModeratorWhoBanned = 0;
		profile.Data.Moderations.TimeWhenUnbanned = 0;
		table.insert(profile.Data.Moderations.PriorUnbans, {Moderator = update[2].ModeratorID, Reason = update[2].UnbanReason, ActionTime = update[2].UnbanTime});
	elseif update[2].UpdateType == "pban" then
		profile.Data.Moderations.IsBanned = true;
		profile.Data.Moderations.IsPermBanned = true;
		profile.Data.Moderations.CurrentBanReason = update[2].BanReason;
		profile.Data.Moderations.CurrentModeratorWhoBanned = update[2].ModeratorID;
		table.insert(profile.Data.Moderations.PriorBans, {Moderator = update[2].ModeratorID, Reason = update[2].BanReason, ActionTime = update[2].BanTime, BanType = "PERM"});
		for _, player in pairs(Players:GetPlayers()) do
			if player.UserId == update[2].PlayerID then
				player:Kick("You have been permanently banned for: "..update[2].BanReason..".");
				break;
			end
		end
	elseif update[2].UpdateType == "tban" then
		profile.Data.Moderations.IsBanned = true;
		profile.Data.Moderations.CurrentBanReason = update[2].BanReason;
		profile.Data.Moderations.CurrentModeratorWhoBanned = update[2].ModeratorID;
		profile.Data.Moderations.TimeWhenUnbanned = os.time() + (update[2].BanLength * 86400);
		table.insert(profile.Data.Moderations.PriorBans, {Moderator = update[2].ModeratorID, Reason = update[2].BanReason, ActionTime = update[2].BanTime, BanType = "TEMP"});
		for _, player in pairs(Players:GetPlayers()) do
			if player.UserId == update[2].PlayerID then
				if update[2].BanLength == 1 then
					player:Kick("You have been temporarily banned for "..update[2].BanLength.." day for: "..update[2].BanReason..".");
				else
					player:Kick("You have been temporarily banned for "..update[2].BanLength.." days for: "..update[2].BanReason..".");
				end
				break;
			end
		end
	elseif update[2].UpdateType == "currency" then
		for _, player in pairs(Players:GetPlayers()) do
			if player.UserId == update[2].PlayerID then
				ProfileManager.AdjustCurrency(player, update[2].Currency, update[2].Amount);
				break;
			end
		end
	elseif update[2].UpdateType == "wipe" then
		profile.Data.Moderations = Template.Moderations;
	end
	profile.GlobalUpdates:ClearLockedUpdate(update[1]);
end

local function playerAdded(player: Player)
	if player:IsDescendantOf(Players) then
		local profile = ProfileStore:LoadProfileAsync(tostring(player.UserId));
		if profile == nil then
			player:Kick("Error while handling your data. Open a bug report in the communications if this error keeps happening.");
			return;
		end

		profile:AddUserId(player.UserId);
		profile:Reconcile();
		profile:ListenToRelease(function()
			ProfileManager.Profiles[player] = nil;
			player:Kick("Error while handling your data. Open a bug report in the communications if this error keeps happening.");
		end)

		for _, playerId in pairs(votekicked) do
			if player.UserId == playerId then
				player:Kick("You have been votekicked from this session!");
			end
		end
		for _, playerId in pairs(serverBanned) do
			if player.UserId == playerId then
				player:Kick("You have been banned from this session!");
			end
		end

		if player:IsDescendantOf(Players) then
			ProfileManager.Profiles[player] = profile;
			
			for _, update in pairs(profile.GlobalUpdates:GetActiveUpdates()) do
				profile.GlobalUpdates:LockActiveUpdate(update[1]);
			end
			for _, update in pairs(profile.GlobalUpdates:GetLockedUpdates()) do
				handleLockedUpdate(profile, update);
			end

			profile.GlobalUpdates:ListenToNewActiveUpdate(function(id, data)
				profile.GlobalUpdates:LockActiveUpdate(id);
			end)
			profile.GlobalUpdates:ListenToNewLockedUpdate(function(id, data)
				handleLockedUpdate(profile, {id, data});
			end)

			if profile.Data.Moderations.IsBanned then
				if profile.Data.Moderations.IsPermBanned then
					player:Kick("You have been permanently banned for: "..profile.Data.Moderations.CurrentBanReason..". If you got unbanned rejoin to let the game update your ban status.");
				elseif os.time() < profile.Data.Moderations.TimeWhenUnbanned then
					local daysLeft = CommonFunctions:GetDaysBetweenTimes(os.time(), profile.Data.Moderations.TimeWhenUnbanned);
					if daysLeft == 1 then
						player:Kick("You have been temporarily banned for "..daysLeft.." day for: "..profile.Data.Moderations.CurrentBanReason..". If you got unbanned rejoin to let the game update your ban status.");
					else
						player:Kick("You have been temporarily banned for "..daysLeft.." days for: "..profile.Data.Moderations.CurrentBanReason..". If you got unbanned rejoin to let the game update your ban status.");
					end
				else
					profile.Data.Moderations.IsBanned = false;
					profile.Data.Moderations.CurrentBanReason = "";
					profile.Data.Moderations.CurrentModeratorWhoBanned = 0;
					profile.Data.Moderations.TimeWhenUnbanned = 0;
				end
			end
			
			local ableToPlay = GameFunctions:PaidRandomItemsNotRestricted(player);
			if not ableToPlay then
				player:Kick("Your account's PolicyService policy prohibits you from playing. This game portrays gambling which isn't permitted on your account.");
				return;
			end
			
			local minutesPast = math.floor(os.time() - profile.Data.LastOnline) / 60;
			local playtimeToBreaktimeRatio = ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes") / ReplicatedStorage:GetAttribute("BreaktimeLengthInMinutes");
			local minutesOnlineReduction = math.floor(playtimeToBreaktimeRatio * minutesPast);
			profile.Data.MinutesOnline = math.clamp(profile.Data.MinutesOnline - minutesOnlineReduction, 0, ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes"));
			if profile.Data.MinutesOnline >= ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes") then
				player:Kick("You reached the playtime limit of "..ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes").." accumulative minutes. Take a break of "..ReplicatedStorage:GetAttribute("BreaktimeLengthInMinutes").." minutes or more to fully reset your playtime cooldown.");
			end
			
			if player:IsDescendantOf(Players) then
				giveStats(player);
				startCurrencyClocks(player);
				
				if CommonFunctions:CheckBadgeOwnership(player.UserId, 908971423031857) == false then
					CommonFunctions:AwardBadge(player, 908971423031857, false);
				end
				if profile.Data.OwnsGoldClub and CommonFunctions:CheckBadgeOwnership(player.UserId, 1743025699831865) == false then
					CommonFunctions:AwardBadge(player, 1743025699831865, false);
				end
				if profile.Data.Playtime == 0 then
					Welcome:FireAllClients(player);
				end
				
				player:GetAttributeChangedSignal("OnBreak"):Connect(function()
					while player:GetAttribute("OnBreak") do
						task.wait(60 / playtimeToBreaktimeRatio); --the breaktime in seconds it takes to reduce 1 minute of playtime limit
						if player:GetAttribute("OnBreak") then
							profile.Data.MinutesOnline = math.clamp(profile.Data.MinutesOnline - 1, 0, ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes"));
							player:SetAttribute("MinutesOnline", profile.Data.MinutesOnline);
						end
					end
				end)
				player:GetAttributeChangedSignal("Cash"):Connect(function()
					local leaderstats = player:FindFirstChild("leaderstats");
					local cash = leaderstats and leaderstats:FindFirstChild("Cash");
					if cash then
						cash.Value = player:GetAttribute("Cash");
					end
				end)
				player:GetAttributeChangedSignal("Playtime"):Connect(function()
					local leaderstats = player:FindFirstChild("leaderstats");
					local playtime = leaderstats and leaderstats:FindFirstChild("Playtime");
					if playtime then
						playtime.Value = player:GetAttribute("Playtime");
					end
				end)
			else
				profile:Release();
			end
		else
			profile:Release();
		end
	end
end

ServerBan.Event:Connect(function(player, toggle)
	if toggle then
		table.insert(serverBanned, player.UserId);
		player:Kick("You have been banned from this session!");
	else
		for index, bannedID in pairs(serverBanned) do
			if bannedID == player then
				table.remove(serverBanned, index);
				break;
			end
		end
	end
end)

Votekick.OnServerEvent:Connect(function(player, playerToVoteOffName)
	if player and typeof(playerToVoteOffName) == "string" and playerToVoteOffName == playerToVoteOffName then
		local passedCooldownCheck = CommonFunctions:CheckPlayerRemoteCooldown(player, "votekick", script:GetAttribute("VotekickCooldown"));
		if passedCooldownCheck then
			local playerToVoteOff = game.Players:FindFirstChild(playerToVoteOffName);
			if playerToVoteOff then
				if not votekicks[playerToVoteOff] then
					votekicks[playerToVoteOff] = 1;
				else
					votekicks[playerToVoteOff] = votekicks[playerToVoteOff] + 1;
				end

				if votekicks[playerToVoteOff] >= script:GetAttribute("VotesNeededToKick") then
					table.insert(votekicked, playerToVoteOff.UserId);
					playerToVoteOff:Kick("You have been votekicked from this session!");
				end
			end
		end
	end
end)

SaveSetting.OnServerEvent:Connect(function(player, settingData)
	if player and typeof(settingData) == "table" then
		local passedCooldownCheck = CommonFunctions:CheckPlayerRemoteCooldown(player, "saveSetting", script:GetAttribute("SaveSettingCooldown"));
		if passedCooldownCheck then
			local profile = ProfileManager.Profiles[player];
			if not profile then return; end
			profile.Data.Settings = settingData;
		end
	end
end)

FetchSetting.OnServerInvoke = function(player)
	if player then
		local passedCooldownCheck = CommonFunctions:CheckPlayerRemoteCooldown(player, "votekick", script:GetAttribute("LoadSettingCooldown"));
		if passedCooldownCheck then
			local profile = ProfileManager.Profiles[player];
			if profile then
				return profile.Data.Settings;
			end
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	playerAdded(player);
end
Players.PlayerAdded:Connect(function(player)
	playerAdded(player);
end);
Players.PlayerRemoving:Connect(function(player: Player)
	local profile = ProfileManager.Profiles[player];
	if not profile then return; end
	profile:Release();
end)