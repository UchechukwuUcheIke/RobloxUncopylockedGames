return {
	Name = "teleport";
	Aliases = {"teleport"};
	Description = "Teleports a player or set of players to another player's location.";
	Group = "Server Owner";
	Args = {
		{
			Type = "players";
			Name = "players";
			Description = "The players to teleport.";
		},
		{
			Type = "player";
			Name = "player";
			Description = "The player to teleport to.";
		}
	};
}