-- ServerDataService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local ServerDataService = Knit.CreateService {
	Name = "ServerDataService",
	Client = {
	},
}

function ServerDataService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function ServerDataService:KnitStart()
    local function playerAdd(player)
        local DBService = Knit.GetService("DBService")
        DBService:PlayerAdded(player)

        local gold = DBService:Get(player.UserId, "Gold")
        local inventory = DBService:Get(player.UserId, "PlayerInventory")
        local toolData = DBService:Get(player.UserId, "PlayerToolData")
        Knit.GetService("GoldService"):playerAdd(player, gold)
        Knit.GetService("InventoryService"):playerAdd(player, inventory, toolData)
    end

    local function playerRemoved(player)
        local DBService = Knit.GetService("DBService")
        DBService:PlayerRemoving(player)
        Knit.GetService("InventoryService"):playerRemoved(player)
        Knit.GetService("GoldService"):playerRemoved(player)
    end

    for _, player in pairs(Players:GetPlayers()) do
        playerAdd(player)
    end
	
	-- 监听玩家加入事件
	Players.PlayerAdded:Connect(function(player)
        playerAdd(player)
	end)

	-- 监听玩家离开事件
	Players.PlayerRemoving:Connect(function(player)
        playerRemoved(player)
	end)
end

function ServerDataService:GetInitData(player)
    local gold = Knit.GetService("GoldService"):GetGoldData(player)
    local inventory = Knit.GetService("InventoryService"):GetInventoryData(player)
    local toolData = Knit.GetService("InventoryService"):GetToolData(player)

    return {
        Gold = gold,
        Inventory = inventory,
        ToolData = toolData,
    }
end

-- 客户端远程方法：获取玩家数据
-- @param player Player 请求数据的玩家
-- @return table 玩家数据
function ServerDataService.Client:GetInitData(player)
    return self.Server:GetInitData(player)
end

return ServerDataService