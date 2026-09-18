function OnTouched(Part) 
if Part.Parent ~= nil then--Keep Parentless blocks from breaking it. 
if Part.Parent:findFirstChild("Humanoid") then
	Part:BreakJoints()
end 
end 
end 
script.Parent.Touched:connect(OnTouched)