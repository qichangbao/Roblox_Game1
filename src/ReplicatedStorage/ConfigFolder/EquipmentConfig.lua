
local EquipmentConfig = {}

EquipmentConfig.Data = {
    [1] = {
        EquipId = 901,
        Type = 1,
        DisplayName = "衣服",
        Quality = 1,
        IconId = "rbxassetid://108864196858289",
        AssetId = "rbxassetid://2067610595",
    },
    [2] = {
        EquipId = 902,
        Type = 2,
        DisplayName = "裤子",
        Quality = 1,
        IconId = "rbxassetid://108864196858289",
        AssetId = "rbxassetid://2067611839",
    },
    [3] = {
        EquipId = 903,
        Type = 3,
        DisplayName = "帽子",
        Quality = 1,
        IconId = "rbxassetid://108864196858289",
        AssetId = 1,
    },
}

-- 辅助函数
function EquipmentConfig:GetByIndex(index)
    return self.Data[index]
end

function EquipmentConfig:GetByEquipId(value)
    for i, item in pairs(self.Data) do
        if item.EquipId == value then
            return item
        end
    end
    return nil
end

function EquipmentConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function EquipmentConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function EquipmentConfig:GetByQuality(value)
    for i, item in pairs(self.Data) do
        if item.Quality == value then
            return item
        end
    end
    return nil
end

function EquipmentConfig:GetByIconId(value)
    for i, item in pairs(self.Data) do
        if item.IconId == value then
            return item
        end
    end
    return nil
end

function EquipmentConfig:GetByAssetId(value)
    for i, item in pairs(self.Data) do
        if item.AssetId == value then
            return item
        end
    end
    return nil
end

function EquipmentConfig:GetAll()
    return self.Data
end

function EquipmentConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function EquipmentConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return EquipmentConfig