local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local GameData = require(ReplicatedStorage.Modules.GameData);
local player = Players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local bigWheelSixGui = script.Parent;
local backing = bigWheelSixGui.Backing;
local tableGame = bigWheelSixGui.ActualTable.Value;
local PlayerAction = tableGame.Remotes.PlayerAction;
local barrier = backing.Barrier;
local winnings = backing.Winnings;
local betBox = backing.BetBox;
local autoBet = backing.AutoBet;
local currentBet;
local currentColor;

humanoid.Changed:Connect(function()
	if not humanoid.Sit or humanoid.Health <= 0 then
		bigWheelSixGui:Destroy();
	end
end)

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "winnings" then
		winnings.Text = data[1];
		task.wait(tableGame:GetAttribute("TimeBeforeNewRound"));
		winnings.Text = "";
	elseif action == "newRound" then
		if autoBet.Image == "rbxassetid://2195446979" and currentColor and currentBet then
			PlayerAction:FireServer("Bet", {currentColor, currentBet});
		end
	end
end)

tableGame:GetAttributeChangedSignal("RoundStarted"):Connect(function()
	barrier.Visible = tableGame:GetAttribute("RoundStarted");
end)

local function doBetAction(selection)
	if selection ~= "Cancel" then
		local betAmount = tonumber(betBox.Text);
		if betAmount then
			currentColor = selection;
			currentBet = math.floor(betAmount);
			PlayerAction:FireServer("Bet", {currentColor, currentBet});
		end
	else
		PlayerAction:FireServer("Cancel");
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if not barrier.Visible then
			if input.KeyCode == Enum.KeyCode.R then
				doBetAction("Green");
			elseif input.KeyCode == Enum.KeyCode.T then
				doBetAction("Blue");
			elseif input.KeyCode == Enum.KeyCode.F then
				doBetAction("Red");
			elseif input.KeyCode == Enum.KeyCode.G then
				doBetAction("Yellow");
			elseif input.KeyCode == Enum.KeyCode.Y then
				doBetAction("Cancel");
			end
		end
	end
end)

local function initialize()
	barrier.Visible = tableGame:GetAttribute("RoundStarted");
	
	for each, button in pairs(backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				if not barrier.Visible then
					if button.Name == "BetGreen" then
						doBetAction("Green");
					elseif button.Name == "BetBlue" then
						doBetAction("Blue");
					elseif button.Name == "BetRed" then
						doBetAction("Red");
					elseif button.Name == "BetYellow" then
						doBetAction("Yellow");
					elseif button.Name == "Cancel" then
						doBetAction("Cancel");
					end
				end
				
				if button.Name == "AutoBet" then
					if button.Image == "" then
						button.Image = "rbxassetid://2195446979";
					else
						button.Image = "";
					end
				end
			end)
		end
	end
end
initialize();
