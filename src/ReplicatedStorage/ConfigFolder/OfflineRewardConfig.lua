
local OfflineRewardConfig = {}

OfflineRewardConfig.Data = {
    [1] = {
        RewardId = 9001,
        PlanId = 5101,
    },
    [2] = {
        RewardId = 9002,
        PlanId = 5102,
    },
    [3] = {
        RewardId = 9003,
        PlanId = 5103,
    },
    [4] = {
        RewardId = 9004,
        PlanId = 5103,
    },
    [5] = {
        RewardId = 9005,
        PlanId = 5103,
    },
    [6] = {
        RewardId = 9006,
        PlanId = 5103,
    },
    [7] = {
        RewardId = 9007,
        PlanId = 5103,
    },
    [8] = {
        RewardId = 9008,
        PlanId = 5103,
    },
    [9] = {
        RewardId = 9009,
        PlanId = 5104,
    },
    [10] = {
        RewardId = 9010,
        PlanId = 5104,
    },
    [11] = {
        RewardId = 9011,
        PlanId = 5104,
    },
    [12] = {
        RewardId = 9012,
        PlanId = 5104,
    },
    [13] = {
        RewardId = 9013,
        PlanId = 5105,
    },
    [14] = {
        RewardId = 9014,
        PlanId = 5105,
    },
    [15] = {
        RewardId = 9015,
        PlanId = 5105,
    },
    [16] = {
        RewardId = 9016,
        PlanId = 5105,
    },
}

-- 辅助函数
function OfflineRewardConfig:GetByIndex(index)
    return self.Data[index]
end

function OfflineRewardConfig:GetByRewardId(value)
    for i, item in pairs(self.Data) do
        if item.RewardId == value then
            return item
        end
    end
    return nil
end

function OfflineRewardConfig:GetByPlanId(value)
    for i, item in pairs(self.Data) do
        if item.PlanId == value then
            return item
        end
    end
    return nil
end

function OfflineRewardConfig:GetAll()
    return self.Data
end

function OfflineRewardConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return OfflineRewardConfig