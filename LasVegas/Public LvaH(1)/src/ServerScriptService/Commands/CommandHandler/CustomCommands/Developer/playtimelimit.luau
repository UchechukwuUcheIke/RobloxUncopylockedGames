return {
	Name = "playtimelimit";
	Aliases = {"playtimelimit"};
	Description = "Adjusts the playtime limit a player has.";
	Group = "Developer";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to adjust the playtime limit of.";
		},
		{
			Type = "number";
			Name = "amount";
			Description = "The amount to adjust by.";
		},
	};
}