local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");

local ServerModules = ServerStorage:WaitForChild("Modules");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local ReplicatedRemotes = ReplicatedStorage:WaitForChild("Remotes");

local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local ProfileManager = require(ServerModules.ProfileService.PlayerData.ProfileManager);
local GameDataModule = require(ReplicatedModules:WaitForChild("GameData"));
local Jackpot = ReplicatedRemotes:WaitForChild("Jackpot");

local TableGame = script.Parent;
local TableGameRemotes = TableGame:WaitForChild("Remotes");
local Functional = TableGame:WaitForChild("Functional");
local NPCs = TableGame:WaitForChild("NPCs");
local Voicelines = script:WaitForChild("Voicelines");

local GameAssets = ServerStorage:WaitForChild("GameAssets");
local PlayingCards = GameAssets:WaitForChild("PlayingCards");
local PlayNPC = TableGameRemotes:WaitForChild("PlayNPC");
local PlayVoiceline = TableGameRemotes:WaitForChild("PlayVoiceline");
local PlayerAction = TableGameRemotes:WaitForChild("PlayerAction");

local Bets = Functional:WaitForChild("Bets");
local Dealer = Functional:WaitForChild("Dealer");
local Stools = Functional:WaitForChild("Stools");
local MinCash = Functional:WaitForChild("MinCash");
local MaxCash = Functional:WaitForChild("MaxCash");
local MaxBonusCash = Functional:WaitForChild("MaxBonusCash");
local Cards = Functional:WaitForChild("Cards");

local RNG = Random.new();
local DealerAnimations = {};
local TheOutcomeSet = {}; -- {{"ace", "spades"}, {"ace", "spades"}, {"ace", "spades"}, {"ace", "spades"}}
local GameData = {}; -- {stool, actualPlayer, playerBet, bankerBet, tieBet, playerEightBet, bankerSevenBet, nineSevenBet, totalBet}
local TurnPlayer = nil;
local ProcessingEvent = false;
local PlayerTotal = 0;
local BankerTotal = 0;

local PayoutMultiplier_Won = 2;
local PayoutMultiplier_Tie = 11;
local PayoutMultiplier_PlayerEight = 25;
local PayoutMultiplier_BankerSeven = 40;
local PayoutMultiplier_NineSeven = 200;

local function GetNextEmptyCard(player)
	for each, card in pairs(Cards[player]:GetChildren()) do
		if card:GetAttribute("Value") == 0 then
			return card;
		end
	end
end

local function ToggleCardVisualForSlot(toggle, slot, cardName)
	local realCard = slot:FindFirstChild(slot:GetAttribute("CardName"));
	if realCard then
		realCard:Destroy();
	end

	if toggle then
		local templateCard = PlayingCards:FindFirstChild(cardName);
		if templateCard then
			local realCard = templateCard:Clone();
			realCard.Orientation = Vector3.new(0, slot.Orientation.Y, 0);
			realCard.Position = slot.Position
			realCard.Parent = slot;
		end
	end
end

local function DealCardToPlayer(player)
	local cardInfo = GameDataModule:GetPlayingCards(TableGame.Name)[RNG:NextInteger(1, 52)];
	local cardSlot = GetNextEmptyCard(player);
	cardSlot:SetAttribute("CardName", cardInfo[1]);
	cardSlot:SetAttribute("Value", cardInfo[2]);
	ToggleCardVisualForSlot(true, cardSlot, cardInfo[1]);
end

local function RemovePlayerFromTable(player)
	TableGame:SetAttribute("WatchingPlayers", TableGame:GetAttribute("WatchingPlayers") - 1);

	for index, playerData in pairs(GameData) do
		if playerData[1] == player then
			TableGame:SetAttribute("ActivePlayers", TableGame:GetAttribute("ActivePlayers") - 1);

			if TurnPlayer == playerData[2] then
				TurnPlayer = nil;
			end

			GameData[index] = nil;

			break;
		end
	end

	for each, betFolder in pairs(Bets:GetChildren()) do
		if betFolder.Name == player then
			for each, bet in pairs(betFolder:GetChildren()) do
				bet.Transparency = 1;
				bet.BillboardGui.Enabled = false;
				bet.BillboardGui.Bet.Text = "";
				bet.BillboardGui.Winnings.Text = "";
			end
		end
	end
