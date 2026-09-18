local Players = game:GetService("Players");
local Debris = game:GetService("Debris");
local npc = script.Parent;
local humanoidRootPart = npc:WaitForChild("HumanoidRootPart");
local humanoid = npc:WaitForChild("Humanoid");
local machine = script.Parent.Parent.Parent;
local Response = script:WaitForChild("Response");
local remotes = machine:WaitForChild("Remotes");
local random = Random.new();
local JumpAnim = npc:WaitForChild("JumpAnim");
local SitAnim = npc:WaitForChild("SitAnim");
local JumpAnimTrack;
local SitAnimTrack;

local function SpinSlots()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "spin");
end

local function BetBigWheel()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "arriving");
end

local function BetRoulette()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "bet");
end

local function BetBlackjack()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "bet");
end

local function BetThreeCardPoker()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "bet");
end

local function BetBaccarat()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "bet");
end

local function BetPlinko()
	task.wait(random:NextNumber(1, 3));
	remotes.PlayNPC:Fire(npc, "bet");
end

local function StartBlackjack()
	remotes.PlayNPC:Fire(npc, "arriving");
	BetBlackjack();
end

local function StartRoulette()
	remotes.PlayNPC:Fire(npc, "arriving");
	BetRoulette();
end

local function StartThreeCardPoker()
	remotes.PlayNPC:Fire(npc, "arriving");
	BetThreeCardPoker();
end

local function StartBaccarat()
	remotes.PlayNPC:Fire(npc, "arriving");
	BetBaccarat();
end

local function StartPlinko()
	remotes.PlayNPC:Fire(npc, "arriving");
	BetPlinko();
end

local function StartBigWheel()
	remotes.PlayNPC:Fire(npc, "arriving");
	BetBigWheel();
end

local function StartTexasHoldem()
	remotes.PlayNPC:Fire(npc, "arriving");
end

