local Players = game:GetService("Players");
local seat = script.Parent;
local previousPlayer;

seat:GetPropertyChangedSignal("Occupant"):Connect(function(occupant)
	if seat.Occupant then
		local player = Players:GetPlayerFromCharacter(seat.Occupant.Parent);
		if player then
			player:SetAttribute("OnBreak", true);
			previousPlayer = player;
		end
	else
		previousPlayer:SetAttribute("OnBreak", false);
		previousPlayer = nil;
	end
end)