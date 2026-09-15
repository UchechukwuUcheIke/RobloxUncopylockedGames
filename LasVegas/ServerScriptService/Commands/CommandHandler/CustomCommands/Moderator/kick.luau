return {
	Name = "kick";
	Aliases = {"kick"};
	Description = "Kicks a player from the server.";
	Group = "Moderator";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to kick.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for the kick.";
		}
	};
}