end

local function ToggleDealerAnimation(trackName, toggle, animation)
	if toggle then
		if animation then
			DealerAnimations[trackName] = Dealer.Humanoid:LoadAnimation(animation);
		end
		DealerAnimations[trackName]:Play();
	else
		DealerAnimations[trackName]:Stop();
	end
end

local function GetPlayerStoolName(actualPlayer)
	for each, stool in pairs(Stools:GetChildren()) do
		if stool.Seat.Occupant and stool.Seat.Occupant.Parent.Name == actualPlayer.Name then
			return stool.Name;
		end
	end
end

local function ShowPlayerBet(stoolName, betType, betAmount)
	if betAmount > 0 then
		Bets[stoolName][betType].Transparency = 0;
		Bets[stoolName][betType].BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(betAmount);
		Bets[stoolName][betType].BillboardGui.Enabled = true;
	else
		Bets[stoolName][betType].Transparency = 1;
		Bets[stoolName][betType].BillboardGui.Bet.Text = "";
		Bets[stoolName][betType].BillboardGui.Enabled = false;
	end
end

local function IncreaseCardTotal(side, value)
	if side == "Player" then
		PlayerTotal += value;
		PlayerTotal %= 10;
	else
		BankerTotal += value;
		BankerTotal %= 10;
	end
end

local function DisplayWinner(bankerResult)
	if bankerResult == "Won" then
		ToggleCardVisualForSlot(true, Cards.Banker.Display1, Cards.Banker.Card1:GetAttribute("CardName"));
		ToggleCardVisualForSlot(true, Cards.Banker.Display2, Cards.Banker.Card2:GetAttribute("CardName"));
		Cards.Banker.Display1:SetAttribute("CardName", Cards.Banker.Card1:GetAttribute("CardName"));
		Cards.Banker.Display2:SetAttribute("CardName",  Cards.Banker.Card2:GetAttribute("CardName"));
		ToggleCardVisualForSlot(false, Cards.Banker.Card1, nil);
		ToggleCardVisualForSlot(false, Cards.Banker.Card2, nil);
	elseif bankerResult == "Lost" then
		ToggleCardVisualForSlot(true, Cards.Player.Display1, Cards.Player.Card1:GetAttribute("CardName"));
		ToggleCardVisualForSlot(true, Cards.Player.Display2, Cards.Player.Card2:GetAttribute("CardName"));
		Cards.Player.Display1:SetAttribute("CardName", Cards.Player.Card1:GetAttribute("CardName"));
		Cards.Player.Display2:SetAttribute("CardName",  Cards.Player.Card2:GetAttribute("CardName"));
		ToggleCardVisualForSlot(false, Cards.Player.Card1, nil);
		ToggleCardVisualForSlot(false, Cards.Player.Card2, nil);
	end
end

local function DrawThirdCard(side)
	if side == "Player" then
		ToggleDealerAnimation("DealPlayer", true);
		
		local connection = DealerAnimations["DealPlayer"].KeyframeReached:Connect(function(keyframeName)
			if TableGame:GetAttribute("ActivePlayers") > 0 then
				if keyframeName == "DealPlayer" then
					DealCardToPlayer("Player");
				end
			end
		end)

		DealerAnimations["DealPlayer"].Stopped:Wait();
		connection:Disconnect();
	else
		ToggleDealerAnimation("DealBanker", true);
		
		local connection = DealerAnimations["DealBanker"].KeyframeReached:Connect(function(keyframeName)
			if TableGame:GetAttribute("ActivePlayers") > 0 then
				if keyframeName == "DealBanker" then
					DealCardToPlayer("Banker");
				end
			end
		end)

		DealerAnimations["DealBanker"].Stopped:Wait();
		connection:Disconnect();
	end
	
	IncreaseCardTotal(side, Cards[side].Card3:GetAttribute("Value"));
	
	task.wait(2);
