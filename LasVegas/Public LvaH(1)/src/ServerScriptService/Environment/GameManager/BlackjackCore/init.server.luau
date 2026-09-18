local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");

local ServerModules = ServerStorage:WaitForChild("Modules");
local GameAssets = ServerStorage:WaitForChild("GameAssets");
local PlayingCards = GameAssets:WaitForChild("PlayingCards");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local GameDataModule = require(ReplicatedModules:WaitForChild("GameData"));
local ProfileService = ServerModules:WaitForChild("ProfileService");
local PlayerData = ProfileService:WaitForChild("PlayerData")
local ProfileManager = require(PlayerData:WaitForChild("ProfileManager"));

local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local Jackpot = Remotes:WaitForChild("Jackpot");
local Table = script.Parent;
local TableRemotes = Table:WaitForChild("Remotes");
local Functional = Table:WaitForChild("Functional");
local TableRemotes = Table:WaitForChild("Remotes");

local PlayNPC = TableRemotes:WaitForChild("PlayNPC");
local PlayVoiceline = TableRemotes:WaitForChild("PlayVoiceline");
local PlayerAction = TableRemotes:WaitForChild("PlayerAction");
local Dealer = Functional:WaitForChild("Dealer");
local Stools = Functional:WaitForChild("Stools");
local MinCash = Functional:WaitForChild("MinCash");
local MaxCash = Functional:WaitForChild("MaxCash");
local Cards = Functional:WaitForChild("Cards");
local Bets = Functional:WaitForChild("Bets");
local Turns = Functional:WaitForChild("Turns");

local RNG = Random.new();
local DealerAnimations = {};
local DealerData = {};  -- {cardsValue, aceStatus, hasBlackjack}
local GameData = {}; -- {stool, actualPlayer, cardsValue, splitCardsValue, aceStatus, splitAceStatus, reallyLuckyMain, doubleDowned, warnedDoubleDown, warnedSplit, alreadySplit, playingOnSplitHand, roundEndData, leftGame, betAmount, insuranceAmount, reallyLuckySplit, doubledDownSplit, betAmountSplit}
local ProcessingEvent = false;
local TurnPlayer = nil;

local Won_PayoutMultiplier = 2;
local Insurance_PayoutMultiplier = 2;
local DoubleDown_PayoutMultiplier = 2;
local Blackjack_PayoutMultiplier = 1.5;
local ReallyLucky_PayoutMultiplier = 10;

local function GetEmptyCard(player, splitHand)
	local hand = splitHand and player.."SplitCards" or player.."Cards";
	for cardIndex, _ in pairs(Cards[hand]:GetChildren()) do
		local card = Cards[hand]["Card"..cardIndex];
		if card:GetAttribute("CardName") == "" then
			return card;
		end
	end
end

local function GetCardAmount(player, splitHand)
	local counter = 0;
	
	local hand = splitHand and player.."SplitCards" or player.."Cards";
	for each, card in pairs(Cards[hand]:GetChildren()) do
		if card:GetAttribute("CardName") ~= "" then
			counter += 1;
		end
	end
	
	return counter;
end

local function CanDoubleDownCards(player, actualPlayer, playerData)
	return playerData[12] and (actualPlayer:GetAttribute("Cash") >= playerData[19] and GetCardAmount(player, true) == 2 and not playerData[18]) or (actualPlayer:GetAttribute("Cash") >= playerData[15] and GetCardAmount(player, false) == 2 and not playerData[8]);
end

local function CanSplitCards(player, actualPlayer, playerData)
	if GetCardAmount(player, false) == 2 then
		if (Cards[player.."Cards"].Card1:GetAttribute("CardName") == Cards[player.."Cards"].Card2:GetAttribute("CardName")) or (Cards[player.."Cards"].Card1:GetAttribute("CardValue") == Cards[player.."Cards"].Card2:GetAttribute("CardValue")) then
			if Cards[player.."SplitCards"].Card1:GetAttribute("CardName") == "" or playerData[4] == 0 then
				if actualPlayer:GetAttribute("Cash") >= playerData[15] then
					return true;
				end
			end
		end
	end
end

local function ResetGameData()
	GameData = {};
	DealerData = {};
	TurnPlayer = nil;
	for each, bet in pairs(Bets:GetDescendants()) do
		if bet:IsA("BasePart") then
			bet.Transparency = 1;
			bet.BillboardGui.Enabled = false;
			bet.BillboardGui.Bet.Text = "";
			bet.BillboardGui.Winnings.Text = "";
		end
	end
	for each, turn in pairs(Turns:GetChildren()) do
		turn.Transparency = 1;
		turn.BillboardGui.Enabled = false;
	end
end

local function ToggleCardVisualForSlot(toggle, slot, cardName, faceDown)
	local realCard = slot:FindFirstChild(slot:GetAttribute("CardName"));
	if realCard then
		realCard:Destroy();
	end
	
	if toggle then
		local templateCard = PlayingCards:FindFirstChild(cardName);
		if templateCard then
			local realCard = templateCard:Clone();
			local slotAdjustment = tonumber(string.sub(slot.Name, 5, 5));
			realCard.Orientation = Vector3.new(faceDown and 180 or 0, slot.Orientation.Y, 0);
			realCard.Position = slot.Position + Vector3.new(0, faceDown and -0.001 or slotAdjustment * 0.001, 0); --move each card up slightly to get rid of "z-fighting"
			realCard.Parent = slot;
		end
	end
end

