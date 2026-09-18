local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Humanoid = Character:WaitForChild("Humanoid");
local Camera = workspace.Camera;
local Tutorial = script.Parent;
local Disclaimers = Tutorial.Parent.Parent:WaitForChild("Disclaimers");
local CameraActive = false;
local OldCameraCFrame;

repeat task.wait(0.1); until not Disclaimers.Disclaimer.Visible and not Disclaimers.Mobile.Visible;
Tutorial[0].Visible = true;

local function ToggleCamera(cameraPart)
	if cameraPart then
		if not CameraActive then
			OldCameraCFrame = Camera.CFrame;
		end
		CameraActive = true;
		
		Camera.CameraType = Enum.CameraType.Scriptable;
		Camera.CameraSubject = cameraPart;
		Camera.CFrame = cameraPart.CFrame;
		
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false);
	elseif CameraActive then
		CameraActive = false;
		Camera.CameraType = Enum.CameraType.Custom;
		Camera.CameraSubject = Humanoid;
		Camera.CFrame = OldCameraCFrame;
		
		task.wait(0.5);
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true);
	end
end

for each, frame in pairs(Tutorial:GetChildren()) do
	if frame:IsA("Frame") then
		frame.Content.Footer.Next.MouseButton1Up:Connect(function()
			local nextCount = tonumber(frame.Name) + 1;
			local nextFrame = Tutorial:FindFirstChild(nextCount);
			frame.Visible = false;
			
			if nextFrame then
				nextFrame.Visible = true;
				local cameraPart = workspace.Map.Tutorial:FindFirstChild(tostring(nextCount));
				if cameraPart then
					ToggleCamera(cameraPart);
				else
					ToggleCamera(nil);
				end
			else
				ToggleCamera(nil);
			end
		end)
		frame.Close.ImageButton.MouseButton1Up:Connect(function()
			frame.Visible = false;
			ToggleCamera(nil);
		end)
	end
end