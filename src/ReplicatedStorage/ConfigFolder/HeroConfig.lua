
local HeroConfig = {}

HeroConfig.Data = {
    [1] = {
        Id = 101,
        Level = {
            1,
            2,
            3
        },
        Name = "S9（酷帅工装风）：礁岩拓荒者",
        Star = {
            1,
            2,
            3
        },
        HeroOpen = 1,
        Model = "soldier1001",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "1_1000",
            "2_1000",
            "3_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "1_1001_100",
            "1_1002_100",
            "1_1003_100"
        },
        HeroDesc = "工装扛斧闯礁滩，凿岩觅泉，是小队生存后盾",
    },
    [2] = {
        Id = 102,
        Level = {
            1,
            2,
            3
        },
        Name = "S8（猫耳航海风）：椰风喵船长",
        Star = {
            2,
            3,
            4
        },
        HeroOpen = 1,
        Model = "soldier1002",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "4_1000",
            "5_1000",
            "6_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "猫耳嗅风辨藏宝，绒尾摇，三海里内无秘藏",
    },
    [3] = {
        Id = 103,
        Level = {
            1,
            2,
            3
        },
        Name = "S7（魔角探险风）：暗礁潜行者",
        Star = {
            2,
            3,
            4
        },
        HeroOpen = 1,
        Model = "soldier1003",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "7_1000",
            "8_1000",
            "9_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "魔角披雾探洞穴，深海摸沉船，悄行无踪迹",
    },
    [4] = {
        Id = 104,
        Level = {
            1,
            2,
            3
        },
        Name = "S6（白袍刺客风）：雾屿寻秘人",
        Star = {
            3,
            4,
            5
        },
        HeroOpen = 1,
        Model = "soldier1004",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "10_1000",
            "11_1000",
            "12_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "白袍执古图破雾，指尖解暗号，引航向秘境",
    },
    [5] = {
        Id = 105,
        Level = {
            1,
            2,
            3
        },
        Name = "S5（红白海盗风）：赤潮女舵手",
        Star = {
            4,
            5,
            6
        },
        HeroOpen = 1,
        Model = "soldier1005",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "13_1000",
            "14_1000",
            "15_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "红装立舵逆狂浪，稳控船舷，怒海辟安途",
    },
    [6] = {
        Id = 106,
        Level = {
            1,
            2,
            3
        },
        Name = "S4（白兔萌系风）：沙洲兔领航",
        Star = {
            4,
            5,
            6
        },
        HeroOpen = 1,
        Model = "soldier1006",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "16_1000",
            "17_1000",
            "1_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "兔耳竖听暗礁险，沙间绘航，精准指安全道",
    },
    [7] = {
        Id = 107,
        Level = {
            1,
            2,
            3
        },
        Name = "S3（经典海盗风）：藏宝湾提督",
        Star = {
            4,
            5,
            6
        },
        HeroOpen = 1,
        Model = "soldier1007",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "2_1000",
            "3_1000",
            "4_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "金披风卷浪，怀藏秘宝图，领航寻传奇",
    },
    [8] = {
        Id = 108,
        Level = {
            1,
            2,
            3
        },
        Name = "S2（黑西装绅士风）：远海航务员",
        Star = {
            4,
            5,
            6
        },
        HeroOpen = 1,
        Model = "soldier1008",
        Icon = "rbxassetid://138713655406841",
        Property = {
            0,
            "1002_20",
            "1002_50"
        },
        Unlock = {
            "5_1000",
            "6_1000",
            "7_1000"
        },
        UpgradeCost = {
            "1_1000",
            "1_2000",
            "1_3000"
        },
        InitialItem = nil,
        EffectAction = {
            "100_1",
            "101_1",
            "102_1"
        },
        HeroDesc = "怀表算潮汐星象，西装记航，定万程方向",
    },
}

-- 辅助函数
function HeroConfig:GetByIndex(index)
    return self.Data[index]
end

function HeroConfig:GetById(value)
    for i, item in pairs(self.Data) do
        if item.Id == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByLevel(value)
    for i, item in pairs(self.Data) do
        if item.Level == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByName(value)
    for i, item in pairs(self.Data) do
        if item.Name == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByStar(value)
    for i, item in pairs(self.Data) do
        if item.Star == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByHeroOpen(value)
    for i, item in pairs(self.Data) do
        if item.HeroOpen == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByModel(value)
    for i, item in pairs(self.Data) do
        if item.Model == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByIcon(value)
    for i, item in pairs(self.Data) do
        if item.Icon == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByProperty(value)
    for i, item in pairs(self.Data) do
        if item.Property == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByUnlock(value)
    for i, item in pairs(self.Data) do
        if item.Unlock == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByUpgradeCost(value)
    for i, item in pairs(self.Data) do
        if item.UpgradeCost == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByInitialItem(value)
    for i, item in pairs(self.Data) do
        if item.InitialItem == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByEffectAction(value)
    for i, item in pairs(self.Data) do
        if item.EffectAction == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetByHeroDesc(value)
    for i, item in pairs(self.Data) do
        if item.HeroDesc == value then
            return item
        end
    end
    return nil
end

function HeroConfig:GetAll()
    return self.Data
end

function HeroConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return HeroConfig