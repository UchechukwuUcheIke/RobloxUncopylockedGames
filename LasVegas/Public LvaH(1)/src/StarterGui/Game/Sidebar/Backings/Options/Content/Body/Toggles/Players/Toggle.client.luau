local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local button = script.Parent;
local OnText = "ON";
local OffText = "OFF";
local OnTextColor = Color3.fromRGB(150, 255, 120);
local OffTextColor = Color3.fromRGB(255, 110, 110);
local States = {"On", "Off"};

local function UpdateCharacterTransparency(character)
	for each, thing in pairs(character:GetDescendants()) do
		if (thing:IsA("BasePart") or thing:IsA("Decal")) and thing.Name ~= "Hitbox" and thing.Name ~= "HumanoidRootPart" then
			if not thing.Parent:IsA("Tool") then --stops tools from becoming transparent
				thing.Transparency = button:GetAttribute("CurrentState") == "On" and 0 or 1;
			end
		elseif thing:IsA("BillboardGui") or thing:IsA("ParticleEmitter") or thing:IsA("Fire") or thing:IsA("Smoke") or thing:IsA("Sparkles") then
			thing.Enabled = button:GetAttribute("CurrentState") == "On";
		end
	end
end

local function UpdateOptionDisplay()
	button.TextFrame.Title.Text = button:GetAttribute("CurrentState") == "On" and OnText or OffText;
	button.TextFrame.TitleStroke.Text = button:GetAttribute("CurrentState") == "On" and OnText or OffText;
	button.Background.Top.BackgroundColor3 = button:GetAttribute("CurrentState") == "On" and OnTextColor or OffTextColor;
end

local function UpdateOptionEffect()
	for each, character in pairs(workspace:GetChildren()) do
		if character:GetAttribute("PlayerModel") and character ~= Character then
			UpdateCharacterTransparency(character);
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

button.MouseButton1Up:Connect(function()
	button:SetAttribute("CurrentState", States[GetNewIndex(States, button:GetAttribute("CurrentState"))]);
	UpdateOptionDisplay();
	UpdateOptionEffect();
end)
button.ForceUpdate.Event:Connect(function(newState)
	button:SetAttribute("CurrentState", newState);
	UpdateOptionDisplay();
	UpdateOptionEffect();
end)

local function PlayerAdded(player)
	if player.Character then --this may result in running this function twice per player
		UpdateCharacterTransparency(player.Character); 
	end
	player.CharacterAdded:Connect(function(character)
		UpdateCharacterTransparency(character);
	end)
end
for each, player in pairs(Players:GetPlayers()) do
	PlayerAdded(player);
end
Players.PlayerAdded:Connect(function(player)
	PlayerAdded(player);
end)