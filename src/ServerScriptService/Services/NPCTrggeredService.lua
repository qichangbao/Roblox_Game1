-- NPCTrggeredService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local NPCTrggeredService = Knit.CreateService {
	Name = "NPCTrggeredService",
	Client = {
        Triggered = Knit.CreateSignal(),
	},
}

function NPCTrggeredService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function NPCTrggeredService:KnitStart()
end

function NPCTrggeredService:Triggered(player, npcType, data)
	self.Client.Triggered:Fire(player, npcType, data)
end

return NPCTrggeredService