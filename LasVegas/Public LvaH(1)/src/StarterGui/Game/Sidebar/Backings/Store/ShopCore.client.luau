local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local ReplicatedRemotes = ReplicatedStorage:WaitForChild("Remotes");
local StorePurchase = ReplicatedRemotes:WaitForChild("StorePurchase");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));
local LocalPlayer = Players.LocalPlayer;

local Backing = script.Parent;
local Upgrades = Backing:WaitForChild("Upgrades");
local Cooldown = false;

local function WaitForAttribute(attributeName)
	if not LocalPlayer:GetAttribute(attributeName) then
		repeat
			RunService.Heartbeat:Wait();
		until LocalPlayer:GetAttribute(attributeName);
	end
end

local function ToggleOwnedDisplay(item)
	WaitForAttribute("Owns"..item.Name);
	item.CashBuy.Visible = not LocalPlayer:GetAttribute("Owns"..item.Name);
end

local function PurchaseUpgrade(element)
	if not Cooldown then
		Cooldown = true;
		local success = StorePurchase:FireServer(element.Name);
		ToggleOwnedDisplay(element);
		task.wait(1);
		Cooldown = false;
	end
end

for each, element in pairs(Upgrades:GetChildren()) do
	ToggleOwnedDisplay(element);
	element.CashBuy.MouseButton1Up:Connect(function()
		PurchaseUpgrade(element);
	end)
end