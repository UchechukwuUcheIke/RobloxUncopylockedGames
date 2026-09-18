local player = game.Players.LocalPlayer
	local backpack, playergui = player:WaitForChild("Backpack"), player:WaitForChild("PlayerGui")
	repeat wait(0.1) until player.Character
		local char, camera = player.Character, workspace.CurrentCamera
local tool = script.Parent
	local handle = tool:WaitForChild("Handle")
	local barrel = tool:WaitForChild("Barrel")
local GunGUI = tool:WaitForChild("GunGUI")
local event = game.ReplicatedStorage:WaitForChild("ClientConnection")

local RbxUtility = require(game:GetService("ReplicatedStorage"):
    WaitForChild("LoadLibrary"):WaitForChild("RbxUtility"))
local create = RbxUtility.Create
local storage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local cframe, cframeXYZ, vector = CFrame.new, CFrame.fromEulerAnglesXYZ, Vector3.new

local arms = {
	Left = cframe(0.9,0.8,0.5) * cframeXYZ(math.rad(280),math.rad(40),math.rad(-2)),
	Right = cframe(-1,0.1,0.35) * cframeXYZ(math.rad(-90),math.rad(-15),math.rad(0)),
}

local creator = create("ObjectValue"){Name = "creator", Value = player}
local laser = create("Part"){Name = "Ray", Anchored = true, CanCollide = false, formFactor = 0, Material = "Neon", Size = vector(1, 1, 1), Reflectance = 0, Transparency = 0.5}
local mesh = create("BlockMesh"){Parent = laser, Name = "Mesh"}

local armToggle = char:FindFirstChild("armToggle") and char.armToggle or create("BoolValue"){Parent = char, Name = "armToggle"}

local settings = require(tool.Settings)
mag = settings.clip

local equipped = false
local mouseDown = false
local reloading = false
local canFire = true
local firing = false

local crouch = false

if tool:FindFirstChild("used") then
	mag = 0
else
	create("ObjectValue"){Name = "used", Parent = tool}
end

local welding = {}
welding.Weld = create("Weld"){}

function welding.SetArms(bool)
	if settings.animationtype == "Weld" then
		event:FireServer({["Function"] = "Weld", ["Bool"] = bool})
	elseif settings.animationtype == "Animations" and settings.animationsfolder ~= nil and bool then
		local default = settings.animationsfolder:FindFirstChild("Default")
		local reload = settings.animationsfolder:FindFirstChild("Reload")
		local crouch = settings.animationsfolder:FindFirstChild("Crouch")
		local sprint = settings.animationsfolder:FindFirstChild("Sprint")
		if default and reload and crouch and sprint and bool then
			defaultanimation = char.Humanoid:LoadAnimation(default)
			reloadanimation = char.Humanoid:LoadAnimation(reload)
			crouchanimation = char.Humanoid:LoadAnimation(crouch)
			sprintanimation = char.Humanoid:LoadAnimation(sprint)
			defaultanimation:Play()
			local con
			con = defaultanimation.KeyframeReached:connect(function(keyframeName)
				con:disconnect()
				if keyframeName == "Finish" then
					defaultanimation:AdjustSpeed(0)
				end
			end)
		end
	else
		defaultanimation:Stop()
		reloadanimation:Stop()
		crouchanimation:Stop()
		sprintanimation:Stop()
	end
end

function welding.Default(...)
	char.Humanoid.WalkSpeed = 16
	if settings.animationtype == "Weld" then
		event:FireServer({["Function"] = "Stance", ["Type"] = "Default"})
		if char and char:FindFirstChild("Torso") and char.Torso:FindFirstChild("Weld1") and char.Torso:FindFirstChild("Weld2") then
			local Left = char.Torso:FindFirstChild("Weld1")
			local Right = char.Torso:FindFirstChild("Weld2")
			Left.C1 = arms.Left
			Right.C1 = arms.Right
		end
	elseif settings.animationtype == "Animations" then
		sprintanimation:Stop()
	end
end

function welding.Holster(...)
	if settings.animationtype == "Weld" then
		event:FireServer({["Function"] = "Stance", ["Type"] = "Sprint"})
		local left = char.Torso:FindFirstChild("Weld1")
		local right = char.Torso:FindFirstChild("Weld2")
		if left and right then
			right.C1 = arms.Right * CFrame.Angles(math.pi/6, -math.pi/6, 0) * CFrame.new(-0.5, 0.1, 0)
			left.C1 = arms.Left * CFrame.Angles(math.pi/6, 0, 0) * CFrame.new(0.5, -0.5, -0.5)
		end
	elseif settings.animationtype == "Animations" then
		local con
		sprintanimation:Play()
		con = sprintanimation.KeyframeReached:connect(function(keyframeName)
			con:disconnect()
			if keyframeName == "Finish" then
				sprintanimation:AdjustSpeed(0)
			end
		end)
	end
