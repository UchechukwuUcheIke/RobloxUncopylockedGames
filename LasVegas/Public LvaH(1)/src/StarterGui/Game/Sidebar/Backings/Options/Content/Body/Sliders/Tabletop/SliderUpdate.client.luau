local ReplicatedStorage = game:GetService("ReplicatedStorage");
local SoundService = game:GetService("SoundService");
local SliderModule = require(ReplicatedStorage.Modules:WaitForChild("Slider"));
local ForceUpdate = script.ForceUpdate;
local holderFrame = script.Parent;
local slider = holderFrame.Slider;
local VolumeSlider = SliderModule.new(holderFrame, {
	SliderData = {Start = 0, End = 2, Increment = 0.05, DefaultValue = 1},
	MoveInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad),
	Axis = "X",
	Padding = 0
});

local function updateSetting(value)
	slider.Text = value;
	SoundService.Games.Volume = value;
end

VolumeSlider.Changed:Connect(function(newVolume)
	updateSetting(newVolume);
end)
VolumeSlider:Track();

ForceUpdate.Event:Connect(function(newValue)
	VolumeSlider:OverrideValue(newValue);
end)