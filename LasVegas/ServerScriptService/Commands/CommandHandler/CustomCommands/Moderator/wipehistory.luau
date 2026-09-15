return {
	Name = "wipehistory";
	Aliases = {"wipehistory"};
	Description = "Wipes the moderation history of a player.";
	Group = "Lead Moderator";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to wipe the history of.";
		}
	};
}