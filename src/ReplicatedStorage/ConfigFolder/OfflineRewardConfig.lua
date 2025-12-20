
local OfflineRewardConfig = {}

OfflineRewardConfig.Data = {
    [1] = {
        RewardId = 1,
        PlanId = 5101,
    },
    [2] = {
        RewardId = 2,
        PlanId = 5102,
    },
    [3] = {
        RewardId = 3,
        PlanId = 5103,
    },
    [4] = {
        RewardId = 4,
        PlanId = 5103,
    },
    [5] = {
        RewardId = 5,
        PlanId = 5103,
    },
    [6] = {
        RewardId = 6,
        PlanId = 5103,
    },
    [7] = {
        RewardId = 7,
        PlanId = 5103,
    },
    [8] = {
        RewardId = 8,
        PlanId = 5103,
    },
    [9] = {
        RewardId = 9,
        PlanId = 5104,
    },
    [10] = {
        RewardId = 10,
        PlanId = 5104,
    },
    [11] = {
        RewardId = 11,
        PlanId = 5104,
    },
    [12] = {
        RewardId = 12,
        PlanId = 5104,
    },
    [13] = {
        RewardId = 13,
        PlanId = 5105,
    },
    [14] = {
        RewardId = 14,
        PlanId = 5105,
    },
    [15] = {
        RewardId = 15,
        PlanId = 5105,
    },
    [16] = {
        RewardId = 16,
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