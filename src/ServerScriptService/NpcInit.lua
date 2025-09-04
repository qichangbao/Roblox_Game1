local ServerStorage = game:GetService("ServerStorage")

local NpcInit = {}

local npc1 = ServerStorage:WaitForChild("Npc1"):Clone()
npc1.Parent = game:GetService("Workspace")
require(npc1:FindFirstChild("ModuleScript"))

local npc2 = ServerStorage:WaitForChild("Npc2"):Clone()
npc2.Parent = game:GetService("Workspace")
require(npc2:FindFirstChild("ModuleScript"))

return NpcInit