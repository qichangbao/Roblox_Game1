--[[
-- 自动生成的Lua配置文件
-- 生成时间: 2025-09-16 22:56:43
-- 源文件: examples\in\WeaponConfig.xls
-- 数据维度: 1行 x 5列
--]]

-- Knit框架兼容的配置模块
local WeaponConfig = {}

-- 坐标配置数据
WeaponConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(3, 3, 3),
        ItemId = 10001,
        Damage = 20,
    },
}

-- 辅助函数
function WeaponConfig:GetByIndex(index)
    for i, item in pairs(self.Coordinates) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByItemId(value)
    for i, item in pairs(self.Coordinates) do
        if item.ItemId == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByDamage(value)
    for i, item in pairs(self.Coordinates) do
        if item.Damage == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetAll()
    return self.Coordinates
end

function WeaponConfig:GetCount()
    local count = 0
    for _ in pairs(self.Coordinates) do
        count = count + 1
    end
    return count
end

return WeaponConfig