return {
	Name = "getattributes";
	Aliases = {"getattributes"};
	Description = "Displays all of the attributes for the game closest to you.";
	Group = "Developer";
	Args = {
		{
			Type = "string";
			Name = "game";
			Description = "The game to show the attributes of.";
		}
	};
}