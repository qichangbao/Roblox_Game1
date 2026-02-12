
local WeaponConfig = {}

WeaponConfig.Data = {
    [1] = {
        ItemId = 201,
        Type = 1,
        Damage = 20,
        ["X-Axis"] = 3,
        ["Y-Axis"] = 3,
        ["Z-Axis"] = 5,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [2] = {
        ItemId = 202,
        Type = 1,
        Damage = 10,
        ["X-Axis"] = 3,
        ["Y-Axis"] = 3,
        ["Z-Axis"] = 5,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [3] = {
        ItemId = 203,
        Type = 2,
        Damage = 10,
        ["X-Axis"] = 3,
        ["Y-Axis"] = 3,
        ["Z-Axis"] = 5,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [4] = {
        ItemId = 204,
        Type = 1,
        Damage = 10,
        ["X-Axis"] = 3,
        ["Y-Axis"] = 3,
        ["Z-Axis"] = 5,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [5] = {
        ItemId = 205,
        Type = 1,
        Damage = 10,
        ["X-Axis"] = 3,
        ["Y-Axis"] = 3,
        ["Z-Axis"] = 5,
        Bullet = nil,
        BulletSpeed = nil,
        MaxDistance = nil,
    },
    [6] = {
        ItemId = 206,
        Type = 3,
        Damage = 10,
        ["X-Axis"] = nil,
        ["Y-Axis"] = nil,
        ["Z-Axis"] = nil,
        Bullet = "子弹1",
        BulletSpeed = 200,
        MaxDistance = 500,
    },
}

-- 辅助函数
function WeaponConfig:GetByIndex(index)
    return self.Data[index]
end

function WeaponConfig:GetByItemId(value)
    for i, item in pairs(self.Data) do
        if item.ItemId == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByDamage(value)
    for i, item in pairs(self.Data) do
        if item.Damage == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByBullet(value)
    for i, item in pairs(self.Data) do
        if item.Bullet == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByBulletSpeed(value)
    for i, item in pairs(self.Data) do
        if item.BulletSpeed == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetByMaxDistance(value)
    for i, item in pairs(self.Data) do
        if item.MaxDistance == value then
            return item
        end
    end
    return nil
end

function WeaponConfig:GetAll()
    return self.Data
end

function WeaponConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function WeaponConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return WeaponConfig