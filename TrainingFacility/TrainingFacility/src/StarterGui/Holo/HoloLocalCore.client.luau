local Debris = game:GetService("Debris");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HoloAction = Remotes:WaitForChild("HoloAction");

local player = Players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local playerRank = player:GetRankInGroup(9164618);

local GUI = script.Parent;
local mainBacking = GUI:WaitForChild("Main");
local notifyBacking = GUI:WaitForChild("Notify");
local allBackings = mainBacking:WaitForChild("Backings");
local menuClick = mainBacking:WaitForChild("MenuClick");
local menuSound = mainBacking:WaitForChild("MenuSound");
local meritControl = allBackings:WaitForChild("Merits"):WaitForChild("MeritControl");
local WOControl = allBackings:WaitForChild("Environment"):WaitForChild("WOControl");
local fogControl = allBackings:WaitForChild("Environment"):WaitForChild("FogControl");
local timeControl = allBackings:WaitForChild("Environment"):WaitForChild("TimeControl");
local obbyControl = allBackings:WaitForChild("Environment"):WaitForChild("ObbyControl");
local teamControl = allBackings:WaitForChild("Environment"):WaitForChild("TeamControl");
local respawnControl = allBackings:WaitForChild("Environment"):WaitForChild("RespawnControl");
local leftControl = allBackings:WaitForChild("StandingLines"):WaitForChild("LeftControl");
local rightControl = allBackings:WaitForChild("StandingLines"):WaitForChild("RightControl");

----------------------------------------------------------

local playersTable = {};
local slotConnections = {};

local function AddPlayerToList()
	for each, player in pairs(Players:GetPlayers()) do
		if playersTable[player.Name] == nil then
			local slot = script.MeritSlotTemplate:Clone();
			slot.Name = player.Name;
			slot.Text = slot.Name;
			slot.Parent = meritControl.NamesButton.PlayerList;
			slot.TextColor3 = player.TeamColor.Color;
			slot.Visible = true;
			
			slot.MouseEnter:Connect(function()
				menuSound:Play();
			end)
			slot.MouseButton1Click:Connect(function()
				menuClick:Play();
				slot:SetAttribute("NameSelected", not slot:GetAttribute("NameSelected"));
				slot.TextColor3 = (slot:GetAttribute("NameSelected") and Color3.fromRGB(255, 255, 0)) or player.TeamColor.Color;
				slot.FontFace = (slot:GetAttribute("NameSelected") and Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold)) or Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Regular);
			end)
			playersTable[player.Name] = 1;
			
			player.Changed:Connect(function(property)
				if property == "Team" and not slot:GetAttribute("NameSelected") then
					slot.TextColor3 = player.TeamColor.Color;
				end
			end)
		end
	end
end

local function RemovePlayerFromList(leaving)
	if leaving then
		meritControl.NamesButton.PlayerList[leaving]:Destroy();
		playersTable[leaving] = nil;
	end
end

local function AdjustPlayerList(leaving)
	AddPlayerToList();
	RemovePlayerFromList(leaving);
end

Players.PlayerAdded:Connect(function(player)
	AdjustPlayerList(nil);
end)
Players.PlayerRemoving:Connect(function(player)
	AdjustPlayerList(player.Name);
end)
AdjustPlayerList(nil);

local function UpdateColorPreview(control)
	local red = tonumber(control.Red.Text) or 0;
	local green = tonumber(control.Green.Text) or 0;
	local blue = tonumber(control.Blue.Text) or 0;
	red = math.clamp(red, 0, 255);
	green = math.clamp(green, 0, 255);
	blue = math.clamp(blue, 0, 255);
	control.Preview.BackgroundColor3 = Color3.fromRGB(red, green, blue);
end

----------------------------------------------------------

GUI:GetAttributeChangedSignal("CurrentScreen"):Connect(function()
	for each, backing in pairs(allBackings:GetChildren()) do
		backing.Visible = backing.Name == GUI:GetAttribute("CurrentScreen");
	end
end)

HoloAction.OnClientEvent:Connect(function(message)
	local template = script.NotifyTemplate:Clone();
	template.Message.Text = message;
	template.Parent = notifyBacking;
	Debris:AddItem(template, 3);
end)

