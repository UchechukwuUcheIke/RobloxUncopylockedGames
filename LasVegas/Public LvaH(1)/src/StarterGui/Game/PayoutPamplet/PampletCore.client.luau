local pamplet = script.Parent;
local back = pamplet.Back;
local forward = pamplet.Forward;

local function refreshPamplet(toggle)
	for each, page in pairs(pamplet:GetChildren()) do
		if tonumber(page.Name) then
			page.Visible = toggle and page.Name == tostring(pamplet:GetAttribute("CurrentPage"))
		end
	end
end

forward.MouseButton1Up:Connect(function()
	pamplet:SetAttribute("CurrentPage", pamplet:GetAttribute("CurrentPage") + 1);
	if pamplet:GetAttribute("CurrentPage") > pamplet:GetAttribute("MaxPages") then
		pamplet:SetAttribute("CurrentPage", 0);
	end
	refreshPamplet(forward.Visible);
end)

back.MouseButton1Up:Connect(function()
	pamplet:SetAttribute("CurrentPage", pamplet:GetAttribute("CurrentPage") - 1);
	if pamplet:GetAttribute("CurrentPage") < 0 then
		pamplet:SetAttribute("CurrentPage", pamplet:GetAttribute("MaxPages"));
	end
	refreshPamplet(forward.Visible);
end)

forward.Changed:Connect(function(property)
	if property == "Visible" then
		back.Visible = forward.Visible;
		refreshPamplet(forward.Visible);
	end
end)