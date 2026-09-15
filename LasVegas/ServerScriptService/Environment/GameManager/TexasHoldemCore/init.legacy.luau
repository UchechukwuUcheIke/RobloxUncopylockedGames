local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local GameDataModule = require(ReplicatedStorage.Modules.GameData);
local Jackpot = ReplicatedStorage.Remotes.Jackpot;
local Card = require(script.Card);
local Prob = require(script.Prob);
local Lookup = require(script.Lookup);
local Analysis = require(script.Analysis);
local tableGame = script.Parent;
local tableGameRemotes = tableGame.Remotes;
local functional = tableGame.Functional;
local PlayNPC = tableGameRemotes.PlayNPC;
local PlayVoiceline = tableGameRemotes.PlayVoiceline;
local PlayerAction = tableGameRemotes.PlayerAction;
local dealer = functional.Dealer;
local cards = functional.Cards;
local bets = functional.Bets;
local turns = functional.Turns;
local symbols = functional.Symbols;
local stools = functional.Stools;
local cardDeck = dealer.CardDeck;

local random = Random.new();
local dealerAnimations = {};
local gameData = {}; -- {stoolName, actualPlayer, amountBetted, finalRank, leftTable}
local theOutcomeSet = {}; -- {{"ace", "spades"}, {"ace", "spades"}, {"ace", "spades"}, {"ace", "spades"}}
local shuffledDeck;
local turnPlayer;
local processingEvent = false;

local lastPlayerWhoBet;
local turnCanConclude = true;
local highestBetActive = 0;
local communityPot = 0;

local function resetGameData()
	gameData = {};
	theOutcomeSet = {};
	shuffledDeck = nil;
	turnPlayer = nil;
	lastPlayerWhoBet = nil;
	turnCanConclude = true;
	highestBetActive = 0;
	communityPot = 0;
end

local function getEndHandResult(player)
	local hand = {
		Card.new(cards[player].Card1:GetAttribute("Card"), cards[player].Card1:GetAttribute("Suit")), 
		Card.new(cards[player].Card2:GetAttribute("Card"), cards[player].Card2:GetAttribute("Suit"))
	};
	local board = {
		Card.new(cards.Community.Card1:GetAttribute("Card"), cards.Community.Card1:GetAttribute("Suit")),
		Card.new(cards.Community.Card2:GetAttribute("Card"), cards.Community.Card2:GetAttribute("Suit")),
		Card.new(cards.Community.Card3:GetAttribute("Card"), cards.Community.Card3:GetAttribute("Suit")),
		Card.new(cards.Community.Card4:GetAttribute("Card"), cards.Community.Card4:GetAttribute("Suit")),
		Card.new(cards.Community.Card5:GetAttribute("Card"), cards.Community.Card5:GetAttribute("Suit"))
	};
	local rank, percentile = Analysis.evaluate(hand, board); --the lower the rank, the better the hand is
	return rank;
end

local function getEmptyCard(player)
	for cardIndex, _ in pairs(cards[player]:GetChildren()) do
		local card = cards[player]["Card"..cardIndex];
		if card:GetAttribute("Card") == 0 then
			return card;
		end
	end
end

