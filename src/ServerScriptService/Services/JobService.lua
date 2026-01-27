local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local HeroConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("HeroConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local JobService = Knit.CreateService({
    Name = 'JobService',
    Client = {
        UpdateJobData = Knit.CreateSignal(),
        ChangeCurJobId = Knit.CreateSignal(),
    },

    curJobId = {},
    JobData = {},
})

function JobService:KnitInit()
end

function JobService:KnitStart()
end

function JobService:PlayerAdded(player)
    self.curJobId[player.UserId] = Knit.GetService("DBService"):Get(player.UserId, "CurJobId")
    self.JobData[player.UserId] = Knit.GetService("DBService"):Get(player.UserId, "JobData")
end

function JobService:PlayerRemoved(player)
    self.JobData[player.UserId] = nil
    self.curJobId[player.UserId] = nil
end

-- 从数据库恢复玩家的任务进度
-- @param player Player 玩家对象
-- @return void
function JobService:LoadPlayerJob(player, jobData)
    if not player then return end
    local userId = player.UserId
    -- 从数据库恢复为服务器规范（数值键）
    self.JobData[userId] = jobData
    self.Client.UpdateJobData:Fire(player, jobData)
end

function JobService:GetJobFromDBService(userId, jobData)
	local player = game.Players:GetPlayerByUserId(userId)
	self:LoadPlayerJob(player, jobData)
end

function JobService:GetJobData(player)
    return self.JobData[player.UserId]
end

function JobService:GetCurJobId(player)
    return self.curJobId[player.UserId]
end

function JobService:TriggerJob(player, jobType, jobValue)
    local jobData = self.JobData[player.UserId]
    if not jobData then return end
    for id, data in pairs(jobData) do
        local config = HeroConfig:GetById(tonumber(id))
        if not config then continue end
        local unlock = Interface.Split(config.Unlock[data.Level], "_")
		local unlockType = tonumber(unlock[1])
        if unlockType == jobType then
            if unlockType == GameConfig.JobUnlockCondition.IslandLevel
            or unlockType == GameConfig.JobUnlockCondition.Escape
            or unlockType == GameConfig.JobUnlockCondition.RobCoins then
                data.Unlock = jobValue
            elseif unlockType == GameConfig.JobUnlockCondition.DamageMonster
            or unlockType == GameConfig.JobUnlockCondition.DamageMonsterNum then
                local monsterId = tonumber(unlock[2])
                if monsterId == jobValue.monsterId then
                    data.Unlock += jobValue.count
                end
            elseif unlockType == GameConfig.JobUnlockCondition.CollectItemNum
            or unlockType == GameConfig.JobUnlockCondition.TreatmentItemNum then
                local itemId = tonumber(unlock[2])
                if itemId == jobValue.itemId then
                    data.Unlock += jobValue.count
                end
            else
                data.Unlock += jobValue
            end
        end
    end
    Knit.GetService("DBService"):Set(player.UserId, "JobData", jobData)
    self.Client.UpdateJobData:Fire(player, jobData)
end

function JobService.Client:LevelUp(player, jobId)
    local jobData = self.Server:GetJobData(player)
    if not jobData then return end
    local data = jobData[jobId]
    if not data then return end
    local config = HeroConfig:GetById(tonumber(jobId))
    if not config then return end

    local unlock = Interface.Split(config.Unlock[data.Level], "_")
    local unlockType = tonumber(unlock[1])
    if unlockType == GameConfig.JobUnlockCondition.DamageMonster
    or unlockType == GameConfig.JobUnlockCondition.DamageMonsterNum
    or unlockType == GameConfig.JobUnlockCondition.CollectItemNum
    or unlockType == GameConfig.JobUnlockCondition.TreatmentItemNum then
        if data.Unlock < tonumber(unlock[3]) then return end
    else
        if data.Unlock < tonumber(unlock[2]) then return end
    end

    local UpgradeCost = Interface.Split(config.UpgradeCost[data.Level], "_")
    local upgradeCostType = tonumber(UpgradeCost[1])
    local upgradeCostValue = tonumber(UpgradeCost[2])
    if upgradeCostType == GameConfig.JobUpgradeCost.Gold then
        local gold = Knit.GetService("GoldService"):GetGoldData(player)
        if gold < upgradeCostValue then return end
        Knit.GetService("GoldService"):ChangeGold(player, -upgradeCostValue)
    elseif upgradeCostType == GameConfig.JobUpgradeCost.RobCoins then
        return
    else
        return
    end

    if data.Level >= 3 then
        data.IsFinished = true
        data.Level = 3
    else
        data.Level += 1
    end
    data.Unlock = 0
    self.UpdateJobData:Fire(player, jobData)
end

function JobService:ChangeJob(player, jobId)
    self.curJobId[player.UserId] = jobId
    Knit.GetService("DBService"):Set(player.UserId, "CurJobId", jobId)
    Knit.GetService("PlayerService"):RefreshAllPlayerAttribute(player)
    self.Client.ChangeCurJobId:Fire(player, tonumber(jobId))
    Knit.GetService("PlayerService"):SetJobModel(player, tonumber(jobId))
end

-- 玩家切换职业
-- @param player Player 玩家对象
-- @param jobId number 任务ID
-- @return boolean 是否激活:ture 激活，false 解除激活
function JobService.Client:ChangeJob(player, jobId)
    return self.Server:ChangeJob(player, jobId)
end

return JobService
