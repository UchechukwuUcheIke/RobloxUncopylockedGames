local Players = game:GetService("Players");
local Teams = game:GetService("Teams");
local spawns = workspace.Holo.Functional.Spawns;
local Allies = {
	{11138687, "The Okami Family", Color3.fromRGB(0, 153, 255)},
	{2548243, "Warriors Of Lethal Force", Color3.fromRGB(0, 60, 255)}
};

local function WaitForAttribute(Object, AttributeName)
	local Clock = os.clock();
	repeat
		if os.clock() - Clock >= 10 then
			warn("Possible infinite yield for "..AttributeName.." on "..Object.Name..".");
			break;
		end;
		game:GetService("RunService").Heartbeat:Wait();
	until Object:GetAttribute(AttributeName) ~= nil;
	return Object:GetAttribute(AttributeName);
end;

local function isAlly(player)
	for each, group in pairs(Allies) do
		if player:IsInGroup(group[1]) then
			return group;
		end
	end
end

local function giveRankGui(player, character)
	local head = character.Head or character:WaitForChild("Head");
	if not head:FindFirstChild("RankGui") then
		local rankGui = script.RankGui:Clone();
		local allyGroup = isAlly(player);
		local phoenixRank = player:GetRankInGroup(9164618);
		
		if phoenixRank >= 1 then
			rankGui.Rank.Text = player:GetRoleInGroup(9164618);
			if phoenixRank == 255 then
				rankGui.Rank.Size = UDim2.new(1, 0, 1, 0);
			elseif phoenixRank == 251 then
				rankGui.Ally.Text = allyGroup[2];
				rankGui.Ally.TextColor3 = allyGroup[3];
				rankGui.Ally.Position = UDim2.new(0, 0, 1, 0);
				rankGui.Ally.Visible = true;
			else
				rankGui.Merits.Text = WaitForAttribute(player, "Merits").." merits";
				rankGui.Merits.Visible = true;
			end
		elseif allyGroup then
			rankGui.Ally.Text = allyGroup[2];
			rankGui.Ally.TextColor3 = allyGroup[3];
			rankGui.Ally.Visible = true;
			rankGui.Rank.Text = player:GetRoleInGroup(allyGroup[1]);
			rankGui.Rank.Position = UDim2.new(0, 0, 0.5, 0);
		else
			rankGui.Rank.Text = "Guest";
		end
		
		local onPhoenixTeam = player.Team == Teams.Training or player.Team == Teams.Initiation;
		local onCombatTeam = player.Team == Teams.Red or player.Team == Teams.Blue;
		rankGui.Obby.Visible = (script.Parent.Parent.Game.HoloCore:GetAttribute("ObbyToggle") and onPhoenixTeam) or false;
		rankGui.Obby.Text = player:GetAttribute("ObbyCount") or 0;
		rankGui.Enabled = not onCombatTeam;
		
		rankGui.Adornee = head;
		rankGui.Parent = head;
	end
end

Players.PlayerAdded:Connect(function(player)
	local phoenixRank = player:GetRankInGroup(9164618);
	if phoenixRank >= 1 then
		local character = player.Character or player.CharacterAdded:Wait();
		if phoenixRank <= 2 then
			player.Team = Teams["Initiation"];
			character.PrimaryPart.CFrame = spawns.Initiation.CFrame;
		else
			player.Team = Teams["Training"];
			character.PrimaryPart.CFrame = spawns.Training.CFrame;
		end
	end
	
	local character = player.Character or player.CharacterAdded:Wait();
	giveRankGui(player, character);
	player.CharacterAdded:Connect(function(character)
		giveRankGui(player, character);
	end)
	
	player:GetAttributeChangedSignal("Merits"):Connect(function()
		local head = player.Character.Head;
		if head:FindFirstChild("RankGui") then
			head.RankGui.Merits.Text = WaitForAttribute(player, "Merits").." merits";
		end
	end)
	
	player.Changed:Connect(function(property)
		if property == "Team" then
			local character = player.Character or player.CharacterAdded:Wait();
			local rankGui = character:WaitForChild("Head"):WaitForChild("RankGui");
			local onCombatTeam = player.Team == Teams.Red or player.Team == Teams.Blue;
			rankGui.Enabled = not onCombatTeam;
		end
	end)
end)