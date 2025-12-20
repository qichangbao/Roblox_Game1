
local DesignConfig = {}

DesignConfig.Data = {
    [1] = {
        DesignId = 0,
        DesignName = "出生岛",
        MapId = 0,
        MapName = "新手岛",
        MusicId = 100,
        WeatherId = 0,
        DesignTarget = 0,
        EvacuateTime = 0,
        ResourceNum = 0,
        Monster = 0,
    },
    [2] = {
        DesignId = 1,
        DesignName = "新手海湾",
        MapId = 100,
        MapName = "恐龙岛",
        MusicId = 100,
        WeatherId = {
            1,
            100
        },
        DesignTarget = 100,
        EvacuateTime = 300,
        ResourceNum = {
            {
                1,
                5
            },
            {
                2,
                5
            },
            {
                3,
                5
            },
            {
                4,
                5
            }
        },
        Monster = {
            1,
            2,
            3,
            4
        },
    },
    [3] = {
        DesignId = 2,
        DesignName = "珊瑚浅滩",
        MapId = 101,
        MapName = nil,
        MusicId = 101,
        WeatherId = {
            1,
            100
        },
        DesignTarget = 200,
        EvacuateTime = 300,
        ResourceNum = nil,
        Monster = nil,
    },
    [4] = {
        DesignId = 3,
        DesignName = "迷雾海峡",
        MapId = 102,
        MapName = nil,
        MusicId = 102,
        WeatherId = {
            {
                2,
                90
            },
            {
                3,
                10
            }
        },
        DesignTarget = 300,
        EvacuateTime = 300,
        ResourceNum = nil,
        Monster = nil,
    },
    [5] = {
        DesignId = 4,
        DesignName = "暴风海域",
        MapId = 103,
        MapName = nil,
        MusicId = 103,
        WeatherId = {
            {
                2,
                90
            },
            {
                3,
                10
            }
        },
        DesignTarget = 400,
        EvacuateTime = 300,
        ResourceNum = nil,
        Monster = nil,
    },
    [6] = {
        DesignId = 5,
        DesignName = "幽灵深渊",
        MapId = 104,
        MapName = nil,
        MusicId = 104,
        WeatherId = {
            {
                1,
                90
            },
            {
                8,
                10
            }
        },
        DesignTarget = 500,
        EvacuateTime = 300,
        ResourceNum = nil,
        Monster = nil,
    },
}

-- 辅助函数
function DesignConfig:GetByIndex(index)
    return self.Data[index]
end

function DesignConfig:GetByDesignId(value)
    for i, item in pairs(self.Data) do
        if item.DesignId == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByDesignName(value)
    for i, item in pairs(self.Data) do
        if item.DesignName == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByMapId(value)
    for i, item in pairs(self.Data) do
        if item.MapId == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByMapName(value)
    for i, item in pairs(self.Data) do
        if item.MapName == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByMusicId(value)
    for i, item in pairs(self.Data) do
        if item.MusicId == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByWeatherId(value)
    for i, item in pairs(self.Data) do
        if item.WeatherId == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByDesignTarget(value)
    for i, item in pairs(self.Data) do
        if item.DesignTarget == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByEvacuateTime(value)
    for i, item in pairs(self.Data) do
        if item.EvacuateTime == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByResourceNum(value)
    for i, item in pairs(self.Data) do
        if item.ResourceNum == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetByMonster(value)
    for i, item in pairs(self.Data) do
        if item.Monster == value then
            return item
        end
    end
    return nil
end

function DesignConfig:GetAll()
    return self.Data
end

function DesignConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return DesignConfig