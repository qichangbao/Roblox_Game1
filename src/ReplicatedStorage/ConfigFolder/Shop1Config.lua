--[[
-- 自动生成的Lua配置文件
-- 生成时间: 2025-08-29 13:32:39
-- 源文件: examples\in\Shop1Config.xls
-- 数据维度: 10行 x 2列
--]]

-- Knit框架兼容的配置模块
local Shop1Config = {}

-- 配置数据
Shop1Config.Data = {
    [1] = {
        Index = 1,
        AssetID = 3386566874,
    },
    [2] = {
        Index = 2,
        AssetID = 3386568397,
    },
    [3] = {
        Index = 3,
        AssetID = 3386569096,
    },
    [4] = {
        Index = 4,
        AssetID = 3386569417,
    },
    [5] = {
        Index = 5,
        AssetID = 3386569943,
    },
    [6] = {
        Index = 6,
        AssetID = 3386570342,
    },
    [7] = {
        Index = 7,
        AssetID = 3386570749,
    },
    [8] = {
        Index = 8,
        AssetID = 3386571239,
    },
    [9] = {
        Index = 9,
        AssetID = 3386571871,
    },
    [10] = {
        Index = 10,
        AssetID = 3386572591,
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

function Shop1Config:GetByAssetID(value)
    for i, item in pairs(self.Data) do
        if item.AssetID == value then
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