local function dealCardToPlayer(player)
	if not shuffledDeck then
		shuffledDeck = {unpack(GameDataModule:GetPlayingCards(tableGame.Name))};
	end
	local randomIndex = random:NextInteger(1, #shuffledDeck);
	local cardInfo = shuffledDeck[randomIndex];		
	table.remove(shuffledDeck, randomIndex);
	
	local card = getEmptyCard(player);
	card:SetAttribute("Card", cardInfo[1]); --attempt to index nil with number
	card:SetAttribute("Suit", cardInfo[2]);
	card.Transparency = 0;
	if player == "Community" then
		card.SurfaceGui.ImageLabel.Image = cardInfo[3];
	else
		card.SurfaceGui.ImageLabel.Image = "rbxassetid://11619654554";
		card:SetAttribute("ImageID", cardInfo[3]);
	end
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

local function resetTable()
	tableGame:SetAttribute("ActivePlayers", 0);
	resetGameData();

	for each, imageLabel in pairs(cards:GetDescendants()) do
		if imageLabel:IsA("ImageLabel") then
			imageLabel.Image = "";
			imageLabel.Parent.Parent:SetAttribute("Card", 0);
			imageLabel.Parent.Parent:SetAttribute("Suit", 0);
			imageLabel.Parent.Parent.Transparency = 1;
		end
	end
	
	for each, currency in pairs(bets:GetDescendants()) do
		if currency:IsA("BasePart") then
			currency.Transparency = 1;
		elseif currency:IsA("TextLabel") then
			currency.Text = "";
		end
	end
	
	for each, turn in pairs(turns:GetChildren()) do
		turn.Transparency = 1;
		turn.BillboardGui.Enabled = false;
	end
	
	for each, symbol in pairs(symbols:GetDescendants()) do
		if symbol:IsA("BasePart") then
			symbol.Transparency = 1;
			symbol.BillboardGui.Enabled = false;
		end
	end
	
	for each, stool in pairs(stools:GetChildren()) do
		stool:SetAttribute("AlreadyBet", 0);
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

local function removePlayerFromTable(player)
	for each, playerData in pairs(gameData) do
		if playerData[1] == player and not playerData[5] then
			tableGame:SetAttribute("ActivePlayers", tableGame:GetAttribute("ActivePlayers") - 1);
			
			if playerData[2] and playerData[2]:IsA("Player") then
				PlayerAction:FireClient(playerData[2], "noLongerYourTurn");
			end
			
			if turnPlayer == playerData[2] then
				turnPlayer = nil;
			end
			
			playerData[5] = true;
			break;
		end
	end
	
	if stools[player]:GetAttribute("AlreadyBet") > 0  then
		communityPot += stools[player]:GetAttribute("AlreadyBet");
		
		local betType;
		if communityPot >= tableGame:GetAttribute("MaxCash") * 5 then
			betType = bets.Community.Large;
		elseif communityPot >= tableGame:GetAttribute("MaxCash") * 2 then
			betType = bets.Community.Medium;
		else
			betType = bets.Community.Small;
		end
		
		bets.Community.Base.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(communityPot);
		
		for each, currency in pairs(betType:GetChildren()) do
			currency.Transparency = 0;
		end
		
		stools[player]:SetAttribute("AlreadyBet", 0);
	end
	
	for each, thing in pairs(cards:GetDescendants()) do
		if thing:IsA("ImageLabel") and thing.Parent.Parent.Parent.Name == player then
			thing.Image = "";
			thing.Parent.Parent:SetAttribute("Card", 0);
			thing.Parent.Parent:SetAttribute("Suit", 0);
			thing.Parent.Parent.Transparency = 1;
		end
	end
	
	for each, thing in pairs(bets:GetDescendants()) do
		if thing:IsA("BasePart") and thing.Parent.Parent.Name == player then
			thing.Transparency = 1;
		elseif thing:IsA("TextLabel") and thing.Parent.Parent.Parent.Name == player then
			thing.Text = "";
		end
	end
	
	for each, turn in pairs(turns:GetChildren()) do
		if turn.Name == player then
			turn.Transparency = 1;
			turn.BillboardGui.Enabled = false;
		end
	end
end

local function displayPlayerBet(player, betAmount)
	local betType;
	
	if player ~= "Community" then
		if betAmount >= tableGame:GetAttribute("MaxCash") * 0.5 then
			GameFunctions:PlaySound("TexasHoldem", "UhOh", functional.Dealer.Head, false, false, false);
			betType = bets[player].Large;
		elseif betAmount >= tableGame:GetAttribute("MaxCash") * 0.2 then
			betType = bets[player].Medium;
		else
			betType = bets[player].Small;
		end
		bets[player].Base.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(betAmount);
	else
		if communityPot >= tableGame:GetAttribute("MaxCash") * 5 then
			betType = bets.Community.Large;
		elseif communityPot >= tableGame:GetAttribute("MaxCash") * 2 then
			betType = bets.Community.Medium;
		else
			betType = bets.Community.Small;
		end
		bets.Community.Base.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(communityPot);
	end
	
	for each, currency in pairs(betType:GetChildren()) do
		currency.Transparency = 0;
	end
end

local function doPlayerTurnCycle()
	for each, playerData in pairs(gameData) do
		if lastPlayerWhoBet == playerData[2] then
			turnCanConclude = true;
			break;
		end
		
		if not playerData[5] then
			turnPlayer = playerData[2];
			tableGame:SetAttribute("TimeBeforeTurnEnds", os.time() + tableGame:GetAttribute("MaxTimePerTurn"));
			
			if playerData[2]:IsA("Player") then
				PlayerAction:FireClient(playerData[2], "yourTurn");
			elseif playerData[2]:FindFirstChild("PlayGame") then
				playerData[2].PlayGame.Response:Fire("TexasHoldem_YourTurn", {cards[playerData[1]], highestBetActive});
			end
			
			turns[playerData[1]].Transparency = 0;
			turns[playerData[1]].BillboardGui.Enabled = true;
			
			repeat task.wait(); until (not turnPlayer or os.time() >= tableGame:GetAttribute("TimeBeforeTurnEnds")) and not processingEvent;
			
			if not playerData[5] then
				if playerData[2]:IsA("Player") then
					PlayerAction:FireClient(playerData[2], "noLongerYourTurn");
				end
				if os.time() >= tableGame:GetAttribute("TimeBeforeTurnEnds") and turnPlayer == playerData[2] then
					PlayVoiceline:Fire("Fold", true);
					removePlayerFromTable(playerData[1]);
				end
			end
			
			turns[playerData[1]].Transparency = 1;
			turns[playerData[1]].BillboardGui.Enabled = false;
		end
	end

	if not turnCanConclude and tableGame:GetAttribute("ActivePlayers") > 0 then
		doPlayerTurnCycle();
	end
end

local function setupCurrentTurn()
	lastPlayerWhoBet = nil;
	turnCanConclude = true;
	highestBetActive = 0;
end

local function concludeCurrentTurn()
	task.wait(1);
	
	for each, playerData in pairs(gameData) do
		if not playerData[5] then
			communityPot += highestBetActive;
		end
	end
	displayPlayerBet("Community");
	
	for each, stool in pairs(stools:GetChildren()) do
		stool:SetAttribute("AlreadyBet", 0);
	end
	
	for each, thing in pairs(bets:GetDescendants()) do
		if thing:IsA("BasePart") and thing.Parent.Parent.Name ~= "Community" then
			thing.Transparency = 1;
		elseif thing:IsA("TextLabel") and thing.Parent.Parent.Parent.Name ~= "Community" then
			thing.Text = "";
		end
	end
end

local function verifyNewRoundCanQueue()
	if tableGame:GetAttribute("WaitingPlayers") >= 2 then
		if not tableGame:GetAttribute("RoundStarted") and not tableGame:GetAttribute("RoundPending") then
			tableGame:SetAttribute("RoundPending", true);
		end
	end
end

local function startNewRound()
	--Start a new round
	PlayVoiceline:Fire("RoundStarting", true); 
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", true);
	tableGame:SetAttribute("WaitingPlayers", 0);
	
	--Get the players who are participating and put their buy-in cash into the pot
	for each, stool in pairs(stools:GetChildren()) do
		if stool.Seat.Occupant then
			if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
				local actualPlayer = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if actualPlayer then
					if actualPlayer:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
						ProfileManager.AdjustCurrency(actualPlayer, "Cash", -tableGame:GetAttribute("MinCash"));
						tableGame:SetAttribute("ActivePlayers", tableGame:GetAttribute("ActivePlayers") + 1);
						communityPot += tableGame:GetAttribute("MinCash");
						table.insert(gameData, {stool.Name, actualPlayer, tableGame:GetAttribute("MinCash"), math.huge, false});
					end
				end
			end
		end
	end
	for each, npc in pairs(tableGame.NPCs:GetChildren()) do
		tableGame:SetAttribute("ActivePlayers", tableGame:GetAttribute("ActivePlayers") + 1);
		communityPot += tableGame:GetAttribute("MinCash");
		table.insert(gameData, {npc:GetAttribute("Stool"), npc, tableGame:GetAttribute("MinCash"), math.huge, false});
	end
	table.sort(gameData, function(a, b)
		if a and b then
			return tonumber(string.match(a[1], "%d")) < tonumber(string.match(b[1], "%d"))
		end
	end)
	--[[if gameData[1][1] == "Player10" then
		table.insert(gameData, gameData[1]);
		table.remove(gameData, 1);
	end--]]
	displayPlayerBet("Community");
	
	--Dealer picks up the cards
	toggleDealerAnimation("PickupCards", true);
	dealerAnimations["PickupCards"].Stopped:Wait();
	toggleDealerAnimation("IdleCards", true);
	toggleDealerAnimation("Idle", false);
	
	--Dealer deals to all participating players
	for each, playerData in pairs(gameData) do
		if not playerData[5] then
			toggleDealerAnimation(playerData[1].."Deal", true);

			local connection = dealerAnimations[playerData[1].."Deal"].KeyframeReached:Connect(function(keyframeName)
				if keyframeName == "DealCard" then
					dealCardToPlayer(playerData[1]);
				end
			end)

			dealerAnimations[playerData[1].."Deal"].Stopped:Wait();
			connection:Disconnect();
		end
	end
	
	--Dealer waits for all players to complete their first turn (check, call, bet, raise, or fold)
	if tableGame:GetAttribute("ActivePlayers") > 1 then
		setupCurrentTurn();
		doPlayerTurnCycle();
		concludeCurrentTurn();
	end
	
	--Dealer reveals the first three community cards (the flop)
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		toggleDealerAnimation("TheFlop", true);

		local connection = dealerAnimations["TheFlop"].KeyframeReached:Connect(function(keyframeName)
			if keyframeName == "DealCard" then
				dealCardToPlayer("Community");
			end
		end)

		dealerAnimations["TheFlop"].Stopped:Wait();
		connection:Disconnect();
	end
	
	--Dealer waits for all players to complete their second turn (check, call, bet, raise, or fold)
	if tableGame:GetAttribute("ActivePlayers") > 1 then
		setupCurrentTurn();
		doPlayerTurnCycle();
		concludeCurrentTurn();
	end
	
	--Dealer reveals the fourth community card (the turn)
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		toggleDealerAnimation("TheTurn", true);

		local connection = dealerAnimations["TheTurn"].KeyframeReached:Connect(function(keyframeName)
			if keyframeName == "DealCard" then
				dealCardToPlayer("Community");
			end
		end)

		dealerAnimations["TheTurn"].Stopped:Wait();
		connection:Disconnect();
	end
	
	--Dealer waits for all players to complete their third turn (check, call, bet, raise, or fold)
	if tableGame:GetAttribute("ActivePlayers") > 1 then
		setupCurrentTurn();
		doPlayerTurnCycle();
		concludeCurrentTurn();
	end
	
	--Dealer reveals the fifth and final community card (the river)
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		toggleDealerAnimation("TheRiver", true);

		local connection = dealerAnimations["TheRiver"].KeyframeReached:Connect(function(keyframeName)
			if keyframeName == "DealCard" then
				dealCardToPlayer("Community");
			end
		end)

		dealerAnimations["TheRiver"].Stopped:Wait();
		connection:Disconnect();
	end
	
	--Dealer waits for all players to complete their fourth and final turn (check, call, bet, raise, or fold)
	if tableGame:GetAttribute("ActivePlayers") > 1 then
		setupCurrentTurn();
		doPlayerTurnCycle();
		concludeCurrentTurn();
	end
	
	--All players reveal their hands and whoever has the best 5 hand combination wins the pot (the showdown)
	if tableGame:GetAttribute("ActivePlayers") > 0 then
		task.wait(1);
		for each, playerData in pairs(gameData) do
			if not playerData[5] then
				cards[playerData[1]].Card1.SurfaceGui.ImageLabel.Image = cards[playerData[1]].Card1:GetAttribute("ImageID");
				cards[playerData[1]].Card2.SurfaceGui.ImageLabel.Image = cards[playerData[1]].Card2:GetAttribute("ImageID");
			end
		end
		GameFunctions:PlaySound("TexasHoldem", "Showdown", functional.Dealer.Head, false, false, false);
		task.wait(3);
		
		if tableGame:GetAttribute("ActivePlayers") > 0 then
			local winners = {};

			for each, playerData in pairs(gameData) do
				if not playerData[5] and playerData[3] > 0 then
					playerData[4] = getEndHandResult(playerData[1]);
				end
			end

			if #gameData > 1 then
				table.sort(gameData, function(a, b)
					if a and b then
						return a[4] < b[4]
					end
				end)
			end
			table.insert(winners, gameData[1]);

			if tableGame:GetAttribute("ActivePlayers") > 1 then
				if gameData[1] then
					for each, playerData in pairs(gameData) do
						if not playerData[5] and playerData[4] == gameData[1][4] and not table.find(winners, playerData) then
							table.insert(winners, playerData);
						end
					end
				end
			end

			for each, playerData in pairs(winners) do
				PlayVoiceline:Fire(playerData[1].."Won");
				symbols[playerData[1]].Winner.Transparency = 0;
				symbols[playerData[1]].Winner.BillboardGui.Enabled = true;
				
				if playerData[2]:IsA("Player") then
					local winnings = math.floor(communityPot/#winners);
					ProfileManager.AdjustCurrency(playerData[2], "Cash", winnings);
					PlayerAction:FireClient(playerData[2], "showWinnings", {winnings});
					Jackpot:FireAllClients(playerData[2], winnings);
					
					if #winners == 1 and communityPot >= 5000 then
						if CommonFunctions:CheckBadgeOwnership(playerData[2].UserId, 3697633229323182) == false then
							CommonFunctions:AwardBadge(playerData[2], 3697633229323182, false);
						end
					end
				end
			end

			task.wait(tableGame:GetAttribute("TimeBetweenHands"));
		end
	end
	
	--End the current round and start the next round if players are still present
	resetTable();
	tableGame:SetAttribute("WaitingPlayers", 0);
	
	for each, stool in pairs(functional.Stools:GetChildren()) do
		if stool.Seat.Occupant then
			local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
			if player then
				PlayerAction:FireClient(player, "roundEnded");
				if player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
					tableGame:SetAttribute("WaitingPlayers", tableGame:GetAttribute("WaitingPlayers") + 1);
					if tableGame:GetAttribute("WaitingPlayers") == 2 then
						PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
					end
				end
			end
		end
	end
	
	for each, npc in pairs(tableGame.NPCs:GetChildren()) do
		tableGame:SetAttribute("WaitingPlayers", tableGame:GetAttribute("WaitingPlayers") + 1);
		if tableGame:GetAttribute("WaitingPlayers") == 2 then
			PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon");
		end
	end
	
	verifyNewRoundCanQueue();
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, betAmount)
	if turnPlayer == actualPlayer and not processingEvent then
		processingEvent = true;
		
		local player = GameFunctions:GetPlayerFromActualPlayer(actualPlayer, gameData);
		local playerData = GameFunctions:GetPlayerDataFromPlayer(player, gameData);
		
		if action == "Check" then
			if highestBetActive == 0 then
				PlayVoiceline:Fire("Check", true);
				turnPlayer = nil;
			else
				PlayerAction:FireClient(actualPlayer, "yourTurn");
			end
		elseif action == "Fold" then
			PlayVoiceline:Fire("Fold", true);
			turnPlayer = nil;
			removePlayerFromTable(player);
		elseif action == "Bet" then
			local amount = tonumber(betAmount);
			if amount then
				local legitAmount = math.floor(amount);
				if legitAmount >= tableGame:GetAttribute("MinCash") and legitAmount <= tableGame:GetAttribute("MaxCash") and highestBetActive == 0 and actualPlayer:GetAttribute("Cash") >= legitAmount then
					if legitAmount == actualPlayer:GetAttribute("Cash") then
						PlayVoiceline:Fire("AllIn", true);
					else
						PlayVoiceline:Fire("Bet", true);
					end

					highestBetActive = legitAmount;
					playerData[3] += highestBetActive;
					stools[player]:SetAttribute("AlreadyBet", highestBetActive);
					lastPlayerWhoBet = actualPlayer;
					turnCanConclude = false;

					ProfileManager.AdjustCurrency(actualPlayer, "Cash", -legitAmount);
					displayPlayerBet(player, highestBetActive);
					turnPlayer = nil;
				else
					PlayerAction:FireClient(actualPlayer, "yourTurn");
				end
			end
		elseif action == "Call" then
			if highestBetActive > 0 then
				local amountToCall = highestBetActive - stools[player]:GetAttribute("AlreadyBet");
				local amountPlayerCanCall = actualPlayer:GetAttribute("Cash") - highestBetActive;
				if amountToCall == 0 then
					amountToCall = highestBetActive;
				end
				
				if amountPlayerCanCall <= 0 then
					PlayVoiceline:Fire("AllIn", true);
					
					amountPlayerCanCall = actualPlayer:GetAttribute("Cash");
					playerData[3] += amountPlayerCanCall;
					stools[player]:SetAttribute("AlreadyBet", amountPlayerCanCall);
					
					ProfileManager.AdjustCurrency(actualPlayer, "Cash", -amountPlayerCanCall);
					displayPlayerBet(player, amountPlayerCanCall);
					turnPlayer = nil;
				elseif actualPlayer:GetAttribute("Cash") >= amountToCall then
					PlayVoiceline:Fire("Call", true);

					playerData[3] += amountToCall;
					stools[player]:SetAttribute("AlreadyBet", highestBetActive);

					ProfileManager.AdjustCurrency(actualPlayer, "Cash", -amountToCall);
					displayPlayerBet(player, highestBetActive);
					turnPlayer = nil;
				end
			else
				PlayerAction:FireClient(actualPlayer, "yourTurn");
			end
		elseif action == "Raise" then
			local amount = tonumber(betAmount);
			if amount then
				local legitAmount = math.floor(amount);
				if legitAmount >= tableGame:GetAttribute("MinCash") and legitAmount + highestBetActive <= tableGame:GetAttribute("MaxCash") and highestBetActive > 0 and actualPlayer:GetAttribute("Cash") >= highestBetActive + legitAmount then
					PlayVoiceline:Fire("Raise", true);

					highestBetActive = highestBetActive + legitAmount;
					playerData[3] += highestBetActive;
					stools[player]:SetAttribute("AlreadyBet", highestBetActive);
					lastPlayerWhoBet = actualPlayer;
					turnCanConclude = false;

					ProfileManager.AdjustCurrency(actualPlayer, "Cash", -highestBetActive);
					displayPlayerBet(player, highestBetActive);
					turnPlayer = nil;
				else
					PlayerAction:FireClient(actualPlayer, "yourTurn");
				end
			end
		end
		
		processingEvent = false;
	end
end)

