--[[---------------------------------------------------------------------------------------------------------
	
	DevForum Link : https://devforum.roblox.com/t/playerslistplus-v1-better-players-list/2975158
	
	How To Setup:
	
		- Move this ModuleScript in ReplicatedStorage
		- Move the Script named "PlayerListPlus" in ServerScriptService
		- Move the LocalScript named "PlayersListPlus" in ReplicatedFirst or StarterPlayer.StarterPlayerScripts
	
	ReadMe:
	
		Made by:
			Roblox : MiniDev (@youtub62)
			X (Twitter) : @MiniSandbox
	
		If you are using this in your game, send me a private message on the devforum! I want to see how are you using my system on your game :D

	Update [1.12]:
		
		- Added Teams support
		- Fixes

	Coming Soon:
	
		- LayoutOrder based on leaderstats value

	Functions:
	
		.AddCustomIconPlayer(Player : Player, Icon : string)
			-> Add a Custom Icon to a Player.
			-> Call this server side so everyone can see it.
			
		.ChangeColorPlayer(Player : Player, Color : Color3)
			-> Change the Color of the Player name.
			-> Call this server side so everyone can see it.
			
		.AddAnimationPlayer(Player : Player, AnimationName : string)
			-> Add an Animation to the Player name.
			-> Check the "Animations" folder for all Animations, you can create a new Animation by following the others animation script.
			-> AnimationName = the name of a Module in the "Animations" folder.
			-> Call this server side so everyone can see it.
			
		.AddTagPlayer(Player : Player, Name : string, Color : Color3, AnimationName : string)
			-> Add a tag to the Player, the Menu when you click on player profil
			-> Check the "Animations" folder for all Animations, you can create a new Animation by following the others animation script.
			-> AnimationName = the name of a Module in the "Animations" folder.
			-> Call this server side so everyone can see it.
			
	Example:
	
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local PlayersListPlus = require(ReplicatedStorage.PlayersListPlus)

		game.Players.PlayerAdded:Connect(function(Player)
		
			PlayersListPlus.AddCustomIconPlayer(Player, "rbxassetid://17451002563")
			
			PlayersListPlus.ChangeColorPlayer(Player, Color3.fromRGB(255, 170, 0))
			
			PlayersListPlus.AddAnimationPlayer(Player, "Golden")
			
			PlayersListPlus.AddTagPlayer(Player, "PREMIUM", Color3.fromRGB(255, 170, 0), "Golden")
			
		end)
		

-------------------------------------------------------------------------------------------------------------]]


