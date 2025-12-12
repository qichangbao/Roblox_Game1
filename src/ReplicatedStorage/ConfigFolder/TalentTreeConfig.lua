
local TalentTreeConfig = {}

TalentTreeConfig.Data = {
    [1] = {
        TalentTreeId = 8001,
        Type = 4,
        ChildType = 2,
        DisplayName = "Carry Capacity 1",
        Description = "Max Carry Capacity +3",
        Value = 3,
        Icon = "rbxassetid://132844373362963",
        Need = {
            {
                Item = 1002,
                Num = 1
            },
            {
                Item = 1004,
                Num = 3
            },
            {
                Gold = 2000
            }
        },
        NextTalent = 8002,
    },
    [2] = {
        TalentTreeId = 8002,
        Type = 2,
        ChildType = 2,
        DisplayName = "Health 1",
        Description = "Max HP +10",
        Value = 10,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = {
            8003,
            8004
        },
    },
    [3] = {
        TalentTreeId = 8003,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 1",
        Description = "Max Movement Speed +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8005,
    },
    [4] = {
        TalentTreeId = 8004,
        Type = 3,
        ChildType = 2,
        DisplayName = "Jump Power 1",
        Description = "Max Jump Power +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8005,
    },
    [5] = {
        TalentTreeId = 8005,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 1",
        Description = "Luck +1",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = {
            8006,
            8007,
            8008
        },
    },
    [6] = {
        TalentTreeId = 8006,
        Type = 4,
        ChildType = 2,
        DisplayName = "Explorer",
        Description = "Max Carry Capacity +10",
        Value = 10,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8009,
    },
    [7] = {
        TalentTreeId = 8007,
        Type = 5,
        ChildType = 1,
        DisplayName = "Battle Master",
        Description = "Crit Chance +30%",
        Value = 0.3,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8010,
    },
    [8] = {
        TalentTreeId = 8008,
        Type = 2,
        ChildType = 2,
        DisplayName = "Survivor",
        Description = "Max HP +20",
        Value = 20,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8011,
    },
    [9] = {
        TalentTreeId = 8009,
        Type = 7,
        ChildType = 2,
        DisplayName = "slot",
        Description = "Permanently unlock 1 slot",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8012,
    },
    [10] = {
        TalentTreeId = 8010,
        Type = 9,
        ChildType = 0,
        DisplayName = "No Retreat",
        Description = "+50% Attack Speed when HP is below 30%",
        Value = 0,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8029,
    },
    [11] = {
        TalentTreeId = 8011,
        Type = 8,
        ChildType = 0,
        DisplayName = "Life Siphon",
        Description = "Restore 1 HP per loot collected",
        Value = 0,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = nil,
    },
    [12] = {
        TalentTreeId = 8012,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 2",
        Description = "Max Movement Speed +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8013,
    },
    [13] = {
        TalentTreeId = 8013,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 2",
        Description = "Luck +1",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8014,
    },
    [14] = {
        TalentTreeId = 8014,
        Type = 4,
        ChildType = 2,
        DisplayName = "Carry Capacity 2",
        Description = "Max Carry Capacity +3",
        Value = 3,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8015,
    },
    [15] = {
        TalentTreeId = 8015,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 3",
        Description = "Max Movement Speed +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8016,
    },
    [16] = {
        TalentTreeId = 8016,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 3",
        Description = "Luck +1",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8017,
    },
    [17] = {
        TalentTreeId = 8017,
        Type = 4,
        ChildType = 2,
        DisplayName = "Carry Capacity 3",
        Description = "Max Carry Capacity +3",
        Value = 3,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8018,
    },
    [18] = {
        TalentTreeId = 8018,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 4",
        Description = "Max Movement Speed +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8019,
    },
    [19] = {
        TalentTreeId = 8019,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 4",
        Description = "Luck +1",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8020,
    },
    [20] = {
        TalentTreeId = 8020,
        Type = 4,
        ChildType = 2,
        DisplayName = "Carry Capacity 4",
        Description = "Max Carry Capacity +5",
        Value = 5,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8021,
    },
    [21] = {
        TalentTreeId = 8021,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 5",
        Description = "Max Movement Speed +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8022,
    },
    [22] = {
        TalentTreeId = 8022,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 5",
        Description = "Luck +1",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8023,
    },
    [23] = {
        TalentTreeId = 8023,
        Type = 4,
        ChildType = 2,
        DisplayName = "Carry Capacity 5",
        Description = "Max Carry Capacity +5",
        Value = 5,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8024,
    },
    [24] = {
        TalentTreeId = 8024,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 6",
        Description = "Max Movement Speed +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8025,
    },
    [25] = {
        TalentTreeId = 8025,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 6",
        Description = "Luck +1",
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8026,
    },
    [26] = {
        TalentTreeId = 8026,
        Type = 4,
        ChildType = 2,
        DisplayName = "Carry Capacity 6",
        Description = "Max Carry Capacity +8",
        Value = 8,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8027,
    },
    [27] = {
        TalentTreeId = 8027,
        Type = 1,
        ChildType = 2,
        DisplayName = "Movement Speed 7",
        Description = "Max Movement Speed +2",
        Value = 4,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 8028,
    },
    [28] = {
        TalentTreeId = 8028,
        Type = 6,
        ChildType = 2,
        DisplayName = "Luck 7",
        Description = "Luck +2",
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
        NextTalent = 0,
    },
    [29] = {
        TalentTreeId = 8029,
        Type = nil,
        ChildType = nil,
        DisplayName = nil,
        Description = nil,
        Value = nil,
        Icon = nil,
        Need = nil,
        NextTalent = nil,
    },
}

-- 辅助函数
function TalentTreeConfig:GetByIndex(index)
    return self.Data[index]
end

function TalentTreeConfig:GetByTalentTreeId(value)
    for i, item in pairs(self.Data) do
        if item.TalentTreeId == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByChildType(value)
    for i, item in pairs(self.Data) do
        if item.ChildType == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByDescription(value)
    for i, item in pairs(self.Data) do
        if item.Description == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByValue(value)
    for i, item in pairs(self.Data) do
        if item.Value == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByIcon(value)
    for i, item in pairs(self.Data) do
        if item.Icon == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByNeed(value)
    for i, item in pairs(self.Data) do
        if item.Need == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetByNextTalent(value)
    for i, item in pairs(self.Data) do
        if item.NextTalent == value then
            return item
        end
    end
    return nil
end

function TalentTreeConfig:GetAll()
    return self.Data
end

function TalentTreeConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function TalentTreeConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return TalentTreeConfig