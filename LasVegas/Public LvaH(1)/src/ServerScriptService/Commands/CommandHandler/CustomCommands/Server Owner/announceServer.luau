local TextService = game:GetService("TextService");
local Players = game:GetService("Players");
local Chat = game:GetService("Chat");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CommandAction = ReplicatedStorage.Remotes.CommandAction;

return function (context, text)
	local filterResult = TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat);

	for _, player in ipairs(Players:GetPlayers()) do
		if Chat:CanUsersChatAsync(context.Executor.UserId, player.UserId) then
			CommandAction:FireClient(player, "Announcement", {filterResult:GetChatForUserAsync(player.UserId), context.Executor.Name})
		end
	end

	return "Created server announcement.";
end