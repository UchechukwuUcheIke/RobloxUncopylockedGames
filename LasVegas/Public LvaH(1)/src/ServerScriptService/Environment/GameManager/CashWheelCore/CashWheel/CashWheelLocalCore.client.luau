local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local GameData = require(ReplicatedStorage.Modules.GameData);
local player = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local cashWheelGui = script.Parent;
local backing = cashWheelGui.Backing;
local tableGame = cashWheelGui.ActualTable.Value;
local PlayerAction = tableGame.Remotes.PlayerAction;
local winnings = backing.Winnings;
local cooldown = backing.Cooldown;
local barrier = backing.Barrier;

local CameraFocused = false;
local OldCameraCFrame;

humanoid.Changed:Connect(function()
	if not humanoid.Sit or humanoid.Health <= 0 then
		cashWheelGui:Destroy();
	end
end)

local function ToggleCamera()
	if not CameraFocused then
		OldCameraCFrame = Camera.CFrame;
		Camera.CameraType = Enum.CameraType.Scriptable;
		Camera.CameraSubject = tableGame.Functional.CameraPart;
		Camera.CFrame = tableGame.Functional.CameraPart.CFrame;
	else
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = humanoid;
		Camera.CFrame = OldCameraCFrame;
	end

	CameraFocused = not CameraFocused;
end

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "winnings" then
		winnings.Text = "You won $"..GameData:AddCommasToNumber(data[1]).."!";
		winnings.Visible = true;
		task.wait(tableGame:GetAttribute("TimeBeforeNewRound"));
		winnings.Visible = false;
		winnings.Text = "";
	elseif action == "eligible" then
		cooldown.Visible = false;
	elseif action == "ineligible" then
		cooldown.Visible = true;
		barrier.Visible = false;
		
		local minutesLeft = math.ceil(data[1] / 60);
		if minutesLeft == 1 then
			cooldown.TimeLeft.Text = "You have <b><font color='rgb(0,255,0)'>"..GameData:AddCommasToNumber(minutesLeft).."</font></b> minute before you can spin the wheel again."
		else
			cooldown.TimeLeft.Text = "You have <b><font color='rgb(0,255,0)'>"..GameData:AddCommasToNumber(minutesLeft).."</font></b> minutes before you can spin the wheel again."
		end
	end
end)

local function HandleInput(input)
	local isKeybind = typeof(input) == "Instance"

	if (isKeybind and input.KeyCode == Enum.KeyCode.C) or input == "Camera" then
		ToggleCamera();
	end
end

humanoid.Changed:Connect(function()
	if not humanoid.Sit or humanoid.Health <= 0 then
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = humanoid;
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
		HandleInput(input);
	end
end)

for each, button in pairs(backing:GetChildren()) do
	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.MouseButton1Up:Connect(function()
			HandleInput(button.Name);
		end)
	end
end

barrier.Visible = tableGame:GetAttribute("RoundStarted") and not cooldown.Visible;
tableGame:GetAttributeChangedSignal("RoundStarted"):Connect(function()
	barrier.Visible = tableGame:GetAttribute("RoundStarted") and not cooldown.Visible;
end)