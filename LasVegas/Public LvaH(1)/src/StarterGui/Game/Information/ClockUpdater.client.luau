local ReplicatedStorage = game:GetService("ReplicatedStorage");
local serverClock = script.Parent:WaitForChild("ServerClock");
local serverClockStroke = script.Parent:WaitForChild("ServerClockStroke");
local serverVersion = script.Parent:WaitForChild("ServerVersion");
local serverVersionStroke = script.Parent:WaitForChild("ServerVersionStroke");

local function updateServerClock()
	local hourText;
	local minuteText;
	local secondsText;

	if ReplicatedStorage:GetAttribute("UptimeHour") == 1 then
		hourText = ReplicatedStorage:GetAttribute("UptimeHour").." hour";
	else
		hourText = ReplicatedStorage:GetAttribute("UptimeHour").." hours";
	end

	if ReplicatedStorage:GetAttribute("UptimeMinute") == 1 then
		minuteText = ReplicatedStorage:GetAttribute("UptimeMinute").." minute";
	else
		minuteText = ReplicatedStorage:GetAttribute("UptimeMinute").." minutes";
	end

	if ReplicatedStorage:GetAttribute("UptimeSecond") == 1 then
		secondsText = ReplicatedStorage:GetAttribute("UptimeSecond").." second";
	else
		secondsText = ReplicatedStorage:GetAttribute("UptimeSecond").." seconds";
	end

	serverClock.Text = "Server uptime - "..hourText..", "..minuteText..", "..secondsText;
	serverClockStroke.Text = "Server uptime - "..hourText..", "..minuteText..", "..secondsText;
end

local function updateServerStatus()
	if ReplicatedStorage:GetAttribute("ServerStatus") == 0 then
		serverVersion.Text = "This server is on the latest version!";
		serverVersionStroke.Text = "This server is on the latest version!";
		serverVersion.TextColor3 = Color3.fromRGB(115, 255, 95);
	elseif ReplicatedStorage:GetAttribute("ServerStatus") == 1 then
		serverVersion.Text = "This server isn't the latest version! Bugs may occur!";
		serverVersionStroke.Text = "This server isn't the latest version! Bugs may occur!";
		serverVersion.TextColor3 = Color3.fromRGB(255, 95, 95);
	end
end

ReplicatedStorage:GetAttributeChangedSignal("ServerStatus"):Connect(function()
	updateServerStatus();
end)

ReplicatedStorage:GetAttributeChangedSignal("UptimeSecond"):Connect(function()
	updateServerClock();
end)

ReplicatedStorage:GetAttributeChangedSignal("UptimeMinute"):Connect(function()
	updateServerClock();
end)

ReplicatedStorage:GetAttributeChangedSignal("UptimeHour"):Connect(function()
	updateServerClock();
end)

updateServerStatus();