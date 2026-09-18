--[[

	Copyright © 2023, MapleMarvel (https://www.roblox.com/users/263710410/profile). All Rights Reserved.
	
	
	ExtendTextLocalScript:
	LocalScript that adds additional functionality.
	
--]]


-- Services
local Players = game:GetService("Players")

-- Modules
local SCRIPTS_FOLDER_NAME = "Epic UI Pack"
local ExtendTextLabelClass = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild(SCRIPTS_FOLDER_NAME):WaitForChild("ExtendTextLabelClass"))

-- GUI Variables
local guiObject = script.Parent.Parent

-- Configuration Variables
local configuration = guiObject:WaitForChild("Configuration")
local guiObjectTextLabelVar = configuration:WaitForChild("ObjectTextLabel")

-- Local Variables
local attributesParent = guiObject


-- Validate
if guiObjectTextLabelVar then

	-- Wait for the objects to load
	while not guiObjectTextLabelVar.Value do task.wait() end

	local guiObjectTextLabel = guiObjectTextLabelVar.Value


	-- Extend the TextLabels

	-- Extend both the main text and the stroke text
	local extendedTextLabel = ExtendTextLabelClass.new(guiObjectTextLabel)

	-- Make the TextLabel text be settable via attributes
	extendedTextLabel:SetTextValueFromAttributes(attributesParent, "TextValueEnabled", "TextValue")

	-- Make the TextLabel size be settable via attributes
	extendedTextLabel:SetTextSizeFromAttributes(attributesParent, "TextSizeEnabled", "TextSizeScale", guiObject)

end