local function DealCardToPlayer(player, splitHand, dealer, faceDown)
	local cardInfo = GameDataModule:GetPlayingCards(Table.Name)[RNG:NextInteger(1, 52)];
	local cardSlot = GetEmptyCard(player, splitHand);
	
	if cardSlot then
		cardSlot:SetAttribute("CardName", cardInfo[1]);
		cardSlot:SetAttribute("CardValue", cardInfo[2] or 1);
		
		ToggleCardVisualForSlot(true, cardSlot, cardInfo[1], faceDown);

		if dealer and DealerData then
			if cardInfo[2] then
				DealerData[1] = DealerData[1] + cardInfo[2];
			elseif DealerData[2] == "" then
				if DealerData[1] + 11 <= 21 then
					DealerData[2] = "aceActive";
					DealerData[1] = DealerData[1] + 11;
				else
					DealerData[1] = DealerData[1] + 1;
				end
			else
				DealerData[1] = DealerData[1] + 1;
			end

			if GetCardAmount(player, false) == 6 and DealerData[1] <= 21 then
				return "sixCardsNoBust";
			end

			if DealerData[1] > 21 then
				if DealerData[2] == "aceActive" then
					DealerData[2] = "aceInactive";
					DealerData[1] = DealerData[1] - 10;
				else
					return "bust";
				end
			elseif DealerData[1] == 21 and GetCardAmount(player, false) == 2 then
				return "blackjack";
			end

			return "passed";
		else
			local playerData = GameFunctions:GetPlayerDataFromPlayer(player, GameData);
			if playerData then
				if splitHand then
					if cardInfo[2] then
						playerData[4] = playerData[4] + cardInfo[2];
					elseif playerData[6] == "" then
						if playerData[4] + 11 <= 21 then
							playerData[6] = "aceActive";
							playerData[4] = playerData[4] + 11;
						else
							playerData[4] = playerData[4] + 1;
						end
					else
						playerData[4] = playerData[4] + 1;
					end

					if GetCardAmount(player, true) == 6 and playerData[4] <= 21 then
						return "sixCardsNoBust";
					end

					if playerData[4] > 21 then
						if playerData[6] == "aceActive" then
							playerData[6] = "aceInactive";
							playerData[4] = playerData[4] - 10;
						else
							return "bust";
						end
					elseif playerData[4] == 21 and GetCardAmount(player, true) == 2 then
						return "blackjack";
					end

					return "passed";
				else
					if cardInfo[2] then
						playerData[3] = playerData[3] + cardInfo[2]; --attempt to index nil with number
					elseif playerData[5] == "" then
						if playerData[3] + 11 <= 21 then
							playerData[5] = "aceActive";
							playerData[3] = playerData[3] + 11;
						else
							playerData[3] = playerData[3] + 1;
						end
					else
						playerData[3] = playerData[3] + 1;
					end
					
					if GetCardAmount(player, false) == 6 and playerData[3] <= 21 then
						return "sixCardsNoBust";
					end

					if playerData[3] > 21 then
						if playerData[5] == "aceActive" then
							playerData[5] = "aceInactive";
							playerData[3] = playerData[3] - 10;
						else
							return "bust";
						end
					elseif playerData[3] == 21 and GetCardAmount(player, false) == 2 then
						return "blackjack";
					end

					return "passed";
				end
			end
		end
	else
		return "sixCardsNoBust";
	end
end

local function RemovePlayerFromTable(player)
	Table:SetAttribute("WatchingPlayers", Table:GetAttribute("WatchingPlayers") - 1);
	
	for index, playerData in pairs(GameData) do
		if playerData[1] == player then
			Table:SetAttribute("ActivePlayers", Table:GetAttribute("ActivePlayers") - 1);
			
			if TurnPlayer == playerData[2] then
				TurnPlayer = nil;
			end
			
			GameData[index] = nil;
			
			break;
		end
	end
	
	for each, cardFolder in pairs(Cards:GetChildren()) do
		if cardFolder.Name == player.."Cards" or cardFolder.Name == player.."SplitCards" then
			for each, card in pairs(cardFolder:GetChildren()) do
				ToggleCardVisualForSlot(false, card, nil, nil);
				card:SetAttribute("CardName", "");
				card:SetAttribute("CardValue", 0);
			end
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
	for each, turn in pairs(Turns:GetChildren()) do
		if turn.Name == player then
			turn.Transparency = 1;
			turn.BillboardGui.Enabled = false;
		end
	end
end

local function EndPlayerTurn(actualPlayer, playerData)
	if playerData[12] then -- If we're ending split hand turn
		TurnPlayer = nil;
	end
	if playerData[4] == 0 then -- If we're ending main hand turn and don't have a split hand
		TurnPlayer = nil;
	end
	if playerData[4] == 21 then -- If we're ending main hand turn but our split hand has blackjack
		TurnPlayer = nil;
	end
	
	if TurnPlayer then -- If we're ending our main hand and have a split hand
		playerData[12] = true;
		Table:SetAttribute("TimeBeforeTurnEnds", os.time() + Table:GetAttribute("MaxTimePerTurn"));
		if playerData[2]:IsA("Player") then
			PlayerAction:FireClient(actualPlayer, "splitHand");
		else
			playerData[2].PlayGame.Response:Fire("Blackjack_YourTurn", Cards[playerData[1].."SplitCards"]);
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

local function EligibleForInsurance()
	local aceCards = GameDataModule:GetAllAceCards("Blackjack");
	for each, cardData in pairs(aceCards) do
		if Cards.DealerCards.Card1:GetAttribute("CardName") == cardData[1] then
			return true;
		end
	end
end