local Config = {

	leaderstats = { -- Add all your leaderstats, without adding stats in the config it won't shows up in the menu
		--{
		--	Name = "Gold",
		--	Icon = "rbxassetid://17536803725",
		--	Color = Color3.fromRGB(255, 170, 0)
		--},
		--{
		--	Name = "Rank",
		--	Icon = "rbxassetid://17536798171",
		--	Color = Color3.fromRGB(255, 85, 127)
		--},
		{
			Name = "Cash",
			Icon = "rbxassetid://13202213179",
			Color = Color3.fromRGB(0, 255, 0)
		},
		{
			Name = "Playtime",
			Icon = "rbxassetid://228648990",
			Color = Color3.fromRGB(255, 255, 255)
		},
	},

	CustomSelectionsButtons = {
		--[[{
			Name = "Kick",
			Icon = "rbxassetid://17536814346",
			Func = function(Player : Player) -- Function when you click on the Button
				script.RemoteEvent:FireServer("Kick", Player)
			end,
			Permission = "Kick", -- Permission needed to view the button
			ShowForYourself = false -- Show the button when you select yourself
		},--]]
	},

	Permissions = { -- Notes: "*" Permission bypass the Permission and you can use all commands.
		UserIds = { -- [UserId] = {PermissionsName}

			--[374169534] = {"*"} -- Example

		},
		Group = { -- [GroupId] = {[RankId] = {PermissionsName}},

			--[10588814] = { -- Example
				--[255] = {"*"},
				--[254] = {"Kick"},
			--},

		},
	},

	CustomIcons = { -- (Developer Hammer Icon Id = rbxassetid://17451002563)
		UserIds = { -- [UserId] = IconId

			[42921866] = "rbxassetid://17451002563" -- Example

		},
		Group = { -- [GroupId] = {[RankId] = IconId},

			--[10588814] = { -- Example
				--[255] = "rbxassetid://17451002563",
				--[254] = "rbxassetid://17451002563"
			--}

		},
	},

	CustomTags = {
		UserIds = { -- [UserId] = {Name = TagName, Color = TagColor, Animation = AnimationName or nil}

			--[374169534] = {Name = "DEV", Color = Color3.fromRGB(255, 255, 255), Animation = "Golden"} -- Example

		},
		Group = { -- [GroupId] = {[RankId] = {Name = TagName, Color = TagColor, Animation = AnimationName or nil}}

			--[10588814] = { -- Example
			--[255] = {Name = "DEV", Color = Color3.fromRGB(255, 255, 255), Animation = "Golden"}
			--}

		}
	},

	MenuFont = Enum.Font.FredokaOne,
	MobileInset = false, -- if true, make the Players List higher on screen if the player uses the new Roblox UI Layout
	TeamSize = 0.115 -- 0.115 recommended
}

Config.VERSION = 1.13



















































local Teams = game.Teams:GetChildren() 

Config.Teams = false
Config.TeamsLayoutOrder = {}

if game.Teams:FindFirstChildWhichIsA("Team") then
	Config.Teams = true

	for i,v in Teams do
		Config.TeamsLayoutOrder[v.Name] = i
	end
end

local module = {}

module.Config = Config

_G.PlayersListPlus = module

--# UIs

local Assets = script:WaitForChild("Assets")

for i,v in script:GetDescendants() do
	if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
		v.Font = Config.MenuFont
	end
end

local UI = Assets:WaitForChild("PlayersList"):Clone()
_G.PlayersListUI = UI

local UIListMaster : CanvasGroup = UI.Frame.PlayerListMaster
local UIPlayerList : CanvasGroup = UIListMaster.ScrollingFrame.PlayerFrame.PlayerList

--# Services

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")
local Modules = script:WaitForChild("Modules")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GetCustomIcon = require(script.Modules.GetCustomIcon)
local GetCustomTag = require(script.Modules.GetCustomTag)

--# Modules

local Abbreviation = require(Modules.Abbreviation)
local SelectPlayer = require(Modules.SelectPlayer)

--# Ratio

local ratio = 1 + (#Config.leaderstats-1) * .5
local statsRatio = (.4/ratio)
local nameRatio = (.6/ratio)
local totalRatio = statsRatio * #Config.leaderstats + nameRatio
nameRatio += 1-totalRatio

--# Others

local LocalPlayer = Players.LocalPlayer

function module.UpdatePlayer(Player : Player)

	local CustomIcon = Player:GetAttribute("PLP_CustomIcon")

	if not CustomIcon and LocalPlayer:IsFriendsWith(Player.UserId) then -- Add or ReAdd the friend icon
		Player:SetAttribute("PLP_CustomIcon", "rbxassetid://17457740660")
	end

	module.RemovePlayer(Player, true)
	module.AddPlayer(Player)
end

function module.AddCustomIconPlayer(Player : Player, Icon : string)
	Player:SetAttribute("PLP_CustomIcon", Icon)
	return
end

function module.ChangeColorPlayer(Player : Player, Color : Color3)
	Player:SetAttribute("PLP_Color", Color)
	return
end

function module.AddAnimationPlayer(Player : Player, AnimationName : string)
	Player:SetAttribute("PLP_Animation", AnimationName)
	return
end

function module.AddTagPlayer(Player : Player, Name : string, Color : Color3, AnimationName : string)
	local Run = RunService:IsClient() and "_Client" or "_Server"

	local Folder = Player:FindFirstChild("PLP_Tags" .. Run)

	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = "PLP_Tags" .. Run
		Folder.Parent = Player
	end

	local Find = Folder:FindFirstChild(Name)
	if Find then
		return
	end

	local new = Instance.new("Color3Value")
	new.Value = Color
	new.Name = Name
	new:SetAttribute("Animation", AnimationName)
	new.Parent = Folder
end

function module.RemoveTagPlayer(Player, Name)
	local Run = RunService:IsClient() and "_Client" or "_Server"

	local Folder = Player:FindFirstChild("PLP_Tags" .. Run)

	if not Folder then
		return
	end

	local Find = Folder:FindFirstChild(Name)
	if Find then
		Find:Destroy()
	end
end


local function getPlrTeam(plr)
	return plr.Team and plr.Team.Name or nil
end

local function updateTeams(TeamName, leaderstatsName)

	local find = UIPlayerList:FindFirstChild("t_" .. TeamName)

	if not find then
		return
	end

	local Text = find:WaitForChild("l_" .. leaderstatsName)

	local TotalTeamValue = 0
	local NoPlayer = true
	local isNotNumber = false

	for i,newPlr in game.Players:GetPlayers() do
		local plrTeam = getPlrTeam(newPlr)
		if isNotNumber == false and (plrTeam == TeamName or (TeamName == "Neutral" and plrTeam == nil)) then
			NoPlayer = false
			
			local leaderstats = newPlr:WaitForChild("leaderstats")
			local stat = leaderstats:WaitForChild(leaderstatsName)
			local val = stat.Value
			
			if typeof(val) ~= "number" then
				isNotNumber = true
				NoPlayer = true
			else
				TotalTeamValue += val
			end


		end
	end

	Text.Text = NoPlayer and "-" or Abbreviation.abbreviateNumber(TotalTeamValue)
end

function AddLeaderstats(Player, Frame)
	for i,v in Config.leaderstats do
		Frame.Size = UDim2.new(1,0,Assets.PlayerFrame.Size.Y.Scale/ratio,0)

		local PlayerNameFrame = Frame:WaitForChild("PlayerNameFrame", 99999)

		if not PlayerNameFrame then
			continue
		end

		PlayerNameFrame.Size = UDim2.new(nameRatio,0,1,0)

		local new = Assets.PlrStats:Clone()
		new.Name = "l_" .. v.Name
		new.Parent = Frame
		new.TextColor3 = v.Color or Color3.fromRGB(255, 255, 255)
		new.LayoutOrder = i
		new.Text = "-"
		new.Size = UDim2.new(statsRatio,0,1,0)

		if not Player then
			continue
		end

		local findValue = Player:WaitForChild("leaderstats"):WaitForChild(v.Name)

		if findValue then
			new.Text = Abbreviation.abbreviateNumber(findValue.Value)
		end

		for i,teamName in Teams do
			updateTeams(teamName.Name, v.Name)
		end

		updateTeams("Neutral", v.Name)

		if not Player:GetAttribute("PLP_l_" .. v.Name) then
			Player:SetAttribute("PLP_l_" .. v.Name, true)
			local Text = new

			local Value : ValueBase = findValue or Player:WaitForChild("leaderstats"):WaitForChild(v.Name)

			local function upd(val)
				if not Text or not Text.Parent then
					local find = UIPlayerList:FindFirstChild("p_" .. Player.UserId)

					if not find then
						return
					end

					Text = find:WaitForChild("l_" .. v.Name)
				end

				Text.Text = Abbreviation.abbreviateNumber(val)

				if Config.Teams and typeof(val) == "number" then
					for i,teamName in Teams do
						updateTeams(teamName.Name, v.Name)
					end

					updateTeams("Neutral", v.Name)
				end
			end

			Value.Changed:Connect(upd)
			upd(Value.Value)
		end
	end
end

local GetSize = require(script.Modules.GetSize)

local function CheckExist(Player)
	if UIPlayerList:FindFirstChild("p_" .. Player.UserId) then
		return true
	end
	return false
end

local function addPlayerFrame(Name, CustomIcon, Color, Animation, FrameName)
	local new = CustomIcon and Assets.IconPlayerFrame:Clone() or Assets.PlayerFrame:Clone()

	new.Visible = false
	new.Name = FrameName
	new.Parent = UIPlayerList

	if CustomIcon then
		new:FindFirstChild("Icon", true).Image = CustomIcon
	end

	local playerNameText = new:FindFirstChild("PlayerName", true)
	playerNameText.Text = Name

	if Color then
		playerNameText.TextColor3 = Color
	end

	if Animation then
		local find = script.Animations:FindFirstChild(Animation)
		if not find then
			warn(`Animation {Animation} not found!`)
		else
			require(find)(playerNameText)
		end
	end

	return new
end


function module.AddPlayer(Player : Player)
	if CheckExist(Player) then
		return
	end

	local IconMaxSize = GetSize.getMaxSizeIcon(Player)

	local CustomIcon = Player:GetAttribute("PLP_CustomIcon")
	local Color = Player:GetAttribute("PLP_Color")
	local Animation = Player:GetAttribute("PLP_Animation")

	if Player:IsInGroup(1200769) then
		CustomIcon = "rbxassetid://17463246052" -- Roblox Admin Logo
	elseif Player:IsInGroup(4199740) then -- Star Creator
		CustomIcon = "rbxassetid://17475876588"
	end

	if CheckExist(Player) then
		return
	end

	local playerName = Player.DisplayName

	if Player.HasVerifiedBadge then
		playerName ..= utf8.char(0xE000)
	end

	if Player.MembershipType == Enum.MembershipType.Premium then
		playerName ..= utf8.char(0xE001)
	end

	local new = addPlayerFrame(playerName, CustomIcon, Color, Animation, "p_" .. Player.UserId)

	task.spawn(AddLeaderstats, Player, new)

	new.MouseEnter:Connect(function()
		new.Transparency = .9
	end)

	new.MouseLeave:Connect(function()
		new.Transparency = 1
	end)

	new.MouseButton1Click:Connect(function()
		SelectPlayer.Show(Player)
	end)

	if Config.Teams then
		if Player.Neutral or not Player.Team then
			new.LayoutOrder = (999) * 1000 + 1
			UIPlayerList.t_Neutral.Visible = true
		else

			new.LayoutOrder = Config.TeamsLayoutOrder[Player.Team.Name] * 1000 + 1

			local ShowNeutral = false

			for i,v in game.Players:GetChildren() do
				if Player.Neutral or not Player.Team then
					ShowNeutral = true
				end
			end

			UIPlayerList.t_Neutral.Visible = ShowNeutral
		end
	end

	new.Visible = true
end

function module.RemovePlayer(Player : Player, NoAnimation)
	local find : Frame = UIPlayerList:FindFirstChild("p_" .. Player.UserId)
	if find then

		if NoAnimation then
			find:Destroy()
			return
		elseif Config.Teams then

			for i,name in Config.leaderstats do
				for i,teamName in Teams do
					updateTeams(teamName.Name, name.Name)
				end

				updateTeams("Neutral", name.Name)
			end
		end

		find:TweenSize(UDim2.new(find.Size.X.Scale,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, .5, true)
		task.wait(.5)
		find:Destroy()
	end
end

function FirstLoadPlayer(Player : Player)
	local function upd()
		module.UpdatePlayer(Player)
	end
	
	pcall(module.AddPlayer, Player)

	Player:GetAttributeChangedSignal("PLP_CustomIcon"):Connect(upd)
	Player:GetAttributeChangedSignal("PLP_Color"):Connect(upd)
	Player:GetAttributeChangedSignal("PLP_Animation"):Connect(upd)

	if not Player:GetAttribute("PLP_CustomIcon") then
		task.spawn(function()
			local custom = GetCustomIcon.Get(Player)
			Player:SetAttribute("PLP_CustomIcon", custom)

			if not custom then
				if LocalPlayer:IsFriendsWith(Player.UserId) then
					Player:SetAttribute("PLP_CustomIcon", "rbxassetid://17457740660")
				end
			end
		end)
	end

	local CustomTag = GetCustomTag.Get(Player)

	if CustomTag then
		module.AddTagPlayer(Player, CustomTag.Name, CustomTag.Color, CustomTag.Animation)
	end

	Player:GetPropertyChangedSignal("Team"):Connect(upd)
	Player:GetPropertyChangedSignal("Neutral"):Connect(upd)
end

local Menu_TI = TweenInfo.new(.1, Enum.EasingStyle.Linear)
local VisibleMenu = TweenService:Create(UIListMaster, Menu_TI, {GroupTransparency = 0})
local InvisibleMenu = TweenService:Create(UIListMaster, Menu_TI, {GroupTransparency = 1})

function module.init()

	local studio = RunService:IsStudio()

	if not studio then
		local creatorId = game.CreatorId

		if game.CreatorType == Enum.CreatorType.Group then
			local succ, info = pcall(function()
				return GroupService:GetGroupInfoAsync(game.CreatorId).Owner 
			end)
			if succ then
				creatorId = info.Id
			end
		end

		if LocalPlayer.UserId ~= creatorId then

			-- DO NOT REMOVE, this support my work, this print doesn't appear on studio.

			print((`\n\n➡️ This game uses PlayersListPlus \n➡️ PlayersListPlus was developed by MiniDev (@youtub62) \n❓ More info: Search "PlayersListPlus" on the Devforum [V{Config.VERSION}]\n`))
		end
	end

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	if Config.MobileInset == true then
		local function onInputTypeChanged(inputType)
			if inputType == Enum.UserInputType.Touch then -- Mobile Player
				if game.GuiService.TopbarInset.Height > 45 then -- New roblox ui uses Height 58
					UI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets -- More space on screen!
				end
			else
				UI.ScreenInsets = Assets.PlayersList.ScreenInsets
			end
		end

		onInputTypeChanged(UserInputService:GetLastInputType())

		UserInputService.LastInputTypeChanged:Connect(onInputTypeChanged)
	end

	if #Config.leaderstats ~= 0 then
		local pSize = UIListMaster.Size
		UIListMaster.Size = UDim2.new(pSize.X.Scale * ratio, 0, pSize.Y.Scale, 0)

		for i,v in UIListMaster:GetDescendants() do
			if v:IsA("GuiObject") and v.Size ~= UDim2.new(1,0,1,0) and v:GetAttribute("resize") == nil then
				local pSize = v.Size
				v.Size = UDim2.new(pSize.X.Scale, 0, pSize.Y.Scale / ratio, 0)
			end
		end
	end

	local function newTeam(Name, i)
		local new = addPlayerFrame(Name, nil, nil, nil, "t_" .. Name)

		task.spawn(AddLeaderstats, nil, new)

		new.LayoutOrder = i * 1_000

		local Team = game.Teams:FindFirstChild(Name)

		local Color

		if not Team then
			Color = Color3.fromRGB(85, 85, 85)
		else
			Color = Team.TeamColor.Color
		end

		new.BackgroundColor3 = Color
		new.BackgroundTransparency = .5

		new.Size = UDim2.new(new.Size.X.Scale, 0, Config.TeamSize, 0)

		new.Visible = true

		return new
	end

	for Name,i in Config.TeamsLayoutOrder do
		newTeam(Name, i)
	end

	game.Teams.ChildAdded:Connect(function(child)
		Config.Teams = true

		local newI = nil

		local UsedI = {}

		for i,v in Config.TeamsLayoutOrder do
			table.insert(UsedI, v)
			
			if not game.Teams:FindFirstChild(i) or i == child.Name then
				Config.TeamsLayoutOrder[i] = nil
				Config.TeamsLayoutOrder[child.Name] = v
				newI = v
			end
		end

		Teams = game.Teams:GetChildren()

		if not newI then
			
			local i = 0
			
			while not newI do
				i += 1
				
				if not table.find(UsedI, i) then
					newI = i
					Config.TeamsLayoutOrder[child.Name] = newI
				end
			end
		end

		newTeam(child.Name, newI)

		for i,v in game.Players:GetPlayers() do
			module.UpdatePlayer(v)
		end
	end)

	game.Teams.ChildRemoved:Connect(function(child)
		if not game.Teams:FindFirstChildWhichIsA("Team") then
			Config.Teams = false

			local find = UIPlayerList:FindFirstChild("t_Neutral")
			if find then
				find.Visible = false
			end
		end

		local find = UIPlayerList:FindFirstChild("t_" .. child.Name)
		if find then
			find:Destroy()
		end

		Teams = game.Teams:GetChildren()

		for i,v in game.Players:GetPlayers() do
			module.UpdatePlayer(v)
		end
	end)

	local Neutral = newTeam("Neutral", 999)
	Neutral.Visible = false

	for  _,Player in Players:GetPlayers() do
		task.spawn(FirstLoadPlayer, Player)
	end

	Players.PlayerAdded:Connect(FirstLoadPlayer)
	Players.PlayerRemoving:Connect(module.RemovePlayer)

	UI.Parent = LocalPlayer.PlayerGui

	UIListMaster.Top.MouseEnter:Connect(function()
		UIListMaster.Top.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)

	UIListMaster.Top.MouseLeave:Connect(function()
		UIListMaster.Top.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	end)

	local DB = false

	local Openned = true

	local function open()
		if DB == true then
			return
		end

		Openned = true

		UIListMaster.Parent.Folder.Open.Visible = false

		DB = true

		UIListMaster.GroupTransparency = 1
		UIListMaster.Visible = true

		VisibleMenu:Play()
		VisibleMenu.Completed:Wait()

		DB = false
	end

	local function close()
		if DB == true then
			return
		end

		Openned = false

		DB = true
		InvisibleMenu:Play()
		InvisibleMenu.Completed:Wait()

		UIListMaster.Visible = false
		UIListMaster.Parent.SelectPlayer.Visible = false
		UIListMaster.Parent.Folder.Open.Visible = true

		DB = false
	end

	UIListMaster.Top.MouseButton1Click:Connect(close)
	UIListMaster.Parent.Folder.Open.MouseButton1Click:Connect(open)

	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == Enum.KeyCode.Tab then
			if Openned then
				close()
			else
				open()
			end
		end
	end)

	for i,v in Config.leaderstats do
		UIListMaster.Top.PlayerName.Size = UDim2.new(nameRatio,0,1,0)

		local new = Assets.TopStats:Clone()
		new.Name = v.Name
		new.Icon.Image = v.Icon
		new.Parent = UIListMaster.Top
		new.LayoutOrder = i
		new.Text.TextColor3 = v.Color or Color3.fromRGB(255, 255, 255)
		new.Text.Text = v.Name
		new.Size = UDim2.new(statsRatio,0,1,0)
	end

	task.delay(5, function()
		StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(Player)
			if not Player:GetAttribute("PLP_CustomIcon") then
				Player:SetAttribute("PLP_CustomIcon", "rbxassetid://17457740660")
			end
		end)

		StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(Player)
			if Player:GetAttribute("PLP_CustomIcon") == "rbxassetid://17457740660" then
				Player:SetAttribute("PLP_CustomIcon", nil)
			end
		end)
	end)
end

return module
