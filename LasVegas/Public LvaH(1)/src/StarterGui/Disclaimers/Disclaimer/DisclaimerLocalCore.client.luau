local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local LocalPlayer = Players.LocalPlayer;
local Backing = script.Parent;
local Play = Backing:WaitForChild("Play");
local Leave = Backing:WaitForChild("Leave");
local Title = Backing:WaitForChild("Title");

Backing.Visible = true;
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false);

Title.Text = "Welcome, "..LocalPlayer.Name.."!";
Leave.MouseButton1Up:Connect(function()
	LocalPlayer:Kick("Thank you for being honest to us and with yourself.");
end)

coroutine.wrap(function()
	while true do
		for i = -180, 180, 2 do
			Backing.UIGradient.Rotation = i;
			task.wait();
		end
	end
end)()

repeat task.wait(0.1); until LocalPlayer:GetAttribute("Playtime") and not Backing.Parent.Mobile.Visible;
if LocalPlayer:GetAttribute("Playtime") < 3 then
	Play.TextLabel.TextColor3 = Color3.fromRGB(255, 107, 107);
	for i = 60, 1, -1 do
		Play.TextLabel.Text = i;
		task.wait(1);
	end
end

Play.TextLabel.Text = "PLAY";
Play.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100);
Play.MouseButton1Up:Connect(function()
	Backing.Visible = false;
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true);
end)