local module = {}

local PlayersListPlus = _G.PlayersListPlus

function module.Get(Player : Player)
	local UserTag = PlayersListPlus.Config.CustomTags.UserIds[Player.UserId]
	if UserTag then
		return UserTag
	end
	
	for groupId, data in PlayersListPlus.Config.CustomTags.Group do
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
