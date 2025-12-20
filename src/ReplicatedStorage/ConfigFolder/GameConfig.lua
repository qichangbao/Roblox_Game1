local GameConfig = {}

-- 物品类型
GameConfig.ItemType = {
    Explore = 1,    -- 探索类
    Weapon = 2,     -- 进攻类
    Assistance = 3, -- 辅助类
    Collect = 4,    -- 搜集类
    Chest = 5,      -- 宝箱类
    Mound = 6,      -- 土堆
    Buff = 7,      --  buff类
    Max = 8,        -- 最大物品类型
}

GameConfig.ItemTypeFolder = {
    [GameConfig.ItemType.Explore] = "探索",
    [GameConfig.ItemType.Weapon] = "进攻",
    [GameConfig.ItemType.Assistance] = "辅助",
    [GameConfig.ItemType.Collect] = "搜集",
    [GameConfig.ItemType.Chest] = "箱子",
    [GameConfig.ItemType.Mound] = "土堆",
    [GameConfig.ItemType.Buff] = "Buff",
}

GameConfig.NpcUIType = {
    Store = 1,      -- 商店
    Sell = 2,       -- 出售
    Talent = 3,     -- 天赋
    Quest = 4,      -- 任务
    Reward = 5,     -- 奖励
}

GameConfig.TalentType = {
    WalkSpeed = 1,      -- 移动
    MaxHealth = 2,      -- 最大生命值
    Jump = 3,           -- 跳跃
    Weight = 4,         -- 重量
    CollectSpeed = 5,   -- 搜集速度
    Lucky = 6,          -- 幸运
}

-- 任务类型枚举（与 QuestConfig.Type 对应）
GameConfig.TaskType = {
    KillMonster = 1,          -- 击杀指定怪物（或玩家）
    CollectItem = 2,          -- 收集/拾取指定物品（环境物品）
    RetrieveAtLocation = 3,   -- 在指定位置拾取某物
    PlaceAtLocation = 4,      -- 将物品放置到指定位置
    ScoutArea = 5,            -- 到达某区域（侦查）
    UseSpecificItemOnTarget = 6, -- 使用特定物品（或装备）击杀指定目标
    Composite = 7,            -- 复合型任务
}

-- 职业解锁条件枚举
GameConfig.JobUnlockCondition = {
    Gold = 1,                   -- 金币获得_数量
    IslandLevel = 2,            -- 达到岛屿_第几关
    FreeRelive = 3,             -- 复活_次数
    Escape = 4,                 -- 撤离_次数
    RobCoins = 5,               -- 罗布币_消耗数量
    DamageNoWeapon = 6,         -- 伤害（无指定武器_伤害值）
    DamageNoWeaponNum = 7,      -- 伤害（无指定武器_数量）
    DamageWithWeapon = 8,       -- 伤害（指定武器_伤害值/数量）
    DamageWithWeaponNum = 9,    -- 伤害（指定武器_数量）
    DamageMonster = 10,         -- 伤害（怪物ID_伤害值）
    DamageMonsterNum = 11,      -- 伤害（怪物ID_数量）
    DamageDefense = 12,         -- 伤害（防御工事_伤害值）
    DamageDefenseNum = 13,      -- 伤害（防御工事_数量）
    CollectItemNum = 14,        -- 收集（道具_数量）
    HealItemNum = 15,           -- 治疗（治疗道具_值/数量）
    SaveNpcNum = 16,            -- 救人（NPC_次数）
    SaveTeammateNum = 17,       -- 救人（队友_次数）
}

-- 职业属性枚举
GameConfig.JobAttributeType = {
    Attribute = 1,              -- 属性
    Backpack = 100,             -- 背包容量
    FreeRelive = 101,           -- 免费复活次数
    DoubleDamage = 102,         -- 双倍伤害
    KillMonsterDoubleDrop = 103, -- 击杀怪物双倍掉落
}