tableGame:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if tableGame:GetAttribute("RoundPending") then
		local success = true;
		
		for i = tableGame:GetAttribute("TimeBetweenHands"), 0, -1 do
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
	tableGame.Functional.MinCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MinCash"));
	tableGame.Functional.MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxCash"));
	tableGame.Functional.MinCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	tableGame.Functional.MaxCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	tableGame.Decoration.Table.Base.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	tableGame.Decoration.Table.Ring.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	tableGame.Decoration.Table.Table.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Salt or Enum.Material.Plastic;
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

	for each, stool in pairs(stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			if stool.Seat.Occupant then
				tableGame:SetAttribute("WaitingPlayers", tableGame:GetAttribute("WaitingPlayers") + 1);
				
				if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
					local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
					if player then
						if player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
							PlayVoiceline:Fire(stool.Name.."Welcome");
							local gui = script.TexasHoldem:Clone();
							gui.ActualTable.Value = tableGame;
							gui.Parent = player.PlayerGui;
							if tableGame:GetAttribute("WaitingPlayers") == 2 then
								PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							end
						end
					end
				end
			else
				removePlayerFromTable(stool.Name);
				
				if tableGame:GetAttribute("RoundStarted") and tableGame:GetAttribute("ActivePlayers") == 0 then
					resetTable();
					verifyNewRoundCanQueue();
				end
			end
			
			if tableGame:GetAttribute("WaitingPlayers") < 2 and tableGame:GetAttribute("RoundPending") then
				resetTable();
			end
			verifyNewRoundCanQueue();
		end)
	end
