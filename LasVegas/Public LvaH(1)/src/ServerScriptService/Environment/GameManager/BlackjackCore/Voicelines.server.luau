local ServerStorage = game:GetService("ServerStorage");
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local tableGame = script.Parent.Parent;
local functional = tableGame.Functional;
local npcs = tableGame.NPCs;
local PlayVoiceline = tableGame.Remotes.PlayVoiceline;
local queuedVoicelines = {};
local priorityQueuedVoicelines = {};
local voicelineActive;

local function isSoundForPlayer(audio)
	local player = string.sub(audio, 1, 7);
	if player == "Player1" or player == "Player2" or player == "Player3" or player == "Player4" or player == "Player5" then
		return player;
	end
end

local function getPlayerNPC(playerName)
	for each, npc in pairs(npcs:GetChildren()) do
		if npc:GetAttribute("Stool") == playerName then
			return true;
		end
	end
end

local function queueVoiceline(audio, priority, queued)
	if not voicelineActive or queued then
		voicelineActive = true;
		
		local index = table.find(queuedVoicelines, audio);
		if index then
			table.remove(queuedVoicelines, index);
		end
		local index = table.find(priorityQueuedVoicelines, audio);
		if index then
			table.remove(priorityQueuedVoicelines, index);
		end
		
		local playerName = isSoundForPlayer(audio);
		if playerName then
			if functional.Stools[playerName].Seat.Occupant or getPlayerNPC(playerName) then
				GameFunctions:PlaySound("Blackjack", audio, functional.Dealer.Head, false, true, false);
			end
		else
			GameFunctions:PlaySound("Blackjack", audio, functional.Dealer.Head, false, true, false);
		end
		
		if #priorityQueuedVoicelines > 0 then
			queueVoiceline(priorityQueuedVoicelines[1], false, true);
		elseif #queuedVoicelines > 0 then
			queueVoiceline(queuedVoicelines[1], false, true);
		end
		
		voicelineActive = false;
	elseif priority then
		table.insert(priorityQueuedVoicelines, audio);
	else
		table.insert(queuedVoicelines, audio);
	end
end

PlayVoiceline.Event:Connect(function(audio, priority)
	queueVoiceline(audio, priority);
end)