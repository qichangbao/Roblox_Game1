
local TalentTreeConfig = {}

TalentTreeConfig.Data = {
    [1] = {
        TalentTreeId = 8001,
        Type = 1,
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
        ChildType = 1,
        DisplayName = "Gathering 1",
        Description = nil,
        Value = 5,
        Icon = nil,
        Need = nil,
        NextTalent = {
            8003,
            8004
        },
    },
    [3] = {
        TalentTreeId = 8003,
        Type = 3,
        ChildType = 1,
        DisplayName = "Movement Speed 1",
        Description = nil,
        Value = nil,
        Icon = nil,
        Need = nil,
        NextTalent = 8005,
    },
    [4] = {
        TalentTreeId = 8004,
        Type = 1,
        ChildType = 2,
        DisplayName = "Carry Capacity 2",
        Description = nil,
        Value = nil,
        Icon = nil,
        Need = nil,
        NextTalent = 8006,
    },
    [5] = {
        TalentTreeId = 8005,
        Type = 4,
        ChildType = 1,
        DisplayName = "Luck 1",
        Description = nil,
        Value = nil,
        Icon = nil,
        Need = nil,
        NextTalent = nil,
    },
    [6] = {
        TalentTreeId = 8006,
        Type = 4,
        ChildType = 1,
        DisplayName = "Luck 1",
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