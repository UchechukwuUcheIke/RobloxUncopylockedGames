return {
	Name = "unban";
	Aliases = {"unban"};
	Description = "Removes a pban or a tban from a player before their ban has expired.";
	Group = "Lead Moderator";
	Args = {
		{
			Type = "string";
			Name = "username";
			Description = "The exact username of the player to unban.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for the early unban.";
		}
	};
}