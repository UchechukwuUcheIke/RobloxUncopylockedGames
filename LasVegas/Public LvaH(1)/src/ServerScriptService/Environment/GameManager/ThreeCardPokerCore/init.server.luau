local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local GameDataModule = require(ReplicatedStorage.Modules.GameData);
local Jackpot = ReplicatedStorage.Remotes.Jackpot;
local tableGame = script.Parent;
local tableGameRemotes = tableGame.Remotes;
local functional = tableGame.Functional;
local decoration = tableGame.Decoration;
local PlayNPC = tableGameRemotes.PlayNPC;
local PlayVoiceline = tableGameRemotes.PlayVoiceline;
local PlayerAction = tableGameRemotes.PlayerAction;
local bets = functional.Bets;
local turns = functional.Turns;
local cards = functional.Cards;
local stools = functional.Stools;
local dealer = functional.Dealer;
local minCash = functional.MinCash;
local maxCash = functional.MaxCash;
local maxBonusCash = functional.MaxBonusCash;

local GameAssets = ServerStorage:WaitForChild("GameAssets");
local PlayingCards = GameAssets:WaitForChild("PlayingCards");

local random = Random.new();
local dealerAnimations = {};
local theOutcomeSet = {}; -- {{card, value}, {card, value}, {card, value}, {card, value}}
local gameData = {}; -- {stool, actualPlayer, folded, anteBet, pairBet, bonusBet}
local turnPlayer;
local processingEvent = false;

local antePayouts = {
	["Straight"] = 1,
	["Three of a Kind"] = 4,
	["Straight Flush"] = 5
};
local pairPayouts = {
	["Pair"] = 1,
	["Flush"] = 4,
	["Straight"] = 6,
	["Three of a Kind"] = 30,
	["Straight Flush"] = 40
};
local bonusPayouts = {
	["Three of a Kind"] = 5,
	["5-Card Straight"] = 10,
	["5-Card Flush"] = 15,
	["Full House"] = 25,
	["Four of a Kind"] = 50,
	["5-Card Straight Flush"] = 200,
	["5-Card Royal Flush"] = 1000
};
local resultRanking = {
	["Straight Flush"] = 6,
	["Three of a Kind"] = 5,
	["Straight"] = 4,
	["Flush"] = 3,
	["Pair"] = 2,
	["High Card"] = 1
};

local function getHighestNumber(numbers)
	local highest;

	for _, number in pairs(numbers) do
		if not highest then
			highest = number;
		elseif number > highest then
			highest = number;
		end
	end

	return highest;
end

local function getValueOccurance(value, hand, group)
	local count = 0;
	
	for _, card in pairs(hand) do
		if group == "value" then
			if card[1] == value then
				count += 1;
			end
		elseif card[2] == value then
			count += 1;
		end
	end
	
	return count;
end

local function checkForFullHouse(hand)
	local valuesFound = {};
	local threeChainFound = false;
	local twoChainFound = false;
	
	for _, card in pairs(hand) do
		local found = false;
		
		for _, values in pairs(valuesFound) do
			if values[1] == card[1] then
				table.insert(values, card[1]);
				found = true;
				break;
			end
		end
		
		if not found then
			table.insert(valuesFound, {card[1]});
		end
	end
	
	for _, values in pairs(valuesFound) do
		if #values == 3 then
			if threeChainFound then
				twoChainFound = true;
			else
				threeChainFound = true;
			end
		elseif #values == 2 then
			twoChainFound = true;
		end
	end
	
	return threeChainFound and twoChainFound
end

