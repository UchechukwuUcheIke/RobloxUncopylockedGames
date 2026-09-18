return {
	Name = "respawn";
	Aliases = {"respawn"};
	Description = "Respawns a player or a group of players at their spawn location.";
	Group = "Server Owner";
	Args = {
		{
			Type = "players";
			Name = "players";
			Description = "The players to respawn.";
		}	
	};
}