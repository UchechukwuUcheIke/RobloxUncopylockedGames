return {
	Name = "pban";
	Aliases = {"pban"};
	Description = "Permanently bans a player in your current server from the game.";
	Group = "Moderator";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to pban.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for the pban.";
		}
	};
}