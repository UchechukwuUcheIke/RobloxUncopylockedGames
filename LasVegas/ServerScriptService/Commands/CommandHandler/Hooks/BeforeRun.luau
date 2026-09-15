local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		local executorRank = Permissions:GetPlayerPermissionRank(context.Executor);

		if context.Group == "Lead Developer" and executorRank == 5 then
			return nil;
		elseif context.Group == "Lead Moderator" and executorRank >= 4 then
			return nil;
		elseif context.Group == "Developer" and executorRank >= 3 then
			return nil;
		elseif context.Group == "Moderator" and executorRank >= 2 then
			return nil;
		elseif context.Group == "Server Owner" and executorRank >= 1 then
			return nil;
		end
		
		return "You don't have permission to run this command.";
	end)
end