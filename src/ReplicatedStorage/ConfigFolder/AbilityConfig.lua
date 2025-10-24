
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
            15,
            30,
            45,
            70
        },
        Icon = "rbxassetid://132844373362963",
        Gold = {
            2000,
            10000,
            50000,
            250000
        },
        NeedItemList = {
            {
                1001,
                1002,
                1014,
                1012
            },
            {
                1010,
                1025,
                1020,
                1018
            },
            {
                1015,
                1030,
                1031,
                1026
            },
            {
                1022,
                1033,
                1034,
                1035
            }
        },
        NeedNumList = {
            {
                2,
                4,
                6,
                8
            },
            {
                2,
                4,
                6,
                8
            },
            {
                1,
                4,
                6,
                8
            },
            {
                1,
                2,
                3,
                4
            }
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
            15,
            30,
            45,
            70
        },
        Icon = "rbxassetid://129227373111985",
        Gold = {
            2000,
            10000,
            50000,
            250000
        },
        NeedItemList = {
            {
                1001,
                1002,
                1014,
                1012
            },
            {
                1010,
                1025,
                1020,
                1018
            },
            {
                1015,
                1030,
                1031,
                1026
            },
            {
                1022,
                1033,
                1034,
                1035
            }
        },
        NeedNumList = {
            {
                2,
                4,
                6,
                8
            },
            {
                2,
                4,
                6,
                8
            },
            {
                1,
                4,
                6,
                8
            },
            {
                1,
                2,
                3,
                4
            }
        },
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
            15,
            30,
            45,
            70
        },
        Icon = "rbxassetid://129701418773918",
        Gold = {
            2000,
            10000,
            50000,
            250000
        },
        NeedItemList = {
            {
                1001,
                1002,
                1014,
                1012
            },
            {
                1010,
                1025,
                1020,
                1018
            },
            {
                1015,
                1030,
                1031,
                1026
            },
            {
                1022,
                1033,
                1034,
                1035
            }
        },
        NeedNumList = {
            {
                2,
                4,
                6,
                8
            },
            {
                2,
                4,
                6,
                8
            },
            {
                1,
                4,
                6,
                8
            },
            {
                1,
                2,
                3,
                4
            }
        },
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
            15,
            30,
            45,
            70
        },
        Icon = "rbxassetid://136616641805670",
        Gold = {
            2000,
            10000,
            50000,
            250000
        },
        NeedItemList = {
            {
                1001,
                1002,
                1014,
                1012
            },
            {
                1010,
                1025,
                1020,
                1018
            },
            {
                1015,
                1030,
                1031,
                1026
            },
            {
                1022,
                1033,
                1034,
                1035
            }
        },
        NeedNumList = {
            {
                2,
                4,
                6,
                8
            },
            {
                2,
                4,
                6,
                8
            },
            {
                1,
                4,
                6,
                8
            },
            {
                1,
                2,
                3,
                4
            }
        },
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

function AbilityConfig:GetByGold(value)
    for i, item in pairs(self.Data) do
        if item.Gold == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedItemList(value)
    for i, item in pairs(self.Data) do
        if item.NeedItemList == value then
            return item
        end
    end
    return nil
end

function AbilityConfig:GetByNeedNumList(value)
    for i, item in pairs(self.Data) do
        if item.NeedNumList == value then
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