GameConfig.DuanWeiType = {
    [1] = {
        name = "新手",
        levelNum = 2,           -- 当前段位里有几个级别
        levelStarNum = 3,       -- 每级别有多少星级
        icons = {
            "rbxassetid://107675934692852",
            "rbxassetid://140101764905074",
        },
        allowDeduction = false,
    },
    [2] = {
        name = "幸存者",
        levelNum = 3,
        levelStarNum = 3,
        icons = {
            "rbxassetid://95055487648786",
            "rbxassetid://107725460727092",
            "rbxassetid://111713244903022",
        },
        allowDeduction = false,
    },
    [3] = {
        name = "猎手",
        levelNum = 3,
        levelStarNum = 3,
        icons = {
            "rbxassetid://126318903951630",
            "rbxassetid://127632100463204",
            "rbxassetid://90815237857389",
        },
        allowDeduction = false,
    },
    [4] = {
        name = "探索者",
        levelNum = 4,
        levelStarNum = 4,
        icons = {
            "rbxassetid://91422772501756",
            "rbxassetid://132653545970076",
            "rbxassetid://91255303512428",
            "rbxassetid://129588252282861",
        },
        allowDeduction = true,
    },
    [5] = {
        name = "袭击者",
        levelNum = 5,
        levelStarNum = 5,
        icons = {
            "rbxassetid://87909143599189",
            "rbxassetid://107943684712921",
            "rbxassetid://79501454052147",
            "rbxassetid://113973751318191",
            "rbxassetid://124479690174981",
        },
        allowDeduction = true,
    },
    [6] = {
        name = "大师",
        levelNum = 5,
        levelStarNum = 5,
        icons = {
            "rbxassetid://131344517321091",
            "rbxassetid://80404558949136",
            "rbxassetid://80854096048450",
            "rbxassetid://116214812869164",
            "rbxassetid://97942786376716",
        },
        allowDeduction = true,
    },
    [7] = {
        name = "传奇",
        levelNum = -1,
        levelStarNum = -1,
        icons = "rbxassetid://75343365000157",
        allowDeduction = true,
    },
}

GameConfig.BackpackSlotCount = 6    -- 背包槽位数量
GameConfig.InitItemNums = 30        -- 初始物品数量
GameConfig.IslandId = 100000        -- 出生岛ID
GameConfig.TeleportPartNames = {"go1", "go2", "go3"}-- 触发传送的Part名称

-- 为了向后兼容，保留原有的FontFace属性
GameConfig.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
GameConfig.SLOT_NUM = 3
GameConfig.Item_DragTime = 0.3       -- 物品拖拽响应事件
GameConfig.Overwhelmed = 15         -- 负重
GameConfig.CollectSpeed = 16        -- 搜集速度
GameConfig.Lucky = 0                -- 幸运

-- 物品的扩展属性，用于服务器客户端同步一些动态数据
GameConfig.GetItemAttribute = function(item)
    if not item then
        return {
            CreateTime = tick(),        -- 创建时间
            IsEquipped = 0,             -- 是否装备
            CDElapsedTime = 0,          -- CD截止时间
            UsedTime = 0,               -- 已使用时间
            UsedNum = 0,                -- 已使用次数
            IsLocked = 0,               -- 是否锁定
        }
    end
    return {
        CreateTime = item:GetAttribute("CreateTime"),
        IsEquipped = item:GetAttribute("IsEquipped"),
        CDElapsedTime = item:GetAttribute("CDElapsedTime"),
        UsedTime = item:GetAttribute("UsedTime"),
        UsedNum = item:GetAttribute("UsedNum"),
        IsLocked = item:GetAttribute("IsLocked"),
    }
end

GameConfig.SetItemAttribute = function(item, attribute)
    if not attribute then
        attribute = GameConfig.GetItemAttribute()
    end
    item:SetAttribute("CreateTime", attribute.CreateTime)
    item:SetAttribute("IsEquipped", attribute.IsEquipped)
    item:SetAttribute("CDElapsedTime", attribute.CDElapsedTime)
    item:SetAttribute("UsedTime", attribute.UsedTime)
    item:SetAttribute("UsedNum", attribute.UsedNum)
    item:SetAttribute("IsLocked", attribute.IsLocked)
end

GameConfig.UpdateItemAttribute = function(item, key, value)
    local attribute = GameConfig.GetItemAttribute(item)
    attribute[key] = value
    GameConfig.SetItemAttribute(item, attribute)
    return attribute
end

return GameConfig