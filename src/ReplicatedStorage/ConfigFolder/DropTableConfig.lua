
local DropTableConfig = {}

DropTableConfig.Data = {
    [1] = {
        ID = 1,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                1001,
                1,
                1000
            },
            {
                1002,
                1,
                1000
            },
            {
                1003,
                1,
                1000
            },
            {
                1004,
                1,
                1000
            }
        },
    },
    [2] = {
        ID = 2,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                1001,
                1,
                1000
            },
            {
                1002,
                1,
                1000
            },
            {
                1003,
                1,
                1000
            },
            {
                1004,
                1,
                1000
            }
        },
    },
    [3] = {
        ID = 3,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                1001,
                1,
                1000
            },
            {
                1002,
                1,
                1000
            },
            {
                1003,
                1,
                1000
            },
            {
                1004,
                1,
                1000
            }
        },
    },
    [4] = {
        ID = 4,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                1001,
                1,
                1000
            },
            {
                1002,
                1,
                1000
            },
            {
                1003,
                1,
                1000
            },
            {
                1004,
                1,
                1000
            }
        },
    },
    [5] = {
        ID = 5,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                1001,
                1,
                1000
            },
            {
                1002,
                1,
                1000
            },
            {
                1003,
                1,
                1000
            },
            {
                1004,
                1,
                1000
            }
        },
    },
    [6] = {
        ID = 401,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                301,
                1,
                1000
            },
            {
                302,
                1,
                1000
            },
            {
                303,
                1,
                1000
            },
            {
                304,
                1,
                1000
            }
        },
    },
    [7] = {
        ID = 402,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                305,
                1,
                1000
            },
            {
                306,
                1,
                1000
            },
            {
                307,
                1,
                1000
            },
            {
                308,
                1,
                1000
            }
        },
    },
    [8] = {
        ID = 403,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                311,
                1,
                1000
            },
            {
                312,
                1,
                1000
            },
            {
                319,
                1,
                1000
            },
            {
                320,
                1,
                1000
            }
        },
    },
    [9] = {
        ID = 404,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                315,
                1,
                1000
            },
            {
                316,
                1,
                1000
            },
            {
                317,
                1,
                1000
            },
            {
                318,
                1,
                1000
            }
        },
    },
    [10] = {
        ID = 405,
        type = 2,
        minDrop = 1,
        maxDrop = 1,
        dropInfo = {
            {
                309,
                1,
                1000
            },
            {
                310,
                1,
                1000
            },
            {
                313,
                1,
                1000
            },
            {
                314,
                1,
                1000
            }
        },
    },
}

-- 辅助函数
function DropTableConfig:GetByIndex(index)
    return self.Data[index]
end

function DropTableConfig:GetByID(value)
    for i, item in pairs(self.Data) do
        if item.ID == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetBytype(value)
    for i, item in pairs(self.Data) do
        if item.type == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetByminDrop(value)
    for i, item in pairs(self.Data) do
        if item.minDrop == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetBymaxDrop(value)
    for i, item in pairs(self.Data) do
        if item.maxDrop == value then
            return item
        end
    end
    return nil
end

function DropTableConfig:GetBydropInfo(value)
    for i, item in pairs(self.Data) do
        if item.dropInfo == value then
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

return DropTableConfig