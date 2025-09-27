
local PlanConfig = {}

PlanConfig.Data = {
    [1] = {
        PlanId = 5001,
        CanisterId = 0,
        ItemId = {
            1001,
            1002,
            1005,
            1013,
            1032
        },
        Probability = {
            2500,
            3000,
            2000,
            1500,
            1000
        },
    },
    [2] = {
        PlanId = 5002,
        CanisterId = 0,
        ItemId = {
            1009,
            1010,
            1016,
            1023,
            1024
        },
        Probability = {
            2000,
            1500,
            1500,
            1000,
            1000
        },
    },
    [3] = {
        PlanId = 5003,
        CanisterId = 0,
        ItemId = {
            1003,
            1004,
            1007,
            1025,
            1027
        },
        Probability = {
            2000,
            1500,
            1500,
            500,
            1000
        },
    },
    [4] = {
        PlanId = 5004,
        CanisterId = 0,
        ItemId = {
            1012,
            1015,
            1017,
            1021,
            1028
        },
        Probability = {
            1200,
            1000,
            1500,
            1000,
            800
        },
    },
    [5] = {
        PlanId = 5005,
        CanisterId = 501,
        ItemId = {
            1011,
            1014,
            1019,
            1020,
            1022
        },
        Probability = {
            5000,
            4500,
            4500,
            3500,
            2500
        },
    },
    [6] = {
        PlanId = 5006,
        CanisterId = 502,
        ItemId = {
            1024,
            1029,
            1030,
            1031,
            1008
        },
        Probability = {
            5000,
            4500,
            4500,
            3500,
            2500
        },
    },
    [7] = {
        PlanId = 5007,
        CanisterId = 502,
        ItemId = {
            1018,
            1025,
            1029,
            1006,
            1013
        },
        Probability = {
            5000,
            4500,
            4500,
            3500,
            2500
        },
    },
    [8] = {
        PlanId = 5008,
        CanisterId = 503,
        ItemId = {
            1026,
            1030,
            1031,
            1001,
            1005
        },
        Probability = {
            5000,
            4500,
            4500,
            3500,
            2500
        },
    },
    [9] = {
        PlanId = 5009,
        CanisterId = 0,
        ItemId = {
            1011,
            1018,
            1030,
            1031,
            1024
        },
        Probability = {
            2000,
            1500,
            800,
            800,
            1000
        },
    },
    [10] = {
        PlanId = 5010,
        CanisterId = 0,
        ItemId = {
            1022,
            1020,
            1028,
            1027,
            1032
        },
        Probability = {
            1500,
            1200,
            1000,
            800,
            1000
        },
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