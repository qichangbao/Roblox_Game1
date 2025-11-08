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
        QuestCompleted = Knit.CreateSignal(), -- 客户端监听任务完成

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
            tp.Counts[item.MonsterId] = 0
            tp.TargetCounts = tp.TargetCounts or {}
            tp.TargetCounts[item.MonsterId] = item.Num or 1
        end
    elseif taskDef.Type == GameConfig.TaskType.CollectItem then
        -- v: 数组 { {ItemId, Num}, ... }
        tp.Counts = {}
        for _, item in ipairs(v or {}) do
            tp.Counts[item.ItemId] = 0
            tp.TargetCounts = tp.TargetCounts or {}
            tp.TargetCounts[item.ItemId] = item.Num or 1
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
    if not player then return false end
    local userId = player.UserId
    self.PlayerQuests[userId] = self.PlayerQuests[userId] or {}

    -- QuestConfig 支持通过 QuestId 查询
    local quest = QuestConfig:GetByQuestId(questId) or QuestConfig.Data[questId]
    if not quest then
        warn("StartQuest: 未找到任务配置:", questId)
        return false
    end

    -- 规范化任务数组并初始化进度
    local tasks = normalizeQuestTasks(quest)
    local progress = {
        QuestId = quest.QuestId or questId,
        QuestName = quest.QuestName,
        RewardItem = quest.RewardItem,
        Tasks = {},
        Completed = false,
    }
    for _, t in ipairs(tasks) do
        table.insert(progress.Tasks, initTaskProgress(t))
    end

    self.PlayerQuests[userId][progress.QuestId] = progress
    -- 通知客户端
    self.Client.QuestUpdated:Fire(player, progress)
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
    if self.PlayerQuests[userId] and self.PlayerQuests[userId][questId] then
        self.PlayerQuests[userId][questId] = nil
        self.Client.QuestUpdated:Fire(player, {QuestId = questId, Abandoned = true})
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
    -- 发放奖励（物品）
    if InventoryService and progress.RewardItem then
        for _, reward in ipairs(progress.RewardItem) do
            local itemData = { ItemId = reward.ItemId, Attribute = {} }
            pcall(function()
                InventoryService:AddItem(player, itemData)
            end)
        end
    end

    -- 通知客户端完成
    self.Client.QuestCompleted:Fire(player, progress)
    -- 持久化到数据库（保存全部任务数据）
    self:SavePlayerQuests(player)
end

-- 进度更新后统一通知客户端
-- @param player Player 玩家对象
-- @param progress table 任务进度对象
-- @return void
function TaskService:_notify(player, progress)
    self.Client.QuestUpdated:Fire(player, progress)
    self:_checkAndComplete(player, progress)
    -- 每次进度变动都进行持久化保存
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
        self:_notify(player, progress)
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
        self:_notify(player, progress)
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
        self:_notify(player, progress)
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
        for _, tp in ipairs(progress.Tasks) do
            if tp.Done then continue end
            if tp.Type == GameConfig.TaskType.KillMonster then
                if tp.TargetCounts and tp.TargetCounts[monsterId] then
                    tp.Counts[monsterId] = math.min((tp.Counts[monsterId] or 0) + 1, tp.TargetCounts[monsterId])
                    local allReached = true
                    for id, target in pairs(tp.TargetCounts) do
                        if (tp.Counts[id] or 0) < target then
                            allReached = false
                            break
                        end
                    end
                    tp.Done = allReached
                end
            elseif tp.Type == GameConfig.TaskType.UseSpecificItemOnTarget then
                if monsterId == tp.MonsterId and info and info.ItemId == tp.ItemId then
                    tp.Current = math.min((tp.Current or 0) + 1, tp.TargetNum)
                    tp.Done = (tp.Current >= tp.TargetNum)
                end
            end
        end
        self:_notify(killer, progress)
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
        self:_notify(player, progress)
    end
end

-- 指定提交：从玩家背包中扣除任务所需物品
-- @param player Player 玩家对象
-- @param questId number 任务ID
-- @return boolean 是否提交成功
function TaskService:SubmitItems(player, questId)
    if not player then return false end
    local quests = self.PlayerQuests[player.UserId]
    if not quests then return false end
    local progress = quests[questId]
    if not progress then return false end

    local hasSubmitTask = false
    local itemsToRemove = {}
    for _, tp in ipairs(progress.Tasks) do
        if tp.Type == GameConfig.TaskType.CollectItem and tp.TargetCounts then
            hasSubmitTask = true
            for itemId, needNum in pairs(tp.TargetCounts) do
                itemsToRemove[itemId] = needNum
            end
        end
    end

    if not hasSubmitTask then
        return false
    end

    if InventoryService and InventoryService.RemoveItemsByNum then
        local ok, removed = pcall(function()
            return InventoryService:RemoveItemsByNum(player, itemsToRemove)
        end)
        if ok and removed then
            -- 标记 CollectItem 任务完成
            for _, tp in ipairs(progress.Tasks) do
                if tp.Type == GameConfig.TaskType.CollectItem then
                    tp.Done = true
                end
            end
            self:_notify(player, progress)
            return true
        end
    end
    return false
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
    -- 将已有进度同步给客户端（UI 可刷新显示）
    for _, progress in pairs(questData) do
        self.Client.QuestUpdated:Fire(player, progress)
    end
end

function TaskService:TriggerTask(player)
    Knit.GetService("ClientUIService"):ShowSingleUI(player, "TaskUI", self.PlayerQuests[player.UserId])
end

return TaskService