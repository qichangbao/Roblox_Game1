
local DropTableConfig = {}

DropTableConfig.Data = {
    [1] = {
        Id = 1,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                1001,
                1,
                3000
            },
            {
                1002,
                1,
                2000
            },
            {
                1003,
                1,
                3000
            },
            {
                1009,
                1,
                1500
            },
            {
                1010,
                1,
                500
            }
        },
        SeeForYourself = "5~30",
    },
    [2] = {
        Id = 2,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                1004,
                1,
                2000
            },
            {
                1005,
                1,
                3000
            },
            {
                1006,
                1,
                3000
            },
            {
                1013,
                1,
                1500
            },
            {
                1014,
                1,
                500
            }
        },
        SeeForYourself = "5~30",
    },
    [3] = {
        Id = 3,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                1025,
                1,
                2900
            },
            {
                1026,
                1,
                2900
            },
            {
                1027,
                1,
                1850
            },
            {
                1028,
                1,
                500
            },
            {
                1032,
                1,
                1850
            }
        },
        SeeForYourself = "5~30",
    },
    [4] = {
        Id = 4,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                1015,
                1,
                1500
            },
            {
                1016,
                1,
                4000
            },
            {
                1019,
                1,
                3000
            },
            {
                1020,
                1,
                1500
            }
        },
        SeeForYourself = "31~99",
    },
    [5] = {
        Id = 5,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                1011,
                1,
                2500
            },
            {
                1012,
                1,
                1600
            },
            {
                1021,
                1,
                1600
            },
            {
                1022,
                1,
                1600
            },
            {
                1023,
                1,
                1600
            },
            {
                1029,
                1,
                1100
            }
        },
        SeeForYourself = "100~300",
    },
    [6] = {
        Id = 6,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            {
                1018,
                1,
                1500
            },
            {
                1030,
                1,
                1400
            },
            {
                1031,
                1,
                1400
            },
            {
                1037,
                1,
                1900
            },
            {
                1038,
                1,
                1900
            },
            {
                1039,
                1,
                1900
            }
        },
        SeeForYourself = "301~1000",
    },
    [7] = {
        Id = 7,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            1033,
            1,
            500
        },
        SeeForYourself = "1001~2999",
    },
    [8] = {
        Id = 8,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            1034,
            1,
            200
        },
        SeeForYourself = "3000~4999",
    },
    [9] = {
        Id = 9,
        Type = 2,
        MinDrop = 1,
        MaxDrop = 1,
        DropInfo = {
            1035,
            1,
            100
        },
        SeeForYourself = "5000以上",
    },
}

-- 辅助函数
function DropTableConfig:GetByIndex(index)
    return self.Data[index]
end

function DropTableConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByMinDrop(value)
    for i, item in pairs(self.Data) do
        if item.MinDrop == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByMaxDrop(value)
    for i, item in pairs(self.Data) do
        if item.MaxDrop == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByDropInfo(value)
    for i, item in pairs(self.Data) do
        if item.DropInfo == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetBySeeForYourself(value)
    for i, item in pairs(self.Data) do
        if item.SeeForYourself == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetAll()
    return self.Data
end

function DropTableConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function DropTableConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return DropTableConfig