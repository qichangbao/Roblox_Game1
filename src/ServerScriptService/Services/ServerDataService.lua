-- ServerDataService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local ServerDataService = Knit.CreateService {
	Name = "ServerDataService",
	Client = {
        SendInitData = Knit.CreateSignal(),
	},

    HasInitData = {},       -- 记录玩家是否初始化数据
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
        Knit.GetService("RankService"):playerAdd(player)
        
        -- 获取传送数据
        local joinData = player:GetJoinData()
        if joinData and joinData.TeleportData then
            local teleportData = joinData.TeleportData
            if teleportData and teleportData.EscapeItems then
                for _, itemId in pairs(teleportData.EscapeItems) do
                    Knit.GetService("InventoryService"):AddItem(player, {ItemId = itemId}, 1)
                end
            end

            if teleportData.IsSuccess then
                Knit.GetService("RankService"):Update(player, {
                    EscapeActions = teleportData.EscapeActions,
                    TotalTime = teleportData.TotalTime,
                    TotalValue = teleportData.TotalValue,
                    IsSuccess = teleportData.IsSuccess,
                })
            end
        end

        if not self.HasInitData[player.UserId] then
            self.Client.SendInitData:Fire(player, self:GetInitData(player))
        end
    end

    local function playerRemoved(player)
        local DBService = Knit.GetService("DBService")
        DBService:PlayerRemoving(player)
        Knit.GetService("InventoryService"):playerRemoved(player)
        Knit.GetService("GoldService"):playerRemoved(player)
        Knit.GetService("RankService"):playerRemoved(player)
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
    if self.HasInitData[player.UserId] then
        return
    end

    local gold = Knit.GetService("GoldService"):GetGoldData(player)
    local inventory = Knit.GetService("InventoryService"):GetInventoryData(player)
    local toolData = Knit.GetService("InventoryService"):GetToolData(player)
    local isAdmin = Knit.GetService("DBService"):IsAdmin(player)

    if gold and inventory and toolData then
        self.HasInitData[player.UserId] = true
    end

    return {
        Gold = gold,
        Inventory = inventory,
        ToolData = toolData,
        IsAdmin = isAdmin,
    }
end

-- 客户端远程方法：获取玩家数据
-- @param player Player 请求数据的玩家
-- @return table 玩家数据
function ServerDataService.Client:GetInitData(player)
    return self.Server:GetInitData(player)
end

return ServerDataService