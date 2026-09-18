local StarterGui = game:GetService("StarterGui");
local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local player = Players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local backpack = player.Backpack;
local frame = script.Parent.Frame;
local template = frame.Template;

local activeTransparency = 0;
local inactiveTransparency = 0.5;
local scaleBetweenSlots = 0.5;
local inputKeys = {["One"] = {txt = "1"}, ["Two"] = {txt = "2"}};
local inputOrder = {inputKeys["One"], inputKeys["Two"]};

local function handleEquip(tool)
	if tool then
		if tool.Parent ~= character then
			humanoid:EquipTool(tool)
		else
			humanoid:UnequipTools();
		end
	end
end

local function createSlots()
	local slotsAmount = #inputOrder;
	frame.Position = UDim2.new(0.5, -((1 + scaleBetweenSlots)/2) * (slotsAmount - 1) * (template.AbsoluteSize.X * 1.5), frame.Position.Y.Scale, 0);
	
	for index = 1, #inputOrder do
		local value = inputOrder[index];
		local slot = template:Clone();
		slot.Parent = frame;
		slot.Label.Text = value["txt"];
		slot.Name = value["txt"];
		slot.Visible = true;
		slot.Position = UDim2.new((index - 1) + (scaleBetweenSlots * index), 0, 0, 0);
		slot.ImageTransparency = inactiveTransparency;
		
		local tool = value["tool"];
		if tool then
			slot.Tool.Image = tool.TextureId;
		end
		
		slot.Tool.MouseButton1Up:Connect(function()
			for _, value in pairs(inputKeys) do
				if value["txt"] == slot.Name then
					handleEquip(value["tool"]);
				end 
			end
		end)
	end
	
	template:Destroy();
end

local function updateSlots()
	for _, value in pairs(inputKeys) do
		local tool = value["tool"];
		local icon = frame:FindFirstChild(value["txt"]);
		if tool then
			icon.Tool.Image = tool.TextureId;
			if tool.Parent == character then
				icon.ImageTransparency = activeTransparency;
			else
				icon.ImageTransparency = inactiveTransparency;
			end
		else
			icon.Tool.Image = "";
			icon.ImageTransparency = inactiveTransparency;
		end
	end
end

local function handleAddition(newChild)
	if newChild:IsA("Tool") then
		local new = true;
		
		for _, value in pairs(inputKeys) do
			local tool = value["tool"];
			if tool and tool == newChild then
				new = false;
				break;
			end
		end
		
		if new then
			for index = 1, #inputOrder do
				local tool = inputOrder[index]["tool"]
				if not tool then
					inputOrder[index]["tool"] = newChild;
					break;
				end
			end
		end
		
		updateSlots();
	end
end

local function handleRemoval(oldChild)
	if oldChild:IsA("Tool") then
		if oldChild.Parent ~= character and oldChild.Parent ~= backpack then
			for index = 1, #inputOrder do
				if inputOrder[index]["tool"] == oldChild then
					inputOrder[index]["tool"] = nil;
					break;
				end
			end
		end
		
		updateSlots();
	end
end

local function initialize()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false);
	
	local tools = backpack:GetChildren();
	for each, tool in pairs(tools) do
		if tool:IsA("Tool") then
			for index = 1, #inputOrder do
				local value = inputOrder[index];
				if not value["tool"] then
					value["tool"] = tools[index];	
					break;
				end
			end
		end
	end
	
	createSlots();
end

UserInputService.InputBegan:Connect(function(input)
	local value = inputKeys[input.KeyCode.Name];
	if value and not UserInputService:GetFocusedTextBox() then
		handleEquip(value["tool"]);
	end
end)

character.ChildAdded:Connect(handleAddition);
backpack.ChildAdded:Connect(handleAddition);
character.ChildRemoved:Connect(handleRemoval);
backpack.ChildRemoved:Connect(handleRemoval);
initialize();