local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));
local Players = game:GetService("Players");
local gui = script.Parent;
local playerListFrame = gui.MainFrame;
local open = true;

local function toggleLeaderboard()
	if not open then
		playerListFrame:TweenPosition(UDim2.new(.99, 0, 0.05, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.1);
	else
		playerListFrame:TweenPosition(UDim2.new(1, 370, 0.05, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.1);
	end
	open = not open;
end

local function getPlayerIcon(player)
	return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
end

local function getPlayerSlot(player)
	for each, slot in pairs(playerListFrame.PlayerHolder:GetChildren()) do
		if slot:IsA("TextButton") and slot:FindFirstChild("PlayerPicture") then
			if slot.PlayerPicture.PlayerName.Text == player.Name then
				return slot;
			end
		end
	end
	return nil;
end

local function updatePlayerSlot(player)
	local slot = getPlayerSlot(player);
	
	if not slot then
		slot = script.Template:Clone();
		slot.Name = player.Name;
		slot.PlayerPicture.Image = getPlayerIcon(player);
		slot.PlayerPicture.PlayerName.Text = player.Name;
		slot.Parent = playerListFrame.PlayerHolder;
		slot.MouseButton1Click:Connect(function()
			toggleLeaderboard();
		end)
	else
		local player = Players:FindFirstChild(slot.PlayerPicture.PlayerName.Text);
		if player then
			if player:GetAttribute("Cash") and player:GetAttribute("Playtime") and player:GetAttribute("Tokens") then
				slot.PlayerPicture.PlayerCash.Text = "$"..GameData:AddCommasToNumber(player:GetAttribute("Cash"));
				slot.PlayerPicture.PlayerPlaytime.Text = GameData:AddCommasToNumber(player:GetAttribute("Playtime"));
				slot.PlayerPicture.PlayerTokens.Text = GameData:AddCommasToNumber(player:GetAttribute("Tokens"));
				slot.PlayerPicture.PlayerTokens.Visible = player:GetAttribute("Tokens") > 0;
				slot.LayoutOrder = -player:GetAttribute("Cash");
			end
		end
	end
end

local function valiateSlots()
	for each, slot in pairs(playerListFrame.PlayerHolder:GetChildren()) do
		if slot:IsA("TextButton") and slot:FindFirstChild("PlayerPicture") then
			local player = Players:FindFirstChild(slot.PlayerPicture.PlayerName.Text);
			if not player then
				slot:Destroy();
			end
		end
	end	
end

local leaderboardUpdate = coroutine.wrap(function()
	while true do
		for each, player in pairs(Players:GetPlayers()) do
			updatePlayerSlot(player);
			task.wait();
		end
		valiateSlots();

		local playerCount = #Players:GetPlayers();
		if playerCount == 1 then
			playerListFrame.PlayerCount.Text = playerCount.." PLAYER IN SERVER";
		else
			playerListFrame.PlayerCount.Text = playerCount.." PLAYERS IN SERVER";
		end
		
		local slotSize = script.Template.Size.Y.Offset + playerListFrame.PlayerHolder.UIListLayout.Padding.Offset;
		if playerCount > 13 then
			playerListFrame.PlayerHolder.CanvasSize = UDim2.new(0, 0, 0, playerCount * slotSize);
		else
			playerListFrame.PlayerHolder.CanvasSize = UDim2.new(0, 0, 0, 0);
		end
	end
	
	task.wait(1);
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.Tab then
			toggleLeaderboard();
		end
	end
end)

local function initialize()
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false);
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		toggleLeaderboard();
	end
	leaderboardUpdate();
end
initialize();