local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));
local player = game:GetService("Players").LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local camera = workspace.CurrentCamera;
local mouse = player:GetMouse();
local rouletteGui = script.Parent;
local backing = rouletteGui.Backing;
local message = backing.Message;
local betBox = backing.BetBox;
local autoBet = backing.AutoBet;
local selected = backing.Selected;
local tableGame = rouletteGui.ActualTable.Value;
local selections = tableGame.Functional.Selections;
local PlayerAction = tableGame.Remotes.PlayerAction;
local cameraFocused = false;
local oldCameraCFrame;
local previousBets = {};

local function createMessage(newText, color, timeUp)
	coroutine.wrap(function()
		message.Visible = true;
		message.Text = newText;
		message.TextColor3 = color;
		task.wait(timeUp);
		message.Visible = false;
		message.Text = "";
		message.TextColor3 = Color3.fromRGB(255, 255, 255);
	end)()
end

local function getPlayerMarkerCount(actualPlayer)
	local markerCount = 0;
	for each, marker in pairs(tableGame.Markers:GetChildren()) do
		if marker.BillboardGui.Player.Text == actualPlayer.Name then
			markerCount += 1;
		end
	end
	return markerCount;
end

local function toggleCamera()
	if not cameraFocused then
		oldCameraCFrame = camera.CFrame;
		camera.CameraType = Enum.CameraType.Scriptable;
		camera.CameraSubject = tableGame.Functional.CameraPart;
		camera.CFrame = tableGame.Functional.CameraPart.CFrame;
	else
		camera.CameraType = Enum.CameraType.Custom;
		camera.CameraSubject = humanoid;
		camera.CFrame = oldCameraCFrame;
	end

	cameraFocused = not cameraFocused;
end

local function fireServer(action, data, isAutoBet)
	if action == "Bet" then
		if data[2] >= tableGame:GetAttribute("MinCash") and data[2] <= tableGame:GetAttribute("MaxCash") then
			if player:GetAttribute("Cash") >= data[2] then
				if getPlayerMarkerCount(player) < tableGame:GetAttribute("BetLimit") then
					PlayerAction:FireServer("Bet", data);
					if not isAutoBet then
						previousBets[selected.Text] = math.floor(data[2]);
					end
				else
					createMessage("Cannot place more bets. Limit of "..GameData:AddCommasToNumber(tableGame:GetAttribute("BetLimit")).." reached.", Color3.fromRGB(255, 100, 100), 3);
				end
			else
				createMessage("Out of cash.", Color3.fromRGB(255, 100, 100), 3);
			end
		else
			createMessage("Bet outside of game limits.", Color3.fromRGB(255, 100, 100), 3);
		end
	elseif action == "Cancel" then
		PlayerAction:FireServer("Cancel", data);
		if previousBets[selected.Text] then
			previousBets[selected.Text] = nil;
		end
	elseif action == "AutoBet" then
		autoBet.Image = autoBet.Image == "" and "rbxassetid://2195446979" or "";
	elseif action == "Camera" then
		toggleCamera();
	end
end

humanoid.Changed:Connect(function()
	if not humanoid.Sit or humanoid.Health <= 0 then
		for each, barrier in pairs(tableGame.Functional:GetChildren()) do
			if barrier.Name == "Barrier" then
				barrier.Position = barrier:GetAttribute("OriginalPosition");
			end
		end
		
		camera.CameraType = Enum.CameraType.Custom;
		camera.CameraSubject = humanoid;	
		rouletteGui:Destroy();
	end
end)

tableGame:GetAttributeChangedSignal("RoundStarted"):Connect(function()
	backing.Barrier.Visible = tableGame:GetAttribute("RoundStarted");
end)

PlayerAction.OnClientEvent:Connect(function(action, data)
	if action == "roundEnded" then
		if data[1] > 0 then
			createMessage("You won $"..GameData:AddCommasToNumber(data[1]).."!", Color3.fromRGB(100, 255, 100), tableGame:GetAttribute("TimeBeforeNewRound"));
		end
	elseif action == "roundStarting" then
		if autoBet.Image == "rbxassetid://2195446979" then
			for betName, bet in pairs(previousBets) do
				fireServer("Bet", {betName, math.floor(bet)}, true);
			end
		else
			previousBets = {};
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not UserInputService:GetFocusedTextBox() then
		if not backing.Barrier.Visible then
			if input.KeyCode == Enum.KeyCode.T then
				local betAmount = tonumber(betBox.Text);
				if betAmount and selected.Text ~= "" then
					fireServer("Bet", {selected.Text, math.floor(betAmount)});
				else
					createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
				end
			elseif input.KeyCode == Enum.KeyCode.F then
				fireServer("Cancel", {selected.Text});
			end
		end
		
		if input.KeyCode == Enum.KeyCode.H then
			fireServer("AutoBet");
		elseif input.KeyCode == Enum.KeyCode.C then
			fireServer("Camera");
		end
	end
end)

local function initialize()
	backing.Barrier.Visible = tableGame:GetAttribute("RoundStarted");
	
	for each, barrier in pairs(tableGame.Functional:GetChildren()) do
		if barrier.Name == "Barrier" then
			barrier.Position = barrier:GetAttribute("OriginalPosition") + Vector3.new(0, -100, 0);
		end
	end
	
	for each, button in pairs(backing:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				if not backing.Barrier.Visible then
					if button.Name == "Bet" then
						local betAmount = tonumber(betBox.Text);
						if betAmount and selected.Text ~= "" then
							fireServer("Bet", {selected.Text, math.floor(betAmount)});
						else
							createMessage("Put a wager in the # box.", Color3.fromRGB(255, 100, 100), 3);
						end
					elseif button.Name == "Cancel" then
						fireServer("Cancel", {selected.Text});
					end
				end
				
				if button.Name == "AutoBet" then
					fireServer("AutoBet");
				elseif button.Name == "Camera" then
					fireServer("Camera");
				end
			end)
		end
	end
	
	for each, button in pairs(selections:GetDescendants()) do
		if button:IsA("TextButton") then
			button.MouseButton1Up:Connect(function()
				selected.Text = button.Parent.Parent.Name;
			end)
		end
	end
	
	coroutine.wrap(function()
		while rouletteGui.Parent == player.PlayerGui do
			task.wait(0.1);
			
			if mouse.Hit then
				for each, selection in pairs(selections:GetChildren()) do
					if selection:GetAttribute("SpecialBet") then
						if (selection.Position - mouse.Hit.Position).Magnitude <= 2 then
							selection.Transparency = 0;
							selection.SurfaceGui.Enabled = true;
						else
							selection.Transparency = 1;
							selection.SurfaceGui.Enabled = false;
						end
					end
				end
				
				for each, marker in pairs(tableGame.Markers:GetChildren()) do
					if (marker:GetAttribute("OriginalPosition") - mouse.Hit.Position).Magnitude <= 2 then
						marker.Position = marker:GetAttribute("OriginalPosition") + Vector3.new(0, -3, 0);
						marker.Transparency = 1;
						marker.BillboardGui.Enabled = false;
					else
						marker.Position = marker:GetAttribute("OriginalPosition");
						marker.Transparency = 0;
						marker.BillboardGui.Enabled = true;
					end
				end
			end
		end
	end)()
end
initialize();