local function getSixCardHandResult(dealerHand, playerHand)
	local hand = {
		{dealerHand[1][1], dealerHand[1][2]},
		{dealerHand[2][1], dealerHand[2][2]},
		{dealerHand[3][1], dealerHand[3][2]},
		{playerHand[1][1], playerHand[1][2]},
		{playerHand[2][1], playerHand[2][2]},
		{playerHand[3][1], playerHand[3][2]}
	}; 
	
	table.sort(hand, function(a, b)
		return a[1] > b[1]
	end)
	
	if hand[1][1] == 14 and hand[2][1] == 13 and hand[3][1] == 12 and hand[4][1] == 11 and hand[5][1] == 10 and hand[1][2] == hand[2][2] and hand[2][2] == hand[3][2] and hand[3][2] == hand[4][2] and hand[4][2] == hand[5][2] then
		return "5-Card Royal Flush"
	elseif (hand[1][1] - 1 == hand[2][1] and hand[2][1] - 1 == hand[3][1] and hand[3][1] - 1 == hand[4][1] and hand[4][1] - 1 == hand[5][1] and hand[1][2] == hand[2][2] and hand[2][2] == hand[3][2] and hand[3][2] == hand[4][2] and hand[4][2] == hand[5][2]) or (hand[2][1] - 1 == hand[3][1] and hand[3][1] - 1 == hand[4][1] and hand[4][1] - 1 == hand[5][1] and hand[5][1] - 1 == hand[6][1] and hand[2][2] == hand[3][2] and hand[3][2] == hand[4][2] and hand[4][2] == hand[5][2] and hand[5][2] == hand[6][2]) then
		return "5-Card Straight Flush"
	elseif getValueOccurance(hand[1][1], hand, "value") == 4 or getValueOccurance(hand[2][1], hand, "value") == 4 or getValueOccurance(hand[3][1], hand, "value") == 4 or getValueOccurance(hand[4][1], hand, "value") == 4 or getValueOccurance(hand[5][1], hand, "value") == 4 or getValueOccurance(hand[6][1], hand, "value") == 4 then
		return "Four of a Kind"
	elseif checkForFullHouse(hand) then
		return "Full House"
	elseif getValueOccurance(hand[1][2], hand) == 5 or getValueOccurance(hand[2][2], hand) == 5 or getValueOccurance(hand[3][2], hand) == 5 or getValueOccurance(hand[4][2], hand) == 5 or getValueOccurance(hand[5][2], hand) == 5 or getValueOccurance(hand[6][2], hand) == 5 then
		return "5-Card Flush"
	elseif (hand[1][1] - 1 == hand[2][1] and hand[2][1] - 1 == hand[3][1] and hand[3][1] - 1 == hand[4][1] and hand[4][1] - 1 == hand[5][1]) or (hand[2][1] - 1 == hand[3][1] and hand[3][1] - 1 == hand[4][1] and hand[4][1] - 1 == hand[5][1] and hand[5][1] - 1 == hand[6][1]) then
		return "5-Card Straight"
	elseif getValueOccurance(hand[1][1], hand, "value") == 3 or getValueOccurance(hand[2][1], hand, "value") == 3 or getValueOccurance(hand[3][1], hand, "value") == 3 or getValueOccurance(hand[4][1], hand, "value") == 3 or getValueOccurance(hand[5][1], hand, "value") == 3 or getValueOccurance(hand[6][1], hand, "value") == 3 then
		return "Three of a Kind"
	end
end 

local function returnHighestCards(rank, hand)
	if rank == "Straight Flush" then
		return {hand[1][1], hand[2][1], hand[3][1]}
	elseif rank == "Three of a Kind" then
		return {hand[1][1], hand[2][1], hand[3][1]}
	elseif rank == "Straight" then
		return {hand[1][1], hand[2][1], hand[3][1]}
	elseif rank == "Flush" then
		return {hand[1][1], hand[2][1], hand[3][1]}
	elseif rank == "Pair" then
		if hand[1][1] == hand[2][1] then
			return {hand[1][1], hand[3][1], hand[2][1]}
		end
		if hand[2][1] == hand[3][1] then
			return {hand[2][1], hand[1][1], hand[3][1]}
		end
		if hand[1][1] == hand[3][1] then
			return {hand[1][1], hand[2][1], hand[3][1]}
		end
	else
		return {hand[1][1], hand[2][1], hand[3][1]}
	end
end

local function getHandResult(hand)
	table.sort(hand, function(a, b)
		return a[1] > b[1]
	end)
	
	if hand[1][2] == hand[2][2] and hand[2][2] == hand[3][2] and hand[1][1] - 1 == hand[2][1] and hand[2][1] - 1 == hand[3][1] then
		return "Straight Flush"
	elseif hand[1][1] == hand[2][1] and hand[2][1] == hand[3][1] then
		return "Three of a Kind"
	elseif hand[1][1] - 1 == hand[2][1] and hand[2][1] - 1 == hand[3][1] then
		return "Straight"
	elseif hand[1][2] == hand[2][2] and hand[2][2] == hand[3][2] then
		return "Flush"
	elseif hand[1][1] == hand[2][1] or hand[2][1] == hand[3][1] or hand[1][1] == hand[3][1] then
		return "Pair"
	end
	return "High Card"
end

local function getEmptyCard(player)
	for _, card in pairs(cards[player]:GetChildren()) do
		if card:GetAttribute("Card") == 0 then
			return card;
		end
	end
end

