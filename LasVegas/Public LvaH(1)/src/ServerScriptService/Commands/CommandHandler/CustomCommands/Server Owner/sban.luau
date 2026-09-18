return {
	Name = "sban";
	Aliases = {"sban"};
	Description = "Bans a player from the current server.";
	Group = "Server Owner";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to sban.";
		}
	};
}