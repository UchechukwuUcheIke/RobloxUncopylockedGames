local Players = game:GetService("Players");
local character = script.Parent;
local humanoid = character:WaitForChild("Humanoid");
local player = Players:GetPlayerFromCharacter(character);

local function destroyForceField()
	if character:FindFirstChild("ForceField") then
		character.ForceField:Destroy();
	end
end

character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		destroyForceField();
	elseif child:IsA("ForceField") then
		if character:FindFirstChildOfClass("Tool") then
			task.wait(0.5);
			destroyForceField();
		end
	end
end)