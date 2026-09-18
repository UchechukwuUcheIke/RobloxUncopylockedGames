local ReplicatedStorage = game:GetService("ReplicatedStorage");
local SaveSetting = ReplicatedStorage.Remotes:WaitForChild("SaveSetting");
local FetchSetting = ReplicatedStorage.Remotes:WaitForChild("FetchSetting");
local body = script.Parent;
local sliders = body.Sliders;
local toggles = body.Toggles;
local loadAttempts = 0

local function loadSettings()
	loadAttempts += 1;
	if loadAttempts >= 5 then
		print("Unable to retrieve saved settings from server. Open a bug report ticket in the communications if this message is spammed.");
	end
	
	local savedSettings = FetchSetting:InvokeServer();
	if savedSettings then
		for each, setting in pairs(toggles:GetChildren())  do
			setting.ForceUpdate:Fire(savedSettings[setting.Name]);
		end
		for each, setting in pairs(sliders:GetChildren())  do
			setting.SliderUpdate.ForceUpdate:Fire(savedSettings[setting.Name]);
		end
	else
		task.wait(1);
		loadSettings();
	end
end

local function initialize()
	loadSettings();
	
	coroutine.wrap(function()
		while true do
			task.wait(15);
			
			local currentSettings = {
				Jackpots = toggles.Jackpots:GetAttribute("CurrentState"),
				LargeGUI = toggles.LargeGUI:GetAttribute("CurrentState"),
				Players = toggles.Players:GetAttribute("CurrentState"),
				Notifications = tonumber(sliders.Notifications.Slider.Text),
				Music = tonumber(sliders.Music.Slider.Text),
				Slots = tonumber(sliders.Slots.Slider.Text),
				NPCs = tonumber(sliders.NPCs.Slider.Text),
				Tabletop = tonumber(sliders.Tabletop.Slider.Text),
				FOV = tonumber(sliders.FOV.Slider.Text),
				Brightness = tonumber(sliders.Brightness.Slider.Text),
				Contrast = tonumber(sliders.Contrast.Slider.Text),
				Saturation = tonumber(sliders.Saturation.Slider.Text)
			};
			SaveSetting:FireServer(currentSettings);
		end
	end)();
end;
initialize();