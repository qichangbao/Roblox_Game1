local Sound = {}

local InitLand = workspace:WaitForChild("出生岛")
local SoundFolder = InitLand:WaitForChild("Special"):WaitForChild("Sound")
SoundFolder:WaitForChild("CampFire1"):WaitForChild("Camp Fire"):WaitForChild("LogMesh1"):WaitForChild("FireSound"):Play()
SoundFolder:WaitForChild("CampFire2"):WaitForChild("CampfireMeshPart"):WaitForChild("FireSound"):Play()

return Sound