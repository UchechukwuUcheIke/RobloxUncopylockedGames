return {
	Name = "globalannounce";
	Aliases = {"globalannounce"};
	Description = "Makes a game-wide announcement.";
	Group = "Server Owner";
	Args = {
		{
			Type = "string";
			Name = "message";
			Description = "The message to announce.";
		},
	};
}