Response.Event:Connect(function(action, data)
	if action == "Victory" then
		local victory = script.Victory[random:NextInteger(1, #script.Victory:GetChildren())]:Clone();
		victory.Parent = npc.Head;
		victory:Play();
		Debris:AddItem(victory, victory.TimeLength);
	elseif action == "SpinSlots" then
		SpinSlots();
	elseif action == "BetBigWheel" then
		BetBigWheel();
	elseif action == "BetRoulette" then
		BetRoulette();
	elseif action == "BetPlinko" then
		BetPlinko();
	elseif action == "BetBlackjack" then
		BetBlackjack();
	elseif action == "BetThreeCardPoker" then
		BetThreeCardPoker();
	elseif action == "BetBaccarat" then
		BetBaccarat();
	elseif action == "Blackjack_YourTurn" then
		task.wait(random:NextNumber(1, 2));
		
		local totalValue = 0;
		local totalCards = 0;
		for each, card in pairs(data:GetChildren()) do
			if card:GetAttribute("CardName") ~= "" then
				if card:GetAttribute("CardValue") ~= 1 then
					totalValue += card:GetAttribute("CardValue");
				elseif totalValue + 11 <= 21 then
					totalValue += 11;
				else
					totalValue += 1;
				end
				totalCards += 1;
			end
		end
		
		if totalCards == 2 and data.Card1:GetAttribute("CardName") == data.Card2:GetAttribute("CardName") then
			if totalValue == 20 then
				remotes.PlayNPC:Fire(npc, "split");
			elseif random:NextNumber() <= 0.5 then
				remotes.PlayNPC:Fire(npc, "split");
			elseif totalValue < 17 then
				remotes.PlayNPC:Fire(npc, "hit");
			else
				remotes.PlayNPC:Fire(npc, "stand");
			end
		elseif totalValue == 11 then
			if random:NextNumber() <= 0.5 then
				remotes.PlayNPC:Fire(npc, "doubleDown");
			else
				remotes.PlayNPC:Fire(npc, "hit");
			end
		elseif totalValue < 17 then
			remotes.PlayNPC:Fire(npc, "hit");
		else
			remotes.PlayNPC:Fire(npc, "stand");
		end
	elseif action == "Blackjack_Insurance" then
		if random:NextNumber() < 0.5 then
			BetBlackjack();
		end
	elseif action == "ThreeCardPoker_YourTurn" then
		task.wait(random:NextNumber(1, 2));
		
		if data then
			remotes.PlayNPC:Fire(npc, "play");
		else
			remotes.PlayNPC:Fire(npc, "fold");
		end
	elseif action == "TexasHoldem_YourTurn" then
		local cards = data[1];
		local highestBetActive = data[2];
		
		if highestBetActive == 0 then
			task.wait(random:NextNumber(1, 4));
			
			if random:NextNumber() <= 0.2 then
				remotes.PlayNPC:Fire(npc, "bet", random:NextInteger(machine:GetAttribute("MinCash"), math.floor(machine:GetAttribute("MaxCash") * 0.5)));
			else
				remotes.PlayNPC:Fire(npc, "check");
			end
		elseif highestBetActive <= machine:GetAttribute("MaxCash") * 0.2 then
			task.wait(random:NextNumber(1, 4));
			
			if random:NextNumber() <= 0.1 then
				remotes.PlayNPC:Fire(npc, "raise", random:NextInteger(1, machine:GetAttribute("MaxCash") - highestBetActive));
			else
				remotes.PlayNPC:Fire(npc, "call");
			end
		elseif highestBetActive <= machine:GetAttribute("MaxCash") * 0.5 then
			task.wait(random:NextNumber(1, 10));
			
			if cards.Card1:GetAttribute("Card") == cards.Card2:GetAttribute("Card") then
				remotes.PlayNPC:Fire(npc, "call");
			elseif random:NextNumber() <= 0.2 then
				remotes.PlayNPC:Fire(npc, "fold");
			else
				remotes.PlayNPC:Fire(npc, "call");
			end
		elseif highestBetActive > machine:GetAttribute("MaxCash") * 0.5 then
			task.wait(random:NextNumber(1, 10));
			
			if cards.Card1:GetAttribute("Card") == cards.Card2:GetAttribute("Card") then
				remotes.PlayNPC:Fire(npc, "call");
			elseif random:NextNumber() <= 0.2 then
				remotes.PlayNPC:Fire(npc, "call");
			else
				remotes.PlayNPC:Fire(npc, "fold");
			end
		end
	end
end)

local function Initialize()
	if not npc:IsDescendantOf(workspace) then
		repeat task.wait(0.5) until npc:IsDescendantOf(workspace);
	end
	
	JumpAnimTrack = humanoid:LoadAnimation(JumpAnim);
	SitAnimTrack = humanoid:LoadAnimation(SitAnim);
	SitAnimTrack:Play();
	
	if npc:GetAttribute("GameType") == "BigWheel" then
		BetBigWheel();
	elseif npc:GetAttribute("GameType") == "Roulette" then
		StartRoulette();
	elseif npc:GetAttribute("GameType") == "Blackjack" then
		StartBlackjack();
	elseif npc:GetAttribute("GameType") == "ThreeCardPoker" then
		StartThreeCardPoker();
	elseif npc:GetAttribute("GameType") == "TexasHoldem" then
		StartTexasHoldem();
	elseif npc:GetAttribute("GameType") == "Baccarat" then
		StartBaccarat();
	elseif npc:GetAttribute("GameType") == "Plinko" then
		StartPlinko();
	else
		SpinSlots();
	end
end
Initialize();

local checkingHit = false;
humanoidRootPart.Touched:Connect(function(hit)
	if not checkingHit then
		checkingHit = true;
		
		local character = hit.Parent;
		if character then
			local player = Players:GetPlayerFromCharacter(character);
			if player then
				remotes.PlayNPC:Fire(npc, "leaving");
				SitAnimTrack:Stop();
				JumpAnimTrack:Play();
				humanoid.Jump = true;
				task.wait(0.5);
				npc:Destroy();
			end
		end
		
		checkingHit = false;
	end
end)