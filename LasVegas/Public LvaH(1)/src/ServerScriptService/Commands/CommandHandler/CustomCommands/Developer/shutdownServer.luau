local Players = game:GetService("Players");
local MessagingService = game:GetService("MessagingService");

return function (context, shutdownType)
	if shutdownType == "current" then
		for _, player in pairs(Players:GetPlayers()) do
			player:Kick("This server has been shutdown by a developer. Please rejoin.");
		end
		return "Shutdown current server."
	elseif shutdownType == "public" then
		MessagingService:PublishAsync("Shutdown", shutdownType);
		return "Shutdown all public servers."
	elseif shutdownType == "private" then
		MessagingService:PublishAsync("Shutdown", shutdownType);
		return "Shutdown all private servers."
	elseif shutdownType == "all" then
		MessagingService:PublishAsync("Shutdown", shutdownType);
		return "Shutdown all servers."
	end
	return "Unable to shutdown, you didn't provide a valid server type."
end