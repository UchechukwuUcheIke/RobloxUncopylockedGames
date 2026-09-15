return {
	Name = "announce";
	Aliases = {"announce"};
	Description = "Makes a server-wide announcement.";
	Group = "Server Owner";
	Args = {
		{
			Type = "string";
			Name = "message";
			Description = "The message to announce.";
		},
	};
}