
local SignConfig = {}

SignConfig.Data = {
    [1] = {
        Id = 1,
        Days = 1,
        SignReward = {
            1,
            100
        },
    },
    [2] = {
        Id = 2,
        Days = 2,
        SignReward = {
            1,
            200
        },
    },
    [3] = {
        Id = 3,
        Days = 3,
        SignReward = {
            1,
            300
        },
    },
    [4] = {
        Id = 4,
        Days = 4,
        SignReward = {
            1,
            400
        },
    },
    [5] = {
        Id = 5,
        Days = 5,
        SignReward = {
            1,
            500
        },
    },
    [6] = {
        Id = 6,
        Days = 6,
        SignReward = {
            1,
            600
        },
    },
    [7] = {
        Id = 7,
        Days = 7,
        SignReward = {
            1,
            700
        },
    },
    [8] = {
        Id = 8,
        Days = 8,
        SignReward = {
            1,
            800
        },
    },
    [9] = {
        Id = 9,
        Days = 9,
        SignReward = {
            1,
            900
        },
    },
    [10] = {
        Id = 10,
        Days = 10,
        SignReward = {
            1,
            1000
        },
    },
    [11] = {
        Id = 11,
        Days = 11,
        SignReward = {
            1,
            1100
        },
    },
    [12] = {
        Id = 12,
        Days = 12,
        SignReward = {
            1,
            1200
        },
    },
    [13] = {
        Id = 13,
        Days = 13,
        SignReward = {
            1,
            1300
        },
    },
    [14] = {
        Id = 14,
        Days = 14,
        SignReward = {
            1,
            1400
        },
    },
    [15] = {
        Id = 15,
        Days = 15,
        SignReward = {
            1,
            1500
        },
    },
    [16] = {
        Id = 16,
        Days = 16,
        SignReward = {
            1,
            1600
        },
    },
    [17] = {
        Id = 17,
        Days = 17,
        SignReward = {
            1,
            1700
        },
    },
    [18] = {
        Id = 18,
        Days = 18,
        SignReward = {
            1,
            1800
        },
    },
    [19] = {
        Id = 19,
        Days = 19,
        SignReward = {
            1,
            1900
        },
    },
    [20] = {
        Id = 20,
        Days = 20,
        SignReward = {
            1,
            2000
        },
    },
    [21] = {
        Id = 21,
        Days = 21,
        SignReward = {
            1,
            2100
        },
    },
    [22] = {
        Id = 22,
        Days = 22,
        SignReward = {
            1,
            2200
        },
    },
    [23] = {
        Id = 23,
        Days = 23,
        SignReward = {
            1,
            2300
        },
    },
    [24] = {
        Id = 24,
        Days = 24,
        SignReward = {
            1,
            2400
        },
    },
    [25] = {
        Id = 25,
        Days = 25,
        SignReward = {
            1,
            2500
        },
    },
    [26] = {
        Id = 26,
        Days = 26,
        SignReward = {
            1,
            2600
        },
    },
    [27] = {
        Id = 27,
        Days = 27,
        SignReward = {
            1,
            2700
        },
    },
    [28] = {
        Id = 28,
        Days = 28,
        SignReward = {
            1,
            2800
        },
    },
    [29] = {
        Id = 29,
        Days = 29,
        SignReward = {
            1,
            2900
        },
    },
    [30] = {
        Id = 30,
        Days = 30,
        SignReward = {
            1,
            3000
        },
    },
    [31] = {
        Id = 31,
        Days = 31,
        SignReward = {
            1,
            3100
        },
    },
}

-- 辅助函数
function SignConfig:GetByIndex(index)
    return self.Data[index]
end

function SignConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function SignConfig:GetByDays(value)
    for i, item in pairs(self.Data) do
        if item.Days == value then
            return item
        end
    end
    return nil
end

function SignConfig:GetBySignReward(value)
    for i, item in pairs(self.Data) do
        if item.SignReward == value then
            return item
        end
    end
    return nil
end

function SignConfig:GetAll()
    return self.Data
end

function SignConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return SignConfig