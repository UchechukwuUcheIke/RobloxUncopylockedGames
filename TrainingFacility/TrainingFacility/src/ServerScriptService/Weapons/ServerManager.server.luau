local event = Instance.new("RemoteEvent", game.ReplicatedStorage)
event.Name = "ClientConnection"
local remote = Instance.new("RemoteFunction", game.ReplicatedStorage)
remote.Name = "ReloadConnection"

local RbxUtility = require(game:GetService("ReplicatedStorage"):
    WaitForChild("LoadLibrary"):WaitForChild("RbxUtility"))
local create = RbxUtility.Create
local cframe, cframeXYZ, vector = CFrame.new, CFrame.fromEulerAnglesXYZ, Vector3.new

Weld = create("Weld"){}

local arms = {
	Left = cframe(0.9,0.8,0.5) * cframeXYZ(math.rad(280),math.rad(40),math.rad(-2)),
	Right = cframe(-1,0.1,0.35) * cframeXYZ(math.rad(-90),math.rad(-15),math.rad(0)),
}

function remote.OnServerInvoke(player)
	local char = player.Character
	if char and char:FindFirstChild("Torso") and char.Torso:FindFirstChild("Weld1") and char.Torso:FindFirstChild("Weld2") then
		local w1 = char.Torso:FindFirstChild("Weld1")
		local w2 = char.Torso:FindFirstChild("Weld2")
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.6,0.35)*CFrame.fromEulerAnglesXYZ(math.rad(-95),math.rad(-15),math.rad(10))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(-100),math.rad(-15),math.rad(20))
		wait(.09*2)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.6,0.35)*CFrame.fromEulerAnglesXYZ(math.rad(-95),math.rad(-15),math.rad(10))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(-100),math.rad(-15),math.rad(20))
		wait(.09*2)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.6,0.65)*CFrame.fromEulerAnglesXYZ(math.rad(-105),math.rad(-15),math.rad(30))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.6,0.65)*CFrame.fromEulerAnglesXYZ(math.rad(-98),math.rad(-15),math.rad(30))
		wait(.09*2)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.1,0.65)*CFrame.fromEulerAnglesXYZ(math.rad(-105),math.rad(-15),math.rad(30))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(360),math.rad(50),math.rad(0))
		wait(.02)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(340),math.rad(50),math.rad(0))
		wait(.02)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(300),math.rad(50),math.rad(0))
		wait(.02)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(285),math.rad(55),math.rad(0))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(293),math.rad(55),math.rad(0))
		wait(.09)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(285),math.rad(50),math.rad(0))
		wait(.13)
		w1.C1=CFrame.new(0.9,0.6,0.5)*CFrame.fromEulerAnglesXYZ(math.rad(280),math.rad(50),math.rad(0))
		w2.C1=CFrame.new(-0.8,0.7,0.65)*CFrame.fromEulerAnglesXYZ(math.rad(-95),math.rad(-15),math.rad(20))
		wait(.09)
		w2.C1=CFrame.new(-0.8,0.7,0.65)*CFrame.fromEulerAnglesXYZ(math.rad(-90),math.rad(-15),math.rad(10))
		wait(.09)
		return true
	else
		return false
	end
end

local function getWeapon(player)
	for each, thing in pairs(player.Character:GetChildren()) do
		if thing:IsA("Tool") then
			return thing;
		end
	end
end

