local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local GUI = script.Parent;
local Backing = GUI:WaitForChild("Backing");
local Barrier = Backing:WaitForChild("Barrier");
local AutoBet = Backing:WaitForChild("AutoBet");

local TableGame = GUI:WaitForChild("ActualTable");
local ActualGame = TableGame.Value;
local Functional = ActualGame:WaitForChild("Functional");
local Remotes = ActualGame:WaitForChild("Remotes");
local PlayerAction = Remotes:WaitForChild("PlayerAction");

local CameraFocused = false;
local OldCameraCFrame;

local function ToggleCamera()
	if not CameraFocused then
		OldCameraCFrame = Camera.CFrame;
		Camera.CameraType = Enum.CameraType.Scriptable;
		Camera.CameraSubject = Functional.CameraPart;
		Camera.CFrame = Functional.CameraPart.CFrame;
	else
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;
		Camera.CFrame = OldCameraCFrame;
	end

	CameraFocused = not CameraFocused;
end

local function FireServer(action, isAutoBet)
	if action == "Spin" then
		PlayerAction:FireServer("Spin");
	elseif action == "Cycle" then
		PlayerAction:FireServer("Cycle");
	elseif action == "AutoBet" then
		AutoBet.Image = AutoBet.Image == "" and "rbxassetid://2195446979" or "";
	elseif action == "Camera" then
		ToggleCamera();
	end
end

local function HandleInput(input, inputEnded)
	local isKeybind = typeof(input) == "Instance";
	if (isKeybind and input.KeyCode == Enum.KeyCode.H) or input == "AutoBet" then
		FireServer("AutoBet");
	elseif (isKeybind and input.KeyCode == Enum.KeyCode.C) or input == "Camera" then
		FireServer("Camera");
	elseif not Backing.Barrier.Visible then
		if (isKeybind and input.KeyCode == Enum.KeyCode.T) or input == "Spin" then
			FireServer("Spin");
		elseif (isKeybind and input.KeyCode == Enum.KeyCode.G) or input == "Cycle" then
			FireServer("Cycle");
		end
	end
end

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "spinConcluded" then
		Barrier.Visible = false;
		if AutoBet.Image == "rbxassetid://2195446979" then
			PlayerAction:FireServer("Spin");
		end
	end
end)

Humanoid.Changed:Connect(function()
	if not Humanoid.Sit or Humanoid.Health <= 0 then
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;	
		GUI:Destroy();
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
		HandleInput(input, false);
	end
end)

ActualGame:GetAttributeChangedSignal("Spinning"):Connect(function()
	Barrier.Visible = ActualGame:GetAttribute("Spinning");
end)
Barrier.Visible = ActualGame:GetAttribute("Spinning");

for each, button in pairs(Backing:GetChildren()) do
	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.MouseButton1Up:Connect(function()
			HandleInput(button.Name, false);
		end)
	end
end