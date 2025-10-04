
local MonsterPosConfig = {}

MonsterPosConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(436.4, -0.7, -176.2),
        MonsterPlanId = 31001,
    },
    [2] = {
        Index = 2,
        Position = Vector3.new(489.8, -0.7, -194.1),
        MonsterPlanId = 31001,
    },
    [3] = {
        Index = 3,
        Position = Vector3.new(484.2, -0.7, -116.7),
        MonsterPlanId = 31001,
    },
    [4] = {
        Index = 4,
        Position = Vector3.new(612.9, -0.7, -147.5),
        MonsterPlanId = 31001,
    },
    [5] = {
        Index = 5,
        Position = Vector3.new(630.2, -0.7, -73.9),
        MonsterPlanId = 31001,
    },
    [6] = {
        Index = 6,
        Position = Vector3.new(237.1, -0.7, -167.8),
        MonsterPlanId = 31001,
    },
    [7] = {
        Index = 7,
        Position = Vector3.new(173.4, -0.7, -127.4),
        MonsterPlanId = 31001,
    },
    [8] = {
        Index = 8,
        Position = Vector3.new(188.8, -0.7, 35.9),
        MonsterPlanId = 31001,
    },
    [9] = {
        Index = 9,
        Position = Vector3.new(56.4, 36.1, 26.7),
        MonsterPlanId = 31001,
    },
    [10] = {
        Index = 10,
        Position = Vector3.new(212.3, 77.3, -114.6),
        MonsterPlanId = 31001,
    },
    [11] = {
        Index = 11,
        Position = Vector3.new(2.1, -0.7, 83.7),
        MonsterPlanId = 31001,
    },
    [12] = {
        Index = 12,
        Position = Vector3.new(-290.9, -0.7, -123.5),
        MonsterPlanId = 31001,
    },
    [13] = {
        Index = 13,
        Position = Vector3.new(486.1, -0.7, -21.7),
        MonsterPlanId = 31001,
    },
    [14] = {
        Index = 14,
        Position = Vector3.new(362.7, 24.2, 124.7),
        MonsterPlanId = 31001,
    },
    [15] = {
        Index = 15,
        Position = Vector3.new(145.5, -0.7, 222.8),
        MonsterPlanId = 31001,
    },
    [16] = {
        Index = 16,
        Position = Vector3.new(346.9, -0.7, 282.9),
        MonsterPlanId = 31001,
    },
    [17] = {
        Index = 17,
        Position = Vector3.new(557.8, -0.7, 186.8),
        MonsterPlanId = 31001,
    },
    [18] = {
        Index = 18,
        Position = Vector3.new(478.1, -0.7, 390.7),
        MonsterPlanId = 31001,
    },
    [19] = {
        Index = 19,
        Position = Vector3.new(230.7, -0.7, 521.2),
        MonsterPlanId = 31001,
    },
    [20] = {
        Index = 20,
        Position = Vector3.new(62.2, -0.7, 628.1),
        MonsterPlanId = 31001,
    },
    [21] = {
        Index = 21,
        Position = Vector3.new(243.2, 91.7, 593.4),
        MonsterPlanId = 31001,
    },
    [22] = {
        Index = 22,
        Position = Vector3.new(366.4, 81.7, 449.2),
        MonsterPlanId = 31001,
    },
    [23] = {
        Index = 23,
        Position = Vector3.new(-406.2, -0.7, 561.6),
        MonsterPlanId = 31001,
    },
    [24] = {
        Index = 24,
        Position = Vector3.new(-489.1, -0.7, 146),
        MonsterPlanId = 31001,
    },
    [25] = {
        Index = 25,
        Position = Vector3.new(-405.9, 0.3, 277.2),
        MonsterPlanId = 31001,
    },
    [26] = {
        Index = 26,
        Position = Vector3.new(-418.1, -0.7, 366.4),
        MonsterPlanId = 31001,
    },
    [27] = {
        Index = 27,
        Position = Vector3.new(-66.9, 14, -743.4),
        MonsterPlanId = 31001,
    },
    [28] = {
        Index = 28,
        Position = Vector3.new(-52.8, -0.7, -32.6),
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