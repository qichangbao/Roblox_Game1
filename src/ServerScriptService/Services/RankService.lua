--[[
全服航行距离排行榜服务
负责管理跨所有服务器的玩家航行距离排行榜

功能:
- 跨服务器总航行距离排行榜
- 跨服务器单次最大航行距离排行榜
- 实时数据同步到全服排行榜
- 高效的数据查询和缓存

作者: Roblox海浪系统
版本: 1.0
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

-- 创建OrderedDataStore用于排行榜
local EscapeActionsDataStore = DataStoreService:GetOrderedDataStore("EscapeActions")
--EscapeActionsDataStore:RemoveAsync(7689724124)

local RankService = Knit.CreateService({
    Name = 'RankService',
    Client = {
        SendPersonalData = Knit.CreateSignal(),
        UpdateLeaderboard = Knit.CreateSignal(),
    },
    
    -- 服务器端数据
    playerEscapeActions = {}, -- 存储玩家当前航行数据
    leaderboardCache = {}, -- 排行榜缓存
    lastCacheUpdate = 0, -- 上次缓存更新时间
    pendingUpdates = {}, -- 待更新的数据队列
    playerNameCache = {}, -- 玩家名称缓存
})

-- 配置参数
local CACHE_UPDATE_INTERVAL = 3600 -- 缓存更新间隔（秒）
local LEADERBOARD_SIZE = 15 -- 排行榜显示数量
local BATCH_UPDATE_INTERVAL = 30 -- 批量更新间隔（秒）

-- 数据编码配置（用于OrderedDataStore存储多个数值）
-- 重新设计：successNum占据最高位，确保排序主要基于成功次数
local ENCODE_MULTIPLIERS = {
    totalTime = 1,            -- 总时间：最低位（0-999999）
    totalValue = 1000000,     -- 总价值：中位（0-999999 * 1000000）
    successNum = 1000000000000 -- 成功次数：最高位，主要排序字段
}

--[[
    将多个数据编码为单个数字用于OrderedDataStore存储
    编码后的数字格式：successNum(最高位) + totalValue(中位) + totalTime(最低位)
    这样确保排序主要基于successNum，其他数据仅用于显示
    @param data table 包含 successNum, totalValue, totalTime 的数据表
    @return number 编码后的整数
]]
local function EncodeDataForOrderedStore(data)
    local encoded = 0
    
    -- 确保数据在合理范围内（防止溢出），并转换为整数
    local successNum = math.floor(math.min(data.successNum or 0, 999999))
    local totalValue = math.floor(math.min(data.totalValue or 0, 999999))
    local totalTime = math.floor(math.min(data.totalTime or 0, 999999))
    
    -- 按优先级编码：successNum最重要，占据最高位
    encoded = encoded + (successNum * ENCODE_MULTIPLIERS.successNum)
    encoded = encoded + (totalValue * ENCODE_MULTIPLIERS.totalValue)
    encoded = encoded + (totalTime * ENCODE_MULTIPLIERS.totalTime)
    
    -- 确保返回整数（防止浮点数导致DataStore错误）
    return math.floor(encoded)
end

--[[
    从OrderedDataStore的编码数字中解码出原始数据
    解码顺序：successNum(最高位) -> totalValue(中位) -> totalTime(最低位)
    @param encoded number 编码后的数字
    @return table 包含 successNum, totalValue, totalTime 的数据表
]]
local function DecodeDataFromOrderedStore(encoded)
    if not encoded or encoded == 0 then
        return {successNum = 0, totalValue = 0, totalTime = 0}
    end
    
    -- 按编码的逆序解码：先解码最高位的successNum
    local successNum = math.floor(encoded / ENCODE_MULTIPLIERS.successNum)
    encoded = encoded % ENCODE_MULTIPLIERS.successNum
    
    local totalValue = math.floor(encoded / ENCODE_MULTIPLIERS.totalValue)
    encoded = encoded % ENCODE_MULTIPLIERS.totalValue
    
    local totalTime = encoded -- 剩余的就是totalTime
    
    return {
        successNum = successNum,
        totalValue = totalValue,
        totalTime = totalTime
    }
end

function RankService:GetPlayerNameCache(userId)
    if not self.playerNameCache[userId] then
        local success, playerName = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        if success and playerName then
            self.playerNameCache[userId] = playerName
        else
            self.playerNameCache[userId] = "未知玩家" .. userId
        end
    end
    return self.playerNameCache[userId]
end

-- 初始化玩家航行数据
-- @param player Player 玩家对象
function RankService:playerAdd(player)
    local userId = player.UserId
    
    -- 从数据库获取玩家航行数据
    local DBService = Knit.GetService('DBService')
    local escapeActions = DBService:Get(player.UserId, "EscapeActions")
    -- 确保所有数据都是整数（防止浮点数导致DataStore错误）
    escapeActions.successNum = math.floor(escapeActions.successNum or 0)
    escapeActions.totalValue = math.floor(escapeActions.totalValue or 0)
    escapeActions.totalTime = math.floor(escapeActions.totalTime or 0)
    
    -- 初始化当前航行数据
    self.playerEscapeActions[userId] = {
        player = player,
        escapeActions = escapeActions,
        lastUpdateTime = tick(), -- 上次更新时间
    }
    
    -- 如果玩家有现有数据，添加到待更新队列同步到OrderedDataStore
    if escapeActions and next(escapeActions) then
        self.pendingUpdates[userId] = {
            escapeActions = escapeActions,
            playerName = player.Name
        }
    end

    local data = self:GetPersonalDataWithRank(player)
    if data then
        self.Client.SendPersonalData:Fire(player, data)
    end
end

function RankService:playerRemoved(player)
    local userId = player.UserId
    if self.playerEscapeActions[userId] then
        -- 清理数据
        self.playerEscapeActions[userId] = nil
    end
end

-- 批量更新全服排行榜
--[[
    批量更新全服排行榜数据到OrderedDataStore
    将待更新队列中的所有玩家数据编码后保存到OrderedDataStore
]]
function RankService:BatchUpdateGlobalLeaderboard()
    if next(self.pendingUpdates) == nil then
        return
    end
    
    for userId, updateData in pairs(self.pendingUpdates) do
        task.spawn(function()
            pcall(function()
                -- 使用编码函数将多个数据存储到OrderedDataStore
                local encodedData = EncodeDataForOrderedStore(updateData.escapeActions)
                EscapeActionsDataStore:SetAsync(userId, encodedData)
            end)
        end)
    end
    
    -- 清空待更新队列
    self.pendingUpdates = {}
end

-- 获取全服排行榜数据
-- @param leaderboardType string 排行榜类型 ("totalDis"、"maxDis"、"totalTime"、"maxTime")
-- @param limit number 获取数量限制
-- @return table 排行榜数据
function RankService:GetGlobalLeaderboardData(leaderboardType, limit)
    local success, pages = pcall(function()
        return EscapeActionsDataStore:GetSortedAsync(false, limit)
    end)
    
    if not success then
        warn("获取全服排行榜失败:", leaderboardType, pages)
        return {}
    end
    
    local leaderboard = {}
    local rank = 1
    
    while true do
        local success2, data = pcall(function()
            return pages:GetCurrentPage()
        end)
        
        if not success2 or not data then
            print("获取当前页面失败:", leaderboardType, data)
            break
        end
        
        for _, entry in pairs(data) do
            local userId = entry.key
            local encodedValue = entry.value
            local playerName = self:GetPlayerNameCache(tonumber(userId))
            
            -- 解码获取完整数据
            local decodedData = DecodeDataFromOrderedStore(encodedValue)
            
            table.insert(leaderboard, {
                rank = rank,
                userId = userId,
                playerName = playerName,
                successNum = decodedData.successNum,    -- 成功次数
                totalValue = decodedData.totalValue,    -- 上交的总价值
                totalTime = decodedData.totalTime,      -- 成功的总时间
            })
            
            rank = rank + 1
            
            if rank > limit then
                break
            end
        end
        
        if rank > limit then
            break
        end
        
        if pages.IsFinished then
            break
        end
        
        local success3 = pcall(function()
            pages:AdvanceToNextPageAsync()
        end)
        
        if not success3 then
            print("翻页失败:", leaderboardType)
            break
        end
    end
    
    return leaderboard
end

-- 更新排行榜缓存
function RankService:UpdateLeaderboardCache()
    local currentTime = tick()
    
    -- 限制缓存更新频率
    if currentTime - self.lastCacheUpdate < CACHE_UPDATE_INTERVAL then
        return
    end
    
    self.lastCacheUpdate = currentTime
    
    -- 获取排行榜数据
    task.spawn(function()
        local escapeActionsLeaderboard = self:GetGlobalLeaderboardData("escapeActions", LEADERBOARD_SIZE)
        
        -- 更新缓存
        self.leaderboardCache = {
            escapeActions = escapeActionsLeaderboard,
            lastUpdate = currentTime
        }
        
        -- 通知所有客户端更新排行榜
        self.Client.UpdateLeaderboard:FireAll(escapeActionsLeaderboard)
    end)
end

-- 获取玩家个人数据和排名
-- @param player Player 玩家对象
-- @return table 玩家数据
function RankService:GetPersonalDataWithRank(player)
    local userId = player.UserId
    local data = self.playerEscapeActions[userId]
    
    if not data then
        return
    end
    
    -- 获取排名（同步等待）
    local escapeActionsRank = 0
    
    -- 获取总距离排名
    local success, totalActionsData = pcall(function()
        return EscapeActionsDataStore:GetSortedAsync(false, 100)
    end)
    
    if success and totalActionsData then
        local rank = 1
        while true do
            local success2, data2 = pcall(function()
                return totalActionsData:GetCurrentPage()
            end)
            
            if not success2 or not data2 then
                break
            end
            
            for _, entry in pairs(data2) do
                if tonumber(entry.key) == userId then
                    escapeActionsRank = rank
                    break
                end
                rank = rank + 1
            end
            
            if totalActionsData.IsFinished then
                break
            end
            
            local success3 = pcall(function()
                totalActionsData:AdvanceToNextPageAsync()
            end)
            
            if not success3 then
                break
            end
        end
    end
    
    return {
        escapeActions = data.escapeActions,
        escapeActionsRank = escapeActionsRank,
    }
end

--[[
    更新玩家数据并同步到排行榜
    @param player Player 玩家对象
    @param data table 包含玩家逃生数据的表，格式: { escapeActions = number }
]]
function RankService:UpdatePlayerRank(player, data)
    if not player or not data then
        warn("RankService:UpdatePlayerRank - 无效的参数")
        return
    end

    local userId = player.UserId
    if not self.playerEscapeActions[userId] then
        return
    end

    local isSuccess = data.IsSuccess
    if not isSuccess then
        return
    end
    
    -- 确保数据为整数（防止浮点数导致DataStore错误）
    local totalTime = math.floor(data.TotalTime or 0)
    local totalValue = math.floor(data.TotalValue or 0)
    
    -- 更新本地玩家数据缓存
    local escapeActions = self.playerEscapeActions[userId].escapeActions
    escapeActions.successNum += 1
    escapeActions.totalValue += totalValue
    escapeActions.totalTime += totalTime
    self.playerEscapeActions[userId].escapeActions = escapeActions
    self.playerEscapeActions[userId].lastUpdateTime = tick()
    Knit.GetService("DBService"):Set(userId, "escapeActions", escapeActions)
    
    -- 添加到待更新队列，准备同步到全服排行榜
    self.pendingUpdates[userId] = {
        escapeActions = escapeActions,
        playerName = player.Name
    }

    local playerData = self:GetPersonalDataWithRank(player)
    if playerData then
        self.Client.SendPersonalData:Fire(player, playerData)
    end
    
    print(string.format("RankService: 更新玩家 %s (ID: %d) 的逃生次数: %d, 总价值: %d, 总时间: %d", 
        player.Name, userId, escapeActions.successNum, escapeActions.totalValue, escapeActions.totalTime))
end

function RankService:GetLeaderboard(player)
    local cache = self.leaderboardCache
    if cache and cache.escapeActions then
        return cache.escapeActions
    else
        self.lastCacheUpdate = tick()
        local escapeActionsLeaderboard = self:GetGlobalLeaderboardData("escapeActions", LEADERBOARD_SIZE)
        -- 更新缓存
        self.leaderboardCache = {
            escapeActions = escapeActionsLeaderboard,
            lastUpdate = self.lastCacheUpdate
        }
        return escapeActionsLeaderboard
    end
end

-- 客户端请求排行榜数据
function RankService.Client:GetLeaderboard(player)
    return self.Server:GetLeaderboard(player)
end

-- 客户端请求个人数据
function RankService.Client:GetPersonalData(player)
    return self.Server:GetPersonalDataWithRank(player)
end

-- 服务启动时初始化
function RankService:KnitStart()
    -- 定期批量更新全服排行榜
    local handler1
    handler1 = task.spawn(function()
        while true do
            task.wait(BATCH_UPDATE_INTERVAL)
            self:BatchUpdateGlobalLeaderboard()
        end
    end)
    
    -- 定期更新排行榜缓存
    local handler2
    handler2 = task.spawn(function()
        while true do
            task.wait(CACHE_UPDATE_INTERVAL)
            self:UpdateLeaderboardCache()
        end
    end)
    
    -- 初始化排行榜缓存
    self:UpdateLeaderboardCache()

    -- 在服务器关闭时保存排行榜数据
    game:BindToClose(function()
        task.cancel(handler1)
        task.cancel(handler2)
        self:BatchUpdateGlobalLeaderboard()
    end)
end

return RankService