for each, thing in pairs(script.Parent:GetDescendants()) do
	if thing:IsA("BasePart") then
		thing:SetNetworkOwner(nil);
	end
end

local rng = Random.new();
for each, horse in pairs(script.Parent:GetChildren()) do
	if horse:IsA("Model") then
		local gallopAnim = horse.Horse.Animations.Gallop;
		local gallopTrack = horse.Horse.Humanoid.Animator:LoadAnimation(gallopAnim);
		gallopTrack:Play();
	end
end