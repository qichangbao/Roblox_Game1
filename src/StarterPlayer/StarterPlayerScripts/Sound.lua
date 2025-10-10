local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local Sound = {}

local InitLand = workspace:WaitForChild("出生岛")
local SoundFolder = InitLand:WaitForChild("Special"):WaitForChild("Sound")
local function playSound1()
    local child = Interface.safeWaitPart(SoundFolder, "CampFire1")
    local child1 = Interface.safeWaitPart(child, "Camp Fire")
    local child2 = Interface.safeWaitPart(child1, "LogMesh1")
    local child3 = Interface.safeWaitPart(child2, "FireSound")
    child3:Play()
end
local function playSound2()
    local child = Interface.safeWaitPart(SoundFolder, "CampFire2")
    local child1 = Interface.safeWaitPart(child, "CampfireMeshPart")
    local child2 = Interface.safeWaitPart(child1, "FireSound")
    child2:Play()
end

playSound1()
playSound2()

local gameSound = Interface.safeWaitPart(game:GetService("SoundService"), "GAME")
local BackMusic = Interface.safeWaitPart(gameSound, "BackMusic")
BackMusic.Looped = true
BackMusic:Play()
local SeaSound = Interface.safeWaitPart(gameSound, "Sea")
SeaSound.Looped = true
SeaSound:Play()

return Sound