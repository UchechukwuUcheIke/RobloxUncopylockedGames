local NPCs = {}

local AllNPCs = {
	"GrandpaOkami", -- put usernames here if you want their NPC in game and they're not on any leaderboards
	"ChaoticOkami"
};

local Blacklisted = { -- those with troll/massive avatars
	"CIetus08",	
	"ThinkerOfGames",
};

function NPCs:GetAllNPCs()
	return AllNPCs;
end

function NPCs:AddPlayerToAllNPCs(playerName)
	if not table.find(AllNPCs, playerName) and not table.find(Blacklisted, playerName) then
		table.insert(AllNPCs, playerName);
	end
end

function NPCs:GetAvatarForNPC(username, parent, isR15)
	local s, result = pcall(function()
		return game.Players:GetUserIdFromNameAsync(username)
	end)
	if s then
		local dummy = nil
		local ss = pcall(function()
			local rig = isR15 and Enum.HumanoidRigType.R15 or Enum.HumanoidRigType.R6
			dummy = game.Players:CreateHumanoidModelFromDescription(game.Players:GetHumanoidDescriptionFromUserId(result), rig)
		end)
		if not ss then
			error("ERROR 2")
			return
		end
		dummy.Parent = parent
		local alignpart = Instance.new('Part',workspace)
		alignpart.Position = workspace.Camera.CFrame.Position + (workspace.CurrentCamera.CFrame.LookVector * 5)
		if not dummy.PrimaryPart then
			local hrpt = dummy:FindFirstChild('HumanoidRootPart')
			if hrpt then
				dummy.PrimaryPart = hrpt
			else
				warn('HumanoidRootPart was not found.')
				alignpart:Destroy()
				dummy:Destroy()
				error("ERROR 3")
				return
			end
		end
		dummy:SetPrimaryPartCFrame(alignpart.CFrame)
		alignpart:Destroy()
		local ss = pcall(function()
			dummy.Name = game.Players:GetNameFromUserIdAsync(result)
		end)
		if not ss then
			error("ERROR 4")
			return
		end

		dummy.HumanoidRootPart.Anchored = false
		for i, obj in ipairs(dummy:GetDescendants()) do
			if obj:IsA('BasePart') then
				obj.Locked = false
			elseif obj:IsA('Script') or obj:IsA('LocalScript') or obj:IsA('Configuration') then
				obj:Destroy()
			elseif obj:IsA('Accessory') then
				local h = obj:FindFirstChild('Handle')
				if h then
					local a = h:FindFirstChildWhichIsA('Attachment')
					local aw = h:FindFirstChild('AccessoryWeld')
					if a and not aw then
						obj.Parent = workspace
						for i, att in ipairs(dummy:GetDescendants()) do
							if (att.Name == a.Name) and att:IsA('Attachment') then
								obj.Parent = dummy
								local weld = Instance.new('Weld')
								weld.Name = 'AccessoryWeld'
								weld.Parent = h
								weld.C0 = att.CFrame
								weld.C1 = a.CFrame
							end 
						end
					end
				end
			end
		end
		return dummy
	else
		error("ERROR 1")
	end
end

return NPCs