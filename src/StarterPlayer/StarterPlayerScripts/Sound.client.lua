local InitLand = workspace:FindFirstChild("出生岛")
while not InitLand do
	task.wait(1)
	InitLand = workspace:FindFirstChild("出生岛")
end

InitLand:WaitForChild("CampFire1"):WaitForChild("Camp Fire"):WaitForChild("LogMesh1"):WaitForChild("FireSound"):Play()
InitLand:WaitForChild("CampFire2"):WaitForChild("CampfireMeshPart"):WaitForChild("FireSound"):Play()