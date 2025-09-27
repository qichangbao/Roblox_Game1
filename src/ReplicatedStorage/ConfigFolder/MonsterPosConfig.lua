
local MonsterPosConfig = {}

MonsterPosConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(476.4, -0.6, -175.5),
        MonsterPlanId = 31001,
    },
    [2] = {
        Index = 2,
        Position = Vector3.new(492.7, -0.6, -176.8),
        MonsterPlanId = 31001,
    },
    [3] = {
        Index = 3,
        Position = Vector3.new(487.3, -0.6, -123.9),
        MonsterPlanId = 31001,
    },
    [4] = {
        Index = 4,
        Position = Vector3.new(603.3, -0.6, -147.4),
        MonsterPlanId = 31001,
    },
    [5] = {
        Index = 5,
        Position = Vector3.new(622.8, 0.4, -62.3),
        MonsterPlanId = 31001,
    },
    [6] = {
        Index = 6,
        Position = Vector3.new(230.2, -0.6, -156.9),
        MonsterPlanId = 31001,
    },
    [7] = {
        Index = 7,
        Position = Vector3.new(165.5, -0.6, -147.5),
        MonsterPlanId = 31001,
    },
    [8] = {
        Index = 8,
        Position = Vector3.new(166.3, -0.6, -80.8),
        MonsterPlanId = 31001,
    },
    [9] = {
        Index = 9,
        Position = Vector3.new(133.2, 18.9, -100.8),
        MonsterPlanId = 31001,
    },
    [10] = {
        Index = 10,
        Position = Vector3.new(168.5, -1.6, -55.4),
        MonsterPlanId = 31001,
    },
}

-- 辅助函数
function MonsterPosConfig:GetByIndex(index)
    for i, item in pairs(self.Coordinates) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function MonsterPosConfig:GetByMonsterPlanId(value)
    for i, item in pairs(self.Coordinates) do
        if item.MonsterPlanId == value then
            return item
        end
    end
    return nil
end

function MonsterPosConfig:GetAll()
    return self.Coordinates
end

function MonsterPosConfig:GetCount()
    local count = 0
    for _ in pairs(self.Coordinates) do
        count = count + 1
    end
    return count
end

return MonsterPosConfig