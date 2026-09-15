local Character = script.Parent;
local Humanoid = Character:WaitForChild("Humanoid");

for each, thing in pairs(Character:GetDescendants()) do
	if thing:IsA("BasePart") then
		thing.CollisionGroup = "Players";
	end
end

Character:SetAttribute("PlayerModel", true);