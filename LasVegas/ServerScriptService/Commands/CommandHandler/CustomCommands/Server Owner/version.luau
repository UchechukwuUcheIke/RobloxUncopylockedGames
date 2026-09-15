local version = "v1.12.0"

return {
	Name = "version",
	Args = {},
	Description = "Shows the current version of Cmdr",
	Group = "Server Owner",

	Run = function()
		return ("Cmdr Version %s"):format(version)
	end,
}
