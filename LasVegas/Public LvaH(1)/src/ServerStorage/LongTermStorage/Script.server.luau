--[[

	This script is a paste-bin for all the commands I run in the command bar. Helps with organization and profiling issues.
	-GamerOkami

]]

local slotParts = 0;
local tableParts = 0;
local floorParts = 0;
local roofParts = 0;
local stairParts = 0;
local structureParts = 0;
local trimParts = 0;
local wallParts = 0;
local furnitureParts = 0;
local glassParts = 0;
local grassParts = 0;
local lightParts = 0;
local messageParts = 0;
local plantParts = 0;
local plaqueParts = 0;
local miscParts = 0;
local mapParts = 0;
local gameParts = 0;
local totalParts = 0;

local function RoundToNearestDecimal(number, scale)
	return tonumber(string.format("%." .. (typeof(scale) == "number" and scale or 2) .. "f", number))
end

local function AddCommasToNumber(number)
	local formatted = number;

	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2');
		if k == 0 then
			break;
		end
	end

	return formatted;
end

for each, thing in pairs(workspace:GetDescendants()) do
	if thing:IsA("BillboardGui") then
		totalParts += 1;
		if thing:IsDescendantOf(workspace.Games) then
			gameParts += 1;
		elseif thing:IsDescendantOf(workspace.Map) then
			mapParts += 1;
		end
		
		if thing:IsDescendantOf(workspace.Games.Slots) then
			slotParts += 1;
		elseif thing:IsDescendantOf(workspace.Games.Tables) then
			tableParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Casino.Floor) then
			floorParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Casino.Roofs) then
			roofParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Casino.Stairs) then
			stairParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Casino.Structure) then
			structureParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Casino.Trim) then
			trimParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Casino.Walls) then
			wallParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Furniture) then
			furnitureParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Glass) then
			glassParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Grass) then
			grassParts += 1
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Lights) then
			lightParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Messages) then
			messageParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Plants) then
			plantParts += 1;
		elseif thing:IsDescendantOf(workspace.Map.Decoration.Plaques) then
			plaqueParts += 1;
		else
			miscParts += 1;
		end
	end
end

print("Total GUIs: "..AddCommasToNumber(totalParts));
print("Misc GUIs: "..AddCommasToNumber(miscParts).." ("..RoundToNearestDecimal((miscParts/totalParts) * 100).."%)");
print("Game GUIs: "..AddCommasToNumber(gameParts).." ("..RoundToNearestDecimal((gameParts/totalParts) * 100).."%)");
print("Map GUIs: "..AddCommasToNumber(mapParts).." ("..RoundToNearestDecimal((mapParts/totalParts) * 100).."%)");
print();
print("Slot GUIs: "..AddCommasToNumber(slotParts).." ("..RoundToNearestDecimal((slotParts/totalParts) * 100).."%)");
print("Table GUIs: "..AddCommasToNumber(tableParts).." ("..RoundToNearestDecimal((tableParts/totalParts) * 100).."%)");
print();
print("Floor GUIs: "..AddCommasToNumber(floorParts).." ("..RoundToNearestDecimal((floorParts/totalParts) * 100).."%)");
print("Roof GUIs: "..AddCommasToNumber(roofParts).." ("..RoundToNearestDecimal((roofParts/totalParts) * 100).."%)");
print("Stair GUIs: "..AddCommasToNumber(stairParts).." ("..RoundToNearestDecimal((stairParts/totalParts) * 100).."%)");
print("Structure GUIs: "..AddCommasToNumber(structureParts).." ("..RoundToNearestDecimal((structureParts/totalParts) * 100).."%)");
print("Trim GUIs: "..AddCommasToNumber(trimParts).." ("..RoundToNearestDecimal((trimParts/totalParts) * 100).."%)");
print("Wall GUIs: "..AddCommasToNumber(wallParts).." ("..RoundToNearestDecimal((wallParts/totalParts) * 100).."%)");
print()
print("Furniture GUIs: "..AddCommasToNumber(furnitureParts).." ("..RoundToNearestDecimal((furnitureParts/totalParts) * 100).."%)");
print("Glass GUIs: "..AddCommasToNumber(glassParts).." ("..RoundToNearestDecimal((glassParts/totalParts) * 100).."%)");
print("Grass GUIs: "..AddCommasToNumber(grassParts).." ("..RoundToNearestDecimal((grassParts/totalParts) * 100).."%)");
print("Light GUIs: "..AddCommasToNumber(lightParts).." ("..RoundToNearestDecimal((lightParts/totalParts) * 100).."%)");
print("Message GUIs: "..AddCommasToNumber(messageParts).." ("..RoundToNearestDecimal((messageParts/totalParts) * 100).."%)");
print("Plant GUIs: "..AddCommasToNumber(plantParts).." ("..RoundToNearestDecimal((plantParts/totalParts) * 100).."%)");
print("Plaque GUIs: "..AddCommasToNumber(plaqueParts).." ("..RoundToNearestDecimal((plaqueParts/totalParts) * 100).."%)");

for each, bench in pairs(workspace.Map.Decoration.Furniture:GetChildren()) do
	for each, part in pairs(bench:GetChildren()) do
		if part:IsA("Seat") then
			part.CastShadow = false;
		end
	end
end