end

local function ResetGameData()
	GameData = {};
	TheOutcomeSet = {};
	TurnPlayer = nil;
	PlayerTotal = 0;
	BankerTotal = 0;
	for each, betFolder in pairs(Bets:GetChildren()) do
		for each, bet in pairs(betFolder:GetChildren()) do
			bet.Transparency = 1;
			bet.BillboardGui.Enabled = false;
			bet.BillboardGui.Bet.Text = "";
			bet.BillboardGui.Winnings.Text = "";
		end
	end
end

local function ResetTable()
	for each, cardFolder in pairs(Cards:GetChildren()) do
		for each, cardSlot in pairs(cardFolder:GetChildren()) do
			ToggleCardVisualForSlot(false, cardSlot, nil);
			cardSlot:SetAttribute("CardName", "");
			cardSlot:SetAttribute("Value", 0);
		end
	end

	for each, animation in pairs(Dealer.Animations:GetChildren()) do
		if animation.Name == "Idle" or (animation.Name == "DropCards" and TableGame:GetAttribute("RoundStarted")) then
			ToggleDealerAnimation(animation.Name, true);
		else
			ToggleDealerAnimation(animation.Name, false);
		end
	end
	
	TableGame:SetAttribute("ActivePlayers", 0);
	TableGame:SetAttribute("RoundPending", false);
	TableGame:SetAttribute("RoundStarted", false);
	ResetGameData();
end

