-- PlayerService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local TalentTreeConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("TalentTreeConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local HeroConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("HeroConfig"))
local PlayerAttribute = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("PlayerAttribute"))

local PlayerService = Knit.CreateService {
	Name = "PlayerService",
	Client = {
	},

    TalentData = {},            -- 能力列表
    OfflineTime = {},           -- 离线时间
    AnimationMarkerConns = {},  -- 动画标记事件连接
}

function PlayerService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function PlayerService:KnitStart()
    local function PlayerAdded(player)
        local function characterAdd(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            humanoid.AutoJumpEnabled = false
            humanoid.UseJumpPower = true
            humanoid.Health = PlayerAttribute.GetMaxHealth(player)
            humanoid.WalkSpeed = PlayerAttribute.GetWalkSpeed(player)
            humanoid.JumpPower = PlayerAttribute.GetJumpPower(player)
            
            -- if self.TalentData[player.UserId] then
            --     self:InitPlayerTalent(player, self.TalentData[player.UserId])
            -- end
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

    local function PlayerRemoved(player)
        self.TalentData[player.UserId] = nil
        self.OfflineTime[player.UserId] = nil

        Knit.GetService("InventoryService"):PlayerRemoved(player)
        Knit.GetService("GoldService"):PlayerRemoved(player)
        Knit.GetService("RankService"):PlayerRemoved(player)
        Knit.GetService("LevelService"):PlayerRemoved(player)
        Knit.GetService("TalentService"):PlayerRemoved(player)
        Knit.GetService("GMService"):PlayerRemoved(player)
        Knit.GetService("QuestService"):PlayerRemoved(player)
        Knit.GetService("EquipmentService"):PlayerRemoved(player)
        Knit.GetService("JobService"):PlayerRemoved(player)

        local DBService = Knit.GetService("DBService")
        -- 在玩家离开时记录离开时间到数据库（仅时间戳）
        -- @param player Player 离开的玩家
        -- @details 写入字段 "LeaveGameTime" 为 Unix 时间戳（单位：秒），用于下次进入时计算累计离线时长
        local now = DateTime.now().UnixTimestamp
        DBService:Set(player.UserId, "LeaveGameTime", now)
        DBService:PlayerRemoving(player)
    end

    for _, player in pairs(Players:GetPlayers()) do
        PlayerAdded(player)
    end
	
	-- 监听玩家加入事件
	Players.PlayerAdded:Connect(function(player)
        PlayerAdded(player)
	end)

	-- 监听玩家离开事件
	Players.PlayerRemoving:Connect(function(player)
        PlayerRemoved(player)
	end)
end

function PlayerService:GetInitData(player)
    local DBService = Knit.GetService("DBService")
    DBService:PlayerAdded(player)

    Knit.GetService("JobService"):PlayerAdded(player)
    Knit.GetService("EquipmentService"):PlayerAdded(player)
    Knit.GetService("GoldService"):PlayerAdded(player)
    Knit.GetService("InventoryService"):PlayerAdded(player)
    Knit.GetService("RankService"):PlayerAdded(player)
    Knit.GetService("LevelService"):PlayerAdded(player)
    Knit.GetService("TalentService"):PlayerAdded(player)
    Knit.GetService("GMService"):PlayerAdded(player)
    Knit.GetService("QuestService"):PlayerAdded(player)
    
    local isFromFuben = false
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
        
        Knit.GetService("DBService"):Set(player.UserId, "IsFirstLoginFuben", 1)
        -- 更新等级数据
        Knit.GetService("LevelService"):Updata(player, teleportData.IsSuccess)
        isFromFuben = true
    end

    local gold = Knit.GetService("GoldService"):GetGoldData(player)
    local inventoryData = Knit.GetService("InventoryService"):GetInventoryData(player)
    local toolData = Knit.GetService("InventoryService"):GetToolData(player)
    local equipmentData = Knit.GetService("EquipmentService"):GetEquipmentData(player)
    local jobData = Knit.GetService("JobService"):GetJobData(player)
    local rankPersonalData = Knit.GetService("RankService"):GetPersonalDataWithRank(player)
    local rankData = Knit.GetService("RankService"):GetLeaderboard()
    local talentData = Knit.GetService("TalentService"):GetTalentData(player)
    local questData = Knit.GetService("QuestService"):GetPlayerQuests(player)
    local isAdmin = Knit.GetService("DBService"):IsAdmin(player)
    local curJobId = Knit.GetService("DBService"):Get(player.UserId, "CurJobId") or 0
    self:SetJobModel(player, tonumber(curJobId))
    self:RefreshAllPlayerAttribute(player)

    self.TalentData[player.UserId] = talentData
    --self:InitPlayerTalent(player, self.TalentData[player.UserId])

    local weight = PlayerAttribute.GetWeight(player)
    local lucky = PlayerAttribute.GetLucky(player)

    -- 计算并累计离线时长（基于上次离开时间）
    -- @function 统计累计离线时长
    -- @param player Player 当前加入的玩家
    -- @details 若存在上次离开时间（LeaveGameTime > 0），则将 (now - LeaveGameTime) 累加到 TotalOfflineSeconds
    local now = DateTime.now().UnixTimestamp
    self.OfflineTime[player.UserId] = 0
    local lastLeave = Knit.GetService("DBService"):Get(player.UserId, "LeaveGameTime") or 0
    if type(lastLeave) == "number" and lastLeave > 0 and now > lastLeave then
        self.OfflineTime[player.UserId] = now - lastLeave
    end

    return {
        Gold = gold,
        Inventory = inventoryData,
        ToolData = toolData,
        EquipmentData = equipmentData,
        TalentData = self.TalentData[player.UserId],
        JobData = jobData,
        CurJobId = tonumber(curJobId),
        RankPersonalData = rankPersonalData,
        RankData = rankData,
        IsAdmin = isAdmin,
        IsFromFuben = isFromFuben,
        QuestData = questData,
        Weight = weight,
        Lucky = lucky,
        OfflineTime = self.OfflineTime[player.UserId],
    }
end

-- 客户端远程方法：获取玩家数据
-- @param player Player 请求数据的玩家
-- @return table 玩家数据
function PlayerService.Client:GetInitData(player)
    return self.Server:GetInitData(player)
end

-- 获取玩家攻击力
-- @param player Player 请求数据的玩家
-- @return number 玩家攻击力
function PlayerService:GetAttack(player)
    return PlayerAttribute.GetAttack(player)
end

-- 获取玩家负重
-- @param player Player 请求数据的玩家
-- @return number 玩家负重
function PlayerService:GetWeight(player)
    return PlayerAttribute.GetWeight(player)
end

-- 获取玩家幸运值
-- @param player Player 请求数据的玩家
-- @return number 玩家幸运值
function PlayerService:GetLucky(player)
    return PlayerAttribute.GetLucky(player)
end

-- 获取玩家暴击概率
-- @param player Player 请求数据的玩家
-- @return number 玩家暴击概率
function PlayerService:GetCriticalProbability(player)
    return PlayerAttribute.GetCriticalProbability(player)
end

-- 获取玩家暴击伤害
-- @param player Player 请求数据的玩家
-- @return number 玩家暴击伤害
function PlayerService:GetCriticalValue(player)
    return PlayerAttribute.GetCriticalValue(player)
end

function PlayerService:GetOfflineTime(player)
    return self.OfflineTime[player.UserId] or 0
end

-- 设置玩家模型
-- @param player Player 请求数据的玩家
-- @param jobId number 玩家职业ID
function PlayerService:SetJobModel(player, jobId)
    if not player or not jobId then return end
    if not player.Character then return end
    local config = HeroConfig:GetById(tonumber(jobId))
    if not config then return end
    local model = config.Model
    if not model then return end
    local jobModel = ReplicatedStorage:FindFirstChild("JobModel"):FindFirstChild(model)
    if not jobModel then return end
    if jobModel:FindFirstChild("Shirt") then
        player.Character.Shirt.ShirtTemplate = jobModel.Shirt.ShirtTemplate
    end
    if jobModel:FindFirstChild("Pants") then
        player.Character.Pants.PantsTemplate = jobModel.Pants.PantsTemplate
    end
end

-- 获取玩家移动速度
-- @param player Player 请求数据的玩家
-- @return number 玩家移动速度
function PlayerService:GetWalkSpeed(player)
    local walkSpeed = PlayerAttribute.GetWalkSpeed(player)
    return walkSpeed
end

-- 获取玩家跑步速度
-- @param player Player 请求数据的玩家
-- @return number 玩家跑步速度
function PlayerService:GetRunSpeed(player)
    local runSpeed = PlayerAttribute.GetRunSpeed(player)
    return runSpeed
end

-- 获取玩家跳跃高度
-- @param player Player 请求数据的玩家
-- @return number 玩家跳跃高度
function PlayerService:GetJumpPower(player)
    local jumpPower = PlayerAttribute.GetJumpPower(player)
    return jumpPower
end

-- 刷新玩家属性
function PlayerService:RefreshPlayerAttribute(player, attributeName)
    if not player or not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if attributeName == "Health" then
        local health = PlayerAttribute.GetMaxHealth(player)
        humanoid.MaxHealth = health
        humanoid.Health = health
    elseif attributeName == "WalkSpeed" then
        humanoid.WalkSpeed = self:GetWalkSpeed(player)
    elseif attributeName == "RunSpeed" then
        humanoid:SetAttribute("RunSpeed", self:GetRunSpeed(player))
    elseif attributeName == "JumpPower" then
        humanoid.JumpPower = self:GetJumpPower(player)
    elseif attributeName == "Weight" then
        humanoid:SetAttribute("Weight", PlayerAttribute.GetWeight(player))
    elseif attributeName == "Lucky" then
        humanoid:SetAttribute("Lucky", PlayerAttribute.GetLucky(player))
    elseif attributeName == "CriticalProbability" then
        humanoid:SetAttribute("CriticalProbability", PlayerAttribute.GetCriticalProbability(player))
    elseif attributeName == "CriticalValue" then
        humanoid:SetAttribute("CriticalValue", PlayerAttribute.GetCriticalValue(player))
    elseif attributeName == "Attack" then
        humanoid:SetAttribute("Attack", PlayerAttribute.GetAttack(player))
    elseif attributeName == "Endurance" then
        humanoid:SetAttribute("Endurance", PlayerAttribute.GetEndurance(player))
    elseif attributeName == "EnduranceConsume" then
        humanoid:SetAttribute("EnduranceConsume", PlayerAttribute.GetEnduranceConsume(player))
    elseif attributeName == "EnduranceRecovery" then
        humanoid:SetAttribute("EnduranceRecovery", PlayerAttribute.GetEnduranceRecovery(player))
    end
end

-- 刷新所有玩家属性
function PlayerService:RefreshAllPlayerAttribute(player)
    for i, v in pairs(GameConfig.PlayerInitAttribute) do
        Knit.GetService("PlayerService"):RefreshPlayerAttribute(player, i)
    end
end

-- -- 初始化玩家能力
-- -- @param player Player 玩家
-- -- @param talent table 能力数据
-- function PlayerService:InitPlayerTalent(player, talent)
--     if not talent then
--         return
--     end
--     for talentId, talentData in pairs(talent) do
--         local talentInfo = TalentTreeConfig:GetByTalentTreeId(tonumber(talentId))
--         if talentInfo then
--             if talentInfo.Type == GameConfig.TalentType.WalkSpeed then
--                 local initWalkSpeed = player:GetAttribute("InitWalkSpeed")
--                 if initWalkSpeed then
--                     if talentInfo.ChildType == 1 then
--                         self:ChangePlayerAttribute(player, "WalkSpeed", initWalkSpeed *  (1 + talentInfo.Value / 100))
--                     else
--                         self:ChangePlayerAttribute(player, "WalkSpeed", initWalkSpeed +  talentInfo.Value)
--                     end
--                 end
--             elseif talentInfo.Type == GameConfig.TalentType.MaxHealth then
--                 local initMaxHealth = player:GetAttribute("InitMaxHealth")
--                 if initMaxHealth then
--                     if talentInfo.ChildType == 1 then
--                         self:ChangePlayerAttribute(player, "MaxHealth", initMaxHealth * (1 + talentInfo.Value / 100))
--                         self:ChangePlayerAttribute(player, "Health", initMaxHealth * (1 + talentInfo.Value / 100))
--                     else
--                         self:ChangePlayerAttribute(player, "MaxHealth", initMaxHealth + talentInfo.Value)
--                         self:ChangePlayerAttribute(player, "Health", initMaxHealth + talentInfo.Value)
--                     end
--                 end
--             elseif talentInfo.Type == GameConfig.TalentType.Jump then
--                 local initJumpPower = player:GetAttribute("InitJumpPower")
--                 if initJumpPower then
--                     if talentInfo.ChildType == 1 then
--                         self:ChangePlayerAttribute(player, "JumpPower", initJumpPower * (1 + talentInfo.Value / 100))
--                     else
--                         self:ChangePlayerAttribute(player, "JumpPower", initJumpPower + talentInfo.Value)
--                     end
--                 end
--             elseif talentInfo.Type == GameConfig.TalentType.Weight then
--                 local initWeight = self:GetOverwhelmed(player)
--                 if initWeight then
--                     if talentInfo.ChildType == 1 then
--                         self:ChangePlayerAttribute(player, "Weight", initWeight * (1 + talentInfo.Value / 100))
--                     else
--                         self:ChangePlayerAttribute(player, "Weight", initWeight + talentInfo.Value)
--                     end
--                 end
--             elseif talentInfo.Type == GameConfig.TalentType.CollectSpeed then
--                 local initCollectSpeed = self:GetCollectSpeed(player)
--                 if initCollectSpeed then
--                     if talentInfo.ChildType == 1 then
--                         self:ChangePlayerAttribute(player, "CollectSpeed", initCollectSpeed * (1 + talentInfo.Value / 100))
--                     else
--                         self:ChangePlayerAttribute(player, "CollectSpeed", initCollectSpeed + talentInfo.Value)
--                     end
--                 end
--             elseif talentInfo.Type == GameConfig.TalentType.Lucky then
--                 local initLucky = self:GetLucky(player)
--                 if initLucky then
--                     if talentInfo.ChildType == 1 then
--                         self:ChangePlayerAttribute(player, "Lucky", initLucky * (1 + talentInfo.Value / 100))
--                     else
--                         self:ChangePlayerAttribute(player, "Lucky", initLucky + talentInfo.Value)
--                     end
--                 end
--             end
--         end
--     end
-- end

function PlayerService:SwitchWalkOrRun(player, state)
    if not player then return end

    if player.Character and player.Character.Humanoid then
        if state == 0 then
            player.Character.Humanoid.WalkSpeed = self:GetWalkSpeed(player)
        else
            player.Character.Humanoid.WalkSpeed = self:GetRunSpeed(player)
        end
    end
end

-- 客户端切换走跑
function PlayerService.Client:SwitchWalkOrRun(player, state)
    return self.Server:SwitchWalkOrRun(player, state)
end

return PlayerService
