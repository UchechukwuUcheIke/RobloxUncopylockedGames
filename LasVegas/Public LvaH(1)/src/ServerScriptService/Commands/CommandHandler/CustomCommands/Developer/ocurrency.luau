return {
	Name = "ocurrency";
	Aliases = {"ocurrency"};
	Description = "Adjusts either the cash or tokens a player has who isn't in your currency server.";
	Group = "Developer";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to adjust the currency of.";
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