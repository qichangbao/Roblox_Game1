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
GameConfig.TeleportPartNames = {"go1", "go2", "go3"}-- 触发传送的Part名称
GameConfig.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
GameConfig.SLOT_NUM = 3

-- 物品的扩展属性，用于服务器客户端同步一些动态数据
GameConfig.GetItemAttribute = function(item)
    if not item then
        return {
            CreateTime = tick(),        -- 创建时间
            UseElapsedTime = 0,         -- 能使用的截止时间
        }
    end
    return {
        CreateTime = item:GetAttribute("CreateTime"),
        UseElapsedTime = item:GetAttribute("UseElapsedTime"),
    }
end

GameConfig.SetItemAttribute = function(item, attribute)
    if not attribute then
        attribute = GameConfig.GetItemAttribute()
    end
    item:SetAttribute("CreateTime", attribute.CreateTime)
    item:SetAttribute("UseElapsedTime", attribute.UseElapsedTime)
end

GameConfig.UpdateItemAttribute = function(item, key, value)
    local attribute = GameConfig.GetItemAttribute(item)
    attribute[key] = value
    GameConfig.SetItemAttribute(item, attribute)
    return attribute
end

return GameConfig