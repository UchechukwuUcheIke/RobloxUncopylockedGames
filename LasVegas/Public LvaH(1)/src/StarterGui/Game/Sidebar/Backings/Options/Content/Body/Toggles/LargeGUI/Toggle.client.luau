local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local UserInterfaceData = require(ReplicatedModules:WaitForChild("UserInterfaceData"));

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer.PlayerGui;
local Button = script.Parent;
local Sidebar = Button.Parent.Parent.Parent.Parent.Parent.Parent;
local Tutorial = Sidebar.Parent:WaitForChild("Tutorial");
local Guide = Sidebar.Parent:WaitForChild("GuidePamplet");
local Payouts = Sidebar.Parent:WaitForChild("PayoutPamplet");

local OnText = "ON";
local OffText = "OFF";
local OnTextColor = Color3.fromRGB(150, 255, 120);
local OffTextColor = Color3.fromRGB(255, 110, 110);
local States = {"On", "Off"};
local NormalScaleLabels, NormalScaleButtons, NormalScaleFrames = UserInterfaceData:GetScaling("Normal");
local BigScaleLabels, BigScaleButtons, BigScaleFrames = UserInterfaceData:GetScaling("Big");

local function UpdateOptionDisplay()
	if Button:GetAttribute("CurrentState") == "On" then
		Button.TextFrame.Title.Text = OnText
		Button.TextFrame.TitleStroke.Text = OnText;
		Button.Background.Top.BackgroundColor3 = OnTextColor;
	else
		Button.TextFrame.Title.Text = OffText
		Button.TextFrame.TitleStroke.Text = OffText;
		Button.Background.Top.BackgroundColor3 = OffTextColor;
	end
end
local function ToggleSidebarVisiblity(toggle)
	for each, folder in pairs(Sidebar:GetChildren()) do
		for each, element in pairs(folder:GetChildren()) do
			if not element:IsA("Frame") then --options and store
				if string.sub(element.Name, 1, 6) == "Tokens" then
					element.Visible = toggle and LocalPlayer:GetAttribute("Tokens") > 0 or false;
				else
					element.Visible = toggle;
				end
			end
		end
	end
end
local function UpdateScalingForNewGUI(gui)
	local newScaleFrames = Button:GetAttribute("CurrentState") == "On" and BigScaleFrames or NormalScaleFrames;
	
	if newScaleFrames[gui.Name] then --casino game GUI
		for each, element in pairs(gui:GetChildren()) do
			if element.Name == "Backing" then
				element.Position = newScaleFrames[gui.Name].Position;
				element.Size = newScaleFrames[gui.Name].Size;
			end
		end
		
		if Button:GetAttribute("CurrentState") == "On" then
			ToggleSidebarVisiblity(false);
		end
	end
end
local function UpdateOptionEffect()
	local newScaleLabels = Button:GetAttribute("CurrentState") == "On" and BigScaleLabels or NormalScaleLabels;
	local newScaleButtons = Button:GetAttribute("CurrentState") == "On" and BigScaleButtons or NormalScaleButtons;
	local newScaleFrames = Button:GetAttribute("CurrentState") == "On" and BigScaleFrames or NormalScaleFrames;
	
	for each, folder in pairs(Sidebar:GetChildren()) do
		for each, element in pairs(folder:GetChildren()) do
			if element:IsA("TextButton") or element:IsA("ImageButton") then
				if newScaleButtons[element.Name] then
					element.Position = newScaleButtons[element.Name].Position;
					element.Size = newScaleButtons[element.Name].Size;
				end
			elseif element:IsA("TextLabel") or element:IsA("ImageLabel") then
				if newScaleLabels[element.Name] then
					element.Position = newScaleLabels[element.Name].Position;
					element.Size = newScaleLabels[element.Name].Size;
				end
			elseif element:IsA("Frame") then
				if newScaleFrames[element.Name] then
					element.Position = newScaleFrames[element.Name].Position;
					element.Size = newScaleFrames[element.Name].Size;
				end
			end
		end
	end
	for each, element in pairs(Tutorial:GetChildren()) do
		if element:IsA("Frame") then
			if newScaleFrames["Tutorial"..element.Name] then
				element.Position = newScaleFrames["Tutorial"..element.Name].Position;
				element.Size = newScaleFrames["Tutorial"..element.Name].Size;
			end
		end
	end
	for each, element in pairs(Guide:GetChildren()) do
		if element:IsA("Frame") then
			element.Position = newScaleFrames["Guide"].Position;
			element.Size = newScaleFrames["Guide"].Size;
		elseif element:IsA("TextButton") or element:IsA("ImageButton") then
			if newScaleButtons["Guide"..element.Name] then
				element.Position = newScaleButtons["Guide"..element.Name].Position;
				element.Size = newScaleButtons["Guide"..element.Name].Size;
			end
		end
	end
	for each, element in pairs(Payouts:GetChildren()) do
		if element:IsA("Frame") then
			element.Position = newScaleFrames["Payouts"].Position;
			element.Size = newScaleFrames["Payouts"].Size;
		elseif element:IsA("TextButton") or element:IsA("ImageButton") then
			if newScaleButtons["Payouts"..element.Name] then
				element.Position = newScaleButtons["Payouts"..element.Name].Position;
				element.Size = newScaleButtons["Payouts"..element.Name].Size;
			end
		end
	end
end
local function GetNewIndex(statesTable, currentState)
	local index = table.find(statesTable, currentState);
	local nextIndex = index + 1;
	if nextIndex > #statesTable then
		nextIndex = 1;
	end
	return nextIndex;
end
local function GetNewOptionState()
	return States[GetNewIndex(States, Button:GetAttribute("CurrentState"))];
end

Button.MouseButton1Up:Connect(function()
	Button:SetAttribute("CurrentState", GetNewOptionState());
	UpdateOptionDisplay();
	UpdateOptionEffect();
end)
Button.ForceUpdate.Event:Connect(function(newState)
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		Button:SetAttribute("CurrentState", "On");
	else
		Button:SetAttribute("CurrentState", newState);
	end
	UpdateOptionDisplay();
	UpdateOptionEffect();
end)

PlayerGui.ChildAdded:Connect(function(newGUI)
	if newGUI:IsA("ScreenGui") then
		UpdateScalingForNewGUI(newGUI);
	end
end)
PlayerGui.ChildRemoved:Connect(function(oldGUI)
	if oldGUI:IsA("ScreenGui") then
		local newScaleFrames = Button:GetAttribute("CurrentState") == "On" and BigScaleFrames or NormalScaleFrames;
		if newScaleFrames[oldGUI.Name] then --casino game GUI
			ToggleSidebarVisiblity(true);
		end
	end
end)