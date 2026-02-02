
local ConstantConfig = {}

ConstantConfig.Data = {
    [1] = {
        Id = 1,
        Constant = "CopyPersonnelTarget",
        Desc = "副本人员目标系数（人数_系数）",
        Effect1 = {
            {
                1,
                10000
            },
            {
                2,
                11000
            },
            {
                3,
                12000
            },
            {
                4,
                13000
            },
            {
                5,
                15000
            }
        },
    },
    [2] = {
        Id = 2,
        Constant = "VoteFastcCountdown",
        Desc = "玩家投票进入下一层，快速倒计时/秒",
        Effect1 = 30,
    },
    [3] = {
        Id = 3,
        Constant = "InitialHealth",
        Desc = "初始生命",
        Effect1 = 100,
    },
    [4] = {
        Id = 4,
        Constant = "InitialMovementSpeed",
        Desc = "初始移动速度",
        Effect1 = 12,
    },
    [5] = {
        Id = 5,
        Constant = "InitialSprintSpeed",
        Desc = "初始奔跑速度",
        Effect1 = 24,
    },
    [6] = {
        Id = 6,
        Constant = "InitialEndurance",
        Desc = "初始体力",
        Effect1 = 100,
    },
    [7] = {
        Id = 7,
        Constant = "InitialEnduranceConsume",
        Desc = "（体力）耐力消耗",
        Effect1 = 20,
    },
    [8] = {
        Id = 8,
        Constant = "InitialEnduranceRecovery",
        Desc = "（体力）耐力恢复",
        Effect1 = 10,
    },
    [9] = {
        Id = 9,
        Constant = "InitialJumpPower",
        Desc = "跳跃（跳跃高度）",
        Effect1 = 55,
    },
    [10] = {
        Id = 10,
        Constant = "InitiaWeight",
        Desc = "负重",
        Effect1 = 15,
    },
    [11] = {
        Id = 11,
        Constant = "InitiaLucky",
        Desc = "幸运",
        Effect1 = 0,
    },
    [12] = {
        Id = 12,
        Constant = "InitiaCriticalProbability",
        Desc = "暴击率",
        Effect1 = 0.05,
    },
    [13] = {
        Id = 13,
        Constant = "InitiaCriticalValue",
        Desc = "暴击伤害",
        Effect1 = {
            150,
            200
        },
    },
    [14] = {
        Id = 14,
        Constant = "InitialAttack",
        Desc = "初始攻击",
        Effect1 = 5,
    },
}

-- 辅助函数
function ConstantConfig:GetByIndex(index)
    return self.Data[index]
end

function ConstantConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function ConstantConfig:GetByConstant(value)
    for i, item in pairs(self.Data) do
        if item.Constant == value then
            return item
        end
    end
    return nil
end

function ConstantConfig:GetByDesc(value)
    for i, item in pairs(self.Data) do
        if item.Desc == value then
            return item
        end
    end
    return nil
end

function ConstantConfig:GetByEffect1(value)
    for i, item in pairs(self.Data) do
        if item.Effect1 == value then
            return item
        end
    end
    return nil
end

function ConstantConfig:GetAll()
    return self.Data
end

function ConstantConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return ConstantConfig