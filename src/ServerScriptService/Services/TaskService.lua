-- TaskService 服务
-- 使用 Knit 框架实现通用任务系统，任务配置来自 ReplicatedStorage/ConfigFolder/QuestConfig.lua
-- 支持的任务类型涵盖：
-- 1) 定点搜寻（在指定位置拾取任务物品）
-- 2) 指定提交（提交指定的道具与数量）
-- 3) 击杀掉落搜寻（击杀指定目标并搜刮任务物品）
-- 4) 放置类（将任务物品放置到指定位置）
-- 5) 侦查位置（到达某位置/区域）
-- 6) 无装或特定装备限制（在装备条件下完成击杀或撤离）
-- 7) 复合型（支持组合多种任务形式）
-- 8) 特定条件：撤离（可选是否要求“不使用复活”）

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local QuestConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("QuestConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

-- 可选依赖服务（存在则调用）
local InventoryService -- 背包服务：用于奖励、提交道具
local DBService        -- 数据库服务：用于持久化（留接口）

local TaskService = Knit.CreateService {
    Name = "TaskService",
    Client = {
        QuestUpdated = Knit.CreateSignal(),   -- 客户端监听任务进度更新

        -- 远程：开始任务
        StartQuest = function(self, player, questId)
            return self.Server:StartQuest(player, questId)
        end,
        -- 远程：放弃任务
        AbandonQuest = function(self, player, questId)
            return self.Server:AbandonQuest(player, questId)
        end,
        -- 远程：获取玩家任务列表
        GetPlayerQuests = function(self, player)
            return self.Server:GetPlayerQuests(player)
        end,
        -- 远程：提交任务所需物品（指定提交）
        SubmitItems = function(self, player, questId)
            return self.Server:SubmitItems(player, questId)
        end,
        -- 远程：提交任务（完成任务）
        SubmitTask = function(self, player, questId)
            return self.Server:SubmitTask(player, questId)
        end,
    },

    -- 玩家->任务进度 字典：Player.UserId -> { [questId] = progress }
    PlayerQuests = {},
}

function TaskService:PlayerAdded(player)
    local ok, data = pcall(function()
        return DBService:Get(player.UserId, "QuestData")
    end)

    local questData = {}
    if ok and type(data) == "table" then
        questData = data
    end
    self:LoadPlayerQuests(player, questData)
end

function TaskService:PlayerRemoved(player)
    self:CleanupPlayer(player)
end

-- 工具方法：安全获取依赖服务
local function getServiceSafe(serviceName)
    local ok, svc = pcall(function()
        return Knit.GetService(serviceName)
    end)
    if ok then
        return svc
    end
    return nil
end

-- 将 QuestConfig 中的单条任务定义标准化为内部任务数组
-- @param quest table QuestConfig 中的一条任务配置
-- @return table 标准化后的任务数组
local function normalizeQuestTasks(quest)
    local tasks = {}
    if quest.Type == GameConfig.TaskType.Composite then
        -- 复合型：Quest.Value 是一个数组，内部每个元素都有 Type 字段
        for _, sub in ipairs(quest.Value or {}) do
            table.insert(tasks, { Type = sub.Type, Value = sub })
        end
    else
        table.insert(tasks, { Type = quest.Type, Value = quest.Value })
    end
    return tasks
end

-- 初始化单个任务的进度对象
-- @param taskDef table 标准化后的任务定义 {Type=, Value=}
-- @return table 任务进度对象
local function initTaskProgress(taskDef)
    local tp = { Type = taskDef.Type, Done = false }
    local v = taskDef.Value
    if taskDef.Type == GameConfig.TaskType.KillMonster then
        -- v: 数组 { {MonsterId, Num}, ... }
        tp.Counts = {}
        for _, item in ipairs(v or {}) do
            tp.Counts[tostring(item.MonsterId)] = 0
            tp.TargetCounts = tp.TargetCounts or {}
            tp.TargetCounts[tostring(item.MonsterId)] = item.Num or 1
        end
    elseif taskDef.Type == GameConfig.TaskType.CollectItem then
        -- v: 数组 { {ItemId, Num}, ... }
        tp.Counts = {}
        for _, item in ipairs(v or {}) do
            tp.Counts[tostring(item.ItemId)] = 0
            tp.TargetCounts = tp.TargetCounts or {}
            tp.TargetCounts[tostring(item.ItemId)] = item.Num or 1
        end
    elseif taskDef.Type == GameConfig.TaskType.RetrieveAtLocation then
        -- v: {ItemId, Pos={X,Y,Z}, Range, ChildType}
        tp.ItemId = v.ItemId
        tp.Pos = v.Pos
        tp.Range = v.Range or 10
        tp.Collected = false
    elseif taskDef.Type == GameConfig.TaskType.PlaceAtLocation then
        -- v: {ItemId, Pos={X,Y,Z}}
        tp.ItemId = v.ItemId
        tp.Pos = v.Pos
        tp.Placed = false
    elseif taskDef.Type == GameConfig.TaskType.ScoutArea then
        -- v: {Pos={X,Y,Z}, Range}
        tp.Pos = v.Pos
        tp.Range = v.Range or 10
        tp.Visited = false
    elseif taskDef.Type == GameConfig.TaskType.UseSpecificItemOnTarget then
        -- v: {ItemId, MonsterId, Num}
        tp.ItemId = v.ItemId
        tp.MonsterId = v.MonsterId
        tp.TargetNum = v.Num or 1
        tp.Current = 0
    elseif taskDef.Type == GameConfig.TaskType.Exfil then
        -- v: {MapId, ExitId, NoRevive=true/false}
        tp.MapId = v.MapId
        tp.ExitId = v.ExitId
        tp.NoRevive = v.NoRevive or false
        tp.Exfiled = false
    end
    return tp
end

-- 判断两点是否在范围内
-- @param pos table {X,Y,Z}
-- @param other table {X,Y,Z}
-- @param range number 范围半径
-- @return boolean 是否在范围内
local function inRange(pos, other, range)
    if not pos or not other then return false end
    local dx = (pos.X or 0) - (other.X or 0)
    local dy = (pos.Y or 0) - (other.Y or 0)
    local dz = (pos.Z or 0) - (other.Z or 0)
    local dist2 = dx*dx + dy*dy + dz*dz
    return dist2 <= (range or 0)^2
end

-- 服务初始化（Knit 生命周期）
function TaskService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function TaskService:KnitStart()
    InventoryService = getServiceSafe("InventoryService")
    DBService = getServiceSafe("DBService")
end

-- 清理玩家任务数据
-- @param player Player 玩家对象
-- @return void
function TaskService:CleanupPlayer(player)
    -- 离开时保存任务进度
    self:SavePlayerQuests(player)
    self.PlayerQuests[player.UserId] = nil
end

-- 为玩家开始一个任务
-- @param player Player 玩家对象
-- @param questId number 任务ID（对应 QuestConfig.Data[*].QuestId）或数组索引
-- @return boolean 是否成功
function TaskService:StartQuest(player, questId)
    print("StartQuest:", player, questId)
    questId = tonumber(questId)
    if not player then return false end
    local userId = player.UserId
    self.PlayerQuests[userId] = self.PlayerQuests[userId] or {}

    -- QuestConfig 支持通过 QuestId 查询
    local quest = QuestConfig:GetByQuestId(questId)
    if not quest then
        warn("StartQuest: 未找到任务配置:", questId)
        return false
    end

    -- 规范化任务数组并初始化进度
    local tasks = normalizeQuestTasks(quest)
    local progress = {
        QuestId = quest.QuestId,
        QuestName = quest.QuestName,
        RewardItem = quest.RewardItem,
        Tasks = {},
        Completed = false,
    }
    for _, t in ipairs(tasks) do
        table.insert(progress.Tasks, initTaskProgress(t))
    end

    self.PlayerQuests[userId][tostring(progress.QuestId)] = progress
    -- 通知客户端
    self.Client.QuestUpdated:Fire(player, self.PlayerQuests[userId])
    -- 持久化到数据库
    self:SavePlayerQuests(player)
    return true
end

-- 放弃任务
-- @param player Player 玩家对象
-- @param questId number 任务ID
-- @return boolean 是否成功
function TaskService:AbandonQuest(player, questId)
    if not player then return false end
    local userId = player.UserId
    questId = tostring(questId)
    if self.PlayerQuests[userId] and self.PlayerQuests[userId][questId] then
        self.PlayerQuests[userId][questId] = nil
        self.Client.QuestUpdated:Fire(player, self.PlayerQuests[userId])
        -- 持久化到数据库
        self:SavePlayerQuests(player)
        return true
    end
    return false
end

-- 获取玩家的所有任务进度
-- @param player Player 玩家对象
-- @return table 进度列表
function TaskService:GetPlayerTasks(player)
    if not player then return {} end
    return self.PlayerQuests[player.UserId] or {}
end

-- 内部：检查任务是否全部完成并发放奖励
-- @param player Player 玩家对象
-- @param progress table 某一任务的进度对象
-- @return void
function TaskService:_checkAndComplete(player, progress)
    for _, tp in ipairs(progress.Tasks) do
        if not tp.Done then
            return -- 尚未完成
        end
    end

    progress.Completed = true
    -- 发放奖励（物品）：使用 Knit.GetService 调用 AddItem
    -- RewardItem 支持两种格式：
    -- 1) 数组内元素为 number（直接代表 ItemId）
    -- 2) 数组内元素为 table，且包含字段 ItemId
    if progress.RewardItem then
        for _, reward in ipairs(progress.RewardItem) do
            local rewardId = (type(reward) == "table" and reward.ItemId) or reward
            if rewardId then
                pcall(function()
                    Knit.GetService("InventoryService"):AddItem(player, { ItemId = rewardId })
                end)
            end
        end
    end
