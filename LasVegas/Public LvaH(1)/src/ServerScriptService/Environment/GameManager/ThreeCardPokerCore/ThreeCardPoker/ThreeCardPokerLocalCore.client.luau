local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.CurrentCamera;

local GUI = script.Parent;
local ActualTable = GUI:WaitForChild("ActualTable");
local Backing = GUI:WaitForChild("Backing");
local BetBarrier = Backing:WaitForChild("BetBarrier");
local TurnBarrier = Backing:WaitForChild("TurnBarrier");
local Message = Backing:WaitForChild("Message");

local Timer = Backing:WaitForChild("Timer");
local AnteBox = Backing:WaitForChild("AnteBox");
local PairBox = Backing:WaitForChild("PairBox");
local BonusBox = Backing:WaitForChild("BonusBox");
local AutoBet = Backing:WaitForChild("AutoBet");

local Table = ActualTable.Value;
local Functional = Table:WaitForChild("Functional");
local Remotes = Table:WaitForChild("Remotes");
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
			if TurnBarrier.Visible then
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

local function fireServer(action, bets)
	TurnBarrier.Visible = true;
	Timer.Visible = false;
	PlayerAction:FireServer(action, bets);
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

PlayerAction.OnClientEvent:Connect(function(action)
	if action == "yourTurn" then
		TurnBarrier.Visible = false;
		startTimer();
	elseif action == "noLongerYourTurn" then
		TurnBarrier.Visible = true;
		Timer.Visible = false;
	elseif action == "roundStarted" then
		BetBarrier.Visible = true;
	elseif action == "roundEnded" then
		BetBarrier.Visible = false;
		if AutoBet.Image == "rbxassetid://2195446979" then
			fireServer("Bet", {tonumber(AnteBox.Text) or 0, tonumber(PairBox.Text) or 0, tonumber(BonusBox.Text) or 0});
		end
	elseif action == "anteHint" then
		createMessage("Bet on Ante before Bonus or Pair Plus.", Color3.fromRGB(255, 100, 100), 3);
	elseif action == "cashHint" then
		createMessage("Out of cash / Outside game limits.", Color3.fromRGB(255, 100, 100), 3);
	end
end)

local connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.C then
			toggleCamera();
		elseif input.KeyCode == Enum.KeyCode.T and not TurnBarrier.Visible then
			fireServer("Play");
		elseif input.KeyCode == Enum.KeyCode.G and not TurnBarrier.Visible then
			fireServer("Fold");
		elseif input.KeyCode == Enum.KeyCode.F and not BetBarrier.Visible then
			local anteBet = tonumber(AnteBox.Text);
			local pairBet = tonumber(PairBox.Text);
			local bonusBet = tonumber(BonusBox.Text);

			if anteBet or pairBet or bonusBet then
				local failedLimit = false;
				if anteBet and (anteBet < Table:GetAttribute("MinCash") or anteBet > Table:GetAttribute("MaxCash")) then
					createMessage("Ante bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
					failedLimit = true;
				end
				if pairBet and (pairBet < Table:GetAttribute("MinBonusCash") or pairBet > Table:GetAttribute("MaxBonusCash")) then
					createMessage("Pair bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
					failedLimit = true;
				end
				if bonusBet and (bonusBet < Table:GetAttribute("MinBonusCash") or bonusBet > Table:GetAttribute("MaxBonusCash")) then
					createMessage("Bonus bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
					failedLimit = true;
				end

				if not failedLimit then
					fireServer("Bet", {anteBet or 0, pairBet or 0, bonusBet or 0});
				end
			else
				createMessage("Put a wager in one of the # boxes.", Color3.fromRGB(255, 100, 100), 3);
			end
		elseif input.KeyCode == Enum.KeyCode.H then
			if AutoBet.Image == "" then
				AutoBet.Image = "rbxassetid://2195446979";
			else
				AutoBet.Image = "";
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
	BetBarrier.Visible = Table:GetAttribute("RoundStarted");
	Table:GetAttributeChangedSignal("RoundStarted"):Connect(function()
		BetBarrier.Visible = Table:GetAttribute("RoundStarted");
	end)
	
	for each, button in pairs(Backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				if button.Name == "Camera" then
					toggleCamera();
				elseif button.Name == "AutoBet" then
					button.Image = button.Image == "" and "rbxassetid://2195446979" or "";
				elseif button.Name == "Bet" and not BetBarrier.Visible then
					local anteBet = tonumber(AnteBox.Text);
					local pairBet = tonumber(PairBox.Text);
					local bonusBet = tonumber(BonusBox.Text);
					
					if anteBet or pairBet or bonusBet then
						local failedLimit = false;
						if anteBet and (anteBet < Table:GetAttribute("MinCash") or anteBet > Table:GetAttribute("MaxCash")) then
							createMessage("Ante bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
							failedLimit = true;
						end
						if pairBet and (pairBet < Table:GetAttribute("MinCash") or pairBet > Table:GetAttribute("MaxBonusCash")) then
							createMessage("Pair bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
							failedLimit = true;
						end
						if bonusBet and (bonusBet < Table:GetAttribute("MinCash") or bonusBet > Table:GetAttribute("MaxBonusCash")) then
							createMessage("Bonus bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
							failedLimit = true;
						end
						
						if not failedLimit then
							fireServer("Bet", {anteBet or 0, pairBet or 0, bonusBet or 0});
						end
					else
						createMessage("Put a wager in one of the # boxes.", Color3.fromRGB(255, 100, 100), 3);
					end
				elseif not TurnBarrier.Visible then
					fireServer(button.Name);
				end
			end)
		end
	end
end
initialize();
