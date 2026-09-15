local Permissions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local GroupService = game:GetService("GroupService");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local groupID = ReplicatedStorage:GetAttribute("GroupID"); --Las Vegas at home
local permissions = {
	[255] = 3, --Developer
	[254] = 2 --Moderator
};

function Permissions:GetPlayerGroupRank(player)
	local actualPlayer = Players:WaitForChild(player.Name, 10);
	if actualPlayer then
		return actualPlayer:GetRankInGroup(groupID);
	end
end

function Permissions:GetPlayerPermissionRank(player)
	if RunService:IsStudio() then
		return permissions[255]
	end
	
	local playerRankInGroup;
	
	if typeof(player) ~= "number" then
		playerRankInGroup = Permissions:GetPlayerGroupRank(player)
	else
		local success, list = pcall(GroupService.GetGroupsAsync, GroupService, player)
		if success then
			for _, group in pairs(list) do
				if group.Id == groupID then
					playerRankInGroup = group.Rank;
					break;
				end
			end
			
			if not playerRankInGroup then
				playerRankInGroup = 0;
			end
		end
	end
	
	if playerRankInGroup then
		if playerRankInGroup < 252 then
			if typeof(player) ~= "number" and ReplicatedStorage:GetAttribute("PrivateServerOwnerId") == player.UserId then
				return 1 --Server Owner
			end
			return 0
		end
		return permissions[playerRankInGroup]
	end
end

function Permissions:CanExecutorActOnPlayer(executor, player)
	local executorRank = Permissions:GetPlayerPermissionRank(executor);
	local playerRank = Permissions:GetPlayerPermissionRank(player);
	
	if not executorRank and not playerRank then
		return "failedBoth"
	elseif not executorRank then
		return "failedExecutor"
	elseif not playerRank then
		return "failedPlayer"
	end
	
	return executorRank >= playerRank
end

return Permissions