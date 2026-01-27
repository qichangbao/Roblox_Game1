
local DesignResConfig = {}

DesignResConfig.Coordinates = {
    [1] = {
        Index = 1,
        Position = Vector3.new(98.2, 13.2, -33),
        PosId = 1,
        MapId = 100,
        Resource = 1,
        Refresh = 1,
        GoldRange = {
    1,
    5
},
        DropGroup = nil,
        CanisterId = nil,
    },
    [2] = {
        Index = 2,
        Position = Vector3.new(100.4, 13.2, 11),
        PosId = 2,
        MapId = 100,
        Resource = 1,
        Refresh = 1,
        GoldRange = {
    5,
    10
},
        DropGroup = nil,
        CanisterId = nil,
    },
    [3] = {
        Index = 3,
        Position = Vector3.new(49.5, 13.5, 13.5),
        PosId = 3,
        MapId = 100,
        Resource = 1,
        Refresh = 2,
        GoldRange = {
    10,
    15
},
        DropGroup = nil,
        CanisterId = nil,
    },
    [4] = {
        Index = 4,
        Position = Vector3.new(38.2, 13.3, -25.3),
        PosId = 4,
        MapId = 100,
        Resource = 1,
        Refresh = 2,
        GoldRange = {
    10,
    15
},
        DropGroup = nil,
        CanisterId = nil,
    },
    [5] = {
        Index = 5,
        Position = Vector3.new(-6.4, 13.4, 14.3),
        PosId = 5,
        MapId = 100,
        Resource = 1,
        Refresh = 2,
        GoldRange = {
    10,
    15
},
        DropGroup = nil,
        CanisterId = nil,
    },
    [6] = {
        Index = 6,
        Position = Vector3.new(-46.5, 12.9, -28.7),
        PosId = 6,
        MapId = 100,
        Resource = 2,
        Refresh = 1,
        GoldRange = nil,
        DropGroup = 1,
        CanisterId = 501,
    },
    [7] = {
        Index = 7,
        Position = Vector3.new(-17.1, 13.2, 60.7),
        PosId = 7,
        MapId = 100,
        Resource = 2,
        Refresh = 1,
        GoldRange = nil,
        DropGroup = 2,
        CanisterId = 501,
    },
    [8] = {
        Index = 8,
        Position = Vector3.new(-38.7, 12.9, 59.8),
        PosId = 8,
        MapId = 100,
        Resource = 2,
        Refresh = 2,
        GoldRange = nil,
        DropGroup = 1,
        CanisterId = 501,
    },
    [9] = {
        Index = 9,
        Position = Vector3.new(-90, 13.2, 7.2),
        PosId = 9,
        MapId = 100,
        Resource = 2,
        Refresh = 2,
        GoldRange = nil,
        DropGroup = 2,
        CanisterId = 501,
    },
    [10] = {
        Index = 10,
        Position = Vector3.new(-83.6, 12.9, -13.9),
        PosId = 10,
        MapId = 100,
        Resource = 2,
        Refresh = 2,
        GoldRange = nil,
        DropGroup = 1,
        CanisterId = 502,
    },
    [11] = {
        Index = 11,
        Position = Vector3.new(-36.8, 13.1, -75.4),
        PosId = 11,
        MapId = 100,
        Resource = 3,
        Refresh = 1,
        GoldRange = nil,
        DropGroup = 1,
        CanisterId = 502,
    },
    [12] = {
        Index = 12,
        Position = Vector3.new(-14.5, 12.9, -67.6),
        PosId = 12,
        MapId = 100,
        Resource = 4,
        Refresh = 1,
        GoldRange = nil,
        DropGroup = 2,
        CanisterId = 503,
    },
}

-- 辅助函数
function DesignResConfig:GetByIndex(index)
    return self.Coordinates[index]
end

function DesignResConfig:GetByPosId(value)
    for i, item in pairs(self.Coordinates) do
        if item.PosId == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetByMapId(value)
    for i, item in pairs(self.Coordinates) do
        if item.MapId == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetByResource(value)
    for i, item in pairs(self.Coordinates) do
        if item.Resource == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetByRefresh(value)
    for i, item in pairs(self.Coordinates) do
        if item.Refresh == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetByGoldRange(value)
    for i, item in pairs(self.Coordinates) do
        if item.GoldRange == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetByDropGroup(value)
    for i, item in pairs(self.Coordinates) do
        if item.DropGroup == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetByCanisterId(value)
    for i, item in pairs(self.Coordinates) do
        if item.CanisterId == value then
            return item
        end
    end
    return nil
end

function DesignResConfig:GetAll()
    return self.Coordinates
end

function DesignResConfig:GetCount()
    local count = 0
    for _ in pairs(self.Coordinates) do
        count = count + 1
    end
    return count
end

return DesignResConfig