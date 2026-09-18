for each, trigger in pairs(script.Parent:GetChildren()) do
	if trigger:IsA("BasePart") then
		trigger:SetAttribute("Moved", false);
		trigger.Touched:Connect(function(hit)
			if hit and hit.Parent and hit.Name == "Mover" and not trigger:GetAttribute("Moved") then
				trigger:SetAttribute("Moved", true);
				
				hit.Parent:SetAttribute("Laps", hit.Parent:GetAttribute("Laps") + 1);
				if hit.Parent:GetAttribute("Laps") == 2 then
					hit.Anchored = true;
				end
				
				task.wait(1);
				trigger:SetAttribute("Moved", false);
			end
		end)
	end
end