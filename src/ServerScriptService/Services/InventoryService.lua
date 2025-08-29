-- InventoryService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local InventoryService = Knit.CreateService {
	Name = "InventoryService",
	Client = {
	},

    Inventory = {},
}

function InventoryService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function InventoryService:KnitStart()
end

function InventoryService:playerAdd(player, inventory)
    self.Inventory[player.UserId] = inventory
end

function InventoryService:playerRemoved(player)
    self.Inventory[player.UserId] = nil
end

function InventoryService:GetInventoryData(player)
    return self.Inventory[player.UserId]
end

function InventoryService:AddItem(player, itemId, num)
    local isFound = false
    for i, v in pairs(self.Inventory[player.UserId]) do
        if v.ItemId == itemId then
            v.Num = v.Num + num
            isFound = true
            return
        end
    end

    if not isFound then
        table.insert(self.Inventory[player.UserId], {
            ItemId = itemId,
            Num = num,
        })
    end
    local DBService = Knit.GetService("DBService")
    DBService:Set(player.UserId, "PlayerInventory", self.Inventory[player.UserId])
    self.Client:UpdateBackpack(player, self.Inventory[player.UserId])
end

function InventoryService:RemoveItem(player, itemId, num)
    for i, v in ipairs(self.Inventory[player.UserId]) do
        if v.ItemId == itemId then
            if v.Num >= num then
                v.Num = v.Num - num
            else
                table.remove(self.Inventory[player.UserId], i)
            end
            break
        end
    end
    local DBService = Knit.GetService("DBService")
    DBService:Set(player.UserId, "PlayerInventory", self.Inventory[player.UserId])
    self.Client:UpdateBackpack(player, self.Inventory[player.UserId])
end

-- 从DataStoreService初始化玩家库存数据
function InventoryService:InitPlayerInventory(player, inventoryStore)
    local userId = player.UserId
    self.Inventory[userId] = {}

    if inventoryStore then
        self.Inventory[userId] = inventoryStore
    end
    self.Client:UpdateBackpack(player, self.Inventory[userId])
end

function InventoryService:GetInventoryFromDBService(userId, value)
    local player = game.Players:GetPlayerByUserId(userId)
    if not player then
        return
    end
    self:InitPlayerInventory(player, value)
end

return InventoryService