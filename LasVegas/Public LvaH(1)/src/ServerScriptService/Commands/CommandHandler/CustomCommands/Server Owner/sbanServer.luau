local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player)
	if context.Executor ~= player then
		if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
			if game.PrivateServerOwnerId ~= 0 then
				ServerScriptService.Player.PlayerManager.ServerBan:Fire(player, true);
				return "Server banned "..player.Name.."."
			end
			return "Unable to sban, you can only server ban players in private servers."
		end
		return "Unable to sban, you don't have permission to run this command on "..player.Name.."."
	end
	return "Unable to sban, you cannot run this command on yourself."
end