local function getPlayerStoolName(actualPlayer)
	for each, stool in pairs(functional.Stools:GetChildren()) do
		if stool.Seat.Occupant and stool.Seat.Occupant.Parent.Name == actualPlayer.Name then
			return stool.Name;
		end
	end
end

local function resetGameData()
	gameData = {};
	theOutcomeSet = {};
	turnPlayer = nil;
	for each, betFolder in pairs(bets:GetChildren()) do
		for each, bet in pairs(betFolder:GetChildren()) do
			bet.Transparency = 1;
			bet.BillboardGui.Enabled = false;
			bet.BillboardGui.Bet.Text = "";
			bet.BillboardGui.Winnings.Text = "";
		end
	end
	for each, turn in pairs(turns:GetChildren()) do
		turn.Transparency = 1;
		turn.BillboardGui.Enabled = false;
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
			local slotAdjustment = tonumber(string.sub(slot.Name, 5, 5));
			realCard.Orientation = Vector3.new(0, slot.Orientation.Y, 0);
			realCard.Position = slot.Position + Vector3.new(0, slotAdjustment * 0.001, 0); --move each card slightly to get rid of "z-fighting"
			realCard.Parent = slot;
		end
	end
end

local function dealCardToPlayer(player)
	local cardInfo = GameDataModule:GetPlayingCards(tableGame.Name)[random:NextInteger(1, 52)];
	local cardSlot = getEmptyCard(player);
	cardSlot:SetAttribute("Card", cardInfo[1]);
	cardSlot:SetAttribute("Suit", cardInfo[2]);
	cardSlot:SetAttribute("CardName", cardInfo[3]);
	ToggleCardVisualForSlot(true, cardSlot, cardInfo[3]);
end

local function toggleDealerAnimation(trackName, toggle, animation)
	if toggle then
		if animation then
			dealerAnimations[trackName] = dealer.Humanoid:LoadAnimation(animation);
		end
		dealerAnimations[trackName]:Play();
	else
		dealerAnimations[trackName]:Stop();
	end
end

local function removePlayerFromTable(player)
	tableGame:SetAttribute("WatchingPlayers", tableGame:GetAttribute("WatchingPlayers") - 1);

	for index, playerData in pairs(gameData) do
		if playerData[1] == player then
			if tableGame:GetAttribute("RoundStarted") then
				tableGame:SetAttribute("ActivePlayers", tableGame:GetAttribute("ActivePlayers") - 1);
			end

			if turnPlayer == playerData[2] then
				turnPlayer = nil;
			end
			
			gameData[index] = nil;
			
			break;
		end
	end

	for each, cardFolder in pairs(cards:GetChildren()) do
		if cardFolder.Name == player then
			for each, cardSlot in pairs(cardFolder:GetChildren()) do
				ToggleCardVisualForSlot(false, cardSlot, nil);
				cardSlot:SetAttribute("Card", 0);
				cardSlot:SetAttribute("Suit", 0);
				cardSlot:SetAttribute("CardName", "");
			end
		end
	end

	for each, betFolder in pairs(bets:GetChildren()) do
		if betFolder.Name == player then
			for each, bet in pairs(betFolder:GetChildren()) do
				bet.Transparency = 1;
				bet.BillboardGui.Enabled = false;
				bet.BillboardGui.Bet.Text = "";
				bet.BillboardGui.Winnings.Text = "";
			end
		end
	end
	for each, turn in pairs(turns:GetChildren()) do
		if turn.Name == player then
			turn.Transparency = 1;
			turn.BillboardGui.Enabled = false;
		end
	end
end

local function resetTable()
	tableGame:SetAttribute("ActivePlayers", 0);
	resetGameData();

	for each, cardFolder in pairs(cards:GetChildren()) do
		for each, cardSlot in pairs(cardFolder:GetChildren()) do
			ToggleCardVisualForSlot(false, cardSlot, nil);
			cardSlot:SetAttribute("Card", 0);
			cardSlot:SetAttribute("Suit", 0);
			cardSlot:SetAttribute("CardName", "");
		end
	end

	for each, animation in pairs(dealer.Animations:GetChildren()) do
		if animation.Name == "Idle" or (animation.Name == "DropCards" and tableGame:GetAttribute("RoundStarted")) then
			toggleDealerAnimation(animation.Name, true);
		else
			toggleDealerAnimation(animation.Name, false);
		end
	end

	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", false);
end

