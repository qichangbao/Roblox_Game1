
local ItemConfig = {}

ItemConfig.Data = {
    [1] = {
        Index = 1,
        Item = "刺刀",
        DisplayName = "Bayonet",
        Icon = "rbxassetid://94897262399463",
        Model = "刺刀",
        Description = "A sharp close-combat weapon designed for piercing and slashing.",
        Type = 2,
        RobloxPrice = 100,
        Price = 10000,
        SellPrice = 5000,
        Gift = 1,
        PickTime = 0,
        CD = 0.8,
        Duration = 0,
        TimeUsed = 0,
    },
    [2] = {
        Index = 2,
        Item = "手电",
        DisplayName = "Flashlight",
        Icon = "rbxassetid://80944253490783",
        Model = "手电",
        Description = "A portable light source that helps you see in dark environments.",
        Type = 1,
        RobloxPrice = 40,
        Price = 4000,
        SellPrice = 2000,
        Gift = 1,
        PickTime = 0,
        CD = 0,
        Duration = 30,
        TimeUsed = 0,
    },
    [3] = {
        Index = 3,
        Item = "荧光棒-红色",
        DisplayName = "Glow Stick - Red",
        Icon = "rbxassetid://117206965019901",
        Model = "荧光棒-红色",
        Description = "A disposable light source that emits a bright red glow, useful for marking areas or signaling.",
        Type = 1,
        RobloxPrice = 10,
        Price = 1000,
        SellPrice = 500,
        Gift = 1,
        PickTime = 0,
        CD = 0,
        Duration = 30,
        TimeUsed = 1,
    },
    [4] = {
        Index = 4,
        Item = "铲子",
        DisplayName = "Shovel",
        Icon = "rbxassetid://117763824854828",
        Model = "铲子",
        Description = "A sturdy digging tool, can also be used as a blunt weapon in emergencies.",
        Type = 2,
        RobloxPrice = 50,
        Price = 5000,
        SellPrice = 2500,
        Gift = 1,
        PickTime = 0,
        CD = 1.5,
        Duration = 0,
        TimeUsed = 0,
    },
    [5] = {
        Index = 5,
        Item = "急救包",
        DisplayName = "First Aid Kit",
        Icon = "rbxassetid://116019405232413",
        Model = "急救包",
        Description = "A medical kit containing supplies to restore health and stop bleeding.",
        Type = 3,
        RobloxPrice = 30,
        Price = 3000,
        SellPrice = 1500,
        Gift = 1,
        PickTime = 0,
        CD = 120,
        Duration = 0,
        TimeUsed = 3,
    },
    [6] = {
        Index = 6,
        Item = "额外的背包",
        DisplayName = "Extra Backpack",
        Icon = "rbxassetid://98954413940819",
        Model = "额外的背包",
        Description = "Increases your carrying capacity for additional supplies.",
        Type = 3,
        RobloxPrice = 500,
        Price = 50000,
        SellPrice = 25000,
        Gift = 1,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [7] = {
        Index = 7,
        Item = "传送装置",
        DisplayName = "Teleport Device",
        Icon = "rbxassetid://86586160503774",
        Model = "传送装置",
        Description = "A rare tool that instantly transports the user to a safe location.",
        Type = 3,
        RobloxPrice = 500,
        Price = 50000,
        SellPrice = 25000,
        Gift = 1,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 1,
    },
    [8] = {
        Index = 501,
        Item = "普通宝箱",
        DisplayName = "Common Chest",
        Icon = nil,
        Model = "宝箱1",
        Description = nil,
        Type = 5,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 0,
        Gift = 0,
        PickTime = 3,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [9] = {
        Index = 502,
        Item = "黄金宝箱",
        DisplayName = "Golden Chest",
        Icon = nil,
        Model = "宝箱2",
        Description = nil,
        Type = 5,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 0,
        Gift = 0,
        PickTime = 5,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [10] = {
        Index = 503,
        Item = "炫彩宝箱",
        DisplayName = "Shiny Chest",
        Icon = nil,
        Model = "宝箱3",
        Description = nil,
        Type = 5,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 0,
        Gift = 0,
        PickTime = 8,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [11] = {
        Index = 1001,
        Item = "破碎陶片",
        DisplayName = "Broken Pottery Shard",
        Icon = "rbxassetid://138603713864045",
        Model = "破碎陶片",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 100,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [12] = {
        Index = 1002,
        Item = "生锈铁钉",
        DisplayName = "Rusty Nail",
        Icon = "rbxassetid://82277829138618",
        Model = "生锈铁钉",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 80,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [13] = {
        Index = 1003,
        Item = "海玻璃碎片",
        DisplayName = "Sea Glass Fragment",
        Icon = "rbxassetid://110975175622147",
        Model = "海玻璃碎片",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 200,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [14] = {
        Index = 1004,
        Item = "石化木片",
        DisplayName = "Petrified Wood Chip",
        Icon = "rbxassetid://72739379270245",
        Model = "石化木片",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 250,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [15] = {
        Index = 1005,
        Item = "旧布条",
        DisplayName = "Old Cloth Strip",
        Icon = "rbxassetid://89935448987523",
        Model = "旧布条",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 90,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [16] = {
        Index = 1006,
        Item = "破旧绳索",
        DisplayName = "Worn Rope",
        Icon = "rbxassetid://122411307036488",
        Model = "破旧绳索",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 110,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [17] = {
        Index = 1007,
        Item = "骨头碎片",
        DisplayName = "Bone Fragment",
        Icon = "rbxassetid://105576003572190",
        Model = "骨头碎片",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 150,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [18] = {
        Index = 1008,
        Item = "旧报纸残页",
        DisplayName = "Old Newspaper Scrap",
        Icon = "rbxassetid://73093497229758",
        Model = "旧报纸残页",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 130,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [19] = {
        Index = 1009,
        Item = "信封",
        DisplayName = "Envelope",
        Icon = "rbxassetid://138713655406841",
        Model = "信封",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 300,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [20] = {
        Index = 1010,
        Item = "陶罐",
        DisplayName = "Clay Pot",
        Icon = "rbxassetid://96684574627137",
        Model = "陶罐",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 600,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [21] = {
        Index = 1011,
        Item = "海盗帽",
        DisplayName = "Pirate Hat",
        Icon = "rbxassetid://75979111313340",
        Model = "海盗帽",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 1400,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [22] = {
        Index = 1012,
        Item = "提灯",
        DisplayName = "Lantern",
        Icon = "rbxassetid://86068885165137",
        Model = "提灯",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 1200,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [23] = {
        Index = 1013,
        Item = "大葱",
        DisplayName = "Green Onion",
        Icon = "rbxassetid://120349324917743",
        Model = "大葱",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 50,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [24] = {
        Index = 1014,
        Item = "扇子",
        DisplayName = "Fan",
        Icon = "rbxassetid://100156804426081",
        Model = "扇子",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 750,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [25] = {
        Index = 1015,
        Item = "木桶",
        DisplayName = "Wooden Barrel",
        Icon = "rbxassetid://117483365334798",
        Model = "木桶",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 1800,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [26] = {
        Index = 1016,
        Item = "水壶",
        DisplayName = "Water Kettle",
        Icon = "rbxassetid://107365993175298",
        Model = "水壶",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 850,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [27] = {
        Index = 1017,
        Item = "木条",
        DisplayName = "Wooden Plank",
        Icon = "rbxassetid://78896655282067",
        Model = "木条",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 400,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [28] = {
        Index = 1018,
        Item = "钱袋",
        DisplayName = "Money Bag",
        Icon = "rbxassetid://85828547583727",
        Model = "钱袋",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 2500,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [29] = {
        Index = 1019,
        Item = "面具",
        DisplayName = "Mask",
        Icon = "rbxassetid://85922917375016",
        Model = "面具",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 950,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [30] = {
        Index = 1020,
        Item = "鬼脸娃娃",
        DisplayName = "Grimace Doll",
        Icon = "rbxassetid://86205452605963",
        Model = "鬼脸娃娃",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 1600,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [31] = {
        Index = 1021,
        Item = "靴子",
        DisplayName = "Boots",
        Icon = "rbxassetid://83774438054930",
        Model = "靴子",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 1100,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [32] = {
        Index = 1022,
        Item = "魔法帽",
        DisplayName = "Wizard Hat",
        Icon = "rbxassetid://104600101847403",
        Model = "魔法帽",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 2200,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [33] = {
        Index = 1023,
        Item = "手套",
        DisplayName = "Gloves",
        Icon = "rbxassetid://135724777590724",
        Model = "手套",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 700,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [34] = {
        Index = 1024,
        Item = "生锈的齿轮",
        DisplayName = "Rusty Gear",
        Icon = "rbxassetid://90347812810054",
        Model = "生锈的齿轮",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 550,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [35] = {
        Index = 1025,
        Item = "兽角",
        DisplayName = "Beast Horn",
        Icon = "rbxassetid://120912130598306",
        Model = "兽角",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 2400,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [36] = {
        Index = 1026,
        Item = "野兽骸骨",
        DisplayName = "Beast Skeleton",
        Icon = "rbxassetid://100485402089375",
        Model = "野兽骸骨",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 3500,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [37] = {
        Index = 1027,
        Item = "粘液",
        DisplayName = "Slime",
        Icon = "rbxassetid://94723848723446",
        Model = "粘液",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 180,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [38] = {
        Index = 1028,
        Item = "一瓶粘液",
        DisplayName = "Vial of Slime",
        Icon = "rbxassetid://88068426664096",
        Model = "一瓶粘液",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 1300,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [39] = {
        Index = 1029,
        Item = "潜水头盔",
        DisplayName = "Diving Helmet",
        Icon = "rbxassetid://123592447775167",
        Model = "潜水头盔",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 2800,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [40] = {
        Index = 1030,
        Item = "船锚",
        DisplayName = "Anchor",
        Icon = "rbxassetid://86963789369428",
        Model = "船锚",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 3200,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [41] = {
        Index = 1031,
        Item = "船舵",
        DisplayName = "Ship's Wheel",
        Icon = "rbxassetid://91850687518910",
        Model = "船舵",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 3400,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
    [42] = {
        Index = 1032,
        Item = "发霉书页",
        DisplayName = "Moldy Book Page",
        Icon = "rbxassetid://81176096156968",
        Model = "发霉书页",
        Description = nil,
        Type = 4,
        RobloxPrice = 0,
        Price = 0,
        SellPrice = 350,
        Gift = 0,
        PickTime = 0,
        CD = 0,
        Duration = 0,
        TimeUsed = 0,
    },
}

-- 辅助函数
function ItemConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByItem(value)
    for i, item in pairs(self.Data) do
        if item.Item == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByIcon(value)
    for i, item in pairs(self.Data) do
        if item.Icon == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByModel(value)
    for i, item in pairs(self.Data) do
        if item.Model == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByDescription(value)
    for i, item in pairs(self.Data) do
        if item.Description == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByRobloxPrice(value)
    for i, item in pairs(self.Data) do
        if item.RobloxPrice == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByPrice(value)
    for i, item in pairs(self.Data) do
        if item.Price == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetBySellPrice(value)
    for i, item in pairs(self.Data) do
        if item.SellPrice == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByGift(value)
    for i, item in pairs(self.Data) do
        if item.Gift == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByPickTime(value)
    for i, item in pairs(self.Data) do
        if item.PickTime == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByCD(value)
    for i, item in pairs(self.Data) do
        if item.CD == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByDuration(value)
    for i, item in pairs(self.Data) do
        if item.Duration == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetByTimeUsed(value)
    for i, item in pairs(self.Data) do
        if item.TimeUsed == value then
            return item
        end
    end
    return nil
end

function ItemConfig:GetAll()
    return self.Data
end

function ItemConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function ItemConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return ItemConfig