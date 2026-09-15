return {
	Name = "otban";
	Aliases = {"otban"};
	Description = "Temporarily bans a player from the game who isn't in your current server.";
	Group = "Moderator";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to tban.";
		},
		{
			Type = "number";
			Name = "days";
			Description = "The length in days of the tban.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for the tban.";
		}
	};
}