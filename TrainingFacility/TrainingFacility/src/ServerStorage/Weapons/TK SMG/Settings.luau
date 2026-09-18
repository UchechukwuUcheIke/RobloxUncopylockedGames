local player = game.Players.LocalPlayer
local settings = {
	-- Basics
	fireMode = "Auto"; -- Available modes; "Auto" and "Semi"
	clip = 35;
	spread = 0.2; -- Per 100 studs
	firerate = 0.09;
	damage = 15;
	teamkill = true;
	sprintspeed = 22;
	crouchspeed = 14;
	-- Animations
	animationtype = "Weld"; -- Toggles between "Weld" or custom "Animations" [Welds are less efficient and will cause server performance drop]
	animationsfolder = nil; -- Specify where the custom animations are located, please read below on how to set up custom animations.
	reloadanimation = false; -- This takes up quite a bit of server performance, by default it's turned off.
	-- Non - Weld Animations
	reloadanimationtempo = 1; -- This should be used only if you are using the "Animations" animationtype
	animationonlyreload = 2.36; -- This should be used only if you are using the "Animations" animationtype
	-- Rays
	raycolor = player.TeamColor; -- Use BrickColor.new("Color") [Add color name in the brackets] or player.TeamColor
	raythickness = 0.15;
	raydecaytime = .05;
	-- User Interface Display
	cursorfriendly = 131718487;
	cursorenemy = 131718495;
	cursorneutral = 131581677;
	--ammotext = nil; -- To be implemented!
	--ammobar = nil; -- To be implemented!
	}

return settings

--[[
	Animations tutorial;
	This is a quick tutorial on how to set up the animations for the smgs, follow this guide and you will be good.
	
	Steps;
	1 ] Create a folder (recommended to make it in replicatedstorage for better client access] and name it whatever you want, specify it's directory in animationsfolder.
	EXAMPLE: animationsfolder = game.ReplicatedStorage.AnimationsFolder
	2 ] Create each animation under the name of "Default", "Sprint", "Crouch" and "Reload" under the animationsfolder location. If poorly named or not present, the gun will not work and you will have to manually edit the scripting at that point.
	3 ] For the animations to not unload, name your major keyframe "Finish" while in animation editor prior to exporting, this applies to all animations.
	4 ] Export the animations and copy each animations ID into each respective animation loader in the folder.
	5 ] Test fire it and see if it works.
	
	NOTE FOR RELOAD ANIMATIONS;
	The animationonlyreload is good for accurate syncing with the reload animtion. If the reload animation seems a bit funny, simply change the animationonlyreload number (it is displayed in seconds) or change the animation tempo.
	--]]