local function DoHitAction(actualPlayer, player, playerData, doubleDown)
	local result;
	
	if not doubleDown then
		PlayVoiceline:Fire("Hit", true);
	end
	
	ToggleDealerAnimation(player.."Deal", true);
	local connection = DealerAnimations[player.."Deal"].KeyframeReached:Connect(function(keyframeName)
		if keyframeName == "DealCard" then
			result = DealCardToPlayer(player, playerData[12], false, false);
		end
	end)
	DealerAnimations[player.."Deal"].Stopped:Wait();
	connection:Disconnect();

	if result == "passed" then
		if not doubleDown then
			Table:SetAttribute("TimeBeforeTurnEnds", os.time() + Table:GetAttribute("MaxTimePerTurn"));
			if actualPlayer:IsA("Player") then
				PlayerAction:FireClient(actualPlayer, "yourTurn");
			elseif actualPlayer:FindFirstChild("PlayGame") then
				actualPlayer.PlayGame.Response:Fire("Blackjack_YourTurn", Cards[playerData[1].."Cards"]);
			end
		else
			EndPlayerTurn(actualPlayer, playerData);
		end
	elseif result == "bust" then
		PlayVoiceline:Fire("Bust", true);
		EndPlayerTurn(actualPlayer, playerData);
	elseif result == "sixCardsNoBust" then
		if playerData[12] then
			playerData[17] = true;
		else
			playerData[7] = true;
		end
		PlayVoiceline:Fire("ReallyLucky", true);
		EndPlayerTurn(actualPlayer, playerData);
	end
end

local function ResetTable()
	Table:SetAttribute("ActivePlayers", 0);
	ResetGameData();

	for each, cardFolder in pairs(Cards:GetChildren()) do
		for each, card in pairs(cardFolder:GetChildren()) do
			ToggleCardVisualForSlot(false, card, nil, nil);
			card:SetAttribute("CardName", "");
			card:SetAttribute("CardValue", 0);
		end
	end

	for each, animation in pairs(Dealer.Animations:GetChildren()) do
		if animation.Name == "Idle" or (animation.Name == "DropCards" and Table:GetAttribute("RoundStarted")) then
			ToggleDealerAnimation(animation.Name, true);
		else
			ToggleDealerAnimation(animation.Name, false);
		end
	end
	
	Table:SetAttribute("RoundPending", false);
	Table:SetAttribute("RoundStarted", false);
end

