local button = script.Parent;
local OnText = "ON";
local OffText = "OFF";
local OnTextColor = Color3.fromRGB(150, 255, 120);
local OffTextColor = Color3.fromRGB(255, 110, 110);
local States = {"On", "Off"};

local function UpdateOptionDisplay(option)
	if option:GetAttribute("CurrentState") == "On" then
		option.TextFrame.Title.Text = OnText
		option.TextFrame.TitleStroke.Text = OnText;
		option.Background.Top.BackgroundColor3 = OnTextColor;
	else
		option.TextFrame.Title.Text = OffText
		option.TextFrame.TitleStroke.Text = OffText;
		option.Background.Top.BackgroundColor3 = OffTextColor;
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
local function GetNewOptionState(option)
	return States[GetNewIndex(States, button:GetAttribute("CurrentState"))];
end

button.MouseButton1Up:Connect(function()
	button:SetAttribute("CurrentState", GetNewOptionState(button.Name));
	UpdateOptionDisplay(button);
end)
button.ForceUpdate.Event:Connect(function(newState)
	button:SetAttribute("CurrentState", newState);
	UpdateOptionDisplay(button);
end)