local function startNewRound()
	--Start a new round
	PlayVoiceline:Fire("RoundStarting", true);
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", true);

	--Get the players who are participating and collect their bets
	tableGame:SetAttribute("ActivePlayers", #gameData);
	for each, playerData in pairs(gameData) do
		if playerData[2]:IsA("Player") then
			PlayerAction:FireClient(playerData[2], "roundStarted");
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[4]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[5]);
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[6]);
		end
	end
	table.sort(gameData, function(a, b)
		if a and b then
			return tonumber(string.match(a[1], "%d")) < tonumber(string.match(b[1], "%d"))
		end
	end)

	--Dealer picks up the cards
	toggleDealerAnimation("PickupCards", true);
	dealerAnimations["PickupCards"].Stopped:Wait();
	toggleDealerAnimation("IdleCards", true);
	toggleDealerAnimation("Idle", false);

	--Dealer deals to all participating players
	for each, playerData in pairs(gameData) do
		if playerData[4] > 0 then
			toggleDealerAnimation(playerData[1].."Deal", true);

			local connection = dealerAnimations[playerData[1].."Deal"].KeyframeReached:Connect(function(keyframeName)
				if tableGame:GetAttribute("ActivePlayers") > 0 then
					if keyframeName == "DealCard" then
						dealCardToPlayer(playerData[1]);
					end
				end
			end)

			dealerAnimations[playerData[1].."Deal"].Stopped:Wait();
			connection:Disconnect();
		end
	end

	--Players take their turn deciding whether to play their hand or fold
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		for each, playerData in pairs(gameData) do
			if playerData[4] > 0 then
				turnPlayer = playerData[2];
				tableGame:SetAttribute("TimeBeforeTurnEnds", os.time() + tableGame:GetAttribute("MaxTimePerTurn"));
				
				if playerData[2]:IsA("Player") then
					PlayerAction:FireClient(playerData[2], "yourTurn");
				else
					local playerHand = {
						{cards[playerData[1]].Card1:GetAttribute("Card"), cards[playerData[1]].Card1:GetAttribute("Suit")},
						{cards[playerData[1]].Card2:GetAttribute("Card"), cards[playerData[1]].Card2:GetAttribute("Suit")},
						{cards[playerData[1]].Card3:GetAttribute("Card"), cards[playerData[1]].Card3:GetAttribute("Suit")}
					};
					local playerResult = getHandResult(playerHand);
					local playerHighestCards = returnHighestCards(playerResult, playerHand);
					local qualified = resultRanking[playerResult] > 1 or playerHighestCards[1] >= 12;
					if playerData[2]:FindFirstChild("PlayGame") then
						playerData[2].PlayGame.Response:Fire("ThreeCardPoker_YourTurn", qualified);
					end
				end
				
				turns[playerData[1]].Transparency = 0;
				turns[playerData[1]].BillboardGui.Enabled = true;
				
				repeat task.wait(); until 
					(not turnPlayer or os.time() >= tableGame:GetAttribute("TimeBeforeTurnEnds")) 
				and 
					not processingEvent;
				
				if os.time() >= tableGame:GetAttribute("TimeBeforeTurnEnds") then
					PlayVoiceline:Fire("Fold", true);
				end
				if playerData[2]:IsA("Player") then
					PlayerAction:FireClient(playerData[2], "noLongerYourTurn");
				end
				
				turns[playerData[1]].Transparency = 1;
				turns[playerData[1]].BillboardGui.Enabled = false;
			end
		end
	end

	--Dealer deals to themselves
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		toggleDealerAnimation("DealerDeal", true);

		local connection = dealerAnimations["DealerDeal"].KeyframeReached:Connect(function(keyframeName)
			if tableGame:GetAttribute("ActivePlayers") > 0 then
				if keyframeName == "DealCard" then
					dealCardToPlayer("Dealer");
				end
			end
		end)

		dealerAnimations["DealerDeal"].Stopped:Wait();
		connection:Disconnect();
	end

	--Results of the round are finalized
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		local dealerHand = {
			{cards.Dealer.Card1:GetAttribute("Card"), cards.Dealer.Card1:GetAttribute("Suit")},
			{cards.Dealer.Card2:GetAttribute("Card"), cards.Dealer.Card2:GetAttribute("Suit")},
			{cards.Dealer.Card3:GetAttribute("Card"), cards.Dealer.Card3:GetAttribute("Suit")}
		};
		local dealerResult = getHandResult(dealerHand);
		local dealerHighestCards = returnHighestCards(dealerResult, dealerHand);
		
		for player, playerData in pairs(gameData) do
			if playerData[4] > 0 then
				local playerHand = {
					{cards[playerData[1]].Card1:GetAttribute("Card"), cards[playerData[1]].Card1:GetAttribute("Suit")},
					{cards[playerData[1]].Card2:GetAttribute("Card"), cards[playerData[1]].Card2:GetAttribute("Suit")},
					{cards[playerData[1]].Card3:GetAttribute("Card"), cards[playerData[1]].Card3:GetAttribute("Suit")}
				};
				local playerResult = getHandResult(playerHand);
				local playerHighestCards = returnHighestCards(playerResult, playerHand);
				local playPayout = 0;
				local antePayout = 0;
				local pairPayout = 0;
				local bonusPayout = 0;
				local playerEnding;

				if not playerData[3] then --Did the player play their hand?
					if resultRanking[dealerResult] > 1 or dealerHighestCards[1] >= 12 then --Did the dealer qualify?
						if resultRanking[playerResult] > resultRanking[dealerResult] then
							playerEnding = "Won";
						elseif resultRanking[dealerResult] > resultRanking[playerResult] then
							playerEnding = "Lost";
						elseif playerHighestCards[1] > dealerHighestCards[1] then
							playerEnding = "Won";
						elseif dealerHighestCards[1] > playerHighestCards[1] then
							playerEnding = "Lost";
						elseif playerHighestCards[2] > dealerHighestCards[2] then -- compare nil < nil
							playerEnding = "Won";
						elseif dealerHighestCards[2] > playerHighestCards[2] then
							playerEnding = "Lost";
						elseif #playerHighestCards == 3 then
							if playerHighestCards[3] > dealerHighestCards[3] then
								playerEnding = "Won";
							elseif dealerHighestCards[3] > playerHighestCards[3] then
								playerEnding = "Lost";
							else
								playerEnding = "Tied";
							end
						else
							playerEnding = "Tied";
						end

						if playerEnding == "Won" then
							playPayout = playerData[4] * 2; --won play
							antePayout = playerData[4] * 2; --won ante
						end
					else
						playerEnding = "Won";
						playPayout = playerData[4]; --push play
						antePayout = playerData[4] * 2; --won ante
					end
				else
					playerEnding = "Lost";
				end

				if playerData[4] > 0 then --Did player make an ante bet?
					if not playerData[3] then --Only award ante bonuses if they played their hand
						if antePayouts[playerResult] then
							antePayout += playerData[4] * antePayouts[playerResult]; --won ante bonus
						end
					end
				end

				if playerData[5] > 0 then --Did player make a pair plus bet?
					if not playerData[3] or playerData[4] == 0 then --Only award if they played their hand or if they didn't bet ante at all
						if pairPayouts[playerResult] then
							pairPayout += playerData[5] * pairPayouts[playerResult]; --pair plus
						end
					end
				end
				
				local sixCardResult = getSixCardHandResult(dealerHand, playerHand);
				if playerData[6] > 0 then --Did player make a 6 card bonus bet?
					if sixCardResult then
						bonusPayout += playerData[6] * bonusPayouts[sixCardResult]; --bonus
					end
				end
				
				if (playerResult == "Three of a Kind" or playerResult == "Straight Flush") or sixCardResult then
					if playerData[2]:IsA("Player") then
						local winnings = 0;
						
						winnings += playPayout;
						if playerData[4] > 0 then --Did player make an ante bet?
							winnings += antePayout;
						end
						if playerData[5] > 0 then --Did player make a pair plus bet?
							winnings += pairPayout;
						end
						if playerData[6] > 0 then --Did player make a 6 card bonus bet?
							winnings += bonusPayout;
						end
						
						if winnings > 0 then
							Jackpot:FireAllClients(playerData[2], winnings);
						end
					end
				end

				PlayVoiceline:Fire(playerData[1]..playerEnding);

				if bets[playerData[1]].Play.BillboardGui.Enabled then
					if playPayout == 0 then
						bets[playerData[1]].Play.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[4]);
						bets[playerData[1]].Play.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						bets[playerData[1]].Play.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(playPayout);
						bets[playerData[1]].Play.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
					end
					
					bets[playerData[1]].Play.BillboardGui.Bet.Text = "";
					ProfileManager.AdjustCurrency(playerData[2], "Cash", playPayout);
				end
				if bets[playerData[1]].Ante.BillboardGui.Enabled then
					if antePayout == 0 then
						bets[playerData[1]].Ante.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[4]);
						bets[playerData[1]].Ante.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						bets[playerData[1]].Ante.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(antePayout);
						bets[playerData[1]].Ante.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
					end
					
					bets[playerData[1]].Ante.BillboardGui.Bet.Text = "";
					ProfileManager.AdjustCurrency(playerData[2], "Cash", antePayout);
				end
				if bets[playerData[1]].PairPlus.BillboardGui.Enabled then
					if pairPayout == 0 then
						bets[playerData[1]].PairPlus.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[5]);
						bets[playerData[1]].PairPlus.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						bets[playerData[1]].PairPlus.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(pairPayout);
						bets[playerData[1]].PairPlus.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
					end
					
					bets[playerData[1]].PairPlus.BillboardGui.Bet.Text = "";
					ProfileManager.AdjustCurrency(playerData[2], "Cash", pairPayout);
				end
				if bets[playerData[1]].Bonus.BillboardGui.Enabled then
					if bonusPayout == 0 then
						bets[playerData[1]].Bonus.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(playerData[6]);
						bets[playerData[1]].Bonus.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
					else
						bets[playerData[1]].Bonus.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(bonusPayout);
						bets[playerData[1]].Bonus.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
					end

					bets[playerData[1]].Bonus.BillboardGui.Bet.Text = "";
					ProfileManager.AdjustCurrency(playerData[2], "Cash", bonusPayout);
				end
			end
		end

		task.wait(tableGame:GetAttribute("TimeBetweenHands"));
	end

	--End the current round and start the next round if players are still present
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		for player, playerData in pairs(gameData) do
			if playerData[2]:IsA("Player") then
				PlayerAction:FireClient(playerData[2], "roundEnded");
			end
		end

		resetTable();

		for each, stool in pairs(functional.Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player and player:GetAttribute("Cash") then
					if player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
						if not tableGame:GetAttribute("RoundPending") then
							tableGame:SetAttribute("RoundPending", true);
							PlayVoiceline:Fire(stool.Name.."RoundStartingSoon", true);
						end
					end
				end
			end
		end
		
		for each, npc in pairs(tableGame.NPCs:GetChildren()) do
			if not tableGame:GetAttribute("RoundPending") then
				tableGame:SetAttribute("RoundPending", true);
				PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon", true);
			end
			if npc:FindFirstChild("PlayGame") then
				npc.PlayGame.Response:Fire("BetThreeCardPoker");
			end
		end
	end
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, playerBets)
	if not processingEvent then
		processingEvent = true;

		local player = GameFunctions:GetPlayerFromActualPlayer(actualPlayer, gameData);
		local playerData = GameFunctions:GetPlayerDataFromPlayer(player, gameData);

		if action == "Play" and turnPlayer == actualPlayer then
			if actualPlayer:GetAttribute("Cash") >= playerData[4] then
				PlayVoiceline:Fire("Play", true);
				ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[4]);
				bets[player].Play.Transparency = 0;
				bets[player].Play.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[4]);
				bets[player].Play.BillboardGui.Enabled = true;
				turnPlayer = nil;
			else
				PlayerAction:FireClient(playerData[2], "yourTurn");
			end
		elseif action == "Fold" and turnPlayer == actualPlayer then
			PlayVoiceline:Fire("Fold", true);
			playerData[3] = true;
			turnPlayer = nil;
		elseif action == "Bet" and not tableGame:GetAttribute("RoundStarted") then
			local anteNumber = 0;
			local pairNumber = 0;
			local bonusNumber = 0;
			local totalBet = 0;

			if tonumber(playerBets[1]) and tonumber(playerBets[1]) >= tableGame:GetAttribute("MinCash") and tonumber(playerBets[1]) <= tableGame:GetAttribute("MaxCash") then
				anteNumber = math.floor(playerBets[1]);
			end
			if tonumber(playerBets[2]) and tonumber(playerBets[2]) >= tableGame:GetAttribute("MinCash") and tonumber(playerBets[2]) <= tableGame:GetAttribute("MaxBonusCash") then
				pairNumber = math.floor(playerBets[2]);
			end
			if tonumber(playerBets[3]) and tonumber(playerBets[3]) >= tableGame:GetAttribute("MinCash") and tonumber(playerBets[3]) <= tableGame:GetAttribute("MaxBonusCash") then
				bonusNumber = math.floor(playerBets[3]);
			end

			if anteNumber == 0 and (pairNumber > 0 or bonusNumber > 0) then
				PlayerAction:FireClient(actualPlayer, "anteHint");
				pairNumber = 0;
				bonusNumber = 0;
			else
				totalBet = anteNumber + pairNumber + bonusNumber;
				if actualPlayer:GetAttribute("Cash") < totalBet then
					PlayerAction:FireClient(actualPlayer, "cashHint");
					anteNumber = 0;
					pairNumber = 0;
					bonusNumber = 0;
				end
			end
			
			if anteNumber > 0 then
				local stoolName = getPlayerStoolName(actualPlayer);
				local foundData;
				for each, playerData in pairs(gameData) do
					if playerData[1] == stoolName then
						foundData = playerData;
						playerData[4] = anteNumber;
						playerData[5] = pairNumber;
						playerData[6] = bonusNumber;
						break;
					end
				end

				if not foundData then
					foundData = {stoolName, actualPlayer, false, anteNumber, pairNumber, bonusNumber};
					table.insert(gameData, foundData);
				end

				if anteNumber > 0 then
					bets[stoolName].Ante.Transparency = 0;
					bets[stoolName].Ante.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[4]);
					bets[stoolName].Ante.BillboardGui.Enabled = true;
				else
					bets[stoolName].Ante.Transparency = 1;
					bets[stoolName].Ante.BillboardGui.Bet.Text = "";
					bets[stoolName].Ante.BillboardGui.Enabled = false;
				end
				if pairNumber > 0 then
					bets[stoolName].PairPlus.Transparency = 0;
					bets[stoolName].PairPlus.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[5]);
					bets[stoolName].PairPlus.BillboardGui.Enabled = true;
				else
					bets[stoolName].PairPlus.Transparency = 1;
					bets[stoolName].PairPlus.BillboardGui.Bet.Text = "";
					bets[stoolName].PairPlus.BillboardGui.Enabled = false;
				end
				if bonusNumber > 0 then
					bets[stoolName].Bonus.Transparency = 0;
					bets[stoolName].Bonus.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[6]);
					bets[stoolName].Bonus.BillboardGui.Enabled = true;
				else
					bets[stoolName].Bonus.Transparency = 1;
					bets[stoolName].Bonus.BillboardGui.Bet.Text = "";
					bets[stoolName].Bonus.BillboardGui.Enabled = false;
				end
			end
		end

		processingEvent = false;
	end
