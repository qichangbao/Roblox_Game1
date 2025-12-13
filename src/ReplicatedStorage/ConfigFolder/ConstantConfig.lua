
local ConstantConfig = {}

ConstantConfig.Data = {
    [1] = {
        ID = 1,
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
        ID = 2,
        Constant = "RunValue",
        Desc = "奔跑值",
        Effect1 = 100,
    },
    [3] = {
        ID = 3,
        Constant = "RunRecoverEfficiency",
        Desc = "奔跑恢复效率（秒_奔跑值）",
        Effect1 = {
            1,
            10
        },
    },
}

-- 辅助函数
function ConstantConfig:GetByIndex(index)
    return self.Data[index]
end

function ConstantConfig:GetByID(value)
    for i, item in pairs(self.Data) do
        if item.ID == value then
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