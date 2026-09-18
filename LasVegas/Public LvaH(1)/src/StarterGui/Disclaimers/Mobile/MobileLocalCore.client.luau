local UserInputService = game:GetService("UserInputService");
local Backing = script.Parent;
local Play = Backing:WaitForChild("Play");

Backing.Visible = UserInputService.TouchEnabled;

coroutine.wrap(function()
	while true do
		for i = 180, -180, -2 do
			Backing.UIGradient.Rotation = i;
			task.wait();
		end
	end
end)()

Play.MouseButton1Up:Connect(function()
	Backing.Visible = false;
end)