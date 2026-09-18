--[[

	Copyright © 2023, MapleMarvel (https://www.roblox.com/users/263710410/profile). All Rights Reserved.
	
	
	ExtendTextButtonLocalScript:
	LocalScript that adds additional functionality.
	
--]]


-- Services
local Players = game:GetService("Players")

-- Modules
local SCRIPTS_FOLDER_NAME = "Epic UI Pack"
local ExtendTextLabelClass = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild(SCRIPTS_FOLDER_NAME):WaitForChild("ExtendTextLabelClass"))
local ExtendGuiObjectClass = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild(SCRIPTS_FOLDER_NAME):WaitForChild("ExtendGuiObjectClass"))

-- GUI Variables
local guiObjectButton = script.Parent.Parent

-- Configuration Variables
local configuration = guiObjectButton:WaitForChild("Configuration")
local guiObjectTextLabelVar = configuration:WaitForChild("ObjectTextLabel")
local guiObjectTextLabelStrokeVar = configuration:WaitForChild("ObjectTextLabelStroke")
local guiObjectHoverVar = configuration:WaitForChild("ObjectHover")

-- Local Variables
local attributesParent = guiObjectButton


-- Validate
if guiObjectTextLabelVar and guiObjectTextLabelStrokeVar and guiObjectHoverVar then

	-- Wait for the objects to load
	while not guiObjectTextLabelVar.Value do task.wait() end
	while not guiObjectTextLabelStrokeVar.Value do task.wait() end
	while not guiObjectHoverVar.Value do task.wait() end

	local guiObjectTextLabel = guiObjectTextLabelVar.Value
	local guiObjectTextLabelStroke = guiObjectTextLabelStrokeVar.Value
	local guiObjectHover = guiObjectHoverVar.Value


	-- Extend the TextLabels

	-- Extend both the main text and the stroke text
	local extendedTextLabel = ExtendTextLabelClass.new(guiObjectTextLabel)
	local extendedTextLabelStroke = ExtendTextLabelClass.new(guiObjectTextLabelStroke)

	-- Make the TextLabel text be settable via attributes
	extendedTextLabel:SetTextValueFromAttributes(attributesParent, "TextValueEnabled", "TextValue")
	extendedTextLabelStroke:SetTextValueFromAttributes(attributesParent, "TextValueEnabled", "TextValue")

	-- Make the TextLabel size be settable via attributes
	extendedTextLabel:SetTextSizeFromAttributes(attributesParent, "TextSizeEnabled", "TextSizeScale", guiObjectButton)
	extendedTextLabelStroke:SetTextSizeFromAttributes(attributesParent, "TextSizeEnabled", "TextSizeScale", guiObjectButton)


	-- Extend the button

	-- Make the button have a hover over effect
	local extendedGuiObjectButton = ExtendGuiObjectClass.new(guiObjectButton)
	extendedGuiObjectButton:SetHoverOver(guiObjectHover)

end