
local PlanConfig = {}

PlanConfig.Data = {
    [1] = {
        PlanId = 5001,
        CanisterId = 0,
        ChestProbability = 0,
        ItemId = {
            1001,
            1002,
            1011,
            1018,
            1026
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            3000
        },
    },
    [2] = {
        PlanId = 5002,
        CanisterId = 0,
        ChestProbability = 0,
        ItemId = {
            1003,
            1004,
            1012,
            1020,
            1030
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            3000
        },
    },
    [3] = {
        PlanId = 5003,
        CanisterId = 0,
        ChestProbability = 0,
        ItemId = {
            1005,
            1006,
            1015,
            1022,
            1031
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            3000
        },
    },
    [4] = {
        PlanId = 5004,
        CanisterId = 0,
        ChestProbability = 0,
        ItemId = {
            1007,
            1008,
            1016,
            1029,
            1030
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            3000
        },
    },
    [5] = {
        PlanId = 5005,
        CanisterId = 501,
        ChestProbability = 5000,
        ItemId = {
            1009,
            1010,
            1018,
            1026,
            1033
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            1200
        },
    },
    [6] = {
        PlanId = 5006,
        CanisterId = 502,
        ChestProbability = 5000,
        ItemId = {
            1013,
            1014,
            1019,
            1022,
            1034
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            3000
        },
    },
    [7] = {
        PlanId = 5007,
        CanisterId = 502,
        ChestProbability = 5000,
        ItemId = {
            1017,
            1021,
            1019,
            1030,
            1031,
            1026
        },
        Probability = {
            3000,
            3000,
            5500,
            5500,
            3000,
            4500
        },
    },
    [8] = {
        PlanId = 5008,
        CanisterId = 502,
        ChestProbability = 5000,
        ItemId = {
            1023,
            1024,
            1027,
            1032,
            1026,
            1033
        },
        Probability = {
            3000,
            3000,
            3000,
            3000,
            5500,
            3000
        },
    },
    [9] = {
        PlanId = 5009,
        CanisterId = 503,
        ChestProbability = 5000,
        ItemId = {
            1025,
            1028,
            1026,
            1033,
            1034
        },
        Probability = {
            4500,
            4500,
            6000,
            7000,
            7000
        },
    },
    [10] = {
        PlanId = 5010,
        CanisterId = 601,
        ChestProbability = 9000,
        ItemId = {
            1013,
            1014,
            1019,
            1022,
            1034
        },
        Probability = {
            4500,
            5500,
            5500,
            4500,
            3000
        },
    },
    [11] = {
        PlanId = 5011,
        CanisterId = 503,
        ChestProbability = 10000,
        ItemId = 1035,
        Probability = 10000,
    },
}

-- 辅助函数
function PlanConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function PlanConfig:GetByPlanId(value)
    for i, item in pairs(self.Data) do
        if item.PlanId == value then
            return item
        end
    end
    return nil
end

function PlanConfig:GetByCanisterId(value)
    for i, item in pairs(self.Data) do
        if item.CanisterId == value then
            return item
        end
    end
    return nil
end

function PlanConfig:GetByChestProbability(value)
    for i, item in pairs(self.Data) do
        if item.ChestProbability == value then
            return item
        end
    end
    return nil
end

function PlanConfig:GetByItemId(value)
    for i, item in pairs(self.Data) do
        if item.ItemId == value then
            return item
        end
    end
    return nil
end

function PlanConfig:GetByProbability(value)
    for i, item in pairs(self.Data) do
        if item.Probability == value then
            return item
        end
    end
    return nil
end

function PlanConfig:GetAll()
    return self.Data
end

function PlanConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return PlanConfig