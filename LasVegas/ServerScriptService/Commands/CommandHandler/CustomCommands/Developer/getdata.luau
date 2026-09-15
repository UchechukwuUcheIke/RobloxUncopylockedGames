return {
	Name = "getdata";
	Aliases = {"getdata"};
	Description = "Displays all of the data for a player from the profile manager.";
	Group = "Developer";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to show the data of.";
		}
	};
}