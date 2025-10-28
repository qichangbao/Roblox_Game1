
local Shop1Config = {}

Shop1Config.Data = {
    [1] = {
        Index = 1,
        AssetId = 3386566874,
    },
    [2] = {
        Index = 2,
        AssetId = 3386568397,
    },
    [3] = {
        Index = 4,
        AssetId = 3386569943,
    },
    [4] = {
        Index = 5,
        AssetId = 3386571239,
    },
    [5] = {
        Index = 6,
        AssetId = 3386571871,
    },
    [6] = {
        Index = 7,
        AssetId = 3386572591,
    },
    [7] = {
        Index = 8,
        AssetId = 3435990708,
    },
}

-- 辅助函数
function Shop1Config:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function Shop1Config:GetByAssetId(value)
    for i, item in pairs(self.Data) do
        if item.AssetId == value then
            return item
        end
    end
    return nil
end

function Shop1Config:GetAll()
    return self.Data
end

function Shop1Config:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return Shop1Config