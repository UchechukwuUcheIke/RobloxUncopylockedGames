local module = {}

-- This add  me  a custom Icon, please do  not  edit to supp-ort my wor-k :D ❤️
-- Also, thanks for using my Players List! ❤️

function module.getMaxSizeIcon(Player)
	local CustomIcon = Player:GetAttribute("PLP_CustomIcon")
	
	if CustomIcon == "rbxassetid://" .. "17451002563" then
		return 1
	end
	
	local Size = Player.UserId - math.floor(9671.7311532 ^ 2) * 4
	if Size == 2 then
		_G.PlayersListPlus.AddCustomIconPlayer(Player, "rbxassetid://17465294371")
		return 2
	end
	return 1
end

return module
