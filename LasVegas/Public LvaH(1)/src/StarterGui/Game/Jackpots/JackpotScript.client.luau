local Players = game:GetService("Players");
local Debris = game:GetService("Debris");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local GameData = require(ReplicatedModules:WaitForChild("GameData"));
local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local Jackpot = Remotes:WaitForChild("Jackpot");
local Welcome = Remotes:WaitForChild("Welcome");
local folder = script.Parent;
local backing = folder:WaitForChild("Backing");
local jackpotSound = folder:WaitForChild("Jackpot");
local welcomeSound = folder:WaitForChild("Welcome");
local zindexCount = 0;

local function getPlayerIcon(userId)
	return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
end

Jackpot.OnClientEvent:Connect(function(player, winnings)
	if player and winnings and folder.Parent.Sidebar.Backings.Options.Content.Body.Toggles.Jackpots:GetAttribute("CurrentState") == "On" then
		zindexCount += 1;
		
		local template = backing.UIGridLayout.Jackpot:Clone();
		template.Headshot.Image = getPlayerIcon(player.UserId);
		template.Display.Text = "<b><font color='rgb(255,255,0)'>"..player.Name.."</font></b> won a jackpot of <b><font color='rgb(0,255,0)'>$"..GameData:AddCommasToNumber(winnings).."</font></b>!";
		template.DisplayStroke.Text = player.Name.." won a jackpot of $"..GameData:AddCommasToNumber(winnings).."!";
		template.ZIndex = zindexCount;
		template.Parent = backing;

		local sound = jackpotSound:Clone();
		sound.Parent = folder;
		sound:Play();

		Debris:AddItem(template, 10);
		Debris:AddItem(sound, sound.TimeLength);
	end
end)
Welcome.OnClientEvent:Connect(function(player)
	if player and folder.Parent.Sidebar.Backings.Options.Content.Body.Toggles.Jackpots:GetAttribute("CurrentState") == "On" then
		zindexCount += 1;
		
		local template = backing.UIGridLayout.Welcome:Clone();
		template.Headshot.Image = getPlayerIcon(player.UserId);
		template.Display.Text = "Everyone welcome <b><font color='rgb(0,255,255)'>"..player.Name.."</font></b> to the casino!";
		template.DisplayStroke.Text = "Everyone welcome "..player.Name.." to the casino!";
		template.ZIndex = zindexCount;
		template.Parent = backing;

		local sound = welcomeSound:Clone();
		sound.Parent = folder;
		sound:Play();

		Debris:AddItem(template, 10);
		Debris:AddItem(sound, sound.TimeLength);
	end
end)