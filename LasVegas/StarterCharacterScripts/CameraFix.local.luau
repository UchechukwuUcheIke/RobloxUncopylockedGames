local player = game:GetService("Players").LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local camera = workspace.CurrentCamera;
camera.CameraType = Enum.CameraType.Custom;
camera.CameraSubject = humanoid;