local function StartNewRound()
	-- Start a new round
	PlayVoiceline:Fire("RoundStarting", true);
	TableGame:SetAttribute("RoundPending", false);
	TableGame:SetAttribute("RoundStarted", true);
	
	-- Get the players who are participating and collect their bets
	TableGame:SetAttribute("ActivePlayers", #GameData);
	for each, playerData in pairs(GameData) do
		if playerData[2]:IsA("Player") then
			PlayerAction:FireClient(playerData[2], "roundStarted");
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[3]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[4]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[5]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[6]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[7]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[8]);
		end
	end
	table.sort(GameData, function(a, b)
		if a and b then
			return tonumber(string.match(a[1], "%d")) < tonumber(string.match(b[1], "%d"))
		end
	end)
	
	-- Dealer picks up the cards
	ToggleDealerAnimation("PickupCards", true);
	DealerAnimations["PickupCards"].Stopped:Wait();
	ToggleDealerAnimation("IdleCards", true);
	ToggleDealerAnimation("Idle", false);
	
	-- Dealer deals the initial two cards to player and two cards to banker
	if TableGame:GetAttribute("ActivePlayers") > 0 then
		ToggleDealerAnimation("InitialDeal", true);

		local connection = DealerAnimations["InitialDeal"].KeyframeReached:Connect(function(keyframeName)
			if TableGame:GetAttribute("ActivePlayers") > 0 then
				if keyframeName == "DealPlayer" then
					DealCardToPlayer("Player");
				elseif keyframeName == "DealBanker" then
					DealCardToPlayer("Banker");
				end
			end
		end)

		DealerAnimations["InitialDeal"].Stopped:Wait();
		connection:Disconnect();
		
		for each, cardFolder in pairs(Cards:GetChildren()) do
			for each, card in pairs(cardFolder:GetChildren()) do
				IncreaseCardTotal(card.Parent.Name, card:GetAttribute("Value"));
			end
		end
	end
	
	task.wait(2);
	
	-- Dealer sees whether player will draw a third card or stand
	-- If banker has a natural the player automatically stands
	-- Player has natural on 8 - 9, stands on 6 - 7, draws on 0 - 5
	if TableGame:GetAttribute("ActivePlayers") > 0 then
		if BankerTotal < 8 and PlayerTotal <= 5 then
			DrawThirdCard("Player");
		end
	end
	
	-- Dealer sees whether banker will draw a third card or stand
	-- If player has a natural the banker automatically stands
	-- If player didn't draw a third card the banker uses same drawing rules as player
	-- If player drew a third card the banker uses the banker drawing rules
	if TableGame:GetAttribute("ActivePlayers") > 0 then
		if PlayerTotal < 8 then
			if Cards.Player.Card3:GetAttribute("Value") == 0 and BankerTotal <= 5 then
				DrawThirdCard("Banker");
			elseif BankerTotal <= 6 then
				if BankerTotal <= 2 then
					DrawThirdCard("Banker");
				elseif BankerTotal == 3 and Cards.Player.Card3:GetAttribute("Value") ~= 8 then
					DrawThirdCard("Banker");
				elseif BankerTotal == 4 and Cards.Player.Card3:GetAttribute("Value") >= 2 and Cards.Player.Card3:GetAttribute("Value") <= 7 then
					DrawThirdCard("Banker");
				elseif BankerTotal == 5 and Cards.Player.Card3:GetAttribute("Value") >= 4 and Cards.Player.Card3:GetAttribute("Value") <= 7 then
					DrawThirdCard("Banker");
				elseif Cards.Player.Card3:GetAttribute("Value") == 6 or Cards.Player.Card3:GetAttribute("Value") == 7 then
					DrawThirdCard("Banker");
				end
			end
		end
	end
	
	-- Results of the round are finalized
	if TableGame:GetAttribute("ActivePlayers") > 0 then
		local bankerResult = "";
		if BankerTotal > PlayerTotal then
			bankerResult = "Won";
		elseif BankerTotal < PlayerTotal then
			bankerResult = "Lost";
		else
			bankerResult = "Tied";
		end
		
		DisplayWinner(bankerResult);
		
		PlayVoiceline:Fire("Banker"..bankerResult);
		task.wait(2);
		
		for player, playerData in pairs(GameData) do
			if playerData[9] > 0 then --if player made any bets at all
				local mainEnding = "";
				local mainPayout = 0;
				local tiePayout = 0;
				local playerEightPayout = 0;
				local bankerSevenPayout = 0;
				local nineSevenPayout = 0;
				local wonJackpot = false;
				
				if playerData[4] > 0 then --bet banker
					mainEnding = bankerResult;
				elseif playerData[3] > 0 then --bet player
					if bankerResult == "Won" then
						mainEnding = "Lost";
					elseif bankerResult == "Lost" then
						mainEnding = "Won";
					else
						mainEnding = "Tied";
					end
				end
				if mainEnding == "Won" then
					mainPayout = playerData[3] > 0 and playerData[3] or playerData[4];
					mainPayout *= PayoutMultiplier_Won;
				end
				
				if playerData[5] > 0 and bankerResult == "Tied" then
					tiePayout = playerData[5];
					tiePayout *= PayoutMultiplier_Tie;
				end
				if playerData[6] > 0 and PlayerTotal == 8 and Cards.Player.Card3:GetAttribute("Value") ~= 0 then
					playerEightPayout = playerData[6];
					playerEightPayout *= PayoutMultiplier_PlayerEight;
					wonJackpot = true;
				end
				if playerData[7] > 0 and BankerTotal == 7 and Cards.Banker.Card3:GetAttribute("Value") ~= 0 then
					bankerSevenPayout = playerData[7];
					bankerSevenPayout *= PayoutMultiplier_BankerSeven;
					wonJackpot = true;
				end
				if playerData[8] > 0 and Cards.Player.Card3:GetAttribute("Value") ~= 0 and Cards.Banker.Card3:GetAttribute("Value") ~= 0 and ((PlayerTotal == 9 and BankerTotal == 7) or (PlayerTotal == 7 and BankerTotal == 9)) then
					nineSevenPayout = playerData[8];
					nineSevenPayout *= PayoutMultiplier_NineSeven;
					wonJackpot = true;
				end
				
				local totalPayout = mainPayout + tiePayout + playerEightPayout + bankerSevenPayout + nineSevenPayout;
				if wonJackpot and playerData[2]:IsA("Player") then
					Jackpot:FireAllClients(playerData[2], totalPayout);
				end
				
				if mainEnding ~= "" then
					PlayVoiceline:Fire(playerData[1]..mainEnding);
				end
				
				if Bets[playerData[1]].Player.BillboardGui.Enabled then
					Bets[playerData[1]].Player.BillboardGui.Bet.Text = "";
					
					if mainPayout == 0 then
						Bets[playerData[1]].Player.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[3]);
						Bets[playerData[1]].Player.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						Bets[playerData[1]].Player.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(mainPayout);
						Bets[playerData[1]].Player.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
						ProfileManager.AdjustCurrency(playerData[2], "Cash", mainPayout);
					end
				end
				if Bets[playerData[1]].Banker.BillboardGui.Enabled then
					Bets[playerData[1]].Banker.BillboardGui.Bet.Text = "";
					
					if mainPayout == 0 then
						Bets[playerData[1]].Banker.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[4]);
						Bets[playerData[1]].Banker.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						Bets[playerData[1]].Banker.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(mainPayout);
						Bets[playerData[1]].Banker.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
						ProfileManager.AdjustCurrency(playerData[2], "Cash", mainPayout);
					end
				end
				if Bets[playerData[1]].Tie.BillboardGui.Enabled then
					Bets[playerData[1]].Tie.BillboardGui.Bet.Text = "";
					
					if tiePayout == 0 then
						Bets[playerData[1]].Tie.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[5]);
						Bets[playerData[1]].Tie.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						Bets[playerData[1]].Tie.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(tiePayout);
						Bets[playerData[1]].Tie.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
						ProfileManager.AdjustCurrency(playerData[2], "Cash", tiePayout);
					end
				end
				if Bets[playerData[1]].PlayerEight.BillboardGui.Enabled then
					Bets[playerData[1]].PlayerEight.BillboardGui.Bet.Text = "";
					
					if playerEightPayout == 0 then
						Bets[playerData[1]].PlayerEight.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[6]);
						Bets[playerData[1]].PlayerEight.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						Bets[playerData[1]].PlayerEight.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(playerEightPayout);
						Bets[playerData[1]].PlayerEight.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
						ProfileManager.AdjustCurrency(playerData[2], "Cash", playerEightPayout);
					end
				end
				if Bets[playerData[1]].BankerSeven.BillboardGui.Enabled then
					Bets[playerData[1]].BankerSeven.BillboardGui.Bet.Text = "";
					
					if bankerSevenPayout == 0 then
						Bets[playerData[1]].BankerSeven.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[7]);
						Bets[playerData[1]].BankerSeven.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						Bets[playerData[1]].BankerSeven.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(bankerSevenPayout);
						Bets[playerData[1]].BankerSeven.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
						ProfileManager.AdjustCurrency(playerData[2], "Cash", bankerSevenPayout);
					end
				end
				if Bets[playerData[1]].NineSeven.BillboardGui.Enabled then
					Bets[playerData[1]].NineSeven.BillboardGui.Bet.Text = "";
					
					if nineSevenPayout == 0 then
						Bets[playerData[1]].NineSeven.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[8]);
						Bets[playerData[1]].NineSeven.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						Bets[playerData[1]].NineSeven.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(nineSevenPayout);
						Bets[playerData[1]].NineSeven.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
						ProfileManager.AdjustCurrency(playerData[2], "Cash", nineSevenPayout);
					end
				end
			end
		end
		
		task.wait(TableGame:GetAttribute("TimeBetweenHands"));
	end
	
	-- End the current round and start the next round if players are still present
	if TableGame:GetAttribute("ActivePlayers") > 0 then
		for player, playerData in pairs(GameData) do
			if playerData[2]:IsA("Player") then
				PlayerAction:FireClient(playerData[2], "roundEnded");
			end
		end

		ResetTable();

		for each, stool in pairs(Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if player:GetAttribute("Cash") >= TableGame:GetAttribute("MinCash") then
						if not TableGame:GetAttribute("RoundPending") then
							TableGame:SetAttribute("RoundPending", true);
							PlayVoiceline:Fire(stool.Name.."RoundStartingSoon", true);
						end
					end
				end
			end
		end

		for each, npc in pairs(NPCs:GetChildren()) do
			if not TableGame:GetAttribute("RoundPending") then
				TableGame:SetAttribute("RoundPending", true);
				PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon", true);
			end
			if npc:FindFirstChild("PlayGame") then
				npc.PlayGame.Response:Fire("BetBaccarat");
			end
		end
	end
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, playerBets)
	if not ProcessingEvent then
		ProcessingEvent = true;
		
		local player = GameFunctions:GetPlayerFromActualPlayer(actualPlayer, GameData);
		local playerData = GameFunctions:GetPlayerDataFromPlayer(player, GameData);
		
		if action == "Bet" and not TableGame:GetAttribute("RoundStarted") then
			local playerBet = 0;
			local bankerBet = 0;
			local tieBet = 0; 
			local playerEightBet = 0;
			local bankerSevenBet = 0;
			local nineSevenBet = 0;
			local totalBet = 0;
			
			if tonumber(playerBets[1]) and tonumber(playerBets[1]) >= TableGame:GetAttribute("MinCash") and tonumber(playerBets[1]) <= TableGame:GetAttribute("MaxCash") then
				playerBet = math.floor(playerBets[1]);
			end
			if tonumber(playerBets[2]) and tonumber(playerBets[2]) >= TableGame:GetAttribute("MinCash") and tonumber(playerBets[1]) <= TableGame:GetAttribute("MaxCash") then
				bankerBet = math.floor(playerBets[2]);
			end
			if tonumber(playerBets[3]) and tonumber(playerBets[3]) >= TableGame:GetAttribute("MinCash") and tonumber(playerBets[3]) <= TableGame:GetAttribute("MaxBonusCash") then
				tieBet = math.floor(playerBets[3]);
			end
			if tonumber(playerBets[4]) and tonumber(playerBets[4]) >= TableGame:GetAttribute("MinCash") and tonumber(playerBets[4]) <= TableGame:GetAttribute("MaxBonusCash") then
				playerEightBet = math.floor(playerBets[4]);
			end
			if tonumber(playerBets[5]) and tonumber(playerBets[5]) >= TableGame:GetAttribute("MinCash") and tonumber(playerBets[5]) <= TableGame:GetAttribute("MaxBonusCash") then
				bankerSevenBet = math.floor(playerBets[5]);
			end
			if tonumber(playerBets[3]) and tonumber(playerBets[6]) >= TableGame:GetAttribute("MinCash") and tonumber(playerBets[6]) <= TableGame:GetAttribute("MaxBonusCash") then
				nineSevenBet = math.floor(playerBets[6]);
			end
			
			if playerBet > 0 and bankerBet > 0 then
				PlayerAction:FireClient(actualPlayer, "betHint");
				playerBet = 0;
				bankerBet = 0;
				tieBet = 0; 
				playerEightBet = 0;
				bankerSevenBet = 0;
				nineSevenBet = 0;
				totalBet = 0;
			else
				totalBet = playerBet + bankerBet + tieBet + playerEightBet + bankerSevenBet + nineSevenBet;
				if actualPlayer:GetAttribute("Cash") < totalBet then
					PlayerAction:FireClient(actualPlayer, "cashHint");
					playerBet = 0;
					bankerBet = 0;
					tieBet = 0; 
					playerEightBet = 0;
					bankerSevenBet = 0;
					nineSevenBet = 0;
					totalBet = 0;
				end
			end
			
			local stoolName = GetPlayerStoolName(actualPlayer);
			local foundData;
			for each, playerData in pairs(GameData) do
				if playerData[1] == stoolName then
					foundData = playerData;
					playerData[3] = playerBet;
					playerData[4] = bankerBet;
					playerData[5] = tieBet;
					playerData[6] = playerEightBet;
					playerData[7] = bankerSevenBet;
					playerData[8] = nineSevenBet;
					playerData[9] = totalBet;
					break;
				end
			end
			if not foundData then
				foundData = {stoolName, actualPlayer, playerBet, bankerBet, tieBet, playerEightBet, bankerSevenBet, nineSevenBet, totalBet};
				table.insert(GameData, foundData);
			end
			
			ShowPlayerBet(stoolName, "Player", foundData[3]);
			ShowPlayerBet(stoolName, "Banker", foundData[4]);
			ShowPlayerBet(stoolName, "Tie", foundData[5]);
			ShowPlayerBet(stoolName, "PlayerEight", foundData[6]);
			ShowPlayerBet(stoolName, "BankerSeven", foundData[7]);
			ShowPlayerBet(stoolName, "NineSeven", foundData[8]);
		end
		
		ProcessingEvent = false;
	end
