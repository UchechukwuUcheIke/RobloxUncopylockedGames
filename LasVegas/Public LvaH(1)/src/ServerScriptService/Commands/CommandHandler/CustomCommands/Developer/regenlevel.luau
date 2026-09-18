return {
	Name = "regenlevel";
	Aliases = {"regenlevel"};
	Description = "Sets the cash regeneration level of a player.";
	Group = "Developer";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to adjust the currency of.";
		},
		{
			Type = "string";
			Name = "regenType";
			Description = "The regeneration to change.";
		},
		{
			Type = "number";
			Name = "level";
			Description = "The level to set to.";
		},
	};
}