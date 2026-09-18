local ReplicatedStorage = game:GetService("ReplicatedStorage");
local SliderModule = require(ReplicatedStorage.Modules:WaitForChild("Slider"));
local ForceUpdate = script.ForceUpdate;
local holderFrame = script.Parent;
local slider = holderFrame.Slider;
local musicPlayer = holderFrame.Player;
local VolumeSlider = SliderModule.new(holderFrame, {
	SliderData = {Start = 0, End = 2, Increment = 0.05, DefaultValue = 0.5},
	MoveInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad),
	Axis = "X",
	Padding = 0
});

local function updateSetting(value)
	slider.Text = value;
	musicPlayer.Volume = value;
end

VolumeSlider.Changed:Connect(function(newVolume)
	updateSetting(newVolume);
end)
VolumeSlider:Track();

ForceUpdate.Event:Connect(function(newValue)
	VolumeSlider:OverrideValue(newValue);
end)