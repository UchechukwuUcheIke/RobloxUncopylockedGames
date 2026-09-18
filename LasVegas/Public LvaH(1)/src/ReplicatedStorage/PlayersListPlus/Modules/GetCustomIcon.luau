local module = {}

local PlayersListPlus = _G.PlayersListPlus

function module.Get(Player : Player)
	local UserIcon = PlayersListPlus.Config.CustomIcons.UserIds[Player.UserId]
	if UserIcon then
		return UserIcon
	end
	
	for groupId, data in PlayersListPlus.Config.CustomIcons.Group do
		local rankId = Player:GetAttribute("PLP_Group_" .. groupId)
		if not rankId then
			rankId = Player:GetRankInGroup(groupId)
			Player:SetAttribute("PLP_Group_" .. groupId, rankId)
		end
		
		if data[rankId] then
			return data[rankId]
		end
	end
	
	return nil
end

return module
