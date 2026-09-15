return {
	Name = "unsban";
	Aliases = {"unsban"};
	Description = "Unbans a player from the current server.";
	Group = "Server Owner";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to unsban.";
		}
	};
}