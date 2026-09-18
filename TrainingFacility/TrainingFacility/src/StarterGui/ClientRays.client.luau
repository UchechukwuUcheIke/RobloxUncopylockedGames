local event = game.ReplicatedStorage:WaitForChild("ClientConnection")
local player = game.Players.LocalPlayer
local cframe, cframeXYZ, vector = CFrame.new, CFrame.fromEulerAnglesXYZ, Vector3.new
local RbxUtility = require(game:GetService("ReplicatedStorage"):
    WaitForChild("LoadLibrary"):WaitForChild("RbxUtility"))
local create = RbxUtility.Create
local laser = create("Part"){Name = "Ray", Anchored = true, CanCollide = false, formFactor = 0, Size = vector(1, 1, 1), Material='Neon', Reflectance = 0.2, Transparency = 0.15}
local mesh = create("BlockMesh"){Parent = laser, Name = "Mesh"}

event.OnClientEvent:connect(function(data)
	if data["Client"] ~= player and data["Function"] == "Ray" then
		local laser1 = laser:clone()
		laser1.BrickColor = data["Color"]
		if data["Barrel"] ~= nil then
			data["Barrel"].Light.Color = data["Color"].Color
			data["Barrel"].Flash.Light.Rotation = math.random(0, 90)
			data["Barrel"].Flash.Enabled = true
		end
		laser1.CFrame = data["Orientation"] * cframe(0, 0, -data["Length"]/2)
		laser1.Mesh.Scale = vector(data["Thickness"], data["Thickness"], data["Length"])
		laser1.Parent = workspace
		game.Debris:AddItem(laser1, data["Decay"])
		if data["Barrel"] ~= nil then
			wait(data["Decay"])
			data["Barrel"].Flash.Enabled = false
		end
	end
end)