
local TalentTreeConfig = {}

TalentTreeConfig.Data = {
    [1] = {
        TalentTreeId = 8001,
        NextTalent = 8002,
        DisplayName = "Carry Capacity 1",
        Description = "Max Carry Capacity +3",
        Type = 4,
        ChildType = 2,
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
    },
    [2] = {
        TalentTreeId = 8002,
        NextTalent = {
            8003,
            8004
        },
        DisplayName = "Health 1",
        Description = "Max HP +10",
        Type = 2,
        ChildType = 2,
        Value = 10,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [3] = {
        TalentTreeId = 8003,
        NextTalent = 8005,
        DisplayName = "Movement Speed 1",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [4] = {
        TalentTreeId = 8004,
        NextTalent = 8005,
        DisplayName = "Jump Power 1",
        Description = "Max Jump Power +2",
        Type = 3,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [5] = {
        TalentTreeId = 8005,
        NextTalent = {
            8006,
            8007,
            8008
        },
        DisplayName = "Luck 1",
        Description = "Luck +1",
        Type = 6,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [6] = {
        TalentTreeId = 8006,
        NextTalent = 8009,
        DisplayName = "Explorer",
        Description = "Max Carry Capacity +10",
        Type = 4,
        ChildType = 2,
        Value = 10,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [7] = {
        TalentTreeId = 8007,
        NextTalent = 8010,
        DisplayName = "Battle Master",
        Description = "Crit Chance +30%",
        Type = 5,
        ChildType = 1,
        Value = 0.3,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [8] = {
        TalentTreeId = 8008,
        NextTalent = 8011,
        DisplayName = "Survivor",
        Description = "Max HP +20",
        Type = 2,
        ChildType = 2,
        Value = 20,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [9] = {
        TalentTreeId = 8009,
        NextTalent = 8012,
        DisplayName = "slot",
        Description = "Permanently unlock 1 slot",
        Type = 7,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [10] = {
        TalentTreeId = 8010,
        NextTalent = 8029,
        DisplayName = "No Retreat",
        Description = "+50% Attack Speed when HP is below 30%",
        Type = 9,
        ChildType = 0,
        Value = 0,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [11] = {
        TalentTreeId = 8011,
        NextTalent = nil,
        DisplayName = "Life Siphon",
        Description = "Restore 1 HP per loot collected",
        Type = 8,
        ChildType = 0,
        Value = 0,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [12] = {
        TalentTreeId = 8012,
        NextTalent = 8013,
        DisplayName = "Movement Speed 2",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [13] = {
        TalentTreeId = 8013,
        NextTalent = 8014,
        DisplayName = "Luck 2",
        Description = "Luck +1",
        Type = 6,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [14] = {
        TalentTreeId = 8014,
        NextTalent = 8015,
        DisplayName = "Carry Capacity 2",
        Description = "Max Carry Capacity +3",
        Type = 4,
        ChildType = 2,
        Value = 3,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [15] = {
        TalentTreeId = 8015,
        NextTalent = 8016,
        DisplayName = "Movement Speed 3",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [16] = {
        TalentTreeId = 8016,
        NextTalent = 8017,
        DisplayName = "Luck 3",
        Description = "Luck +1",
        Type = 6,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [17] = {
        TalentTreeId = 8017,
        NextTalent = 8018,
        DisplayName = "Carry Capacity 3",
        Description = "Max Carry Capacity +3",
        Type = 4,
        ChildType = 2,
        Value = 3,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [18] = {
        TalentTreeId = 8018,
        NextTalent = 8019,
        DisplayName = "Movement Speed 4",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [19] = {
        TalentTreeId = 8019,
        NextTalent = 8020,
        DisplayName = "Luck 4",
        Description = "Luck +1",
        Type = 6,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [20] = {
        TalentTreeId = 8020,
        NextTalent = 8021,
        DisplayName = "Carry Capacity 4",
        Description = "Max Carry Capacity +5",
        Type = 4,
        ChildType = 2,
        Value = 5,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [21] = {
        TalentTreeId = 8021,
        NextTalent = 8022,
        DisplayName = "Movement Speed 5",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [22] = {
        TalentTreeId = 8022,
        NextTalent = 8023,
        DisplayName = "Luck 5",
        Description = "Luck +1",
        Type = 6,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [23] = {
        TalentTreeId = 8023,
        NextTalent = 8024,
        DisplayName = "Carry Capacity 5",
        Description = "Max Carry Capacity +5",
        Type = 4,
        ChildType = 2,
        Value = 5,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [24] = {
        TalentTreeId = 8024,
        NextTalent = 8025,
        DisplayName = "Movement Speed 6",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [25] = {
        TalentTreeId = 8025,
        NextTalent = 8026,
        DisplayName = "Luck 6",
        Description = "Luck +1",
        Type = 6,
        ChildType = 2,
        Value = 1,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [26] = {
        TalentTreeId = 8026,
        NextTalent = 8027,
        DisplayName = "Carry Capacity 6",
        Description = "Max Carry Capacity +8",
        Type = 4,
        ChildType = 2,
        Value = 8,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [27] = {
        TalentTreeId = 8027,
        NextTalent = 8028,
        DisplayName = "Movement Speed 7",
        Description = "Max Movement Speed +2",
        Type = 1,
        ChildType = 2,
        Value = 4,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [28] = {
        TalentTreeId = 8028,
        NextTalent = 0,
        DisplayName = "Luck 7",
        Description = "Luck +2",
        Type = 6,
        ChildType = 2,
        Value = 2,
        Icon = "rbxassetid://132844373362963",
        Need = nil,
    },
    [29] = {
        TalentTreeId = 8029,
        NextTalent = nil,
        DisplayName = nil,
        Description = nil,
        Type = nil,
        ChildType = nil,
        Value = nil,
        Icon = nil,
        Need = nil,
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

function TalentTreeConfig:GetByNextTalent(value)
    for i, item in pairs(self.Data) do
        if item.NextTalent == value then
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