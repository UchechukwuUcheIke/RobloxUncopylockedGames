return {
	Name = "awardbadge";
	Aliases = {"awardbadge"};
	Description = "Awards a badge to a player.";
	Group = "Developer";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to award the badge to.";
		},
		{
			Type = "number";
			Name = "badgeID";
			Description = "The asset ID of the badge to award.";
		}
	};
}