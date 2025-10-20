
local WeaponConfig = {}

WeaponConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(3, 3, 3),
        ItemId = 1,
        Damage = 20,
    },
    [2] = {
        Index = 2,
        Position = Vector3.new(3, 3, 3),
        ItemId = 4,
        Damage = 10,
    },
    [3] = {
        Index = 3,
        Position = Vector3.new(3, 3, 3),
        ItemId = 8,
        Damage = 10,
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