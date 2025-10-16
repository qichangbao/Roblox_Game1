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
    if not child3.IsLoaded then
        child3.Loaded:Wait()
    end
    child3:Play()
end
local function playSound2()
    local child = Interface.safeWaitPart(SoundFolder, "CampFire2")
    local child1 = Interface.safeWaitPart(child, "CampfireMeshPart")
    local child2 = Interface.safeWaitPart(child1, "FireSound")
    if not child2.IsLoaded then
        child2.Loaded:Wait()
    end
    child2:Play()
end

playSound1()
playSound2()

local gameSound = Interface.safeWaitPart(game:GetService("SoundService"), "GAME")
local BackMusic = Interface.safeWaitPart(gameSound, "BackMusic")
if not BackMusic.IsLoaded then
    BackMusic.Loaded:Wait()
end
BackMusic.Looped = true
BackMusic:Play()
local SeaSound = Interface.safeWaitPart(gameSound, "Sea")
if not SeaSound.IsLoaded then
    SeaSound.Loaded:Wait()
end
SeaSound.Looped = true
SeaSound:Play()

return Sound