local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");

local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));
local LocalPlayer = Players.LocalPlayer;
local Sidebar = script.Parent;
local Tutorial = Sidebar.Parent:WaitForChild("Tutorial");

local Toggles = Sidebar:WaitForChild("Toggles");
local Backings = Sidebar:WaitForChild("Backings");
local CashFolder = Sidebar:WaitForChild("Cash");
local CashText = CashFolder:WaitForChild("Cash");
local CashStrokeText = CashFolder:WaitForChild("CashStroke");
local TotalPlaytimeFolder = Sidebar:WaitForChild("TotalPlaytime");
local TotalPlaytimeText = TotalPlaytimeFolder:WaitForChild("TotalPlaytime");
local TotalPlaytimeStrokeText = TotalPlaytimeFolder:WaitForChild("TotalPlaytimeStroke");
local PlaytimeLimitFolder = Sidebar:WaitForChild("PlaytimeLimit");
local PlaytimeLimitText = PlaytimeLimitFolder:WaitForChild("PlaytimeLimit");
local PlaytimeLimitStrokeText = PlaytimeLimitFolder:WaitForChild("PlaytimeLimitStroke");
local TokensFolder = Sidebar:WaitForChild("Tokens");
local TokensText = TokensFolder:WaitForChild("Tokens");
local TokensStrokeText = TokensFolder:WaitForChild("TokensStroke");

local function WaitForAttribute(attributeName)
	if not LocalPlayer:GetAttribute(attributeName) then
		repeat
			RunService.Heartbeat:Wait();
		until LocalPlayer:GetAttribute(attributeName);
	end
end

local function UpdateDisplay(attributeName)
	WaitForAttribute(attributeName);
	
	local newValue = GameData:AddCommasToNumber(LocalPlayer:GetAttribute(attributeName));
	if attributeName == "Cash" then
		local newDisplay = "$"..newValue;
		CashText.Text = newDisplay;
		CashStrokeText.Text = newDisplay;
	elseif attributeName == "Playtime" then
		local newDisplay = LocalPlayer:GetAttribute("Playtime") == 1 and newValue.." minute" or newValue.." minutes";
		TotalPlaytimeText.Text = newDisplay;
		TotalPlaytimeStrokeText.Text = newDisplay;
	elseif attributeName == "MinutesOnline" then
		local newDisplay = newValue.." / "..GameData:AddCommasToNumber(ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes")).. " minutes";
		PlaytimeLimitText.Text = newDisplay;
		PlaytimeLimitStrokeText.Text = newDisplay;
	elseif attributeName == "Tokens" then
		local newDisplay = "T$"..newValue;
		TokensText.Text = newDisplay;
		TokensStrokeText.Text = newDisplay;
		for each, element in pairs(TokensFolder:GetChildren()) do
			element.Visible = LocalPlayer:GetAttribute("Tokens") > 0;
		end
	end
end

UpdateDisplay("Cash");
UpdateDisplay("Playtime");
UpdateDisplay("MinutesOnline");
UpdateDisplay("Tokens");

LocalPlayer:GetAttributeChangedSignal("Cash"):Connect(function()
	UpdateDisplay("Cash");
end)
LocalPlayer:GetAttributeChangedSignal("Playtime"):Connect(function()
	UpdateDisplay("Playtime");
end)
LocalPlayer:GetAttributeChangedSignal("MinutesOnline"):Connect(function()
	UpdateDisplay("MinutesOnline");
end)
LocalPlayer:GetAttributeChangedSignal("Tokens"):Connect(function()
	UpdateDisplay("Tokens");
end)

for each, toggle in pairs(Toggles:GetChildren()) do
	toggle.MouseButton1Click:Connect(function()
		for each, backing in pairs(Backings:GetChildren()) do
			if backing.Name == toggle.Name then
				backing.Visible = not backing.Visible;
			else
				backing.Visible = backing.Name == toggle.Name;
			end
			if backing.Name == "Options" and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not backing.Visible);
			end
		end
		
		if toggle.Name == "Tutorial" then
			local canOpen = true;
			for each, frame in pairs(Tutorial:GetChildren()) do
				if frame:IsA("Frame") and frame.Visible then
					canOpen = false;
					break;
				end
			end
			Tutorial[0].Visible = canOpen;
		end
	end)
end
for each, backing in pairs(Backings:GetChildren()) do
	backing.Close.ImageButton.MouseButton1Click:Connect(function()
		backing.Visible = false;
		if backing.Name == "Options" and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true);
		end
	end)
end