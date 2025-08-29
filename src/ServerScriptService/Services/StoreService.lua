-- StoreService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))

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

function StoreService.Client:GoldBuyItem(player, itemId, itemNum)
    local itemInfo = ItemConfig.GetByIndex(itemId)
    if not itemInfo then
        return "Item not found"
    end

    local gold = Knit.GetService("GoldService"):GetGoldData(player)
    if gold < itemInfo.Price * itemNum then
        return "Not enough coins"
    end
    Knit.GetService("GoldService"):ChangeGold(player, -itemInfo.Price * itemNum)
    Knit.GetService("InventoryService"):AddItem(player, itemId, itemNum)
    return "Success"
end

function StoreService.Client:GifeItem(player, itemId, assetID, itemNum)
end

function StoreService.Client:RobBuyItem(player, itemId, assetID, itemNum)
end

return StoreService