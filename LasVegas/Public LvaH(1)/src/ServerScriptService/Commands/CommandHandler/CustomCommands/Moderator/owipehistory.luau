return {
	Name = "owipehistory";
	Aliases = {"owipehistory"};
	Description = "Wipes the moderation history of a player who isn't in your current server.";
	Group = "Lead Moderator";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to wipe the history of.";
		}
	};
}