end

function welding.Crouch(bool)
	if settings.animationtype == "Weld" then
	event:FireServer({["Function"] = "Stance", ["Type"] = "Crouch", ["Bool"] = bool})
	elseif settings.animationtype == "Animations" then
		if bool then
			local con
			crouchanimation:Play()
			con = crouchanimation.KeyframeReached:connect(function(keyframeName)
				con:disconnect()
				if keyframeName == "Finish" then
					crouchanimation:AdjustSpeed(0)
				end
			end)
		else
			crouchanimation:Stop()
		end
	end
end

local remote = game.ReplicatedStorage:WaitForChild("ReloadConnection")
function welding.Animations()
	welding.Default()
	if settings.animationtype == "Weld" and settings.reloadanimation == true then
		local s, m = pcall(function() return remote:InvokeServer()end)
		if s then
			print("Reloaded")
			welding.Default()
		else
			print("Did not reload properly")
			welding.Default()
		end
	elseif settings.animationtype == "Animations" then
		reloadanimation:Play()
		reloadanimation:AdjustSpeed(settings.reloadanimationtempo)
		wait(settings.animationonlyreload)
	else
		wait(2.36)
	end
end

local call = {}

function call.UpdateGui(...)
	if playergui:FindFirstChild("GunGUI") then
		playergui.GunGUI.Main.Ammo.Text = mag
		playergui.GunGUI.Main.GunMain.AmmoBar2.Size = UDim2.new(mag/settings.clip, 0, 1, 0)
	end
end

function call.GetPlayer(hit)
	if hit and hit.Parent then
		if hit.Parent:FindFirstChild("Humanoid") then
			return hit.Parent.Humanoid
		elseif hit.Parent.Parent:FindFirstChild("Humanoid") then
			return hit.Parent.Parent.Humanoid
		end
	end
end

local gun = {}

function gun.Raycast(init, last, ign)
	local dir = (last-init).unit
	local ray = Ray.new(init, dir*999)
	local hit, at = workspace:FindPartOnRayWithIgnoreList(ray, ign)
		if hit and at and hit.Name == "Ray" then
			hit, at = gun.Raycast(at, dir*999, ign)
		end
	return hit, at
end

function gun.Fire(focus, mouse)
	local interval = (barrel.Position-focus).magnitude
	local min, max = -(settings.spread/100)*interval, (settings.spread/100)*interval
	local aim = vector((focus.x)+(math.random(min, max)), (focus.y)+(math.random(min, max)), (focus.z)+(math.random(min, max)))
	local hitPart, hitPos = gun.Raycast(char.Head.Position, aim, {char})
	local length, orientation = (barrel.Position-hitPos).magnitude, cframe(barrel.Position, hitPos)
	event:FireServer({["Function"] = "Ray", ["Client"] = player, ["Color"] = settings.raycolor, ["Orientation"] = orientation, ["Length"] = length, ["Thickness"] = settings.raythickness, ["Barrel"] = barrel, ["Decay"] = settings.raydecaytime})
	local laser1 = laser:clone()
	laser1.BrickColor = settings.raycolor
	barrel.Light.Color = settings.raycolor.Color
	laser1.CFrame = orientation * cframe(0, 0, -length/2)
	laser1.Mesh.Scale = vector(settings.raythickness, settings.raythickness, length)	
	laser1.Parent = workspace
	game.Debris:AddItem(laser1, settings.raydecaytime)	
	if hitPart then
		local hum = call.GetPlayer(hitPart)
		if hum and hitPart.Parent.Name ~= "JumpingTarget" then
			local target = game.Players:playerFromCharacter(hum.Parent)
			if not settings.teamkill and (target and target.TeamColor ~= player.TeamColor) or settings.teamkill then
				if hum.Health > 0 and playergui:FindFirstChild("GunGUI") then
					playergui:FindFirstChild("GunGUI").Hit.Rotation = math.random(1, 360)
					playergui:FindFirstChild("GunGUI").Hit.Visible = true
					delay(0.1, function()
						playergui:FindFirstChild("GunGUI").Hit.Visible = false
					end)
				end
				event:FireServer({["Function"] = "Hurt", ["Victim"] = hum, ["Damage"] = settings.damage, ["HitPart"] = hitPart, ["HitPartSize"] = hitPart.Size})
			end
		elseif hitPart:FindFirstChild("HitsReceived") then
			event:FireServer({["Function"] = "Hurt", ["Victim"] = hitPart, ["Damage"] = settings.damage})
		end
	end
