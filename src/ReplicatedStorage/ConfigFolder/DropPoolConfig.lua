
local DropPoolConfig = {}

DropPoolConfig.Data = {
    [1] = {
        Id = 1,
        DropType = 1,
        Weight = {
            {
                1,
                6000
            },
            {
                2,
                3500
            }
        },
    },
    [2] = {
        Id = 2,
        DropType = 1,
        Weight = {
            {
                3,
                6000
            },
            {
                4,
                3500
            }
        },
    },
}

-- 辅助函数
function DropPoolConfig:GetByIndex(index)
    return self.Data[index]
end

function DropPoolConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function DropPoolConfig:GetByDropType(value)
    for i, item in pairs(self.Data) do
        if item.DropType == value then
            return item
        end
    end
    return nil
end

function DropPoolConfig:GetByWeight(value)
    for i, item in pairs(self.Data) do
        if item.Weight == value then
            return item
        end
    end
    return nil
end

function DropPoolConfig:GetAll()
    return self.Data
end

function DropPoolConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return DropPoolConfig