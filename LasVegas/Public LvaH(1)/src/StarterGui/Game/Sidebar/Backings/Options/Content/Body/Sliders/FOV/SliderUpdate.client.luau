local ReplicatedStorage = game:GetService("ReplicatedStorage");
local SliderModule = require(ReplicatedStorage.Modules:WaitForChild("Slider"));
local ForceUpdate = script.ForceUpdate;
local holderFrame = script.Parent;
local slider = holderFrame.Slider;
local FOVSlider = SliderModule.new(holderFrame, {
	SliderData = {Start = 20, End = 120, Increment = 1, DefaultValue = 70},
	MoveType = "Tween",
	MoveInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad),
	Axis = "X",
	Padding = 0,
	AllowBackgroundClick = true
});

local Camera = workspace.CurrentCamera;

local function updateSetting(value)
	slider.Text = value;
	Camera.FieldOfView = value;
end

FOVSlider.Changed:Connect(function(newVolume)
	updateSetting(newVolume);
end)
FOVSlider:Track();

ForceUpdate.Event:Connect(function(newValue)
	FOVSlider:OverrideValue(newValue);
end)