local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local Players = game:GetService("Players");
local BetterChat = ServerScriptService:WaitForChild("BetterChat V3");
local BetterChatConfig = require(BetterChat:WaitForChild("Config"));
local Character = script.Parent;
local Player = Players:GetPlayerFromCharacter(Character);
local Humanoid = Character:WaitForChild("Humanoid");
local Head;

local groupRank = Player:GetRankInGroup(ReplicatedStorage:GetAttribute("GroupID"));
local groupRole = BetterChatConfig.Permissions.Groups[ReplicatedStorage:GetAttribute("GroupID")][groupRank];
local chatRank = 1;
for rank, role in pairs(BetterChatConfig.Permissions.Ranks) do
	if role == groupRole then
		chatRank = rank;
		break;
	end
end
local roleColor = BetterChatConfig.ChatTags.Ranks[chatRank][1]["Color"];

local function getHead()
	Head = Character:WaitForChild("Head", 10);
	if not Head then
		getHead();
	end
end

local function giveOverhead()
	local overhead = script.Overhead:Clone();
	overhead.Backing.Username.Text = Player.DisplayName;
	overhead.Backing.Role.Text = groupRole or "Guest";
	overhead.Backing.Role.TextColor3 = roleColor or Color3.fromRGB(255, 255, 255);
	overhead.Parent = Head;
	overhead.Adornee = Head;
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
end

getHead();
giveOverhead();