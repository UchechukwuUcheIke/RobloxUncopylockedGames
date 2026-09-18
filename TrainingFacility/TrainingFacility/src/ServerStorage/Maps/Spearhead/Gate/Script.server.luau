sp=script.Parent
gate1=sp.Gate1
gate2=sp.Gate2
gate3=sp.Gate3
button=sp.Button
status=sp.Status
distance=12.5 --distance to be closed, then nothing else has to be edited

deb=false
status.Changed:connect(function()
if deb then return end
button.BrickColor=BrickColor.new("Bright orange")
if status.Value==false then
deb=true
for i = 1, distance*8 do
gate1.CFrame=gate1.CFrame*CFrame.new(0, 0, -.125)
gate2.CFrame=gate2.CFrame*CFrame.new(0, 0, -.125)
gate3.CFrame=gate3.CFrame*CFrame.new(0, 0, .125)
wait(.02)
end
deb=false
button.BrickColor=BrickColor.new("Bright red")
else
deb=true
for i = 1, distance*8 do
gate1.CFrame=gate1.CFrame*CFrame.new(0, 0, .125)
gate2.CFrame=gate2.CFrame*CFrame.new(0, 0, .125)
gate3.CFrame=gate3.CFrame*CFrame.new(0, 0, -.125)
wait(.02)
end
deb=false
button.BrickColor=BrickColor.new("Bright green")
end
end)

button.Touched:connect(function(hit)
if hit and not deb then
if hit.Parent then
if hit.Parent:findFirstChild("Humanoid") then
	--if hit.Parent:findFirstChild("Surrendered")==nil then
	status.Value = not status.Value
	--end
end
end
end
end)