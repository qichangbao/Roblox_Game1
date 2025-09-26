local InitLand = workspace:FindFirstChild("出生岛")
while not InitLand do
	task.wait(1)
	InitLand = workspace:FindFirstChild("出生岛")
end

local SoundFolder = InitLand:WaitForChild("Special"):WaitForChild("Sound")
SoundFolder:WaitForChild("CampFire1"):WaitForChild("Camp Fire"):WaitForChild("LogMesh1"):WaitForChild("FireSound"):Play()
SoundFolder:WaitForChild("CampFire2"):WaitForChild("CampfireMeshPart"):WaitForChild("FireSound"):Play()