local function StartNewRound()
	--Start a new round
	PlayVoiceline:Fire("RoundStarting", true);
	Table:SetAttribute("RoundPending", false);
	Table:SetAttribute("RoundStarted", true);
	
	--Get the players who are participating and collect their Bets
	Table:SetAttribute("ActivePlayers", #GameData);
	for each, playerData in pairs(GameData) do
		if playerData[2]:IsA("Player") then
			PlayerAction:FireClient(playerData[2], "roundStarted");
			ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[15]);
		end
	end
	table.sort(GameData, function(a, b)
		if a and b then
			return tonumber(string.match(a[1], "%d")) < tonumber(string.match(b[1], "%d"))
		end
	end)
	
	--Dealer picks up the Cards
	ToggleDealerAnimation("PickupCards", true);
	DealerAnimations["PickupCards"].Stopped:Wait();
	ToggleDealerAnimation("IdleCards", true);
	ToggleDealerAnimation("Idle", false);
	
	--Dealer deals to all participating players
	for each, playerData in pairs(GameData) do
		ToggleDealerAnimation(playerData[1].."DealTwo", true);

		local connection = DealerAnimations[playerData[1].."DealTwo"].KeyframeReached:Connect(function(keyframeName)
			if Table:GetAttribute("ActivePlayers") > 0 then
				if keyframeName == "DealCard" then
					local result = DealCardToPlayer(playerData[1], false, false, false);
					if result == "blackjack" then
						PlayVoiceline:Fire(playerData[1].."Blackjack", true);
					end
				end
			end
		end)

		DealerAnimations[playerData[1].."DealTwo"].Stopped:Wait();
		connection:Disconnect();
	end
	
	--Dealer deals themselves 2 Cards, 1 face down and 1 face up, if potential blackjack then offer insurance, 
	--if dealer blackjack then end the round immediately and payout insurance Bets
	if Table:GetAttribute("ActivePlayers") > 0 then
		local result;
		DealerData = {0, "", false};
		
		for i = 1, 2 do
			if Table:GetAttribute("ActivePlayers") > 0 then
				ToggleDealerAnimation("DealerDeal", true);
				
				local connection = DealerAnimations["DealerDeal"].KeyframeReached:Connect(function(keyframeName)
					if keyframeName == "DealCard" then
						if i == 1 then
							result = DealCardToPlayer("Dealer", false, true, false);
						else
							result = DealCardToPlayer("Dealer", false, true, true);
						end
					end
				end)
				
				DealerAnimations["DealerDeal"].Stopped:Wait();
				connection:Disconnect();
			end
		end
		
		if Table:GetAttribute("ActivePlayers") > 0 then
			if EligibleForInsurance() then
				PlayVoiceline:Fire("Insurance", true);
				Table:SetAttribute("InsuranceActive", true);
				for each, playerData in pairs(GameData) do

					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "insuranceStarted");
					elseif playerData[2]:FindFirstChild("PlayGame") then
						playerData[2].PlayGame.Response:Fire("Blackjack_Insurance", Cards[playerData[1].."Cards"]);
					end
				end

				task.wait(Table:GetAttribute("TimeToBet"));	

				Table:SetAttribute("InsuranceActive", false);
				for each, playerData in pairs(GameData) do
					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "insuranceEnded");
						ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[16]);
					end
				end
			end

			if result == "blackjack" then
				DealerData[3] = true;
				ToggleDealerAnimation("DealerFlipCard", true);

				local connection = DealerAnimations["DealerFlipCard"].KeyframeReached:Connect(function(keyframeName)
					if keyframeName == "FlipCard" then
						PlayVoiceline:Fire("DealerBlackjack", true);
						ToggleCardVisualForSlot(true, Cards["DealerCards"].Card2, Cards["DealerCards"].Card2:GetAttribute("CardName"), false);
					end
				end)

				DealerAnimations["DealerFlipCard"].Stopped:Wait();
				connection:Disconnect();
			end
		end
	end
	
	--Dealer waits for each player to complete their turn
	if Table:GetAttribute("ActivePlayers") > 0 then
		if not DealerData[3] then
			for each, playerData in pairs(GameData) do
				if playerData[3] ~= 21 then
					TurnPlayer = playerData[2];
					Table:SetAttribute("TimeBeforeTurnEnds", os.time() + Table:GetAttribute("MaxTimePerTurn"));
					
					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "yourTurn");
					elseif playerData[2]:FindFirstChild("PlayGame") then
						playerData[2].PlayGame.Response:Fire("Blackjack_YourTurn", Cards[playerData[1].."Cards"]);
					end
					
					Turns[playerData[1]].Transparency = 0;
					Turns[playerData[1]].BillboardGui.Enabled = true;
					
					repeat task.wait(); until 
						(not TurnPlayer or os.time() >= Table:GetAttribute("TimeBeforeTurnEnds")) 
					and 
						not ProcessingEvent;
					
					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "noLongerYourTurn");
					end
					
					Turns[playerData[1]].Transparency = 1;
					Turns[playerData[1]].BillboardGui.Enabled = false;
				end
			end
		end
	end
	
	--Dealers flips over their hidden card and acts accordingly
	if Table:GetAttribute("ActivePlayers") > 0 then
		if not DealerData[3] then
			ToggleDealerAnimation("DealerFlipCard", true);
			local connection = DealerAnimations["DealerFlipCard"].KeyframeReached:Connect(function(keyframeName)
				if keyframeName == "FlipCard" then
					ToggleCardVisualForSlot(true, Cards["DealerCards"].Card2, Cards["DealerCards"].Card2:GetAttribute("CardName"), false);
				end
			end)
			DealerAnimations["DealerFlipCard"].Stopped:Wait();
			connection:Disconnect();

			local allPlayersBustOrBlackjack = true;
			
			for player, playerData in pairs(GameData) do
				if playerData[3] < 21 or (playerData[3] == 21 and GetCardAmount(playerData[1], false) > 2) then
					allPlayersBustOrBlackjack = false;
					break;
				end
				if (playerData[4] > 0 and playerData[4] < 21) or (playerData[4] == 21 and GetCardAmount(playerData[1], true) > 2) then
					allPlayersBustOrBlackjack = false;
					break;
				end
				
				if playerData[3] ~= 21 and GetCardAmount(playerData[1], false) == 2 then 
					allPlayersBustOrBlackjack = false;
					break;
				end
				if playerData[4] > 0 and playerData[4] ~= 21 and GetCardAmount(playerData[1], true) == 2 then 
					allPlayersBustOrBlackjack = false;
					break;
				end
			end
			
			if not allPlayersBustOrBlackjack then
				local doneDrawing = false;
				
				while DealerData and DealerData[1] and DealerData[1] < 17 and not doneDrawing do
					ToggleDealerAnimation("DealerDeal", true);
					local connection = DealerAnimations["DealerDeal"].KeyframeReached:Connect(function(keyframeName)
						if keyframeName == "DealCard" then
							local result = DealCardToPlayer("Dealer", false, true, false);
							if result == "bust" then
								PlayVoiceline:Fire("DealerBust", true);
							elseif result == "sixCardsNoBust" then
								doneDrawing = true;
							end
						end
					end)
					DealerAnimations["DealerDeal"].Stopped:Wait();
					connection:Disconnect();
				end
			end
		end
	end
	
	--Results of the round are finalized
	if Table:GetAttribute("ActivePlayers") > 0 then
		--playerData[3] = main hand Cards value
		--playerData[4] = split hand Cards value
		--playerData[7] = main hand really lucky
		--playerData[17] = split hand really lucky
		--playerData[8] = double downed main
		--playerData[18] = double downed split
		--playerData[13][1] = main hand result (win/lost/tied)
		--playerData[13][2] = split hand result (win/lost/tied)
		--playerData[13][3] = insurance result (win/lost)
		--playerData[15] = betAmount
		--playerData[19] = betAmountSplit
		--playerData[16] = insuranceAmount
		
		for player, playerData in pairs(GameData) do
			-- Setup result values --
			local mainWinnings = 0;
			local splitWinnings = 0;
			local insuranceWinnings = 0;
			playerData[13][1] = "Lost";
			if playerData[4] > 0 then
				playerData[13][2] = "Lost";
			end
			if playerData[16] > 0 then
				playerData[13][3] = "Lost";
			end
			
			-- If a hand got really lucky on a hand give payout and exclude that hand from further calculations --
			if playerData[7] then
				mainWinnings += playerData[15] + (ReallyLucky_PayoutMultiplier * playerData[15]);
				playerData[13][1] = "Won";
			end
			if playerData[17] then
				splitWinnings += playerData[19] + (ReallyLucky_PayoutMultiplier * playerData[19]);
				playerData[13][2] = "Won";
			end
			
			if DealerData[1] > 21 then -- If the dealer bust
				if not playerData[7] then -- If the main hand didn't get really lucky
					if playerData[3] < 21 or (playerData[3] == 21 and GetCardAmount(playerData[1], false) ~= 2) then -- If the main hand didn't bust and didn't get blackjack
						if playerData[8] then
							mainWinnings += DoubleDown_PayoutMultiplier * playerData[15];
						else
							mainWinnings += Won_PayoutMultiplier * playerData[15];
						end
						playerData[13][1] = "Won";
					elseif playerData[3] == 21 and GetCardAmount(playerData[1], false) == 2 then -- If the main hand got blackjack
						mainWinnings += playerData[15] + (Blackjack_PayoutMultiplier * playerData[15]);
						playerData[13][1] = "Won";
					end
				end

				if not playerData[17] and playerData[4] > 0 then -- If the split hand was active didn't get really lucky
					if playerData[4] < 21 or (playerData[4] == 21 and GetCardAmount(playerData[1], true) ~= 2) then -- If the split hand didn't bust and didn't get blackjack
						if playerData[18] then
							splitWinnings += DoubleDown_PayoutMultiplier * playerData[19];
						else
							splitWinnings += Won_PayoutMultiplier * playerData[19];
						end
						playerData[13][2] = "Won";
					elseif playerData[4] == 21 and GetCardAmount(playerData[1], true) == 2 then -- If the split hand got blackjack
						splitWinnings += playerData[19] + (Blackjack_PayoutMultiplier * playerData[19]);
						playerData[13][2] = "Won";
					end
				end
			elseif DealerData[1] == 21 and DealerData[3] then -- If the dealer got blackjack
				if playerData[16] > 0 then -- If insurance bet was made
					insuranceWinnings += Insurance_PayoutMultiplier * playerData[16];
					playerData[13][3] = "Won";
				end	
				
				if not playerData[7] then -- If the main hand didn't get really lucky
					if playerData[3] == 21 and GetCardAmount(playerData[1], false) == 2 then --If the main hand got blackjack
						mainWinnings += playerData[15];
						playerData[13][1] = "Tied";
					end
				end
				
				if not playerData[17] and playerData[4] > 0 then -- If the split hand was active didn't get really lucky
					if playerData[4] == 21 and GetCardAmount(playerData[1], true) == 2 then --If the split hand got blackjack
						splitWinnings += playerData[19];
						playerData[13][2] = "Tied";
					end
				end
			else -- If the dealer got hard 21 or 20-17
				if not playerData[7] then -- If the main hand didn't get really lucky
					if playerData[3] == 21 and GetCardAmount(playerData[1], false) == 2 then -- If the main hand got blackjack
						mainWinnings += playerData[15] + (Blackjack_PayoutMultiplier * playerData[15]);
						playerData[13][1] = "Won";
					elseif playerData[3] > DealerData[1] and playerData[3] < 22 then -- If the main hand beat the dealer's hand
						if playerData[8] then
							mainWinnings += DoubleDown_PayoutMultiplier * playerData[15];
						else
							mainWinnings += Won_PayoutMultiplier * playerData[15];
						end
						playerData[13][1] = "Won";
					elseif playerData[3] == DealerData[1] then -- If the main hand tied with the dealer's hand
						mainWinnings += playerData[15];
						playerData[13][1] = "Tied";
					end
				end
					
				if not playerData[17] and playerData[4] > 0 then -- If the split hand was active didn't get really lucky
					if playerData[4] == 21 and GetCardAmount(playerData[1], true) == 2 then -- If the split hand got blackjack
						splitWinnings += playerData[19] + (Blackjack_PayoutMultiplier * playerData[19]);
						playerData[13][2] = "Won";
					elseif playerData[4] > DealerData[1] and playerData[4] < 22 then -- If the split hand beat the dealer's hand
						if playerData[8] then
							splitWinnings += DoubleDown_PayoutMultiplier * playerData[19];
						else
							splitWinnings += Won_PayoutMultiplier * playerData[19];
						end
						playerData[13][2] = "Won";
					elseif playerData[4] == DealerData[1] then -- If the split hand tied with the dealer's hand
						splitWinnings += playerData[15];
						playerData[13][2] = "Tied";
					end
				end
			end
			
			-- Display and announce the winnings --
			Bets[playerData[1]].Main.BillboardGui.Bet.Text = "";
			Bets[playerData[1]].Main.BillboardGui.Winnings.Text = mainWinnings > 0 and "+$"..GameDataModule:AddCommasToNumber(mainWinnings) or "-$"..GameDataModule:AddCommasToNumber(playerData[15]);
			Bets[playerData[1]].Main.BillboardGui.Winnings.TextColor3 = mainWinnings > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100);
			PlayVoiceline:Fire(playerData[1]..playerData[13][1]); -- Main hand result
			if playerData[4] > 0 then
				Bets[playerData[1]].Split.BillboardGui.Bet.Text = "";
				Bets[playerData[1]].Split.BillboardGui.Winnings.Text = splitWinnings > 0 and "+$"..GameDataModule:AddCommasToNumber(splitWinnings) or "-$"..GameDataModule:AddCommasToNumber(playerData[19]);
				Bets[playerData[1]].Split.BillboardGui.Winnings.TextColor3 = splitWinnings > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100);
				PlayVoiceline:Fire(playerData[1]..playerData[13][2]); -- Split hand result
			end
			if playerData[16] > 0 then
				Bets[playerData[1]].Insurance.BillboardGui.Bet.Text = "";
				Bets[playerData[1]].Insurance.BillboardGui.Winnings.Text = insuranceWinnings > 0 and "+$"..GameDataModule:AddCommasToNumber(insuranceWinnings) or "-$"..GameDataModule:AddCommasToNumber(playerData[16]);
				Bets[playerData[1]].Insurance.BillboardGui.Winnings.TextColor3 = insuranceWinnings > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100);
				PlayVoiceline:Fire(playerData[1]..playerData[13][3]); -- Insurance result
			end
			
			-- Payout the winnings and show jackpot if really lucky --
			if playerData[2]:IsA("Player") then
				ProfileManager.AdjustCurrency(playerData[2], "Cash", mainWinnings + splitWinnings + insuranceWinnings);
				if playerData[7] or playerData[17] then
					Jackpot:FireAllClients(playerData[2], mainWinnings + splitWinnings + insuranceWinnings);
				end
			end
		end
		
		task.wait(Table:GetAttribute("TimeBetweenHands"));
	end
	
	--End the current round and start the next round if players are still present
	if Table:GetAttribute("ActivePlayers") > 0 then
		for player, playerData in pairs(GameData) do
			if playerData[2]:IsA("Player") then
				PlayerAction:FireClient(playerData[2], "roundEnded");
			end
		end

		ResetTable();

		for each, stool in pairs(Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if player:GetAttribute("Cash") >= Table:GetAttribute("MinCash") then
						if not Table:GetAttribute("RoundPending") then
							Table:SetAttribute("RoundPending", true);
							PlayVoiceline:Fire(stool.Name.."RoundStartingSoon", true);
						end
					end
				end
			end
		end
		
		for each, npc in pairs(Table.NPCs:GetChildren()) do
			if not Table:GetAttribute("RoundPending") then
				Table:SetAttribute("RoundPending", true);
				PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon", true);
			end
			if npc:FindFirstChild("PlayGame") then
				npc.PlayGame.Response:Fire("BetBlackjack");
			end
		end
	end
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, betAmount)
	if not ProcessingEvent then
		ProcessingEvent = true;
		
		local player = GameFunctions:GetPlayerFromActualPlayer(actualPlayer, GameData);
		local playerData = GameFunctions:GetPlayerDataFromPlayer(player, GameData);
		if action == "Hit" and TurnPlayer == actualPlayer then
			DoHitAction(actualPlayer, player, playerData, false);
		elseif action == "Stand" and TurnPlayer == actualPlayer then
			PlayVoiceline:Fire("Stand", true);
			EndPlayerTurn(actualPlayer, playerData);
		elseif action == "DoubleDown" and TurnPlayer == actualPlayer then
			local canDoubleDown = CanDoubleDownCards(player, actualPlayer, playerData);
			
			if canDoubleDown then
				if playerData[12] then -- If double downing split hand
					playerData[18] = true;
					ProfileManager.AdjustCurrency(actualPlayer, "Cash", -playerData[19]);
					playerData[19] = playerData[19] * 2;
					Bets[player].Split.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[19]);		
				else -- If double downing main hand
					playerData[8] = true;
					ProfileManager.AdjustCurrency(actualPlayer, "Cash", -playerData[15]);
					playerData[15] = playerData[15] * 2;
					Bets[player].Main.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[15]);
				end
				
				PlayVoiceline:Fire("DoubleDown", true);
				DoHitAction(actualPlayer, player, playerData, true);
			else
				if not playerData[9] then
					playerData[9] = true;
					PlayVoiceline:Fire("CantDoubleDown", true);
				end
				PlayerAction:FireClient(actualPlayer, "yourTurn");
			end
		elseif action == "Split" and TurnPlayer == actualPlayer then
			if CanSplitCards(player, actualPlayer, playerData) then
				PlayVoiceline:Fire("Split", true);
				
				--Take an additional split bet
				playerData[19] = playerData[15];
				ProfileManager.AdjustCurrency(playerData[2], "Cash", -playerData[19]);
				Bets[player].Split.Transparency = 0;
				Bets[player].Split.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[19]);
				Bets[player].Split.BillboardGui.Enabled = true;
				
				--Split the current 2 Cards into 2 hands
				ToggleCardVisualForSlot(true, Cards[player.."SplitCards"].Card1, Cards[player.."Cards"].Card2:GetAttribute("CardName"), false);
				ToggleCardVisualForSlot(false, Cards[player.."Cards"].Card2, nil, nil);
				Cards[player.."SplitCards"].Card1:SetAttribute("CardName", Cards[player.."Cards"].Card2:GetAttribute("CardName"));
				Cards[player.."SplitCards"].Card1:SetAttribute("CardValue", Cards[player.."Cards"].Card2:GetAttribute("CardValue"));
				Cards[player.."Cards"].Card2:SetAttribute("CardName", "");
				Cards[player.."Cards"].Card2:SetAttribute("CardValue", 0);
				if Cards[player.."Cards"].Card1:GetAttribute("CardName") == "ace" then
					playerData[3] = 11;
					playerData[5] = "aceActive";
					playerData[6] = "aceActive";
				else
					playerData[3] = playerData[3] / 2;
				end
				playerData[4] = playerData[3];
				
				--Deal the player 1 more card on each hand
				local result;
				ToggleDealerAnimation(player.."Deal", true);
				local connection = DealerAnimations[player.."Deal"].KeyframeReached:Connect(function(keyframeName)
					if keyframeName == "DealCard" then
						result = DealCardToPlayer(player, false, false, false);
						if result == "blackjack" then
							PlayVoiceline:Fire(playerData[1].."Blackjack", true);
						end
					end
				end)
				DealerAnimations[player.."Deal"].Stopped:Wait();
				connection:Disconnect();
				
				local result;
				ToggleDealerAnimation(player.."Deal", true);
				local connection = DealerAnimations[player.."Deal"].KeyframeReached:Connect(function(keyframeName)
					if keyframeName == "DealCard" then
						result = DealCardToPlayer(player, true, false, false);
						if result == "blackjack" then
							PlayVoiceline:Fire(playerData[1].."Blackjack", true);
						end
					end
				end)
				DealerAnimations[player.."Deal"].Stopped:Wait();
				connection:Disconnect();
				
				--Tell the player it's their turn
				if playerData[3] == 21 then
					playerData[12] = true;
				end
				if playerData[4] == 21 and playerData[12] then
					EndPlayerTurn(actualPlayer, playerData);
				end
				
				Table:SetAttribute("TimeBeforeTurnEnds", os.time() + Table:GetAttribute("MaxTimePerTurn"));
				if playerData[12] then
					PlayerAction:FireClient(actualPlayer, "splitHand");
				else
					PlayerAction:FireClient(actualPlayer, "originalHand");
				end
			elseif GetCardAmount(player, true) >= 1 then
				if not playerData[11] then
					playerData[11] = true;
					PlayVoiceline:Fire("AlreadySplit", true);
				end
				PlayerAction:FireClient(actualPlayer, "yourTurn");
			else
				if not playerData[10] then
					playerData[10] = true;
					PlayVoiceline:Fire("CantSplit", true);
				end
				PlayerAction:FireClient(actualPlayer, "yourTurn");
			end
		elseif action == "Bet" and (not Table:GetAttribute("RoundStarted") or Table:GetAttribute("InsuranceActive")) then
			local betNumber = tonumber(betAmount);
			if betNumber and actualPlayer:GetAttribute("Cash") >= betAmount and betNumber >= Table:GetAttribute("MinCash") and betNumber <= Table:GetAttribute("MaxCash") then
				local fixedBet = math.floor(betNumber);
				local stoolName = GetPlayerStoolName(actualPlayer);
				local foundData;
				
				for each, playerData in pairs(GameData) do
					if playerData[1] == stoolName then
						foundData = playerData
						
						if Table:GetAttribute("InsuranceActive") then
							playerData[16] = fixedBet;
						else
							playerData[15] = fixedBet;
						end
						
						break;
					end
				end
				
				if not foundData then
					foundData = {stoolName, actualPlayer, 0, 0, "", "", false, false, false, false, false, false, {}, false, fixedBet, 0, false, false, 0}
					table.insert(GameData, foundData);
				end

				if Table:GetAttribute("InsuranceActive") then
					Bets[stoolName].Insurance.Transparency = 0;
					Bets[stoolName].Insurance.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[16]);
					Bets[stoolName].Insurance.BillboardGui.Enabled = true;
				else
					Bets[stoolName].Main.Transparency = 0;
					Bets[stoolName].Main.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[15]);
					Bets[stoolName].Main.BillboardGui.Enabled = true;
				end
			end
		end
		
		ProcessingEvent = false;
	end
