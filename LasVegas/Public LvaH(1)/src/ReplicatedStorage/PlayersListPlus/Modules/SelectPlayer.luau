local module = {}

--# Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local GetPermissions = require(ReplicatedStorage.PlayersListPlus.Modules.GetPermissions)
local Assets = script.Parent.Parent.Assets
local PlayersListPlus = _G.PlayersListPlus

--# UIs

local UI = _G.PlayersListUI

local UISelectPlayer : CanvasGroup = UI.Frame.SelectPlayer
local UIActionList : CanvasGroup = UISelectPlayer.ScrollingFrame.ActionFrame.ActionList

--# Others

local LocalPlayer = Players.LocalPlayer
local SelectedPlayer = nil

local AddFriendButton = {
	Name = "Add Friend",
	Icon = "rbxassetid://17449420190",
	Func = function(Player)
		StarterGui:SetCore("PromptSendFriendRequest", Player)
	end
}

local UnFriendButton = {
	Name = "Unfriend",
	Icon = "rbxassetid://17449420483",
	Func = function(Player)
		StarterGui:SetCore("PromptUnfriend", Player)
	end
}

local BlockButton = {
	Name = "Block",
	Icon = "rbxassetid://17449420606",
	Func = function(Player)
		StarterGui:SetCore("PromptBlockPlayer", Player)
	end
}

local UnBlockButton = {
	Name = "Unblock",
	Icon = "rbxassetid://17449420606",
	Func = function(Player)
		StarterGui:SetCore("PromptUnblockPlayer", Player)
	end
}

local BaseActionButtons = {
	{
		Name = "Examine Avatar",
		Icon = "rbxassetid://17449420345",
		Func = function(Player)
			GuiService:InspectPlayerFromUserId(Player.UserId)
		end
	}
}

local Info = "MINIDEV"
local Info2 = Color3.fromRGB(255, 255, 255)

function module.Clear()
	for i,v in UIActionList:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for i,v in UISelectPlayer.Top.Tags:GetChildren() do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end
end

function module.AddButtons(list)
	local Player = SelectedPlayer

	for _, data in list do
		local new = Assets.SelectedButton:Clone()

		new.MouseEnter:Connect(function()
			new.Transparency = .9
		end)

		new.MouseLeave:Connect(function()
			new.Transparency = 1
		end)

		new.MouseButton1Click:Connect(function()
			data.Func(Player)
		end)

		new.ActionName.Text = data.Name
		new.ActionIcon.Image = data.Icon

		new.Parent = UIActionList
	end
end

local PlayersIcons = {}

local Menu_TI = TweenInfo.new(.1, Enum.EasingStyle.Linear)
local VisibleMenu = TweenService:Create(UISelectPlayer, Menu_TI, {GroupTransparency = 0})
local InvisibleMenu = TweenService:Create(UISelectPlayer, Menu_TI, {GroupTransparency = 1})
local DB = false

local GetSize = require(ReplicatedStorage.PlayersListPlus.Modules.GetSize)

local function AddTag(Name, Color, Animation)
	local new = Assets.Tag:Clone()
	new.Text = Name
	new.TextColor3 = Color

	if Animation then
		local find = script.Parent.Parent.Animations:FindFirstChild(Animation)
		if not find then
			warn(`Animation {Animation} not found!`)
		else
			require(find)(new)
		end
	end

	new.Parent = UISelectPlayer.Top.Tags
end

function module.Show(Player : Player)

	if DB == true then
		return
	end

	DB = true

	task.delay(.2, function()
		DB = false
	end)

	if Player == SelectedPlayer then
		DB = true

		SelectedPlayer = nil

		InvisibleMenu:Play()
		InvisibleMenu.Completed:Wait()
		UISelectPlayer.Visible = false
		DB = false
		return
	end

	module.Clear()
	SelectedPlayer = Player

	if Player ~= LocalPlayer then
		local isFriend = LocalPlayer:IsFriendsWith(Player.UserId)

		if isFriend then
			module.AddButtons({UnFriendButton})
		else
			module.AddButtons({AddFriendButton})
		end

		local BlockedIds = StarterGui:GetCore("GetBlockedUserIds")
		local isBlocked = table.find(BlockedIds, LocalPlayer.UserId)

		if isBlocked then
			module.AddButtons({UnBlockButton})
		else
			module.AddButtons({BlockButton})
		end
	end

	module.AddButtons(BaseActionButtons)

	for i,v in PlayersListPlus.Config.CustomSelectionsButtons do
		if v.Permission and not GetPermissions.HasPlayerPermission(LocalPlayer, v.Permission) then
			continue
		end

		if v.ShowForYourself == false and Player == LocalPlayer then
			continue
		end

		module.AddButtons({v})
	end

	UISelectPlayer.Top.PlayerIcon.Image = ""

	task.spawn(function()
		local Icon = PlayersIcons[Player.UserId]
		if not Icon then
			Icon = game.Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
			PlayersIcons[Player.UserId] = Icon
		end

		UISelectPlayer.Top.PlayerIcon.Image = Icon
	end)

	local playerName = Player.DisplayName

	if Player.HasVerifiedBadge then
		playerName ..= utf8.char(0xE000)
	end

	if Player.MembershipType == Enum.MembershipType.Premium then
		playerName ..= utf8.char(0xE001)
	end

	-- DO  NOT   REMOVE, this  support my  work (This add a custom tag to me)

	if GetSize.getMaxSizeIcon(Player) ~= 1 then
		AddTag(Info, Info2, "RainbowGradient")
	end

	local ServerTags = Player:FindFirstChild("PLP_Tags_Server")
	if ServerTags then
		for i,v in ServerTags:GetChildren() do
			AddTag(v.Name, v.Value, v:GetAttribute("Animation"))
		end
	end

	local ClientTags = Player:FindFirstChild("PLP_Tags_Client")
	if ClientTags then
		for i,v in ClientTags:GetChildren() do
			AddTag(v.Name, v.Value, v:GetAttribute("Animation"))
		end
	end

	UISelectPlayer.Top.NameFrame.DisplayName.Text = playerName
	UISelectPlayer.Top.NameFrame.PlayerName.Text = "@" .. Player.Name

	UISelectPlayer.GroupTransparency = 1
	UISelectPlayer.Visible = true

	DB = true

	VisibleMenu:Play()
	VisibleMenu.Completed:Wait()

	DB = false
end

return module