end)

TableGame:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if TableGame:GetAttribute("RoundPending") then
		local success = true;

		repeat task.wait(0.5); until #GameData > 0

		for i = TableGame:GetAttribute("TimeToBet"), 0, -1 do
			if not TableGame:GetAttribute("RoundPending") then
				success = false;
				break;
			end

			if i ~= 0 then
				for i = 0, 1, 0.05 do
					if not TableGame:GetAttribute("RoundPending") then
						break;
					end
					task.wait(0.05);
				end
			end
		end

		if success then
			StartNewRound();
		end
	end
end)

local function Initialize()
	MinCash.SurfaceGui.TextLabel.Text ="MIN: $"..GameDataModule:AddCommasToNumber(TableGame:GetAttribute("MinCash"));
	MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(TableGame:GetAttribute("MaxCash"));
	MaxBonusCash.SurfaceGui.TextLabel.Text = "BONUS MAX: $"..GameDataModule:AddCommasToNumber(TableGame:GetAttribute("MaxBonusCash"));
	MinCash.Fire.Enabled = TableGame:GetAttribute("HighRoller");
	MaxCash.Fire.Enabled = TableGame:GetAttribute("HighRoller");
	MaxBonusCash.Fire.Enabled = TableGame:GetAttribute("HighRoller");
	TableGame.Decoration.Table.Base.Material = TableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	TableGame.Decoration.Table.Ring.Material = TableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	TableGame.Decoration.Table.Table.Material = TableGame:GetAttribute("HighRoller") and Enum.Material.Salt or Enum.Material.Plastic;
	
	Voicelines.Enabled = true;

	for each, animation in pairs(Dealer.Animations:GetChildren()) do
		ToggleDealerAnimation(animation.Name, true, animation);
	end
	for each, animation in pairs(Dealer.Animations:GetChildren()) do
		if animation.Name ~= "Idle" then
			ToggleDealerAnimation(animation.Name, false);
		end
	end
	GameFunctions:GiveDealerNametag(Dealer);
	
	for each, stool in pairs(Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			if stool.Seat.Occupant then
				TableGame:SetAttribute("WatchingPlayers", TableGame:GetAttribute("WatchingPlayers") + 1);

				local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
						if player:GetAttribute("Cash") >= TableGame:GetAttribute("MinCash") then
							PlayVoiceline:Fire(stool.Name.."Welcome");
							local gui = script.Baccarat:Clone();
							gui.ActualTable.Value = TableGame;
							gui.Parent = player.PlayerGui;
							if not TableGame:GetAttribute("RoundStarted") and not TableGame:GetAttribute("RoundPending") then
								TableGame:SetAttribute("RoundPending", true);
								PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							end
						end
					end
				end
			else
				RemovePlayerFromTable(stool.Name);

				if TableGame:GetAttribute("ActivePlayers") == 0 and TableGame:GetAttribute("RoundStarted") then
					ResetTable();
					for each, stool in pairs(Stools:GetChildren()) do
						if stool.Seat.Occupant then
							TableGame:SetAttribute("RoundPending", true);
							PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							break;
						end
						for each, npc in pairs(NPCs:GetChildren()) do
							if not TableGame:GetAttribute("RoundPending") then
								TableGame:SetAttribute("RoundPending", true);
								PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon", true);
							end
							if npc:FindFirstChild("PlayGame") then
								npc.PlayGame.Response:Fire("BetThreeCardPoker");
							end
						end
					end
				end
			end

			if TableGame:GetAttribute("WatchingPlayers") == 0 then
				ResetTable();
			end
		end)
	end
