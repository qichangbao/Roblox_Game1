local GameConfig = {}

-- 物品类型
GameConfig.ItemType = {
    Explore = 1,    -- 探索类
    Weapon = 2,     -- 进攻类
    Assistance = 3, -- 辅助类
    Collect = 4,    -- 搜集类
    Max = 5,        -- 最大物品类型
}

GameConfig.NpcUIType = {
    Store = 1, -- 商店
    Sell = 2, -- 出售
}

GameConfig.BackpackSlotCount = 6    -- 背包槽位数量
GameConfig.InitItemNums = 30        -- 初始物品数量
GameConfig.LandName = "出生岛"
GameConfig.TeleportPartNames = {"EUCHVORAL1", "EUCHVORAL2", "EUCHVORAL3"}-- 触发传送的Part名称
GameConfig.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")

return GameConfig