end

-- 进度更新后统一通知客户端
-- @param player Player 玩家对象
-- @return void
function TaskService:_notify(player)
    self.Client.QuestUpdated:Fire(player, self.PlayerQuests[player.UserId])
    -- 持久化到数据库（保存全部任务数据）
    self:SavePlayerQuests(player)
end

-- 事件：拾取物品（环境实体/击杀掉落）
-- 该事件由地图交互或拾取逻辑调用
-- @param player Player 玩家对象
-- @param itemId number 物品ID
-- @param worldPos table {X,Y,Z} 拾取位置（用于定点搜寻判断）
-- @return void
function TaskService:OnItemPicked(player, itemId, worldPos)
    if not player then return end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return end

    for _, progress in pairs(quests) do
        if progress.Completed then continue end
        for _, tp in ipairs(progress.Tasks) do
            if tp.Done then continue end

            if tp.Type == GameConfig.TaskType.CollectItem then
                if tp.TargetCounts and tp.TargetCounts[itemId] then
                    tp.Counts[itemId] = math.min((tp.Counts[itemId] or 0) + 1, tp.TargetCounts[itemId])
                    if tp.Counts[itemId] >= tp.TargetCounts[itemId] then
                        -- 检查所有都达成
                        local allReached = true
                        for id, target in pairs(tp.TargetCounts) do
                            if (tp.Counts[id] or 0) < target then
                                allReached = false
                                break
                            end
                        end
                        tp.Done = allReached
                    end
                end
            elseif tp.Type == GameConfig.TaskType.RetrieveAtLocation then
                if itemId == tp.ItemId and inRange(tp.Pos, worldPos, tp.Range) then
                    tp.Collected = true
                    tp.Done = true
                end
            elseif tp.Type == GameConfig.TaskType.KillMonster then
                -- 击杀掉落搜寻：如果拾取的是击杀后掉落的任务物品，可按 CollectItem 计数
                if tp.TargetCounts and tp.TargetCounts[itemId] then
                    tp.Counts[itemId] = math.min((tp.Counts[itemId] or 0) + 1, tp.TargetCounts[itemId])
                    local allReached = true
                    for id, target in pairs(tp.TargetCounts) do
                        if (tp.Counts[id] or 0) < target then
                            allReached = false
                            break
                        end
                    end
                    tp.Done = allReached
                end
            elseif tp.Type == GameConfig.TaskType.PlaceAtLocation then
                -- 放置类的拾取事件一般不触发进度，这里忽略
            end
        end
        self:_notify(player)
    end
