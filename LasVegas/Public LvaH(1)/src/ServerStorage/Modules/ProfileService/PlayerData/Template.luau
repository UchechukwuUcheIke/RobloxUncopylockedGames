local Template = {
	Cash = 0,
	Playtime = 0,
	Tokens = 0,
	TournamentWins = 0,
	Credits = 0,
	Tickets = 0,
	
	TimeOfLastCashWheel = 0,
	
	OwnsGoldClub = false,
	OwnsFasterSpins = false,
	OwnsDoubleSpins = false,
	OwnsCheaperSuite = false,
	OwnsHighRoller = false,
	
	CashRegenLevel = 0,
	
	LastOnline = os.time(),
	MinutesOnline = 0,
	
	Suite = {
		OwnsAdvancedControls = false,
		SecondsRemaining = 0,
		ColorR_Wall = 107,
		ColorG_Wall = 79,
		ColorB_Wall = 79,
		ColorR_Roof = 53,
		ColorG_Roof = 28,
		ColorB_Roof = 28,
	},
	
	Settings = {
		Jackpots = "On",
		LargeGUI = "Off",
		Players = "On",
		Notifications = 0.2,
		Music = 1,
		Slots = 1,
		NPCs = 1,
		Tabletop = 1,
		FOV = 70,
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	},
	
	Moderations = {
		PriorKicks = {}, --{ModeratorWhoKicked = 0, Reason = "", ActionTime = os.time()}
		PriorBans = {}, --{ModeratorWhoBanned = 0, Reason = "", BanType = "", ActionTime = os.time()}
		PriorUnbans = {}, --{ModeratorWhoUnbanned = 0, Reason = "", ActionTime = os.time()}
		IsBanned = false,
		IsPermBanned = false,
		CurrentBanReason = "",
		CurrentModeratorWhoBanned = 0,
		TimeWhenUnbanned = 0
	}
};
return Template;