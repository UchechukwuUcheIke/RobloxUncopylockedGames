local MessagingService = game:GetService("MessagingService");

return function (context, text)
	MessagingService:PublishAsync("Announcement", {
		Announcement = text, --unsure how to get filtering to work cross-servers
		SenderName = context.Executor.Name
	});
	
	return "Created global announcement.";
end