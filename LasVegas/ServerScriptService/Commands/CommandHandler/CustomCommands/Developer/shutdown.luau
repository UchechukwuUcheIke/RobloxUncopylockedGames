return {
	Name = "shutdown";
	Aliases = {"shutdown"};
	Description = "Shutdowns either your current server or a group of servers.";
	Group = "Developer";
	Args = {
		{
			Type = "string";
			Name = "server type";
			Description = "The servers to shutdown (current, public, private, all).";
		}	
	};
}