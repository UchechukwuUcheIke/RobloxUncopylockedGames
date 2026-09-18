local module = {}

local PlayersListPlus = _G.PlayersListPlus

function module.Get(Player : Player)
	local Perms = {}
	
	local UserPerm = PlayersListPlus.Config.Permissions.UserIds[Player.UserId]
	if UserPerm then
		for _,v in UserPerm do
			table.insert(Perms, v)
			if v == "*" then
				return Perms
			end
		end
	end
	
	for groupId, data in PlayersListPlus.Config.Permissions.Group do
		local rankId = Player:GetAttribute("PLP_Group_" .. groupId)
		if not rankId then
			rankId = Player:GetRankInGroup(groupId)
			Player:SetAttribute("PLP_Group_" .. groupId, rankId)
		end
		
		if data[rankId] then
			for _,v in data[rankId] do
				table.insert(Perms, v)
				if v == "*" then
					return Perms
				end
			end
		end
	end
	
	return Perms
end

function module.HasPlayerPermission(Player : Player, TargetPermission : string)
	local perms = module.Get(Player)
	
	if not perms then
		return false
	end
	
	if table.find(perms, "*") or table.find(perms, TargetPermission) then
		return true
	end
	
	return false
end

return module
