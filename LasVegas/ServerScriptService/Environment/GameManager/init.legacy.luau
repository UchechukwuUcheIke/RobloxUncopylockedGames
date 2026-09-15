local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local DataStoreService = game:GetService("DataStoreService");
local MessagingService = game:GetService("MessagingService");
local TextService = game:GetService("TextService");
local Players = game:GetService("Players");
local Chat = game:GetService("Chat");
local ReplicatedRemotes = ReplicatedStorage:WaitForChild("Remotes");
local ServerModules = ServerStorage:WaitForChild("Modules");
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local VersionStore = DataStoreService:GetDataStore("GameVersion");
local CommandAction = ReplicatedRemotes:WaitForChild("CommandAction");
local Games = workspace:WaitForChild("Games");
local Map = workspace:WaitForChild("Map");
local Decoration = Map:WaitForChild("Decoration");
local Furniture = Decoration:WaitForChild("Furniture");
local RNG = Random.new();
local allImages = {
	"http://www.roblox.com/asset/?id=1008743",
	"http://www.roblox.com/asset/?id=1008745",
	"http://www.roblox.com/asset/?id=1017342",
	"http://www.roblox.com/asset/?id=1017343",
	"http://www.roblox.com/asset/?id=1008744",
	"http://www.roblox.com/asset/?id=1017344",
	"http://www.roblox.com/asset/?id=1017341",
	"http://www.roblox.com/asset/?id=1017345",
	"http://www.roblox.com/asset/?id=1017335",
	"http://www.roblox.com/asset/?id=1017330",
	"http://www.roblox.com/asset/?id=1008748",
	"http://www.roblox.com/asset/?id=1017334",
	"http://www.roblox.com/asset/?id=1017331",
	"http://www.roblox.com/asset/?id=1017349",
	"http://www.roblox.com/asset/?id=1017340",
	"http://www.roblox.com/asset/?id=1017347",
	"http://www.roblox.com/asset/?id=1017348",
	"rbxassetid://19006121860",
};
local CurrentVersion;

if not MessagingService then
	MessagingService = game:GetService("MessagingService"); -- fix????? for MessagingService: Service disconnected
end
MessagingService:SubscribeAsync("Shutdown", function(message)
	if message.Data == "public" and game.PrivateServerOwnerId == 0 then
		for _, player in pairs(Players:GetPlayers()) do
			player:Kick("This server has been shutdown by a developer. Please rejoin.");
		end
	elseif message.Data == "private" and game.PrivateServerOwnerId ~= 0 then
		for _, player in pairs(Players:GetPlayers()) do
			player:Kick("This server has been shutdown by a developer. Please rejoin.");
		end
	elseif message.Data == "all" then
		for _, player in pairs(Players:GetPlayers()) do
			player:Kick("This server has been shutdown by a developer. Please rejoin.");
		end
	end
end)
MessagingService:SubscribeAsync("Announcement", function(message)
	for _, player in ipairs(Players:GetPlayers()) do
		CommandAction:FireClient(player, "Announcement", {message.Data.Announcement, message.Data.SenderName});
	end
end)

local function initialize()
	ReplicatedStorage:SetAttribute("PrivateServerOwnerId", game.PrivateServerOwnerId);
	
	for each, thing in pairs(Games:GetDescendants()) do
		if thing:IsA("Model") and script:FindFirstChild(thing.Name.."Core") then
			local source = script[thing.Name.."Core"]:Clone();
			source.Parent, source.Enabled = thing, true;
		end
	end
	for each, furniture in pairs(Furniture:GetChildren()) do
		for each, seat in pairs(furniture:GetChildren()) do
			if seat:IsA("Seat") then
				local source = script["ToggleBreaktime"]:Clone();
				source.Parent, source.Enabled = seat, true;
			end
		end
	end
	
	-- hacky fix to stop accessories from NPC spawns sticking around in workspace causing lag --
	workspace.ChildAdded:Connect(function(child)
		if child:IsA("Accessory") then
			task.wait(1);
			if child.Parent == workspace then
				child:Destroy();
			end
		end
	end)
	
	coroutine.wrap(function()
		while true do
			ReplicatedStorage:SetAttribute("UptimeSecond", ReplicatedStorage:GetAttribute("UptimeSecond") + 1);
			if ReplicatedStorage:GetAttribute("UptimeSecond") == 60 then
				ReplicatedStorage:SetAttribute("UptimeMinute", ReplicatedStorage:GetAttribute("UptimeMinute") + 1);
				ReplicatedStorage:SetAttribute("UptimeSecond", 0);
				if ReplicatedStorage:GetAttribute("UptimeMinute") == 60 then
					ReplicatedStorage:SetAttribute("UptimeHour", ReplicatedStorage:GetAttribute("UptimeHour") + 1);
					ReplicatedStorage:SetAttribute("UptimeMinute", 0);
				end
			end
			
			task.wait(1);
		end
	end)()
	
	coroutine.wrap(function()
		while true do
			local storeVersion;
			local success, error = pcall(function()
				storeVersion = VersionStore:GetAsync("Version");
			end)
			
			if storeVersion then
				if not CurrentVersion then
					CurrentVersion = storeVersion;
				elseif CurrentVersion ~= storeVersion then
					ReplicatedStorage:SetAttribute("ServerStatus", 1);
				end
			end
			
			task.wait(15);
		end
	end)()
	
	coroutine.wrap(function()
		while true do
			for each, message in pairs(workspace.Map.Decoration.Messages:GetChildren()) do
				message.SurfaceGui.ImageLabel.Image = allImages[RNG:NextInteger(1, #allImages)];
			end

			task.wait(30);
		end
	end)()
end
initialize();