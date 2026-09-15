local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player, currency, amount)
	if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
		if currency == "Cash" or currency == "Tokens" or currency == "TournamentWins" or currency == "Playtime" or currency == "Credits" or currency == "Tickets" then
			local profile = ProfileManager.Profiles[player];
			if profile then
				local legitAmount = math.floor(amount);
				ProfileManager.AdjustCurrency(player, currency, legitAmount);
				return "Adjusted the "..currency.." of "..player.Name.." by "..legitAmount.."."
			end
			return "Unable to adjust currency, no data profile found for "..player.Name.." in the profile manager."
		end
		return "Unable to adjust currency, you didn't provide a valid currency type."
	end
	return "Unable to adjust currency, you don't have permission to run this command on "..player.Name.."."
end