end)

Table:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if Table:GetAttribute("RoundPending") then
		local success = true;
		
		repeat task.wait(0.5); until #GameData > 0
		
		for i = Table:GetAttribute("TimeToBet"), 0, -1 do
			if not Table:GetAttribute("RoundPending") then
				success = false;
				break;
			end
			
			if i ~= 0 then
				for i = 0, 1, 0.05 do
					if not Table:GetAttribute("RoundPending") then
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
	MinCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(Table:GetAttribute("MinCash"));
	MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(Table:GetAttribute("MaxCash"));
	Table.Functional.MinCash.Fire.Enabled = Table:GetAttribute("HighRoller");
	Table.Functional.MaxCash.Fire.Enabled = Table:GetAttribute("HighRoller");
	Table.Decoration.Table.Base.Material = Table:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	Table.Decoration.Table.Ring.Material = Table:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	Table.Decoration.Table.Table.Material = Table:GetAttribute("HighRoller") and Enum.Material.Salt or Enum.Material.Plastic;
	
	script.Voicelines.Enabled = true;
	
	for each, animation in pairs(Dealer.Animations:GetChildren()) do
		ToggleDealerAnimation(animation.Name, true, animation);
	end
	for each, animation in pairs(Dealer.Animations:GetChildren()) do
		if animation.Name ~= "Idle" then
			ToggleDealerAnimation(animation.Name, false);
		end
	end
	GameFunctions:GiveDealerNametag(Dealer);
	
	ResetGameData();
	
	for each, stool in pairs(Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			if stool.Seat.Occupant then
				Table:SetAttribute("WatchingPlayers", Table:GetAttribute("WatchingPlayers") + 1);
				
				local player = game:GetService("Players"):FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
						if player:GetAttribute("Cash") >= Table:GetAttribute("MinCash") then
							PlayVoiceline:Fire(stool.Name.."Welcome");
							local gui = script.Blackjack:Clone();
							gui.ActualTable.Value = Table;
							gui.Parent = player.PlayerGui;
							if not Table:GetAttribute("RoundStarted") and not Table:GetAttribute("RoundPending") then
								Table:SetAttribute("RoundPending", true);
								PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							end
						end
					end
				end
			else
				RemovePlayerFromTable(stool.Name);
				
				if Table:GetAttribute("ActivePlayers") == 0 and Table:GetAttribute("RoundStarted") then
					ResetTable();
					for each, stool in pairs(Stools:GetChildren()) do
						if stool.Seat.Occupant then
							Table:SetAttribute("RoundPending", true);
							PlayVoiceline:Fire(stool.Name.."RoundStartingSoon");
							break;
						end
					end
				end
			end
			
			if Table:GetAttribute("WatchingPlayers") == 0 then
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
		if not Table:GetAttribute("RoundStarted") and not Table:GetAttribute("RoundPending") then
			Table:SetAttribute("RoundPending", true);
			PlayVoiceline:Fire(npc:GetAttribute("Stool").."RoundStartingSoon");
		end
	elseif action == "leaving" then
		Table:SetAttribute("NPCsAtGame", Table:GetAttribute("NPCsAtGame") - 1);
	elseif action == "bet" and (not Table:GetAttribute("RoundStarted") or Table:GetAttribute("InsuranceActive")) then
		local fixedBet = RNG:NextInteger(Table:GetAttribute("MinCash"), Table:GetAttribute("MaxCash"));
		local foundData;

		for each, playerData in pairs(GameData) do
			if playerData[1] == npc:GetAttribute("Stool") then
				foundData = playerData

				if Table:GetAttribute("InsuranceActive") then
					playerData[16] = fixedBet;
				else
					playerData[15] = fixedBet;
				end

				break;
			end
		end

		if not foundData then
			foundData = {npc:GetAttribute("Stool"), npc, 0, 0, "", "", false, false, false, false, false, false, {}, false, fixedBet, 0, false, false, 0}
			table.insert(GameData, foundData);
		end

		if Table:GetAttribute("InsuranceActive") then
			Bets[npc:GetAttribute("Stool")].Insurance.Transparency = 0;
			Bets[npc:GetAttribute("Stool")].Insurance.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[16]);
			Bets[npc:GetAttribute("Stool")].Insurance.BillboardGui.Enabled = true;
		else
			Bets[npc:GetAttribute("Stool")].Main.Transparency = 0;
			Bets[npc:GetAttribute("Stool")].Main.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(foundData[15]);
			Bets[npc:GetAttribute("Stool")].Main.BillboardGui.Enabled = true;
		end
	elseif action == "hit" and TurnPlayer == npc then
		DoHitAction(npc, npc:GetAttribute("Stool"), playerData, false);
	elseif action == "stand" and TurnPlayer == npc then
		PlayVoiceline:Fire("Stand", true);
		EndPlayerTurn(npc, playerData);
	elseif action == "split" and TurnPlayer == npc then
		PlayVoiceline:Fire("Split", true);
		
		--Take an additional split bet
		playerData[19] = playerData[15];
		Bets[player].Split.Transparency = 0;
		Bets[player].Split.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[19]);
		Bets[player].Split.BillboardGui.Enabled = true;

		--Split the current 2 Cards into 2 hands
		ToggleCardVisualForSlot(true, Cards[player.."SplitCards"].Card1, Cards[player.."Cards"].Card2:GetAttribute("CardName"), false);
		ToggleCardVisualForSlot(false, Cards[player.."Cards"].Card2, nil, nil);
		Cards[player.."SplitCards"].Card1:SetAttribute("CardName", Cards[player.."Cards"].Card2:GetAttribute("CardName"));
		Cards[player.."SplitCards"].Card1:SetAttribute("CardValue", Cards[player.."Cards"].Card2:GetAttribute("CardValue"));
		Cards[player.."Cards"].Card2:SetAttribute("CardName", "");
		Cards[player.."Cards"].Card2:SetAttribute("CardValue", 0);
		if Cards[player.."Cards"].Card1:GetAttribute("CardName") == "ace" then
			playerData[3] = 11;
			playerData[5] = "aceActive";
			playerData[6] = "aceActive";
		else
			playerData[3] = playerData[3] / 2;
		end
		playerData[4] = playerData[3];

		--Deal the player 1 more card on each hand
		local result;
		ToggleDealerAnimation(player.."Deal", true);
		local connection = DealerAnimations[player.."Deal"].KeyframeReached:Connect(function(keyframeName)
			if keyframeName == "DealCard" then
				result = DealCardToPlayer(player, false, false, false);
				if result == "blackjack" then
					PlayVoiceline:Fire(playerData[1].."Blackjack", true);
				end
			end
		end)
		DealerAnimations[player.."Deal"].Stopped:Wait();
		connection:Disconnect();

		local result;
		ToggleDealerAnimation(player.."Deal", true);
		local connection = DealerAnimations[player.."Deal"].KeyframeReached:Connect(function(keyframeName)
			if keyframeName == "DealCard" then
				result = DealCardToPlayer(player, true, false, false);
				if result == "blackjack" then
					PlayVoiceline:Fire(playerData[1].."Blackjack", true);
				end
			end
		end)
		DealerAnimations[player.."Deal"].Stopped:Wait();
		connection:Disconnect();

		--Tell the player it's their turn
		if playerData[3] == 21 then
			playerData[12] = true;
		end
		if playerData[4] == 21 and playerData[12] then
			EndPlayerTurn(npc, playerData);
		end

		Table:SetAttribute("TimeBeforeTurnEnds", os.time() + Table:GetAttribute("MaxTimePerTurn"));
		if playerData[12] then
			npc.PlayGame.Response:Fire("Blackjack_YourTurn", Cards[playerData[1].."SplitCards"]);
		else
			npc.PlayGame.Response:Fire("Blackjack_YourTurn", Cards[playerData[1].."Cards"]);
		end
	elseif action == "doubleDown" and TurnPlayer == npc then
		if playerData[12] then -- If double downing split hand
			playerData[18] = true;
			playerData[19] = playerData[19] * 2;
			Bets[player].Split.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[19]);		
		else -- If double downing main hand
			playerData[8] = true;
			playerData[15] = playerData[15] * 2;
			Bets[player].Main.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(playerData[15]);
		end
		
		PlayVoiceline:Fire("DoubleDown", true);
		DoHitAction(npc, player, playerData, true);
	end
end)

Initialize();