end

-- 事件：在指定位置放置物品
-- @param player Player 玩家对象
-- @param itemId number 物品ID
-- @param worldPos table {X,Y,Z} 放置位置
-- @return void
function TaskService:OnPlaceItem(player, itemId, worldPos)
    if not player then return end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return end

    for _, progress in pairs(quests) do
        if progress.Completed then continue end
        for _, tp in ipairs(progress.Tasks) do
            if tp.Done then continue end
            if tp.Type == GameConfig.TaskType.PlaceAtLocation then
                if itemId == tp.ItemId and inRange(tp.Pos, worldPos, 5) then
                    tp.Placed = true
                    tp.Done = true
                end
            end
        end
        self:_notify(player)
    end
end

-- 事件：进入或侦查某个区域
-- @param player Player 玩家对象
-- @param worldPos table {X,Y,Z} 玩家当前位置
-- @return void
function TaskService:OnEnterArea(player, worldPos)
    if not player then return end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return end

    for _, progress in pairs(quests) do
        if progress.Completed then continue end
        for _, tp in ipairs(progress.Tasks) do
            if tp.Done then continue end
            if tp.Type == GameConfig.TaskType.ScoutArea and inRange(tp.Pos, worldPos, tp.Range) then
                tp.Visited = true
                tp.Done = true
            end
        end
        self:_notify(player)
    end
