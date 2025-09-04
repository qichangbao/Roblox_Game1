--[[
-- 自动生成的Lua配置文件
-- 生成时间: 2025-09-03 18:24:57
-- 源文件: examples\in\Shop1Config.xls
-- 数据维度: 7行 x 2列
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
        Index = 4,
        AssetID = 3386569417,
    },
    [4] = {
        Index = 5,
        AssetID = 3386569943,
    },
    [5] = {
        Index = 8,
        AssetID = 3386571239,
    },
    [6] = {
        Index = 9,
        AssetID = 3386571871,
    },
    [7] = {
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