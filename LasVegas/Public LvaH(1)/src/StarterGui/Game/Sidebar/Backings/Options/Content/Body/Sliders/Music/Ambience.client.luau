local player = game.Players.LocalPlayer ;
local character = player.Character or player.CharacterAdded:Wait();
local musicPlayer = script.Parent.Player;
--[[local musicList = {
	--https://www.youtube.com/watch?v=q55gUXPGQHA&list=OLAK5uy_njPkPesqGITjFmwPrKhANMVFgyzddMtAc&index=1
	"rbxassetid://12386472646", --Lates Nights and Dice
	"rbxassetid://12386473406", --Counting Cards
	"rbxassetid://12386474206", --The House Always Wins
	"rbxassetid://12386474695", --Playing The Slots
	"rbxassetid://12386475154", --Poker Jazz
	"rbxassetid://12386475753", --Perfect Jazz for Casino Players
	"rbxassetid://12386476258", --Chips are Down
	"rbxassetid://12386476747", --Playing the Tables
	"rbxassetid://12386477076", --Ideal Jazz for Casino Nights
	"rbxassetid://12386477580", --Happy Times on the Strip
	"rbxassetid://12386478156", --Early Hours Winning
	"rbxassetid://12386478577", --Jazz BGM Casino
};--]]
local musicList = {
	"rbxassetid://1839280853", --Latin Casino
	"rbxassetid://1835751459", --Casino Luck
	"rbxassetid://1835441471", --Caracas Gambling
	"rbxassetid://9044850753", --Upp i det bla? (c)
	"rbxassetid://1835723881", --Dream Experience
	"rbxassetid://9039581164", --Forest Light (c)
	"rbxassetid://1836500792", --Upbeat Jazz
	"rbxassetid://1842418969", --Jazz Waltz (a)
	"rbxassetid://1836728800", --Cheeky Break
	"rbxassetid://1840434748", --Soul Motivator (A)
	"rbxassetid://1840534623", --Funk Street (A)
}
--[[local musicList = {
	"rbxassetid://119785045189926", --Casino Funk - Arc De Soleli
	"rbxassetid://129163723910761", --Boogie Town - Wanda Shakes
	"rbxassetid://110282530387784", --Bark and Bite - Elliot Holmes
	"rbxassetid://77589812658822", --A Warm Welcome - Martin Landström
	"rbxassetid://135593643492469", --Blackjack Table - White Bones
	"rbxassetid://118040555582462", --All In - White Bones
	"rbxassetid://78844183050282", --Back to the Old House - White Bones
	"rbxassetid://136613650361640", --Jackpot - White Bones
	"rbxassetid://82596463393260", --No Questions - White Bones
	"rbxassetid://105875330607152", --The Cover Up - White Bones
	"rbxassetid://136725893904508", --The Demand of Man - Secession Studios
}--]]
local random = Random.new();
local trackPosition = random:NextInteger(1, #musicList);
local currentID = musicList[trackPosition];

local function playNextMusic()
	currentID = musicList[trackPosition];
	musicPlayer.SoundId = currentID;
	if not musicPlayer.IsLoaded then
		musicPlayer.Loaded:Wait();
	end
	musicPlayer:Play();
end

local function moveTrackPosition(direction)
	if direction == "forward" then
		trackPosition += 1;
		if trackPosition > #musicList then
			trackPosition = 1;
		end
	else
		trackPosition -= 1;
		if trackPosition < 1 then
			trackPosition = #musicList;
		end
	end
end

musicPlayer.Ended:Connect(function()
	moveTrackPosition("forward");
	playNextMusic();
end)
playNextMusic();