local function Initiatize()
	if playerRank >= 252 or RunService:IsStudio() then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Equals then
				menuSound:Play();
				mainBacking.Visible = not mainBacking.Visible;
			end
		end)
		
		for each, backing in pairs(allBackings:GetChildren()) do
			if backing.Name == "Main" then
				for each, toggleButton in pairs(backing.Toggles:GetChildren()) do
					toggleButton.MouseEnter:Connect(function()
						menuSound:Play();
					end)
					toggleButton.MouseButton1Click:Connect(function()
						menuClick:Play();
						GUI:SetAttribute("CurrentScreen", toggleButton.Name);
					end)
				end
			else
				backing.Back.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				backing.Back.MouseButton1Click:Connect(function()
					menuClick:Play();
					GUI:SetAttribute("CurrentScreen", "Main");
				end)
			end
			
			if backing.Name == "Maps" then
				for each, mapButton in pairs(backing.List:GetChildren()) do
					if mapButton:IsA("ImageButton") then
						mapButton.MouseEnter:Connect(function()
							menuSound:Play();
						end)
						mapButton.MouseButton1Click:Connect(function()
							menuClick:Play();
							HoloAction:FireServer("Map", {mapButton.Name});
						end)
					end
				end
			elseif backing.Name == "Minigames" then
				for each, minigameButton in pairs(backing.List:GetChildren()) do
					if minigameButton:IsA("ImageButton") then
						minigameButton.MouseEnter:Connect(function()
							menuSound:Play();
						end)
						minigameButton.MouseButton1Click:Connect(function()
							menuClick:Play();
							HoloAction:FireServer("Minigame", {minigameButton.Name});
						end)
					end
				end
			elseif backing.Name == "Obbies" then
				for each, obbyButton in pairs(backing.List:GetChildren()) do
					if obbyButton:IsA("ImageButton") then
						obbyButton.MouseEnter:Connect(function()
							menuSound:Play();
						end)
						obbyButton.MouseButton1Click:Connect(function()
							menuClick:Play();
							HoloAction:FireServer("Obby", {obbyButton.Name});
						end)
					end
				end
			elseif backing.Name == "Weapons" then
				for each, weaponButton in pairs(backing.List:GetChildren()) do
					if weaponButton:IsA("ImageButton") then
						weaponButton.MouseEnter:Connect(function()
							menuSound:Play();
						end)
						weaponButton.MouseButton1Click:Connect(function()
							menuClick:Play();
							HoloAction:FireServer("Weapon", {weaponButton.Name});
						end)
					end
				end
			elseif backing.Name == "Merits" then
				meritControl.NamesButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				meritControl.NamesButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					meritControl.NamesButton.PlayerList.Visible = not meritControl.NamesButton.PlayerList.Visible;
				end)
				
				meritControl.GiveButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				meritControl.GiveButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					
					local playersToMerit = {};
					for each, slot in pairs(meritControl.NamesButton.PlayerList:GetChildren()) do
						if slot.Name ~= "UIGridLayout" then
							if slot.Visible and slot:GetAttribute("NameSelected") then
								table.insert(playersToMerit, slot.Name);
							end
						end
					end
					
					HoloAction:FireServer("Merit", {playersToMerit, tonumber(meritControl.AmountTextBox.Text)});
				end)
			elseif backing.Name == "Environment" then
				WOControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				WOControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("WOLimit", {tonumber(WOControl.AmountTextBox.Text)});
				end)
				
				fogControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				fogControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("Fog", {tonumber(fogControl.AmountTextBox.Text)});
				end)
				
				timeControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				timeControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("Time", {tonumber(timeControl.AmountTextBox.Text)});
				end)
				
				obbyControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				obbyControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("ObbyToggle");
				end)
				
				teamControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				teamControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("Teams");
				end)
				
				respawnControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				respawnControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("Respawn");
				end)
			elseif backing.Name == "StandingLines" then
				leftControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				leftControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("StandingLines", {"Left", leftControl.Preview.BackgroundColor3});
				end)
				rightControl.SubmitButton.MouseEnter:Connect(function()
					menuSound:Play();
				end)
				rightControl.SubmitButton.MouseButton1Click:Connect(function()
					menuClick:Play();
					HoloAction:FireServer("StandingLines", {"Right", rightControl.Preview.BackgroundColor3});
				end)
				
				leftControl.Red.Changed:Connect(function(property)
					if property == "Text" then 
						UpdateColorPreview(leftControl);
					end
				end)
				leftControl.Green.Changed:Connect(function(property)
					if property == "Text" then 
						UpdateColorPreview(leftControl);
					end
				end)
				leftControl.Blue.Changed:Connect(function(property)
					if property == "Text" then 
						UpdateColorPreview(leftControl);
					end
				end)
				rightControl.Red.Changed:Connect(function(property)
					if property == "Text" then 
						UpdateColorPreview(rightControl);
					end
				end)
				rightControl.Green.Changed:Connect(function(property)
					if property == "Text" then 
						UpdateColorPreview(rightControl);
					end
				end)
				rightControl.Blue.Changed:Connect(function(property)
					if property == "Text" then 
						UpdateColorPreview(rightControl);
					end
				end)
			end
		end
	end
end
Initiatize();