local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService("StarterGui");
local Players = game:GetService("Players");

local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local GUI = script.Parent;
local Backing = GUI:WaitForChild("Backing");
local Barrier = Backing:WaitForChild("Barrier");
local Message = Backing:WaitForChild("Message");
local BetBox = Backing:WaitForChild("BetBox");
local AutoBet = Backing:WaitForChild("AutoBet");
local Ball = script:WaitForChild("Ball");

local TableGame = GUI:WaitForChild("ActualTable");
local ActualGame = TableGame.Value;
local Functional = ActualGame:WaitForChild("Functional");
local Remotes = ActualGame:WaitForChild("Remotes");
local PlayerAction = Remotes:WaitForChild("PlayerAction");
local Spawns = Functional:WaitForChild("Spawns");
local SpawnA = Spawns:WaitForChild("SpawnA");
local SpawnB = Spawns:WaitForChild("SpawnB");
local LimitA = Spawns:WaitForChild("LimitA");
local LimitB = Spawns:WaitForChild("LimitB");

local CameraFocused = false;
local OldCameraCFrame;
local CurrentPlinko;
local PreviousPlinko;

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
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not CameraFocused);
end

local function CreateBall()
	if Functional:FindFirstChild("Ball") then
		Functional.Ball:Destroy();
		CurrentPlinko = nil;
	end
	if not CurrentPlinko then
		print("making new ball")
		CurrentPlinko = Ball:Clone();
		CurrentPlinko.CFrame = SpawnA.CFrame;
		CurrentPlinko.Transparency = 0;
		CurrentPlinko.Parent = Functional;
	end
end

local function DestroyBall(leaving)
	if CurrentPlinko then
		print("destroying current ball")
		CurrentPlinko:Destroy();
		CurrentPlinko = nil;
	end
	if leaving then
		GUI:Destroy();
	end
end

local function FireServer(action, isAutoBet)
	if action == "Bet" then
		local betAmount = tonumber(BetBox.Text);
		local fixedBet = betAmount and math.floor(betAmount);
		if CurrentPlinko and fixedBet then
			if fixedBet >= ActualGame:GetAttribute("MinCash") and fixedBet <= ActualGame:GetAttribute("MaxCash") then
				if LocalPlayer:GetAttribute("Cash") >= fixedBet then
					PlayerAction:FireServer("Bet", {CurrentPlinko.Position, fixedBet});
					PreviousPlinko = CurrentPlinko.Position;
				else
					CreateMessage("Out of cash.", Color3.fromRGB(255, 100, 100), 3);
				end
			else
				CreateMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
			end
		else
			CreateMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
		end
	elseif action == "Cancel" then
		PlayerAction:FireServer("Cancel");
	elseif action == "AutoBet" then
		AutoBet.Image = AutoBet.Image == "" and "rbxassetid://2195446979" or "";
	elseif action == "Camera" then
		ToggleCamera();
	end
end

local function HandleInput(input, inputEnded)
	local isKeybind = typeof(input) == "Instance"
	
	if (isKeybind and input.KeyCode == Enum.KeyCode.H) or input == "AutoBet" then
		FireServer("AutoBet");
	elseif (isKeybind and input.KeyCode == Enum.KeyCode.C) or input == "Camera" then
		FireServer("Camera");
	elseif not Backing.Barrier.Visible then
		if (isKeybind and input.KeyCode == Enum.KeyCode.R) or input == "MoveLeft" then
			if not inputEnded then
				GUI:SetAttribute("PlinkoMoveDirection", GUI:GetAttribute("PlinkoMoveDirection") + 1);
				if GUI:GetAttribute("PlinkoMoveDirection") > 1 then
					GUI:SetAttribute("PlinkoMoveDirection", 1);
				end
			else
				GUI:SetAttribute("PlinkoMoveDirection", GUI:GetAttribute("PlinkoMoveDirection") - 1);
				if GUI:GetAttribute("PlinkoMoveDirection") < -1 then
					GUI:SetAttribute("PlinkoMoveDirection", -1);
				end
			end
		elseif (isKeybind and input.KeyCode == Enum.KeyCode.T) or input == "MoveRight" then
			if not inputEnded then
				GUI:SetAttribute("PlinkoMoveDirection", GUI:GetAttribute("PlinkoMoveDirection") - 1);
				if GUI:GetAttribute("PlinkoMoveDirection") < -1 then
					GUI:SetAttribute("PlinkoMoveDirection", -1);
				end
			else
				GUI:SetAttribute("PlinkoMoveDirection", GUI:GetAttribute("PlinkoMoveDirection") + 1);
				if GUI:GetAttribute("PlinkoMoveDirection") > 1 then
					GUI:SetAttribute("PlinkoMoveDirection", 1);
				end
			end
		elseif (isKeybind and input.KeyCode == Enum.KeyCode.G) or input == "Place" then
			FireServer("Bet");
		elseif (isKeybind and input.KeyCode == Enum.KeyCode.Y) or input == "Cancel" then
			FireServer("Cancel");
		end
	end
end

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "roundEnded" then
		if data[1] > 0 then
			CreateMessage("You won $"..GameData:AddCommasToNumber(data[1]).."!", Color3.fromRGB(100, 255, 100), ActualGame:GetAttribute("TimeBeforeNewRound"));
		end
	elseif action == "dropping" then
		DestroyBall(false);
		Barrier.Visible = true;
	elseif action == "roundStarting" then
		CreateBall();
		Barrier.Visible = false;
		if AutoBet.Image == "rbxassetid://2195446979" then
			local betAmount = tonumber(BetBox.Text);
			local fixedBet = betAmount and math.floor(betAmount);
			if PreviousPlinko and fixedBet and fixedBet >= ActualGame:GetAttribute("MinCash") and fixedBet <= ActualGame:GetAttribute("MaxCash") and LocalPlayer:GetAttribute("Cash") >= fixedBet then
				PlayerAction:FireServer("Bet", {PreviousPlinko, fixedBet});
			end
		else
			PreviousPlinko = nil;
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
		HandleInput(input, false);
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.T then
			HandleInput(input, true);
		end
	end
end)

Humanoid.Changed:Connect(function()
	if not Humanoid.Sit or Humanoid.Health <= 0 then
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;	
		DestroyBall(true);
	end
end)

GUI:GetAttributeChangedSignal("PlinkoMoveDirection"):Connect(function()
	if CurrentPlinko then
		local direction = CurrentPlinko.CFrame.LookVector * GUI:GetAttribute("PlinkoMoveDirection");
		local limitCFrame = GUI:GetAttribute("PlinkoMoveDirection") > 0 and LimitB.CFrame or LimitA.CFrame;
		
		while GUI:GetAttribute("PlinkoMoveDirection") ~= 0 and CurrentPlinko do
			local newCFrame = CurrentPlinko.CFrame + (direction * 0.1);
			if (newCFrame.Position - limitCFrame.Position).Magnitude > 1 then
				CurrentPlinko.CFrame = newCFrame;
			end
			task.wait(1/60);
		end
	end
end)

local function initialize()
	Barrier.Visible = ActualGame:GetAttribute("RoundStarted");

	if not ActualGame:GetAttribute("RoundStarted") then
		CreateBall();
	end
	
	for each, button in pairs(Backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Down:Connect(function()
				HandleInput(button.Name, false);
			end)
			if button.Name == "MoveLeft" or button.Name == "MoveRight" then
				button.MouseButton1Up:Connect(function()
					HandleInput(button.Name, true);
				end)
			end
		end
	end
end
initialize();