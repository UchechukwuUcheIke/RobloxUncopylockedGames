local ReplicatedStorage = game:GetService("ReplicatedStorage");
local SoundService = game:GetService("SoundService");
local SliderModule = require(ReplicatedStorage.Modules:WaitForChild("Slider"));
local ForceUpdate = script.ForceUpdate;
local holderFrame = script.Parent;
local slider = holderFrame.Slider;
local VolumeSlider = SliderModule.new(holderFrame, {
	SliderData = {Start = -0.5, End = 0.5, Increment = 0.01, DefaultValue = 0},
	MoveType = "Tween",
	MoveInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad),
	Axis = "X",
	Padding = 0,
	AllowBackgroundClick = true
});

local Lighting = game:GetService("Lighting");
local ColorCorrection = Lighting:WaitForChild("ColorCorrection");
local DefaultBrightness = ColorCorrection.Brightness;

local function updateSetting(value)
	slider.Text = value;
	ColorCorrection.Brightness = DefaultBrightness + value;
end

VolumeSlider.Changed:Connect(function(newVolume)
	updateSetting(newVolume);
end)
VolumeSlider:Track();

ForceUpdate.Event:Connect(function(newValue)
	VolumeSlider:OverrideValue(newValue);
end)