end

-- 事件：击杀 NPC/玩家（由战斗系统调用）
-- @param killer Player 击杀者
-- @param monsterId number 被击杀对象ID（或类型ID）
-- @param info table 附加信息，如 {ItemId=武器ID, HitPart="Head"}
-- @return void
function TaskService:OnNPCKilled(killer, monsterId, info)
    if not killer then return end
    local quests = self.PlayerQuests[killer.UserId]
    if not quests then return end

    for _, progress in pairs(quests) do
        if progress.Completed then continue end
        local progressChanged = false -- 仅当子任务进度发生变化时才通知客户端
        for _, tp in ipairs(progress.Tasks) do
            if tp.Done then continue end
            if tp.Type == GameConfig.TaskType.KillMonster then
                if tp.TargetCounts and tp.TargetCounts[monsterId] then
                    local beforeCount = tp.Counts[monsterId] or 0
                    local beforeDone = tp.Done
                    tp.Counts[monsterId] = math.min(beforeCount + 1, tp.TargetCounts[monsterId])
                    local allReached = true
                    for id, target in pairs(tp.TargetCounts) do
                        if (tp.Counts[id] or 0) < target then
                            allReached = false
                            break
                        end
                    end
                    tp.Done = allReached
                    if tp.Counts[monsterId] ~= beforeCount or tp.Done ~= beforeDone then
                        progressChanged = true
                    end
                end
            elseif tp.Type == GameConfig.TaskType.UseSpecificItemOnTarget then
                if monsterId == tp.MonsterId and info and info.ItemId == tp.ItemId then
                    local beforeCurrent = tp.Current or 0
                    local beforeDone = tp.Done
                    tp.Current = math.min(beforeCurrent + 1, tp.TargetNum)
                    tp.Done = (tp.Current >= tp.TargetNum)
                    if tp.Current ~= beforeCurrent or tp.Done ~= beforeDone then
                        progressChanged = true
                    end
                end
            end
        end
        if progressChanged then
            self:_notify(killer)
        end
    end
end

-- 事件：撤离成功（由关卡/地图系统调用）
-- @param player Player 玩家对象
-- @param mapId any 地图标识
-- @param exitId any 撤离点标识
-- @param usedRevive boolean 是否使用复活
-- @return void
function TaskService:OnExfil(player, mapId, exitId, usedRevive)
    if not player then return end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return end

    for _, progress in pairs(quests) do
        if progress.Completed then continue end
        for _, tp in ipairs(progress.Tasks) do
            if tp.Done then continue end
            if tp.Type == GameConfig.TaskType.Exfil then
                local okMap = (tp.MapId == nil) or (tp.MapId == mapId)
                local okExit = (tp.ExitId == nil) or (tp.ExitId == exitId)
                local okNoRevive = (not tp.NoRevive) or (tp.NoRevive and not usedRevive)
                if okMap and okExit and okNoRevive then
                    tp.Exfiled = true
                    tp.Done = true
                end
            end
        end
        self:_notify(player)
    end
end