end


function gun.Reload(mouse)
	barrel.Light.Enabled = false
	call.UpdateGui()
	if not reloading then
		if mag < settings.clip and equipped then
			reloading = true
			char.Humanoid.WalkSpeed = 16
			spawn(function()
				for i = 1, 3 do
					if playergui:FindFirstChild("GunGUI") and reloading and equipped then
						playergui:FindFirstChild("GunGUI").Main.Ammo.Text = "REL" .. string.rep(".", i)
						wait(0.4)
					else
						break
					end
				end		
			end)
			handle.Reload:Play()
			welding.Animations()
			if not reloading or not equipped then return end
			mag = settings.clip
			reloading = false
			call.UpdateGui()
		end
	end
end

local bindings = {}

function bindings.KeyPressed(key, mouse)
	local key = key:lower()
	if key == "r" and not reloading and not mouseDown then
		gun.Reload(mouse)
	elseif key == "f" and not reloading and not mouseDown then
		if armToggle.Value then
			armToggle.Value = false
			char.Humanoid.WalkSpeed = 16
			welding.Default()
		else
			armToggle.Value = true
			char.Humanoid.WalkSpeed = settings.sprintspeed
			welding.Holster()
		end
	elseif key == "c" and not armToggle.Value then
		if crouch then
			crouch = false
			char.Humanoid.WalkSpeed = 16
			welding.Crouch(false)
		else
			crouch = true
			char.Humanoid.WalkSpeed = settings.crouchspeed
			welding.Crouch(true)
		end
	end
end

function bindings.MouseClick(mouse)
	if equipped and not mouseDown and not reloading and canFire and char.Humanoid.Health > 0 then
		mouseDown = true
		call.UpdateGui()
		welding.Default()
		armToggle.Value = false
		barrel.Light.Enabled = true
		if settings.fireMode == "Auto" then
			while mouseDown and char.Humanoid.Health > 0 and canFire and mag > 0 and equipped do
				call.UpdateGui()
				barrel.Light.Angle = math.random(90, 180)
				mag = mag - 1
				gun.Fire(mouse.hit.p, mouse)
				handle.Fire:Play()
				handle.Parent.Barrel.Flash.Light.Rotation = math.random(0, 90)
				handle.Parent.Barrel.Flash.Enabled = true
				canFire = false
				wait(settings.firerate)
				canFire = true
			end
		elseif settings.fireMode == "Semi" then
			barrel.Light.Angle = math.random(90, 180)
			mag = mag - 1
			gun.Fire(mouse.hit.p, mouse)
			handle.Fire:Play()
			handle.Parent.Barrel.Flash.Enabled = true
			canFire = false
			wait(settings.firerate)
			canFire = true
		end
		if mag <= 0 then
			gun.Reload(mouse)
		end
		call.UpdateGui()
		barrel.Light.Enabled = false
		handle.Parent.Barrel.Flash.Enabled = false
	end
end

function bindings.MouseRelease(mouse)
	mouseDown = false
	barrel.Light.Enabled = false
	handle.Parent.Barrel.Flash.Enabled = false
end

tool.Equipped:connect(function(mouse)
	wait()
	welding.SetArms(true)
	equipped = true
	local newGui = GunGUI:Clone()
	newGui.Parent = playergui
	call.UpdateGui()
	mouse.Button1Down:connect(function() bindings.MouseClick(mouse) end)
	mouse.Button1Up:connect(function() bindings.MouseRelease(mouse) end)
	mouse.KeyDown:connect(function(key) bindings.KeyPressed(key, mouse) end)
	mouse.Move:connect(function()
		if equipped and playergui:FindFirstChild("GunGUI") then
			playergui:FindFirstChild("GunGUI").Hit.Position = UDim2.new(0, mouse.X-22.5, 0, mouse.Y-22.5)
		end
	end)
end)
tool.Unequipped:connect(function(mouse)
	if playergui:FindFirstChild("GunGUI") then
		playergui:FindFirstChild("GunGUI"):Destroy()
	end
	char.Humanoid.WalkSpeed = 16
	welding.SetArms(false)
	equipped = false
	mouseDown = false
	crouch = false
	welding.Crouch(false)
	reloading = false
	barrel.Light.Enabled = false
	armToggle.Value = false
end)