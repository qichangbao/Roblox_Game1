
local WeaponConfig = {}

WeaponConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(3, 3, 5),
        ItemId = 201,
        Damage = 20,
    },
    [2] = {
        Index = 2,
        Position = Vector3.new(3, 3, 5),
        ItemId = 202,
        Damage = 10,
    },
    [3] = {
        Index = 3,
        Position = Vector3.new(3, 3, 5),
        ItemId = 203,
        Damage = 10,
    },
}

-- 辅助函数
function WeaponConfig:GetByIndex(index)
    return self.Coordinates[index]
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