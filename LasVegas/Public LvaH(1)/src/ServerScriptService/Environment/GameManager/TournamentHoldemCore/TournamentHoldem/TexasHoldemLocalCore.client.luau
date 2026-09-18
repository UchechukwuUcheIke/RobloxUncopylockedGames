local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local GUI = script.Parent;
local ActualTable = GUI:WaitForChild("ActualTable");
local Backing = GUI:WaitForChild("Backing");
local Message = Backing:WaitForChild("Message");
local Barrier = Backing:WaitForChild("Barrier");

local Timer = Backing:WaitForChild("Timer");
local BetBox = Backing:WaitForChild("BetBox");
local Table = ActualTable.Value;
local Functional = Table:WaitForChild("Functional");
local Remotes = Table:WaitForChild("Remotes");
local Cards = Functional:WaitForChild("Cards");
local CameraParts = Functional:WaitForChild("CameraParts");
local Stools = Functional:WaitForChild("Stools");
local PlayerAction = Remotes:WaitForChild("PlayerAction");

local CameraPart;
local OldCameraCFrame;
local StoolName;

local function createMessage(newText, color, timeUp)
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

local function startTimer()
	coroutine.wrap(function()
		Timer.Visible = true;

		while os.time() < Table:GetAttribute("TimeBeforeTurnEnds") do
			Timer.Text = Table:GetAttribute("TimeBeforeTurnEnds") - os.time();
			if Barrier.Visible then
				break;
			end
			task.wait();
		end

		Timer.Visible = false;
	end)()
end

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "yourTurn" then
		Barrier.Visible = false;
		startTimer();
	elseif action == "noLongerYourTurn" then
		Barrier.Visible = true;
		Timer.Visible = false;
	elseif action == "showWinnings" then
		createMessage("You won $"..GameData:AddCommasToNumber(data[1]).."!", Color3.fromRGB(100, 255, 100), Table:GetAttribute("TimeBetweenHands"));
	end
end)

local function fireServer(action, betAmount)
	Barrier.Visible = true;
	Timer.Visible = false;
	BetBox.Text = "";
	PlayerAction:FireServer(action, betAmount);
end

local function getPlayerStoolName(actualPlayer)
	local character = actualPlayer:IsA("Player") and actualPlayer.Character or actualPlayer;
	local Humanoid = character and character:FindFirstChild("Humanoid");
	for each, stool in pairs(Stools:GetChildren()) do
		if stool.Seat.Occupant and stool.Seat.Occupant == Humanoid then
			return stool.Name;
		end
	end
end

local function toggleCamera()
	if not StoolName then
		StoolName = getPlayerStoolName(LocalPlayer);
	end

	if not CameraPart then
		OldCameraCFrame = Camera.CFrame;
		CameraPart = CameraParts:FindFirstChild(StoolName);
		if CameraPart then
			Camera.CameraType = Enum.CameraType.Scriptable;
			Camera.CameraSubject = CameraPart;
			Camera.CFrame = CameraPart.CFrame;
		end
	elseif CameraPart.Name ~= "Dealer" then
		CameraPart = CameraParts:FindFirstChild("Dealer");
		if CameraPart then
			Camera.CameraType = Enum.CameraType.Scriptable;
			Camera.CameraSubject = CameraPart;
			Camera.CFrame = CameraPart.CFrame;
		end
	else
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;
		Camera.CFrame = OldCameraCFrame;
		CameraPart = nil;
	end
end

local connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.C then
			toggleCamera();
		elseif not Barrier.Visible then
			if input.KeyCode == Enum.KeyCode.G then
				fireServer("Fold");
			elseif input.KeyCode == Enum.KeyCode.F then
				fireServer("Check");
			elseif input.KeyCode == Enum.KeyCode.R then
				fireServer("Call");
			elseif input.KeyCode == Enum.KeyCode.T then
				local betAmount = tonumber(BetBox.Text);
				if betAmount then
					if betAmount >= Table:GetAttribute("MinCash") and betAmount <= Table:GetAttribute("MaxCash") then
						fireServer("Raise", math.floor(betAmount));
					else
						createMessage("Raise outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
					end
				else
					createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
				end
			elseif input.KeyCode == Enum.KeyCode.Y then
				local betAmount = tonumber(BetBox.Text);
				if betAmount then
					if betAmount >= Table:GetAttribute("MinCash") and betAmount <= Table:GetAttribute("MaxCash") then
						fireServer("Bet", math.floor(betAmount));
					else
						createMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
					end
				else
					createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
				end
			end
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
	for each, stool in pairs(Table.Functional.Stools:GetChildren()) do
		if stool.Seat.Occupant == Humanoid then
			Cards[stool.Name].Card1:GetAttributeChangedSignal("ImageID"):Connect(function()
				Cards[stool.Name].Card1.SurfaceGui.ImageLabel.Image = Cards[stool.Name].Card1:GetAttribute("ImageID");
			end)
			Cards[stool.Name].Card2:GetAttributeChangedSignal("ImageID"):Connect(function()
				Cards[stool.Name].Card2.SurfaceGui.ImageLabel.Image = Cards[stool.Name].Card2:GetAttribute("ImageID");
			end)
		end
	end
	
	for each, button in pairs(Backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				if string.sub(button.Name, 1, 4) == "Card" then
					toggleCamera();
				elseif not Barrier.Visible then
					if button.Name == "Raise" then
						local betAmount = tonumber(BetBox.Text);
						if betAmount then
							if betAmount >= Table:GetAttribute("MinCash") and betAmount <= Table:GetAttribute("MaxCash") then
								fireServer("Raise", math.floor(betAmount));
							else
								createMessage("Raise outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
							end
						else
							createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
						end
					elseif button.Name == "Bet" then
						local betAmount = tonumber(BetBox.Text);
						if betAmount then
							if betAmount >= Table:GetAttribute("MinCash") and betAmount <= Table:GetAttribute("MaxCash") then
								fireServer("Bet", math.floor(betAmount));
							else
								createMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
							end
						else
							createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
						end
					else
						fireServer(button.Name);
					end
				end
			end)
		end
	end
end
initialize();