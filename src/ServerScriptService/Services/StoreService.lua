-- StoreService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local StoreService = Knit.CreateService {
	Name = "StoreService",
	Client = {
        Triggered = Knit.CreateSignal(),
	},
}

function StoreService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function StoreService:KnitStart()
end

function StoreService.Client:GoldBuyItem(player, itemId)
    local itemInfo = ItemConfig:GetByItemId(itemId)
    if not itemInfo then
        return "Item not found"
    end

    local gold = Knit.GetService("GoldService"):GetGoldData(player)
    if gold < itemInfo.Price then
        return "Not enough coins"
    end
    Knit.GetService("GoldService"):ChangeGold(player, -itemInfo.Price)
    Knit.GetService("InventoryService"):AddItem(player, {ItemId = itemId})
    return "Success"
end

function StoreService.Client:RobBuyItem(player, itemId, assetID, targetUserId)
    return Knit.GetService("PurchaseService"):BuyItem(player, itemId, assetID, targetUserId)
end

function StoreService.Client:Sell(player, itemData)
    if not itemData or itemData.Attribute.IsLocked == 1 then
        return
    end

    Knit.GetService("GoldService"):ChangeGold(player, itemData.Attribute.Gold)
    Knit.GetService("InventoryService"):RemoveItem(player, itemData)
    return itemData
end

function StoreService.Client:SellAll(player)
    local sellItems = {}
    local gold = 0
    local inventory = Knit.GetService("InventoryService"):GetInventoryData(player)
    for _, itemData in ipairs(inventory) do
        local itemInfo = ItemConfig:GetByItemId(itemData.ItemId)
        -- 收集类物品可以一键全部出售
        if itemInfo and itemInfo.Type == GameConfig.ItemType.Collect and itemData.Attribute.IsLocked == 0 then
            gold += itemData.Attribute.Gold
            table.insert(sellItems, itemData)
        end
    end

    Knit.GetService("GoldService"):ChangeGold(player, gold)
    Knit.GetService("InventoryService"):RemoveItems(player, sellItems)
    return sellItems
end

return StoreService