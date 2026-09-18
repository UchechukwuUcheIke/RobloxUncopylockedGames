local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local GUI = script.Parent;
local Backing = GUI:WaitForChild("Backing");
local AutoBet = Backing:WaitForChild("AutoBet");
local BetBarrier = Backing:WaitForChild("BetBarrier");
local Message = Backing:WaitForChild("Message");
local BankerSevenBox = Backing:WaitForChild("BankerSevenBox");
local NineSevenBox = Backing:WaitForChild("NineSevenBox");
local PlayerEightBox = Backing:WaitForChild("PlayerEightBox");
local TieBox = Backing:WaitForChild("TieBox");
local PlayerBox = Backing:WaitForChild("PlayerBox");
local BankerBox = Backing:WaitForChild("BankerBox");

local ActualGame = GUI:WaitForChild("ActualTable");
local ActualGame = ActualGame.Value;
local Remotes = ActualGame:WaitForChild("Remotes");
local Functional = ActualGame:WaitForChild("Functional");
local PlayerAction = Remotes:WaitForChild("PlayerAction");

local CameraFocused = false;
local OldCameraCFrame;

local function ToggleCamera()
	if not CameraFocused then
		OldCameraCFrame = Camera.CFrame;
		Camera.CameraType = Enum.CameraType.Scriptable;
		Camera.CFrame = Functional.CameraPart.CFrame;
	else
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;
		Camera.CFrame = OldCameraCFrame;
	end
	CameraFocused = not CameraFocused;
end

local function CreateMessage(newText, color, timeUp)
	coroutine.wrap(function()
		Message.Visible = true;
		Message.Text = newText;
		Message.TextColor3 = color;
		task.wait(timeUp);
		Message.Visible = false;
		Message.Text = "";
		Message.TextColor3 = Color3.fromRGB(255, 255, 255);
	end)()
end

local function FireServer(action)
	if action == "Bet" then
		if tonumber(PlayerBox.Text) or tonumber(BankerBox.Text) or tonumber(TieBox.Text) or tonumber(PlayerEightBox.Text) or tonumber(BankerSevenBox.Text) or tonumber(NineSevenBox.Text) then
			PlayerAction:FireServer("Bet", {
				tonumber(PlayerBox.Text) or 0,
				tonumber(BankerBox.Text) or 0,
				tonumber(TieBox.Text) or 0,
				tonumber(PlayerEightBox.Text) or 0,
				tonumber(BankerSevenBox.Text) or 0,
				tonumber(NineSevenBox.Text) or 0,
			});
		else
			CreateMessage("Put a wager in one of the # boxes.", Color3.fromRGB(255, 100, 100), 3);
		end
	elseif action == "Clear" and not BetBarrier.Visible then
		PlayerAction:FireServer("Bet", {0, 0, 0, 0, 0, 0});
	elseif action == "AutoBet" then
		if AutoBet.Image == "" then
			AutoBet.Image = "rbxassetid://2195446979";
		else
			AutoBet.Image = "";
		end
	elseif action == "Camera" then
		ToggleCamera();
	end
end

PlayerAction.OnClientEvent:Connect(function(action)
	if action == "roundStarted" then
		BetBarrier.Visible = true;
	elseif action == "roundEnded" then
		BetBarrier.Visible = false;
		if AutoBet.Image == "rbxassetid://2195446979" then
			FireServer("Bet");
		end
	elseif action == "betHint" then
		CreateMessage("Cannot bet on Player and Banker.", Color3.fromRGB(255, 100, 100), 3);
	elseif action == "cashHint" then
		CreateMessage("Out of cash / Outside game limits.", Color3.fromRGB(255, 100, 100), 3);
	end
end)

local connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.F and not BetBarrier.Visible then
			FireServer("Bet");
		elseif input.KeyCode == Enum.KeyCode.R and not BetBarrier.Visible then
			FireServer("Clear");
		elseif input.KeyCode == Enum.KeyCode.H then
			FireServer("AutoBet");
		elseif input.KeyCode == Enum.KeyCode.C then
			FireServer("Camera");
		end
	end
end)

Humanoid.Changed:Connect(function()
	if not Humanoid.Sit then
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;	
		connection:Disconnect();
		GUI:Destroy();
	end
end)

local function initialize()
	BetBarrier.Visible = ActualGame:GetAttribute("RoundStarted");
	ActualGame:GetAttributeChangedSignal("RoundStarted"):Connect(function()
		BetBarrier.Visible = ActualGame:GetAttribute("RoundStarted");
	end)
	
	for each, button in pairs(Backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				if button.Name == "Bet" and not BetBarrier.Visible then
					FireServer("Bet");
				elseif button.Name == "Clear" and not BetBarrier.Visible then
					FireServer("Clear");
				elseif button.Name == "AutoBet" then
					FireServer("AutoBet");
				elseif button.Name == "Camera" then
					FireServer("Camera");
				end
			end)
		end
	end
end
initialize();