end)

tableGame:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if tableGame:GetAttribute("RoundPending") then
		local success = true;

		repeat task.wait(0.5); until #gameData > 0

		for i = tableGame:GetAttribute("TimeToBet"), 0, -1 do
			if not tableGame:GetAttribute("RoundPending") then
				success = false;
				break;
			end

			if i ~= 0 then
				for i = 0, 1, 0.05 do
					if not tableGame:GetAttribute("RoundPending") then
						break;
					end
					task.wait(0.05);
				end
			end
		end

		if success then
			startNewRound();
		end
	end
end)

local function initialize()
	minCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MinCash"));
	maxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxCash"));
	maxBonusCash.SurfaceGui.TextLabel.Text = "BONUS MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxBonusCash"));
	minCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	maxCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	maxBonusCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	decoration.Table.Base.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	decoration.Table.Ring.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	decoration.Table.Table.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Salt or Enum.Material.Plastic;

	script.Voicelines.Enabled = true;

	for each, animation in pairs(dealer.Animations:GetChildren()) do
		toggleDealerAnimation(animation.Name, true, animation);
	end
	for each, animation in pairs(dealer.Animations:GetChildren()) do
		if animation.Name ~= "Idle" then
			toggleDealerAnimation(animation.Name, false);
		end
	end
	GameFunctions:GiveDealerNametag(dealer);

	resetGameData();

	for each, stool in pairs(functional.Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			if stool.Seat.Occupant then
				tableGame:SetAttribute("WatchingPlayers", tableGame:GetAttribute("WatchingPlayers") + 1);

				local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
						if player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
							PlayVoiceline:Fire(stool.Name.."Welcome");
							local gui = script.ThreeCardPoker:Clone();
							gui.ActualTable.Value = tableGame;
							gui.Parent = player.PlayerGui;
							if not tableGame:GetAttribute("RoundStarted") and not tableGame:GetAttribute("RoundPending") then
								tableGame:SetAttribute("RoundPending", true);
								PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							end
						end
					end
				end
			else
				removePlayerFromTable(stool.Name);

				if tableGame:GetAttribute("ActivePlayers") == 0 and tableGame:GetAttribute("RoundStarted") then
					resetTable();
					for each, stool in pairs(functional.Stools:GetChildren()) do
						if stool.Seat.Occupant then
							tableGame:SetAttribute("RoundPending", true);
							PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							break;
						end
						for each, npc in pairs(tableGame.NPCs:GetChildren()) do
							if not tableGame:GetAttribute("RoundPending") then
								tableGame:SetAttribute("RoundPending", true);
								PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon", true);
							end
							if npc:FindFirstChild("PlayGame") then
								npc.PlayGame.Response:Fire("BetThreeCardPoker");
							end
						end
					end
				end
			end
			
			if tableGame:GetAttribute("WatchingPlayers") == 0 then
				resetTable();
			end
		end)
	end
