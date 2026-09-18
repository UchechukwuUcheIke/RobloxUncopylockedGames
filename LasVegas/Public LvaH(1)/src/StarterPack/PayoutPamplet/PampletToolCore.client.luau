local Players = game:GetService("Players");
local player = Players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local playerGui = player.PlayerGui;
local pamplet = script.Parent;

pamplet.Equipped:Connect(function()
	playerGui.Game.PayoutPamplet.Forward.Visible = true;
end)
pamplet.Unequipped:Connect(function()
	playerGui.Game.PayoutPamplet.Forward.Visible = false;
end)
humanoid.Died:Connect(function()
	playerGui.Game.PayoutPamplet.Forward.Visible = false;
end)