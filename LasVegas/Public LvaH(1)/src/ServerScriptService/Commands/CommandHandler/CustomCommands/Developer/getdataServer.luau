local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player)
	local profile = ProfileManager.Profiles[player];
	if profile then
		context:Reply("----- Player data for "..player.Name.." -----");

		context:Reply(" ");
		context:Reply("- Currency -");
		context:Reply("Cash: "..tostring(profile.Data.Cash));
		context:Reply("CashRegenLevel: "..tostring(profile.Data.CashRegenLevel));
		context:Reply("Playtime: "..tostring(profile.Data.Playtime));
		context:Reply("Tokens: "..tostring(profile.Data.Tokens));
		context:Reply("TournamentWins: "..tostring(profile.Data.TournamentWins));
		context:Reply("Credits: "..tostring(profile.Data.Credits));
		context:Reply("Tickets: "..tostring(profile.Data.Tickets));

		context:Reply(" ");
		context:Reply("- Cooldowns -");
		context:Reply("TimeOfLastCashWheel: "..tostring(profile.Data.TimeOfLastCashWheel));
		context:Reply("MinutesOnline: "..tostring(profile.Data.MinutesOnline));
		context:Reply("LastOnline: "..tostring(profile.Data.LastOnline));

		context:Reply(" ");
		context:Reply("- Upgrades -");
		context:Reply("OwnsGoldClub: "..tostring(profile.Data.OwnsGoldClub));
		context:Reply("OwnsFasterSpins: "..tostring(profile.Data.OwnsFasterSpins));
		context:Reply("OwnsDoubleSpins: "..tostring(profile.Data.OwnsDoubleSpins));
		context:Reply("OwnsCheaperSuite: "..tostring(profile.Data.OwnsCheaperSuite));

		context:Reply(" ");
		context:Reply("- Settings -");
		context:Reply("Jackpots: "..tostring(profile.Data.Settings.Jackpots));
		context:Reply("Fish: "..tostring(profile.Data.Settings.Fish));
		context:Reply("Music: "..tostring(profile.Data.Settings.Music));
		context:Reply("Slots: "..tostring(profile.Data.Settings.Slots));
		context:Reply("NPCs: "..tostring(profile.Data.Settings.NPCs));
		context:Reply("Tools: "..tostring(profile.Data.Settings.Tools));
		context:Reply("Tabletop: "..tostring(profile.Data.Settings.Tabletop));
		context:Reply("Brightness: "..tostring(profile.Data.Settings.Brightness));
		context:Reply("Contrast: "..tostring(profile.Data.Settings.Contrast));
		context:Reply("Saturation: "..tostring(profile.Data.Settings.Saturation));

		context:Reply(" ");
		return "End of player data for "..player.Name..".";
	end
	return "Unable to view data, no data profile found for "..player.Name.." in the profile manager."
end