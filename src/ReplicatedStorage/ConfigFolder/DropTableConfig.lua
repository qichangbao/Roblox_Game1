
local DropTableConfig = {}

DropTableConfig.Data = {
    [1] = {
        Id = 1,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                101,
                1,
                1000
            },
            {
                102,
                1,
                1000
            }
        },
    },
    [2] = {
        Id = 2,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                101,
                1,
                1000
            },
            {
                102,
                1,
                1000
            }
        },
    },
    [3] = {
        Id = 3,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                201,
                1,
                1000
            },
            {
                202,
                1,
                1000
            }
        },
    },
    [4] = {
        Id = 4,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                201,
                1,
                1000
            },
            {
                202,
                1,
                1000
            }
        },
    },
}

-- 辅助函数
function DropTableConfig:GetByIndex(index)
    return self.Data[index]
end

function DropTableConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByMinDrop(value)
    for i, item in pairs(self.Data) do
        if item.MinDrop == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByMaxDrop(value)
    for i, item in pairs(self.Data) do
        if item.MaxDrop == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByDropInfo(value)
    for i, item in pairs(self.Data) do
        if item.DropInfo == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetAll()
    return self.Data
end

function DropTableConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function DropTableConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return DropTableConfig