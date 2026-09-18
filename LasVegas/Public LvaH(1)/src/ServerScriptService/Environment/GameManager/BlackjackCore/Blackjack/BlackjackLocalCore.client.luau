local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local GUI = script.Parent;
local ActualTable = GUI:WaitForChild("ActualTable");
local Backing = GUI:WaitForChild("Backing");
local Message = Backing:WaitForChild("Message");
local Barrier = Backing:WaitForChild("Barrier");

local BetBarrier = Backing:WaitForChild("BetBarrier");
local AutoBet = Backing:WaitForChild("AutoBet");
local Timer = Backing:WaitForChild("Timer");
local Hand = Backing:WaitForChild("Hand");
local BetBox = Backing:WaitForChild("BetBox");
local Table = ActualTable.Value;
local Functional = Table:WaitForChild("Functional");
local Remotes = Table:WaitForChild("Remotes");
local Bets = Functional:WaitForChild("Bets");
local Turns = Functional:WaitForChild("Turns");
local CameraParts = Functional:WaitForChild("CameraParts");
local Stools = Functional:WaitForChild("Stools");
local PlayerAction = Remotes:WaitForChild("PlayerAction");

local CameraPart;
local OldCameraCFrame;
local StoolName;

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

local function getPlayerStoolName(actualPlayer)
	local character = actualPlayer:IsA("Player") and actualPlayer.Character or actualPlayer;
	local humanoid = character and character:FindFirstChild("Humanoid");
	for each, stool in pairs(Stools:GetChildren()) do
		if stool.Seat.Occupant and stool.Seat.Occupant == humanoid then
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

Humanoid.Changed:Connect(function()
	if not Humanoid.Sit then
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;	
		GUI:Destroy();
	end
end)

local function fireServer(action, betAmount)
	Barrier.Visible = true;
	Timer.Visible = false;
	Hand.Visible = false;
	PlayerAction:FireServer(action, betAmount);
end

PlayerAction.OnClientEvent:Connect(function(action)
	if action == "yourTurn" then
		Barrier.Visible = false;
		startTimer();
	elseif action == "originalHand" then
		Barrier.Visible = false;
		Hand.Visible = true;
		Hand.Text = "(original Hand)";
		startTimer();
	elseif action == "splitHand" then
		Barrier.Visible = false;
		Hand.Visible = true;
		Hand.Text = "(split Hand)";
		startTimer();
	elseif action == "noLongerYourTurn" then
		Barrier.Visible = true;
		Timer.Visible = false;
		Hand.Visible = false;
	elseif action == "roundStarted" or action == "insurnaceEnded" then
		BetBarrier.Visible = true;
	elseif action == "roundEnded" or action == "insuranceStarted" then
		BetBarrier.Visible = false;
		if AutoBet.Image == "rbxassetid://2195446979" and action ~= "insuranceStarted" then
			local betAmount = tonumber(BetBox.Text);
			if betAmount then
				if tonumber(betAmount) >= Table:GetAttribute("MinCash") and tonumber(betAmount) <= Table:GetAttribute("MaxCash") then
					if LocalPlayer:GetAttribute("Cash") >= betAmount then
						fireServer("Bet", math.floor(betAmount));
					else
						createMessage("Out of cash.", Color3.fromRGB(255, 100, 100), 3);
					end
				else
					createMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
				end
			else
				createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.R and not Barrier.Visible then
			fireServer("Hit");
		elseif input.KeyCode == Enum.KeyCode.T and not Barrier.Visible then
			fireServer("Stand");
		elseif input.KeyCode == Enum.KeyCode.F and not Barrier.Visible then
			fireServer("DoubleDown");
		elseif input.KeyCode == Enum.KeyCode.G and not Barrier.Visible then
			fireServer("Split");
		elseif input.KeyCode == Enum.KeyCode.Y and not BetBarrier.Visible then
			local betAmount = tonumber(BetBox.Text);
			if betAmount then
				if tonumber(betAmount) >= Table:GetAttribute("MinCash") and tonumber(betAmount) <= Table:GetAttribute("MaxCash") then
					if LocalPlayer:GetAttribute("Cash") >= betAmount then
						fireServer("Bet", math.floor(betAmount));
					else
						createMessage("Out of cash.", Color3.fromRGB(255, 100, 100), 3);
					end
				else
					createMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
				end
			else
				createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
			end
		elseif input.KeyCode == Enum.KeyCode.H then
			if AutoBet.Image == "" then
				AutoBet.Image = "rbxassetid://2195446979";
			else
				AutoBet.Image = "";
			end
		elseif input.KeyCode == Enum.KeyCode.C then
			toggleCamera();
		end
	end
end)

local function initialize()
	BetBarrier.Visible = Table:GetAttribute("RoundStarted");
	Table:GetAttributeChangedSignal("RoundStarted"):Connect(function()
		BetBarrier.Visible = Table:GetAttribute("RoundStarted");
	end)
	
	for each, button in pairs(Backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				if button.Name == "Bet" and not BetBarrier.Visible then
					local betAmount = tonumber(BetBox.Text);
					if betAmount then
						if tonumber(betAmount) >= Table:GetAttribute("MinCash") and tonumber(betAmount) <= Table:GetAttribute("MaxCash") then
							if LocalPlayer:GetAttribute("Cash") >= betAmount then
								fireServer("Bet", math.floor(betAmount));
							else
								createMessage("Out of cash.", Color3.fromRGB(255, 100, 100), 3);
							end
						else
							createMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
						end
					else
						createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
					end
				elseif button.Name == "AutoBet" then
					if button.Image == "" then
						button.Image = "rbxassetid://2195446979";
					else
						button.Image = "";
					end
				elseif button.Name == "Camera" then
					toggleCamera();
				elseif not Barrier.Visible then
					fireServer(button.Name);
				end
			end)
		end
	end
end
initialize();
