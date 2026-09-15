return {
	Name = "currency";
	Aliases = {"currency"};
	Description = "Adjusts the amount of currency a player has.";
	Group = "Developer";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to adjust the currency of.";
		},
		{
			Type = "string";
			Name = "currency";
			Description = "The currency to adjust.";
		},
		{
			Type = "number";
			Name = "amount";
			Description = "The amount to adjust by.";
		},
	};
}