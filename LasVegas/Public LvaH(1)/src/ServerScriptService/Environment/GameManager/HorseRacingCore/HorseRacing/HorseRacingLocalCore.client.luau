local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local GameData = require(ReplicatedStorage.Modules.GameData);
local player = Players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local horseRacingGui = script.Parent;
local backing = horseRacingGui.Backing;
local tableGame = horseRacingGui.ActualTable.Value;
local PlayerAction = tableGame.Remotes.PlayerAction;
local barrier = backing.Barrier;
local winnings = backing.Winnings;
local betBox = backing.BetBox;
local firstBox = backing.FirstBox;
local secondBox = backing.SecondBox;
local thirdBox = backing.ThirdBox;

humanoid.Changed:Connect(function()
	if not humanoid.Sit or humanoid.Health <= 0 then
		horseRacingGui:Destroy();
	end
end)

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "winnings" then
		winnings.Text = "You won "..GameData:AddCommasToNumber(data[1]).." tickets!";
		task.wait(tableGame:GetAttribute("TimeBetweenRaces"));
		winnings.Text = "";
	end
end)

tableGame:GetAttributeChangedSignal("RoundStarted"):Connect(function()
	barrier.Visible = tableGame:GetAttribute("RoundStarted");
end)

local function doBetAction()
	local betAmount = tonumber(betBox.Text);
	local firstNumber = tonumber(firstBox.Text);
	local secondNumber = tonumber(secondBox.Text);
	local thirdNumber = tonumber(thirdBox.Text);
	if betAmount and firstNumber and secondNumber and thirdNumber then
		PlayerAction:FireServer("Bet", {math.floor(betAmount), math.floor(firstNumber), math.floor(secondNumber), math.floor(thirdNumber)});
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if not barrier.Visible then
			if input.KeyCode == Enum.KeyCode.Y then
				doBetAction();
			end
		end
	end
end)

local function initialize()
	barrier.Visible = tableGame:GetAttribute("RoundStarted");

	for each, button in pairs(backing:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Up:Connect(function()
				if not barrier.Visible then
					if button.Name == "Bet" then
						doBetAction();
					end
				end
			end)
		end
	end
end
initialize();
