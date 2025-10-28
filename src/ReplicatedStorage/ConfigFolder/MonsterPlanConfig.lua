
local MonsterPlanConfig = {}

MonsterPlanConfig.Data = {
    [1] = {
        MonsterPlanId = 31001,
        MonsterId = 30001,
        Probability = 7500,
    },
    [2] = {
        MonsterPlanId = 31002,
        MonsterId = 30002,
        Probability = 7500,
    },
    [3] = {
        MonsterPlanId = 31003,
        MonsterId = 30003,
        Probability = 7000,
    },
}

-- 辅助函数
function MonsterPlanConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function MonsterPlanConfig:GetByMonsterPlanId(value)
    for i, item in pairs(self.Data) do
        if item.MonsterPlanId == value then
            return item
        end
    end
    return nil
end

function MonsterPlanConfig:GetByMonsterId(value)
    for i, item in pairs(self.Data) do
        if item.MonsterId == value then
            return item
        end
    end
    return nil
end

function MonsterPlanConfig:GetByProbability(value)
    for i, item in pairs(self.Data) do
        if item.Probability == value then
            return item
        end
    end
    return nil
end

function MonsterPlanConfig:GetAll()
    return self.Data
end

function MonsterPlanConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return MonsterPlanConfig