local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local player = game:GetService("Players").LocalPlayer;
local CmdrClient = require(game.ReplicatedStorage:WaitForChild("CmdrClient"));

local function initialize()
	CmdrClient:SetActivationKeys({Enum.KeyCode.F2, Enum.KeyCode.BackSlash});
	if not RunService:IsStudio() then
		if Permissions:GetPlayerPermissionRank(player) == 0 then
			CmdrClient:SetEnabled(false);
		end
	end
end
initialize();