-- 指定提交：从玩家背包中扣除任务所需物品
-- @param player Player 玩家对象
-- @param questId number 任务ID
-- @return boolean 是否提交成功
function TaskService:SubmitItems(player, questId)
    questId = tostring(questId)
    if not player then return false end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return false end
    local progress = quests[questId]
    if not progress then return false end

    -- 阶段性提交（仅对可完整满足的 CollectItem 子任务做扣除并标记完成）
    -- 步骤：
    -- 1) 统计玩家背包各 ItemId 的数量；
    -- 2) 按子任务逐项检查是否可满足 tp.TargetCounts；
    -- 3) 仅对可满足的子任务调用 RemoveItemsByNum 扣除对应物品；
    -- 4) 扣除成功且数量满足后，标记该子任务完成，其它子任务不变；
    -- 5) 不触发整条任务奖励，除非全部子任务均完成（由 _checkAndComplete 控制）。

    if not InventoryService then return false end
    local inventory = InventoryService:GetInventoryData(player)
    if not inventory then return false end

    -- 统计当前库存数量
    local invCounts = {}
    for _, itemData in ipairs(inventory) do
        local id = itemData.ItemId
        invCounts[id] = (invCounts[id] or 0) + 1
    end

    local anySubmitted = false

    for _, tp in ipairs(progress.Tasks) do
        if tp.Type == GameConfig.TaskType.CollectItem and not tp.Done and tp.TargetCounts then
            -- 检查该子任务是否可被完全满足
            local canFulfill = true
            for itemId, needNum in pairs(tp.TargetCounts) do
                if (invCounts[itemId] or 0) < needNum then
                    canFulfill = false
                    break
                end
            end

            if canFulfill then
                -- 针对该子任务执行扣除
                local itemsToRemove = {}
                for itemId, needNum in pairs(tp.TargetCounts) do
                    itemsToRemove[itemId] = needNum
                end

                local ok, removedOk, removedMap = pcall(function()
                    local suc, removed = InventoryService:RemoveItemsByNum(player, itemsToRemove)
                    return suc, removed
                end)

                if ok and removedOk then
                    -- 验证移除数量是否满足该子任务需求
                    local allSatisfied = true
                    for itemId, needNum in pairs(itemsToRemove) do
                        local got = (removedMap and removedMap[itemId]) or 0
                        if got < needNum then
                            allSatisfied = false
                            break
                        end
                    end

                    if allSatisfied then
                        tp.Done = true
                        -- 维护显示用的计数（若存在 Counts 字段）
                        if tp.Counts then
                            for itemId, needNum in pairs(tp.TargetCounts) do
                                tp.Counts[itemId] = needNum
                            end
                        end
                        -- 同步本地库存计数，避免后续子任务重复扣除过量
                        for itemId, needNum in pairs(itemsToRemove) do
                            invCounts[itemId] = math.max((invCounts[itemId] or 0) - needNum, 0)
                        end
                        anySubmitted = true
                    end
                end
            end
        end
    end

    if anySubmitted then
        self:_notify(player)
        return true
    end
    return false
end

-- 提交任务（完成任务）
-- 逻辑（混合任务更精细）：
-- 1) 若存在未完成的 CollectItem 子任务，先尝试调用 SubmitItems 进行扣物；
-- 2) 无论是否存在 CollectItem，统一在扣物后检查所有子任务是否完成；
-- 3) 仅当所有子任务都完成时，标记整条任务完成并返回 true，否则返回 false。
-- @param player Player 玩家对象
-- @param questId number 任务ID
-- @return boolean 是否提交成功
function TaskService:SubmitTask(player, questId)
    questId = tostring(questId)
    if not player then return false end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return false end
    local progress = quests[questId]
    if not progress then return false end

    -- 若存在未完成 CollectItem 子任务，尝试扣物
    local hasPendingCollectItem = false
    for _, tp in ipairs(progress.Tasks) do
        if tp.Type == GameConfig.TaskType.CollectItem and not tp.Done then
            hasPendingCollectItem = true
            break
        end
    end
    if hasPendingCollectItem then
        -- 尝试扣物；不直接返回，以便统一完成性检查
        self:SubmitItems(player, questId)
    end

    -- 扣物后统一检查是否全部完成
    local allDone = true
    for _, tp in ipairs(progress.Tasks) do
        if not tp.Done then
            allDone = false
            break
        end
    end

    if not allDone then
        return false
    end

    -- 所有子任务已完成，提交并标记任务完成
    progress.Completed = true
    self:_notify(player)
    self:_checkAndComplete(player, progress)
    return true
end

-- 将玩家的任务进度保存到数据库
-- @param player Player 玩家对象
-- @return void
function TaskService:SavePlayerQuests(player)
    if not player or not DBService then return end
    local userId = player.UserId
    local data = self.PlayerQuests[userId] or {}
    pcall(function()
        DBService:Set(userId, "QuestData", data)
    end)
end

-- 从数据库恢复玩家的任务进度
-- @param player Player 玩家对象
-- @return void
function TaskService:LoadPlayerQuests(player, questData)
    if not player or not DBService then return end
    local userId = player.UserId
    self.PlayerQuests[userId] = questData
    self.Client.QuestUpdated:Fire(player, self.PlayerQuests[userId])
end

function TaskService:GetQuestFromDBService(userId, questData)
	local player = game.Players:GetPlayerByUserId(userId)
	self:LoadPlayerQuests(player, questData)
end

function TaskService:TriggerTask(player)
    Knit.GetService("ClientUIService"):ShowSingleUI(player, "TaskUI", self.PlayerQuests[player.UserId])
end

return TaskService