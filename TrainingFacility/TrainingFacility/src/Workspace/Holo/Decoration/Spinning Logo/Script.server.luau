game:GetService("RunService").Heartbeat:Connect(function()
	script.Parent.CFrame = script.Parent.CFrame * CFrame.Angles(0, 0.02, 0);
end)