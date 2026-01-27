
local WeaponConfig = {}

WeaponConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(3, 3, 5),
        ItemId = 201,
        Type = 1,
        Damage = 20,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [2] = {
        Index = 2,
        Position = Vector3.new(3, 3, 5),
        ItemId = 202,
        Type = 1,
        Damage = 10,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [3] = {
        Index = 3,
        Position = Vector3.new(3, 3, 5),
        ItemId = 203,
        Type = 2,
        Damage = 10,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [4] = {
        Index = 4,
        Position = Vector3.new(3, 3, 5),
        ItemId = 204,
        Type = 1,
        Damage = 10,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [5] = {
        Index = 5,
        Position = Vector3.new(3, 3, 5),
        ItemId = 205,
        Type = 1,
        Damage = 10,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [6] = {
        Index = 6,
        Position = Vector3.new(0, 0, 0),
        ItemId = 206,
        Type = 3,
        Damage = 10,
        Bullet = "子弹1",
        BulletSpeed = 200,
        MaxDistance = 500,
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

function WeaponConfig:GetByType(value)
    for i, item in pairs(self.Coordinates) do
        if item.Type == value then
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

function WeaponConfig:GetByBullet(value)
    for i, item in pairs(self.Coordinates) do
        if item.Bullet == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByBulletSpeed(value)
    for i, item in pairs(self.Coordinates) do
        if item.BulletSpeed == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByMaxDistance(value)
    for i, item in pairs(self.Coordinates) do
        if item.MaxDistance == value then
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

function WeaponConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Coordinates) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return WeaponConfig