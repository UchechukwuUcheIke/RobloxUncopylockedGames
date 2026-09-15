return {
	Name = "tban";
	Aliases = {"tban"};
	Description = "Temporarily bans a player in your current server from the game.";
	Group = "Moderator";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to tban.";
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