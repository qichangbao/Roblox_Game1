
local AttributeConfig = {}

AttributeConfig.Data = {
    [1] = {
        Id = 1001,
        DisplayName = "攻击",
        AttributeType = 1,
        NumValueType = 1,
    },
    [2] = {
        Id = 1002,
        DisplayName = "生命",
        AttributeType = 1,
        NumValueType = 1,
    },
    [3] = {
        Id = 1003,
        DisplayName = "体力",
        AttributeType = 1,
        NumValueType = 1,
    },
    [4] = {
        Id = 1004,
        DisplayName = "移动速度",
        AttributeType = 1,
        NumValueType = 1,
    },
    [5] = {
        Id = 1005,
        DisplayName = "（体力）耐力恢复",
        AttributeType = 1,
        NumValueType = 1,
    },
    [6] = {
        Id = 1006,
        DisplayName = "攻击速度(每秒攻击X次）",
        AttributeType = 1,
        NumValueType = 1,
    },
    [7] = {
        Id = 1007,
        DisplayName = "攻击范围",
        AttributeType = 1,
        NumValueType = 1,
    },
    [8] = {
        Id = 1008,
        DisplayName = "跳跃（跳跃高度）",
        AttributeType = 1,
        NumValueType = 1,
    },
    [9] = {
        Id = 1009,
        DisplayName = "负重",
        AttributeType = 1,
        NumValueType = 1,
    },
    [10] = {
        Id = 1010,
        DisplayName = "幸运",
        AttributeType = 1,
        NumValueType = 1,
    },
    [11] = {
        Id = 2001,
        DisplayName = "攻击加成",
        AttributeType = 1,
        NumValueType = 2,
    },
    [12] = {
        Id = 2002,
        DisplayName = "生命加成",
        AttributeType = 1,
        NumValueType = 2,
    },
    [13] = {
        Id = 2003,
        DisplayName = "体力加成",
        AttributeType = 1,
        NumValueType = 2,
    },
    [14] = {
        Id = 2004,
        DisplayName = "移动速度加成",
        AttributeType = 1,
        NumValueType = 2,
    },
    [15] = {
        Id = 2005,
        DisplayName = "暴击率",
        AttributeType = 1,
        NumValueType = 2,
    },
    [16] = {
        Id = 2006,
        DisplayName = "暴击伤害",
        AttributeType = 1,
        NumValueType = 2,
    },
}

-- 辅助函数
function AttributeConfig:GetByIndex(index)
    return self.Data[index]
end

function AttributeConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function AttributeConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function AttributeConfig:GetByAttributeType(value)
    for i, item in pairs(self.Data) do
        if item.AttributeType == value then
            return item
        end
    end
    return nil
end

function AttributeConfig:GetByNumValueType(value)
    for i, item in pairs(self.Data) do
        if item.NumValueType == value then
            return item
        end
    end
    return nil
end

function AttributeConfig:GetAll()
    return self.Data
end

function AttributeConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return AttributeConfig