end

PlayNPC.Event:Connect(function(npc, action)
	local player = GameFunctions:GetPlayerFromActualPlayer(npc, gameData);
	local playerData = GameFunctions:GetPlayerDataFromPlayer(player, gameData);
	
	if action == "arriving" then
		PlayVoiceline:Fire(npc:GetAttribute("Stool").."Welcome");
		if not tableGame:GetAttribute("RoundStarted") and not tableGame:GetAttribute("RoundPending") then
			tableGame:SetAttribute("RoundPending", true);
			PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon");
		end
	elseif action == "leaving" then
		tableGame:SetAttribute("NPCsAtGame", tableGame:GetAttribute("NPCsAtGame") - 1);
	elseif action == "bet" and not tableGame:GetAttribute("RoundStarted") then
		local anteNumber = random:NextInteger(tableGame:GetAttribute("MinCash"), tableGame:GetAttribute("MaxCash"));
		local pairNumber = random:NextNumber() <= 0.5 and random:NextInteger(tableGame:GetAttribute("MinCash"), tableGame:GetAttribute("MaxBonusCash")) or 0;
		local bonusNumber = random:NextNumber() <= 0.5 and random:NextInteger(tableGame:GetAttribute("MinCash"), tableGame:GetAttribute("MaxBonusCash")) or 0;
		local foundData;

		for each, playerData in pairs(gameData) do
			if playerData[1] == npc:GetAttribute("Stool") then
				foundData = playerData;
				playerData[4] = anteNumber;
				playerData[5] = pairNumber;
				playerData[6] = bonusNumber;
				break;
			end
		end

		if not foundData then
			foundData = {npc:GetAttribute("Stool"), npc, false, anteNumber, pairNumber, bonusNumber};
			table.insert(gameData, foundData);
		end

		if anteNumber > 0 then
			bets[npc:GetAttribute("Stool")].Ante.Transparency = 0;
			bets[npc:GetAttribute("Stool")].Ante.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[4]);
			bets[npc:GetAttribute("Stool")].Ante.BillboardGui.Enabled = true;
		else
			bets[npc:GetAttribute("Stool")].Ante.Transparency = 1;
			bets[npc:GetAttribute("Stool")].Ante.BillboardGui.Bet.Text = "";
			bets[npc:GetAttribute("Stool")].Ante.BillboardGui.Enabled = false;
		end
		if pairNumber > 0 then
			bets[npc:GetAttribute("Stool")].PairPlus.Transparency = 0;
			bets[npc:GetAttribute("Stool")].PairPlus.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[5]);
			bets[npc:GetAttribute("Stool")].PairPlus.BillboardGui.Enabled = true;
		else
			bets[npc:GetAttribute("Stool")].PairPlus.Transparency = 1;
			bets[npc:GetAttribute("Stool")].PairPlus.BillboardGui.Bet.Text = "";
			bets[npc:GetAttribute("Stool")].PairPlus.BillboardGui.Enabled = false;
		end
		if bonusNumber > 0 then
			bets[npc:GetAttribute("Stool")].Bonus.Transparency = 0;
			bets[npc:GetAttribute("Stool")].Bonus.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[6]);
			bets[npc:GetAttribute("Stool")].Bonus.BillboardGui.Enabled = true;
		else
			bets[npc:GetAttribute("Stool")].Bonus.Transparency = 1;
			bets[npc:GetAttribute("Stool")].Bonus.BillboardGui.Bet.Text = "";
			bets[npc:GetAttribute("Stool")].Bonus.BillboardGui.Enabled = false;
		end
	elseif action == "play" and turnPlayer == npc then
		PlayVoiceline:Fire("Play", true);
		bets[npc:GetAttribute("Stool")].Play.Transparency = 0;
		bets[npc:GetAttribute("Stool")].Play.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[4]);
		bets[npc:GetAttribute("Stool")].Play.BillboardGui.Enabled = true;
		turnPlayer = nil;
	elseif action == "fold" and turnPlayer == npc then
		PlayVoiceline:Fire("Fold", true);
		playerData[3] = true;
		turnPlayer = nil;
	end
end)

initialize();