event.OnServerEvent:connect(function(player, data)
	if data["Function"] == "Hurt" then
		if data["Victim"]:IsA("Humanoid") and data["Victim"].Health > 0 then
			if data["HitPart"].Size == data["HitPartSize"] then
				data["Victim"]:TakeDamage(data["Damage"])
				if player:FindFirstChild("leaderstats") and not data["Victim"].Parent:FindFirstChild("ForceField") then
					player.leaderstats.DMG.Value = player.leaderstats.DMG.Value + data["Damage"];
				end
				local tag = create("ObjectValue"){Name = "creator", Value = player, Parent = data["Victim"]}
				game.Debris:AddItem(tag, .5)
			else
				print("HBE detected from: "..player.Name);
			end
		elseif data["Victim"]:IsA("Part") or data["Victim"]:IsA("UnionOperation") then
			local target = data["Victim"];
			if target:FindFirstChild("Active") then
				if target.Active.Value then
					data["Victim"].HitsReceived.Value = data["Victim"].HitsReceived.Value + 1;
				end
			end
		end
	elseif data["Function"] == "Ray" then
		event:FireAllClients(data)
	elseif data["Function"] == "Weld" then
		local char = player.Character
		if char then
			if data["Bool"] == true then
				local la, ra = char:FindFirstChild("Left Arm"), char:FindFirstChild("Right Arm")
				local torso = char:FindFirstChild("Torso")
				local ls, rs = torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")
				ls.Part1, rs.Part1 = nil, nil
				local leftWeld = Weld:Clone()
				leftWeld.Name = "Weld1"; leftWeld.Part0 = torso; leftWeld.Part1 = la; leftWeld.C1 = arms.Left; leftWeld.Parent = torso
				local rightWeld = Weld:Clone()
				rightWeld.Name = "Weld2"; rightWeld.Part0 = torso; rightWeld.Part1 = ra; rightWeld.C1 = arms.Right; rightWeld.Parent = torso
			else
				local la, ra = char:FindFirstChild("Left Arm"), char:FindFirstChild("Right Arm")
				local torso = char:FindFirstChild("Torso")
				torso:FindFirstChild("Right Shoulder").Part1, torso:FindFirstChild("Left Shoulder").Part1 = ra, la
					local lw, rw = torso:FindFirstChild("Weld1"), torso:FindFirstChild("Weld2")
					if lw and rw then
						lw:Destroy()
						rw:Destroy()
					end
				end
			end
	elseif data["Function"] == "Stance" then
		local char = player.Character
		if data["Type"] == "Default" then
			if char and char:FindFirstChild("Torso") and char.Torso:FindFirstChild("Weld1") and char.Torso:FindFirstChild("Weld2") then
				local Left = char.Torso:FindFirstChild("Weld1")
				local Right = char.Torso:FindFirstChild("Weld2")
				Left.C1 = arms.Left
				Right.C1 = arms.Right
			end
		elseif data["Type"] == "Crouch" then
			if char:findFirstChild('Left Leg') and char:findFirstChild('Right Leg') and char:findFirstChild('HumanoidRootPart') and char.HumanoidRootPart:findFirstChild('RootJoint') and char.Torso and char.Torso:findFirstChild('Left Hip') and char.Torso:findFirstChild('Right Hip') then
				if data["Bool"] == true then
					local leftCrouchWeld, rightCrouchWeld = create("Weld"){}, create("Weld"){}
					char.Torso['Right Hip'].Part1 = nil
					char.Torso['Left Hip'].Part1 = nil
					char.HumanoidRootPart.RootJoint.C1 = CFrame.new(0,1,0)*CFrame.Angles(math.rad(90),math.rad(180),0)
					leftCrouchWeld.Part0 = char.Torso leftCrouchWeld.Parent = char.Torso leftCrouchWeld.Part1 = char['Left Leg']
					rightCrouchWeld.Part0 = char.Torso rightCrouchWeld.Parent = char.Torso rightCrouchWeld.Part1 = char['Right Leg']
					leftCrouchWeld.C1 = CFrame.new(.5,.5,1.5)*CFrame.Angles(math.rad(90),0,0)
					rightCrouchWeld.C1 = CFrame.new(-.55,1.3,.5)*CFrame.Angles(math.rad(-15),0,0)
				else
					char.Torso['Right Hip'].Part1 = char['Right Leg']
					char.Torso['Left Hip'].Part1 = char['Left Leg']
					char.HumanoidRootPart.RootJoint.C1 = CFrame.new(0,0,0)*CFrame.Angles(math.rad(90),math.rad(180),0)
					for i, parts in pairs (char.Torso:GetChildren()) do
						if parts.Name == "Weld" then
							parts:Destroy()
						end
					end
				end
			end
		elseif data["Type"] == "Sprint" then
			local left = char.Torso:FindFirstChild("Weld1")
			local right = char.Torso:FindFirstChild("Weld2")
			--phantomvisual was here
			right.C1 = arms.Right * CFrame.Angles(math.pi/6, -math.pi/6, 0) * CFrame.new(-0.5, 0.1, 0)
			left.C1 = arms.Left * CFrame.Angles(math.pi/6, 0, 0) * CFrame.new(0.5, -0.5, -0.5)
		end
	end
end)