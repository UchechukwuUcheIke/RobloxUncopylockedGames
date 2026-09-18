return {
	Name = "showhistory";
	Aliases = {"showhistory"};
	Description = "Shows the moderation history of a player.";
	Group = "Moderator";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to show the history of.";
		}
	};
}