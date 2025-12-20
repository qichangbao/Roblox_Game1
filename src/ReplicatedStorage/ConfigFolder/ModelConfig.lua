
local ModelConfig = {}

ModelConfig.Data = {
    [1] = {
        ModelId = 1,
        Name = "大天使之剑",
        Clothes = 1000,
        Trousers = 2000,
        Accessories1 = 100,
        Accessories2 = 101,
        Accessories3 = 102,
        Accessories4 = 103,
        Accessories5 = 104,
        Accessories6 = 105,
        Accessories7 = nil,
        Accessories8 = nil,
        Accessories9 = nil,
        Accessories10 = nil,
    },
    [2] = {
        ModelId = 2,
        Name = "XX",
        Clothes = 1000,
        Trousers = 2000,
        Accessories1 = 101,
        Accessories2 = 103,
        Accessories3 = 104,
        Accessories4 = nil,
        Accessories5 = nil,
        Accessories6 = nil,
        Accessories7 = nil,
        Accessories8 = nil,
        Accessories9 = nil,
        Accessories10 = nil,
    },
}

-- 辅助函数
function ModelConfig:GetByIndex(index)
    return self.Data[index]
end

function ModelConfig:GetByModelId(value)
    for i, item in pairs(self.Data) do
        if item.ModelId == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByName(value)
    for i, item in pairs(self.Data) do
        if item.Name == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByClothes(value)
    for i, item in pairs(self.Data) do
        if item.Clothes == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByTrousers(value)
    for i, item in pairs(self.Data) do
        if item.Trousers == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories1(value)
    for i, item in pairs(self.Data) do
        if item.Accessories1 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories2(value)
    for i, item in pairs(self.Data) do
        if item.Accessories2 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories3(value)
    for i, item in pairs(self.Data) do
        if item.Accessories3 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories4(value)
    for i, item in pairs(self.Data) do
        if item.Accessories4 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories5(value)
    for i, item in pairs(self.Data) do
        if item.Accessories5 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories6(value)
    for i, item in pairs(self.Data) do
        if item.Accessories6 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories7(value)
    for i, item in pairs(self.Data) do
        if item.Accessories7 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories8(value)
    for i, item in pairs(self.Data) do
        if item.Accessories8 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories9(value)
    for i, item in pairs(self.Data) do
        if item.Accessories9 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetByAccessories10(value)
    for i, item in pairs(self.Data) do
        if item.Accessories10 == value then
            return item
        end
    end
    return nil
end

function ModelConfig:GetAll()
    return self.Data
end

function ModelConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return ModelConfig