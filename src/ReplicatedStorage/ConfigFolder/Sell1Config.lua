--[[
-- 自动生成的Lua配置文件
-- 生成时间: 2025-08-29 13:32:39
-- 源文件: examples\in\Sell1Config.xls
-- 数据维度: 82行 x 1列
--]]

-- Knit框架兼容的配置模块
local Sell1Config = {}

-- 配置数据
Sell1Config.Data = {
    [1] = {
        Index = 1,
    },
    [2] = {
        Index = 2,
    },
    [3] = {
        Index = 3,
    },
    [4] = {
        Index = 4,
    },
    [5] = {
        Index = 5,
    },
    [6] = {
        Index = 6,
    },
    [7] = {
        Index = 7,
    },
    [8] = {
        Index = 8,
    },
    [9] = {
        Index = 9,
    },
    [10] = {
        Index = 10,
    },
    [11] = {
        Index = 1001,
    },
    [12] = {
        Index = 1002,
    },
    [13] = {
        Index = 1003,
    },
    [14] = {
        Index = 1004,
    },
    [15] = {
        Index = 1005,
    },
    [16] = {
        Index = 1006,
    },
    [17] = {
        Index = 1007,
    },
    [18] = {
        Index = 1008,
    },
    [19] = {
        Index = 1009,
    },
    [20] = {
        Index = 1010,
    },
    [21] = {
        Index = 1011,
    },
    [22] = {
        Index = 1012,
    },
    [23] = {
        Index = 1013,
    },
    [24] = {
        Index = 1014,
    },
    [25] = {
        Index = 1015,
    },
    [26] = {
        Index = 1016,
    },
    [27] = {
        Index = 1017,
    },
    [28] = {
        Index = 1018,
    },
    [29] = {
        Index = 1019,
    },
    [30] = {
        Index = 1020,
    },
    [31] = {
        Index = 1021,
    },
    [32] = {
        Index = 1022,
    },
    [33] = {
        Index = 1023,
    },
    [34] = {
        Index = 1024,
    },
    [35] = {
        Index = 1025,
    },
    [36] = {
        Index = 1026,
    },
    [37] = {
        Index = 1027,
    },
    [38] = {
        Index = 1028,
    },
    [39] = {
        Index = 1029,
    },
    [40] = {
        Index = 1030,
    },
    [41] = {
        Index = 1031,
    },
    [42] = {
        Index = 1032,
    },
    [43] = {
        Index = 1033,
    },
    [44] = {
        Index = 1034,
    },
    [45] = {
        Index = 1035,
    },
    [46] = {
        Index = 1036,
    },
    [47] = {
        Index = 1037,
    },
    [48] = {
        Index = 1038,
    },
    [49] = {
        Index = 1039,
    },
    [50] = {
        Index = 1040,
    },
    [51] = {
        Index = 1041,
    },
    [52] = {
        Index = 1042,
    },
    [53] = {
        Index = 1043,
    },
    [54] = {
        Index = 1044,
    },
    [55] = {
        Index = 1045,
    },
    [56] = {
        Index = 1046,
    },
    [57] = {
        Index = 1047,
    },
    [58] = {
        Index = 1048,
    },
    [59] = {
        Index = 1049,
    },
    [60] = {
        Index = 1050,
    },
    [61] = {
        Index = 1051,
    },
    [62] = {
        Index = 1052,
    },
    [63] = {
        Index = 1053,
    },
    [64] = {
        Index = 1054,
    },
    [65] = {
        Index = 1055,
    },
    [66] = {
        Index = 1056,
    },
    [67] = {
        Index = 1057,
    },
    [68] = {
        Index = 1058,
    },
    [69] = {
        Index = 1059,
    },
    [70] = {
        Index = 1060,
    },
    [71] = {
        Index = 1061,
    },
    [72] = {
        Index = 1062,
    },
    [73] = {
        Index = 1063,
    },
    [74] = {
        Index = 1064,
    },
    [75] = {
        Index = 1065,
    },
    [76] = {
        Index = 1066,
    },
    [77] = {
        Index = 1067,
    },
    [78] = {
        Index = 1068,
    },
    [79] = {
        Index = 1069,
    },
    [80] = {
        Index = 1070,
    },
    [81] = {
        Index = 1071,
    },
    [82] = {
        Index = 1072,
    },
}

-- 辅助函数
function Sell1Config:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function Sell1Config:GetAll()
    return self.Data
end

function Sell1Config:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return Sell1Config