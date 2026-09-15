local ServerStorage = game:GetService("ServerStorage");
local ServerModules = ServerStorage:WaitForChild("Modules");
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
local NPCs = require(ServerModules:WaitForChild("NPCs"));
local Games = workspace:WaitForChild("Games");
local Slots = Games:WaitForChild("Slots");
local TableGames = Games:WaitForChild("Tables");
local AllGames = {};
local AllStools = {};
local AllPriorityGames = {};
local AllPriorityStools = {};
local AllNPCs = {};
local RNG = Random.new();

local function SetGlobalNPCCount()
	local count = 0;
	for each, arcadeGame in pairs(AllGames) do
		if arcadeGame:GetAttribute("NPCsAtGame") then
			count += arcadeGame:GetAttribute("NPCsAtGame");
		end
	end
	script:SetAttribute("GlobalNPCCount", count);
end

local function UpdateTables()
	AllGames = {};
	AllStools = {};
	AllPriorityGames = {};
	AllPriorityStools = {};
	
	for each, slotGroup in pairs(Slots:GetChildren()) do
		for each, slot in pairs(slotGroup:GetChildren()) do
			if slot:GetAttribute("NPCsPriority") then
				table.insert(AllPriorityGames, slot);
			else
				table.insert(AllGames, slot);
			end
		end
	end
	for each, tableGroup in pairs(TableGames:GetChildren()) do
		for each, tableGame in pairs(tableGroup:GetChildren()) do
			if tableGame:GetAttribute("NPCsPriority") then
				table.insert(AllPriorityGames, tableGame);
			else
				table.insert(AllGames, tableGame);
			end
		end
	end
	for each, arcadeGame in pairs(AllGames) do
		if arcadeGame:GetAttribute("NPCsAllowed") then
			if arcadeGame:IsDescendantOf(Slots) then
				table.insert(AllStools, arcadeGame.Functional.Stool);
			else
				for each, stool in pairs(arcadeGame.Functional.Stools:GetChildren()) do
					table.insert(AllStools, stool);
				end
			end
		end
	end
	for each, arcadeGame in pairs(AllPriorityGames) do
		if arcadeGame:GetAttribute("NPCsAllowed") then
			if arcadeGame:IsDescendantOf(Slots) then
				table.insert(AllPriorityStools, arcadeGame.Functional.Stool);
			else
				for each, stool in pairs(arcadeGame.Functional.Stools:GetChildren()) do
					table.insert(AllPriorityStools, stool);
				end
			end
		end
	end
end

local function SpawnNPC(casinoGame, stool, gameType)
	-- Determine whether NPC will be R15 or R6
	local r15 = true --RNG:NextNumber() >= 0.5;     some R15 avatars which spawn as R6 have their layered clothing out of position
	
	-- Get an NPC and put them in their stool at the gane
	local npcName = AllNPCs[RNG:NextInteger(1, #AllNPCs)];
	local npc = NPCs:GetAvatarForNPC(npcName, casinoGame.NPCs, r15);
	npc.HumanoidRootPart.Anchored = false;
	npc:SetPrimaryPartCFrame(stool.Seat.CFrame);
	
	-- Get the animations for the NPC and load them
	local sitAnim = r15 and script.SitAnimR15:Clone() or script.SitAnimR6:Clone();
	sitAnim.Parent = npc;
	sitAnim.Name = "SitAnim";
	local jumpAnim = r15 and script.JumpAnimR15:Clone() or script.JumpAnimR6:Clone();
	jumpAnim.Parent = npc;
	jumpAnim.Name = "JumpAnim";
	
	-- Put a nametag over their head
	local overhead = script.Overhead:Clone();
	overhead.Backing.Username.Text = npcName;
	overhead.Backing.Role.Text = "NPC";
	overhead.Parent = npc.Head;
	overhead.Adornee = npc.Head;
	npc.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;

	-- Finalize Values
	casinoGame:SetAttribute("NPCsAtGame", casinoGame:GetAttribute("NPCsAtGame") + 1);
	npc:SetAttribute("GameType", gameType);
	npc:SetAttribute("Stool", stool.Name);
	local playGame = script.PlayGame:Clone();
	playGame.Parent = npc;
	playGame.Disabled = false;
end

local function GetAllNPCsTemplates()
	AllNPCs = NPCs:GetAllNPCs();
	if #AllNPCs < 50 then
		task.wait(1);
		GetAllNPCsTemplates();
	end
end

local function AttemptSpawn(listOfStools)
	local randomIndex = RNG:NextInteger(1, #listOfStools);
	local randomStool = listOfStools[randomIndex];				
	local randomGame = randomStool.Parent.Parent.Parent;
	if randomGame:IsDescendantOf(Slots) then
		randomGame = randomStool.Parent.Parent;
	end
	
	if not randomStool.Seat.Occupant and not randomGame.NPCs:FindFirstChild(randomStool.Name) then
		if not randomGame:IsDescendantOf(Slots) or (not randomGame:GetAttribute("Spinning") and not randomGame:GetAttribute("Cooldown")) then
			SpawnNPC(randomGame, randomStool, randomGame.Name);
			script:SetAttribute("GlobalNPCCount", script:GetAttribute("GlobalNPCCount") + 1);
		end
	end
	
	table.remove(listOfStools, randomIndex);
end

local function Initialize()
	UpdateTables();
	GetAllNPCsTemplates();

	while true do
		if script:GetAttribute("GlobalSpawning") then
			SetGlobalNPCCount();

			local AvailableStools = table.clone(AllStools);
			local AvailablePriorityStools = table.clone(AllPriorityStools);
			
			while script:GetAttribute("GlobalNPCCount") < script:GetAttribute("GlobalNPCLimit") or script:GetAttribute("Cinema") do --cinema fills all the games with NPCs for thumbnails/pictures
				-- Spawn NPCs at all the priority games before spawning them elsewhere --
				-- This is useful for debugging if you need NPCs at a specific game to test stuff --
				if #AvailablePriorityStools > 0 then 
					AttemptSpawn(AvailablePriorityStools);
				elseif #AvailableStools > 0 then
					AttemptSpawn(AvailableStools);
				else
					break;
				end
				
				task.wait(script:GetAttribute("Cinema") and 0 or RNG:NextNumber(1, 3));
			end
		end
		
		task.wait(15);
	end
end
Initialize();