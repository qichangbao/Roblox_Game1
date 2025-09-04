-- 充值购买服务
-- 专门处理船只购买功能

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Shop1Config = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("Shop1Config"))

local PurchaseService = Knit.CreateService({
    Name = 'PurchaseService',
    Client = {
        PurchaseProduct = Knit.CreateSignal(),
        PurchaseCompleted = Knit.CreateSignal(),
        PurchaseFailed = Knit.CreateSignal(),
    },
})

-- 存储待处理的购买请求
local PendingPurchases = {}
local targetPlayerUserId = nil

-- 处理开发者产品购买回调
-- @param receiptInfo table 购买收据信息
-- @return Enum.ProductPurchaseDecision 购买决定
local function processReceipt(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    -- 发放船只
    local shopInfo = Shop1Config:GetByAssetID(receiptInfo.ProductId)
    if not shopInfo then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if targetPlayerUserId then
        local targetPlayer = Players:GetPlayerByUserId(targetPlayerUserId)
        if targetPlayer then
            Knit.GetService('InventoryService'):AddItem(targetPlayer, shopInfo.Index)
        end
        targetPlayerUserId = nil
    else
        Knit.GetService('InventoryService'):AddItem(player, shopInfo.Index)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- 客户端接口：购买物品
-- @param player Player 玩家对象
-- @param productId string 物品商品ID
-- @return boolean 是否成功发起购买
function PurchaseService:BuyItem(player, itemId, productId, targetUserId)
    -- 存储待处理的购买请求
    PendingPurchases[player.UserId] = {
        itemId = itemId,
        productId = productId,
        timestamp = tick(),
    }
    targetPlayerUserId = targetUserId
    
    -- 发起购买
    local success, errorMessage = pcall(function()
        MarketplaceService:PromptProductPurchase(player, productId)
    end)
    
    if not success then
        PendingPurchases[player.UserId] = nil
        PurchaseService.Client.PurchaseFailed:Fire(player, errorMessage)
        return false
    end
    
    return true
end

-- 清理过期的待处理购买请求
-- @param maxAge number 最大存活时间（秒）
function PurchaseService:CleanupPendingPurchases(maxAge)
    maxAge = maxAge or 300 -- 默认5分钟
    local currentTime = tick()
    
    for userId, purchaseData in pairs(PendingPurchases) do
        if currentTime - purchaseData.timestamp > maxAge then
            PendingPurchases[userId] = nil
        end
    end
end

function PurchaseService:KnitInit()
    -- 设置购买处理回调
    MarketplaceService.ProcessReceipt = processReceipt
end

function PurchaseService:KnitStart()
    -- 定期清理过期的待处理购买请求
    task.spawn(function()
        while true do
            task.wait(60) -- 每分钟清理一次
            self:CleanupPendingPurchases()
        end
    end)
end

return PurchaseService