local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local StarterPlayer = game:GetService("StarterPlayer");
local LocalPlayer = game.Players.LocalPlayer;
local Character = LocalPlayer.Character;
local Humanoid = Character:WaitForChild("Humanoid");

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
			Humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed * 1.5;
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
			Humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed;
		end
	end
end)