for each, SurfaceGui in pairs(workspace:GetDescendants()) do
	if SurfaceGui:IsA("SurfaceGui") then
		SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud;
		SurfaceGui.PixelsPerStud = 50;
	end
end

for each, thing in pairs(workspace.Map.Decoration.Plaques:GetChildren()) do
	thing.CanCollide = false;
	thing.CanQuery = false;
	thing.CanTouch = false;
end

for each, thing in pairs(workspace:GetDescendants()) do
	if thing:IsA("BasePart") then
		if thing.Color == Color3.fromRGB(117, 0, 0) then
			thing.Parent = workspace.Floor;
		elseif thing.Color == Color3.fromRGB(86, 36, 36) then
			thing.Parent = workspace.Stairs;
		elseif thing.Color == Color3.fromRGB(213, 115, 61) then
			thing.Parent = workspace.Walls;
		elseif thing.Color == Color3.fromRGB(31, 128, 29) then
			thing.Parent = workspace.Roofs;
		elseif thing.Color == Color3.fromRGB(91, 93, 105) then
			thing.Parent = workspace.Structure;
		elseif thing.Color == Color3.fromRGB(91, 154, 76) then
			thing.Parent = workspace.Grass;
		elseif thing.Color == Color3.fromRGB(255, 176, 0) then
			thing.Parent = workspace.Trim;
		end
		if thing.Transparency ~= 0 then
			thing.Parent = workspace.Glass
		end
	end
end

for each, decal in pairs(workspace.Games.Slots:GetDescendants()) do
	if decal:IsA("Decal") then
		local SurfaceGui = Instance.new("SurfaceGui");
		SurfaceGui.Parent = decal.Parent;
		SurfaceGui.Adornee = decal.Parent;
		SurfaceGui.Face = Enum.NormalId.Left;
		SurfaceGui.PixelsPerStud = 10;
		SurfaceGui.Name = "SlotIcon";
		
		local ImageLabel = Instance.new("ImageLabel");
		ImageLabel.Parent = SurfaceGui;
		ImageLabel.Size = UDim2.new(1, 0, 1, 0);
		ImageLabel.Image = decal.Texture;
		ImageLabel.BackgroundTransparency = 1;
		
		decal:Destroy();
	end
end

for each, surfaceGui in pairs(workspace.Games.Slots:GetDescendants()) do
	if surfaceGui.Name == "SlotIcon" then
		surfaceGui.MaxDistance = 50;
	end
end

for each, wheel in pairs(workspace.Games.Slots:GetDescendants()) do
	if string.sub(wheel.Name, 1, 5) == "Wheel" then
		wheel:Destroy();
	end
end

local slotName = "SevensAndCherries";
for each, slot in pairs(workspace.Games.Slots[slotName]:GetChildren()) do
	local newSlot = workspace.SlotTemplates[slotName]:Clone();
	newSlot:PivotTo(slot.WorldPivot);
	newSlot.Parent = workspace.Games.Slots[slotName];
	slot:Destroy();
end

for each, surfaceGui in pairs(workspace:GetDescendants()) do
	if surfaceGui:IsA("SurfaceGui") then
		surfaceGui.LightInfluence = 0
	end
end

for each, fish in pairs(game.StarterPlayer.StarterPlayerScripts.StartFish.PendingFish.Aquarium1:GetChildren()) do
	if fish:IsA("MeshPart") then
		fish.Size = Vector3.new(fish.Size.X * 2, fish.Size.Y * 2, fish.Size.Z * 2)
	end
end

local allPoints = {};
local RNG = Random.new();
for each, point in pairs(workspace.Map.Decoration.Aquarium1.Paths:GetChildren()) do
	table.insert(allPoints, point)
end
for each, point in pairs(workspace.Map.Decoration.Aquarium2.Paths:GetChildren()) do
	table.insert(allPoints, point)
end
for each, point in pairs(workspace.Map.Decoration.Aquarium3.Paths:GetChildren()) do
	table.insert(allPoints, point)
end
for i = 1, math.floor(#allPoints / 2) do
	local index = RNG:NextInteger(1, #allPoints);
	local point = allPoints[index];
	point:Destroy();
	table.remove(allPoints, index)
end

for each, lightModel in pairs(workspace.Map.Decoration.Lights:GetChildren()) do
	for each, part in pairs(lightModel:GetChildren()) do
		if part:FindFirstChild("SpotLight") then
			part.SpotLight.Range = 30;
		end
	end
end

for each, thing in pairs(workspace.Games.Slots:GetDescendants()) do
	if thing:IsA("BasePart") then
		thing.CastShadow = false;
	end
end

for each, casinoGame in pairs(workspace.Games.Tables.Plinko:GetChildren()) do
	for each, podium in pairs(casinoGame.Functional.Podiums:GetChildren()) do
		podium.Picture.SurfaceGui.ImageLabel.Image = "rbxassetid://130345054974245"
	end
end
for each, casinoGame in pairs(workspace.Games.Tables.Blackjack:GetChildren()) do
	casinoGame.Decoration.Title.SurfaceGui.ImageLabel.Image = "rbxassetid://81891544126216";
end
for each, casinoGame in pairs(workspace.Games.Slots.GreenHot:GetChildren()) do
	casinoGame.Decoration.Payouts2.SurfaceGui.ImageLabel.Image = "rbxassetid://106276422050451";
end