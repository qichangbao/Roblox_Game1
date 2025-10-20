
local AbilityConfig = {}

AbilityConfig.Data = {
    [1] = {
        AbilityId = 1,
        Level = {
            1,
            2,
            3,
            4
        },
        Type = 1,
        DisplayName = "Haste",
        Description = "Increase Movement Speed",
        Value = {
            0.15,
            0.3,
            0.45,
            0.7
        },
        Icon = "rbxassetid://132844373362963",
        NeedItem1 = {
            1001,
            1002,
            1014,
            1012
        },
        NeedNum1 = {
            2,
            4,
            6,
            8
        },
        NeedItem2 = {
            1010,
            1025,
            1020,
            1018
        },
        NeedNum2 = {
            2,
            4,
            6,
            8
        },
        NeedItem3 = {
            1015,
            1030,
            1031,
            1026
        },
        NeedNum3 = {
            1,
            4,
            6,
            8
        },
        NeedItem4 = {
            1022,
            1033,
            1034,
            1035
        },
        NeedNum4 = {
            1,
            2,
            3,
            4
        },
        Gold = {
            2000,
            10000,
            50000,
            250000
        },
    },
    [2] = {
        AbilityId = 2,
        Level = {
            1,
            2,
            3,
            4
        },
        Type = 2,
        DisplayName = "Health",
        Description = "Increase Maximum Health",
        Value = {
            0.15,
            0.3,
            0.45,
            0.7
        },
        Icon = "rbxassetid://129227373111985",
        NeedItem1 = nil,
        NeedNum1 = nil,
        NeedItem2 = nil,
        NeedNum2 = nil,
        NeedItem3 = nil,
        NeedNum3 = nil,
        NeedItem4 = nil,
        NeedNum4 = nil,
        Gold = nil,
    },
    [3] = {
        AbilityId = 3,
        Level = {
            1,
            2,
            3,
            4
        },
        Type = 3,
        DisplayName = "Bounce",
        Description = "Increase Jump Height",
        Value = {
            0.15,
            0.3,
            0.45,
            0.7
        },
        Icon = "rbxassetid://129701418773918",
        NeedItem1 = nil,
        NeedNum1 = nil,
        NeedItem2 = nil,
        NeedNum2 = nil,
        NeedItem3 = nil,
        NeedNum3 = nil,
        NeedItem4 = nil,
        NeedNum4 = nil,
        Gold = nil,
    },
    [4] = {
        AbilityId = 4,
        Level = {
            1,
            2,
            3,
            4
        },
        Type = 4,
        DisplayName = "Damage",
        Description = "Increase Damage",
        Value = {
            0.15,
            0.3,
            0.45,
            0.7
        },
        Icon = "rbxassetid://136616641805670",
        NeedItem1 = nil,
        NeedNum1 = nil,
        NeedItem2 = nil,
        NeedNum2 = nil,
        NeedItem3 = nil,
        NeedNum3 = nil,
        NeedItem4 = nil,
        NeedNum4 = nil,
        Gold = nil,
    },
}

-- 辅助函数
function AbilityConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByAbilityId(value)
    for i, item in pairs(self.Data) do
        if item.AbilityId == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByLevel(value)
    for i, item in pairs(self.Data) do
        if item.Level == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByDescription(value)
    for i, item in pairs(self.Data) do
        if item.Description == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByValue(value)
    for i, item in pairs(self.Data) do
        if item.Value == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByIcon(value)
    for i, item in pairs(self.Data) do
        if item.Icon == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedItem1(value)
    for i, item in pairs(self.Data) do
        if item.NeedItem1 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedNum1(value)
    for i, item in pairs(self.Data) do
        if item.NeedNum1 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedItem2(value)
    for i, item in pairs(self.Data) do
        if item.NeedItem2 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedNum2(value)
    for i, item in pairs(self.Data) do
        if item.NeedNum2 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedItem3(value)
    for i, item in pairs(self.Data) do
        if item.NeedItem3 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedNum3(value)
    for i, item in pairs(self.Data) do
        if item.NeedNum3 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedItem4(value)
    for i, item in pairs(self.Data) do
        if item.NeedItem4 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedNum4(value)
    for i, item in pairs(self.Data) do
        if item.NeedNum4 == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByGold(value)
    for i, item in pairs(self.Data) do
        if item.Gold == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetAll()
    return self.Data
end

function AbilityConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function AbilityConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return AbilityConfig