end

PlayNPC.Event:Connect(function(npc, action)
	local player = GameFunctions:GetPlayerFromActualPlayer(npc, GameData);
	local playerData = GameFunctions:GetPlayerDataFromPlayer(player, GameData);
	
	if action == "arriving" then
		PlayVoiceline:Fire(npc:GetAttribute("Stool").."Welcome");
		if not TableGame:GetAttribute("RoundStarted") and not TableGame:GetAttribute("RoundPending") then
			TableGame:SetAttribute("RoundPending", true);
			PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon");
		end
	elseif action == "leaving" then
		TableGame:SetAttribute("NPCsAtGame", TableGame:GetAttribute("NPCsAtGame") - 1);
	elseif action == "bet" and not TableGame:GetAttribute("RoundStarted") then
		local playerBet = (RNG:NextNumber() <= 0.5) and RNG:NextInteger(TableGame:GetAttribute("MinCash"), TableGame:GetAttribute("MaxCash")) or 0;
		local bankerBet = (playerBet == 0) and RNG:NextInteger(TableGame:GetAttribute("MinCash"), TableGame:GetAttribute("MaxCash")) or 0;
		local tieBet = (RNG:NextNumber() <= 0.5) and RNG:NextInteger(TableGame:GetAttribute("MinCash"), TableGame:GetAttribute("MaxBonusCash")) or 0;
		local playerEightBet = (RNG:NextNumber() <= 0.5) and RNG:NextInteger(TableGame:GetAttribute("MinCash"), TableGame:GetAttribute("MaxBonusCash")) or 0;
		local bankerSevenBet = (RNG:NextNumber() <= 0.5) and RNG:NextInteger(TableGame:GetAttribute("MinCash"), TableGame:GetAttribute("MaxBonusCash")) or 0;
		local nineSevenBet = (RNG:NextNumber() <= 0.5) and RNG:NextInteger(TableGame:GetAttribute("MinCash"), TableGame:GetAttribute("MaxBonusCash")) or 0;
		local totalBet = playerBet + bankerBet + tieBet + playerEightBet + bankerSevenBet + nineSevenBet;

		local foundData;
		for each, playerData in pairs(GameData) do
			if playerData[1] == npc:GetAttribute("Stool") then
				foundData = playerData;
				playerData[3] = playerBet;
				playerData[4] = bankerBet;
				playerData[5] = tieBet;
				playerData[6] = playerEightBet;
				playerData[7] = bankerSevenBet;
				playerData[8] = nineSevenBet;
				break;
			end
		end
		if not foundData then
			foundData = {npc:GetAttribute("Stool"), npc, playerBet, bankerBet, tieBet, playerEightBet, bankerSevenBet, nineSevenBet, totalBet};
			table.insert(GameData, foundData);
		end

		ShowPlayerBet(npc:GetAttribute("Stool"), "Player", foundData[3]);
		ShowPlayerBet(npc:GetAttribute("Stool"), "Banker", foundData[4]);
		ShowPlayerBet(npc:GetAttribute("Stool"), "Tie", foundData[5]);
		ShowPlayerBet(npc:GetAttribute("Stool"), "PlayerEight", foundData[6]);
		ShowPlayerBet(npc:GetAttribute("Stool"), "BankerSeven", foundData[7]);
		ShowPlayerBet(npc:GetAttribute("Stool"), "NineSeven", foundData[8]);
	end
end)

Initialize();