return {
	Name = "oshowhistory";
	Aliases = {"oshowhistory"};
	Description = "Shows the moderation history of a player who isn't in your current server.";
	Group = "Moderator";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to show the history of.";
		}
	};
}