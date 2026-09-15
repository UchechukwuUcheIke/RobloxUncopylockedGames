return {
	Name = "opban";
	Aliases = {"opban"};
	Description = "Permanently bans a player from the game who isn't in your current server.";
	Group = "Moderator";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to pban.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for the pban.";
		}
	};
}