end

PlayNPC.Event:Connect(function(npc, action, amount)
	local player = GameFunctions:GetPlayerFromActualPlayer(npc, gameData);
	local playerData = GameFunctions:GetPlayerDataFromPlayer(player, gameData);

	if action == "arriving" then
		PlayVoiceline:Fire(npc:GetAttribute("Stool").."Welcome");
		if tableGame:GetAttribute("WaitingPlayers") == 2 then
			PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon");
		end
		verifyNewRoundCanQueue();
	elseif action == "leaving" then
		tableGame:SetAttribute("NPCsAtGame", tableGame:GetAttribute("NPCsAtGame") - 1);
	elseif action == "check" then
		PlayVoiceline:Fire("Check", true);
		turnPlayer = nil;
	elseif action == "fold" then
		PlayVoiceline:Fire("Fold", true);
		turnPlayer = nil;
		removePlayerFromTable(player);
	elseif action == "bet" and playerData then
		PlayVoiceline:Fire("Bet", true);
		highestBetActive = amount;
		playerData[3] += highestBetActive;
		stools[player]:SetAttribute("AlreadyBet", highestBetActive);
		lastPlayerWhoBet = npc;
		turnCanConclude = false;
		displayPlayerBet(player, highestBetActive);
		turnPlayer = nil;
	elseif action == "call" and playerData then
		local amountToCall = highestBetActive - stools[player]:GetAttribute("AlreadyBet");
		PlayVoiceline:Fire("Call", true);
		playerData[3] += amountToCall;
		stools[player]:SetAttribute("AlreadyBet", highestBetActive);
		displayPlayerBet(player, highestBetActive);
		turnPlayer = nil;
	elseif action == "raise" and playerData then
		local legitAmount = math.floor(amount);
		if legitAmount >= tableGame:GetAttribute("MinCash") and legitAmount + highestBetActive <= tableGame:GetAttribute("MaxCash") and highestBetActive > 0 then
			PlayVoiceline:Fire("Raise", true);
			highestBetActive = highestBetActive + amount;
			playerData[3] += highestBetActive;
			stools[player]:SetAttribute("AlreadyBet", highestBetActive);
			lastPlayerWhoBet = npc;
			turnCanConclude = false;
			displayPlayerBet(player, highestBetActive);
			turnPlayer = nil;
		else
			playerData[2].PlayGame.Response:Fire("TexasHoldem_YourTurn", {cards[playerData[1]], highestBetActive});
		end
	end
end)

initialize();