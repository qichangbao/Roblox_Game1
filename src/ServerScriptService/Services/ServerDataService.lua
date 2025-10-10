-- ServerDataService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

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
        local function characterAdd(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
            Knit.GetService("LevelService"):CreatePlayerBillboard(player)
        end
        if player.Character then
            characterAdd(player.Character)
        else
            player.CharacterAdded:Connect(function(character)
                characterAdd(character)
            end)
        end
    end

    local function playerRemoved(player)
        local DBService = Knit.GetService("DBService")
        DBService:PlayerRemoving(player)
        Knit.GetService("InventoryService"):playerRemoved(player)
        Knit.GetService("GoldService"):playerRemoved(player)
        Knit.GetService("RankService"):playerRemoved(player)
        Knit.GetService("LevelService"):playerRemoved(player)
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
    local DBService = Knit.GetService("DBService")
    DBService:PlayerAdded(player)

    local gold = DBService:Get(player.UserId, "Gold")
    local inventory = DBService:Get(player.UserId, "PlayerInventory")
    local tool = DBService:Get(player.UserId, "PlayerToolData")
    local duanWeiData = DBService:Get(player.UserId, "DuanWeiData")
    Knit.GetService("GoldService"):playerAdd(player, gold)
    Knit.GetService("InventoryService"):playerAdd(player, inventory, tool)
    Knit.GetService("RankService"):playerAdd(player)
    Knit.GetService("LevelService"):playerAdd(player, duanWeiData)
    
    -- 获取传送数据
    local joinData = player:GetJoinData()
    if joinData and joinData.TeleportData then
        local teleportData = joinData.TeleportData
        if teleportData.IsSuccess then
            -- 成功撤离，更新排行榜数据
            Knit.GetService("RankService"):UpdatePlayerRank(player, {
                EscapeActions = teleportData.EscapeActions,
                TotalTime = teleportData.TotalTime,
                TotalValue = teleportData.TotalValue,
                IsSuccess = teleportData.IsSuccess,
            })
        end

        -- 更新等级数据
        Knit.GetService("LevelService"):Updata(player, teleportData.IsSuccess)
    end

    local inventoryData = Knit.GetService("InventoryService"):GetInventoryData(player)
    local toolData = Knit.GetService("InventoryService"):GetToolData(player)
    local rankPersonalData = Knit.GetService("RankService"):GetPersonalDataWithRank(player)
    local rankData = Knit.GetService("RankService"):GetLeaderboard()
    local isAdmin = Knit.GetService("DBService"):IsAdmin(player)

    return {
        Gold = gold,
        Inventory = inventoryData,
        ToolData = toolData,
        RankPersonalData = rankPersonalData,
        RankData = rankData,
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