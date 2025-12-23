-- GoldService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local GoldService = Knit.CreateService {
	Name = "GoldService",
	Client = {
        ChangeGold = Knit.CreateSignal(),
	},

    Gold = {},
}

function GoldService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function GoldService:KnitStart()
end

function GoldService:PlayerAdded(player)
    local gold = Knit.GetService("DBService"):Get(player.UserId, "Gold")
    self.Gold[player.UserId] = tonumber(gold)
end

function GoldService:PlayerRemoved(player)
    self.Gold[player.UserId] = nil
end

function GoldService:GetGoldData(player)
    return self.Gold[player.UserId]
end

function GoldService:SetGold(player, gold)
    self.Gold[player.UserId] = tonumber(gold)
    self.Client.ChangeGold:Fire(player, self.Gold[player.UserId])
    Knit.GetService("DBService"):Set(player.UserId, "Gold", self.Gold[player.UserId])
end

function GoldService:ChangeGold(player, gold)
    self.Gold[player.UserId] = self.Gold[player.UserId] + tonumber(gold)
    self.Client.ChangeGold:Fire(player, self.Gold[player.UserId])
    Knit.GetService("DBService"):Set(player.UserId, "Gold", self.Gold[player.UserId])

    if gold > 0 then
        Knit.GetService("JobService"):TriggerJob(player, GameConfig.JobUnlockCondition.Gold, tonumber(gold))
    end
end

return GoldService