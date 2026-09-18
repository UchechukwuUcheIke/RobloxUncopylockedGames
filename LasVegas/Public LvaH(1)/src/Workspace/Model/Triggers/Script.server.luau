for each, trigger in pairs(script.Parent:GetChildren()) do
	if trigger:IsA("BasePart") then
		trigger:SetAttribute("Moved", false);
		trigger.Touched:Connect(function(hit)
			if hit and hit.Parent and hit.Name == "Mover" and not trigger:GetAttribute("Moved") then
				trigger:SetAttribute("Moved", true);
				hit.CFrame = hit.CFrame * CFrame.Angles(0, math.rad(5), 0);
				--hit.LinearVelocity.VectorVelocity = Vector3.new(hit.LinearVelocity.VectorVelocity.X -5, hit.LinearVelocity.VectorVelocity.Y, hit.LinearVelocity.VectorVelocity.Z)
				task.wait(1);
				trigger:SetAttribute("Moved", false);
			end
		end)
	end
end