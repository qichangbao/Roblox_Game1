-- PlayerService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local TalentTreeConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("TalentTreeConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local PlayerService = Knit.CreateService {
	Name = "PlayerService",
	Client = {
	},

    TalentData = {},       -- 能力列表
    Overwhelmed = {},       -- 负重
    CollectSpeed = {},       -- 搜集速度
    Lucky = {},              -- 幸运
    AnimationTracks = {},
}

function PlayerService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function PlayerService:KnitStart()
    local function PlayerAdded(player)
        local function characterAdd(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                humanoid.AutoJumpEnabled = false
                humanoid.UseJumpPower = true
                humanoid:SetAttribute("InitHealth", humanoid.Health)
                humanoid:SetAttribute("InitWalkSpeed", humanoid.WalkSpeed)
                humanoid:SetAttribute("InitJumpPower", humanoid.JumpPower)
                humanoid:SetAttribute("InitMaxHealth", humanoid.MaxHealth)
                
                if self.TalentData[player.UserId] then
                    self:InitPlayerTalent(player, self.TalentData[player.UserId])
                end
            end
            Knit.GetService("LevelService"):CreatePlayerBillboard(player)

            self.AnimationTracks[player.UserId] = {}
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                -- 定义动画映射表
                local animationMap = {
                    swing = {"rbxassetid://107273238071706", "rbxassetid://90203983110020"},
                    dig = {"rbxassetid://96906531402562", "rbxassetid://82370673878002"},
                }
                
                -- 预加载所有动画
                for animName, animInfo in pairs(animationMap) do
                    local animation = Instance.new("Animation")
                    if humanoid.RigType == Enum.HumanoidRigType.R6 then
                        animation.AnimationId = animInfo[1]
                    else
                        animation.AnimationId = animInfo[2]
                    end
                    
                    local success, track = pcall(function()
                        return animator:LoadAnimation(animation)
                    end)
                    
                    if success and track then
                        track.Priority = Enum.AnimationPriority.Action
                        track.Looped = false
                        self.AnimationTracks[player.UserId][animName] = track
                    end
                end

                local gameSound = Interface.safeWaitPart(game:GetService("SoundService"), "GAME")
                local music1 = Interface.safeWaitPart(gameSound, "Attack1")
                music1.Name = "Attack1"
                if not music1.IsLoaded then
                    music1.Loaded:Wait()
                end
                music1.Parent = character

                local music2 = Interface.safeWaitPart(gameSound, "Attack2")
                music2.Name = "Attack2"
                if not music2.IsLoaded then
                    music2.Loaded:Wait()
                end
                music2.Parent = character
            end
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
        self.AnimationTracks[player.UserId] = nil
        self.TalentData[player.UserId] = nil
        self.Overwhelmed[player.UserId] = nil
        self.CollectSpeed[player.UserId] = nil
        self.Lucky[player.UserId] = nil

        local DBService = Knit.GetService("DBService")
        DBService:PlayerRemoving(player)
        Knit.GetService("InventoryService"):PlayerRemoved(player)
        Knit.GetService("GoldService"):PlayerRemoved(player)
        Knit.GetService("RankService"):PlayerRemoved(player)
        Knit.GetService("LevelService"):PlayerRemoved(player)
        Knit.GetService("TalentService"):PlayerRemoved(player)
        Knit.GetService("GMService"):PlayerRemoved(player)
        Knit.GetService("QuestService"):PlayerRemoved(player)
        Knit.GetService("EquipmentService"):PlayerRemoved(player)
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
    local rankPersonalData = Knit.GetService("RankService"):GetPersonalDataWithRank(player)
    local rankData = Knit.GetService("RankService"):GetLeaderboard()
    local talentData = Knit.GetService("TalentService"):GetTalentData(player)
    local questData = Knit.GetService("QuestService"):GetPlayerQuests(player)
    local isAdmin = Knit.GetService("DBService"):IsAdmin(player)
    self.TalentData[player.UserId] = talentData
    self.Overwhelmed[player.UserId] = GameConfig.Overwhelmed
    self.CollectSpeed[player.UserId] = GameConfig.CollectSpeed
    self.Lucky[player.UserId] = GameConfig.Lucky
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetAttribute("Weight", self.Overwhelmed[player.UserId])
        humanoid:SetAttribute("CollectSpeed", self.CollectSpeed[player.UserId])
        humanoid:SetAttribute("Lucky", self.Lucky[player.UserId])
    end
    self:InitPlayerTalent(player, self.TalentData[player.UserId])

    local weight = self.Overwhelmed[player.UserId]
    local collectSpeed = self.CollectSpeed[player.UserId]
    local lucky = self.Lucky[player.UserId]
    if humanoid then
        weight = humanoid:GetAttribute("Weight")
        collectSpeed = humanoid:GetAttribute("CollectSpeed")
        lucky = humanoid:GetAttribute("Lucky")
    end

    return {
        Gold = gold,
        Inventory = inventoryData,
        ToolData = toolData,
        EquipmentData = equipmentData,
        TalentData = self.TalentData[player.UserId],
        RankPersonalData = rankPersonalData,
        RankData = rankData,
        IsAdmin = isAdmin,
        IsFromFuben = isFromFuben,
        QuestData = questData,
        Weight = weight,
        CollectSpeed = collectSpeed,
        Lucky = lucky,
    }
end

-- 客户端远程方法：获取玩家数据
-- @param player Player 请求数据的玩家
-- @return table 玩家数据
function PlayerService.Client:GetInitData(player)
    return self.Server:GetInitData(player)
end

-- 获取玩家负重
-- @param player Player 请求数据的玩家
-- @return number 玩家负重
function PlayerService:GetOverwhelmed(player)
    return self.Overwhelmed[player.UserId]
end

-- 获取玩家搜集速度
-- @param player Player 请求数据的玩家
-- @return number 玩家搜集速度
function PlayerService:GetCollectSpeed(player)
    return self.CollectSpeed[player.UserId]
end

-- 获取玩家幸运值
-- @param player Player 请求数据的玩家
-- @return number 玩家幸运值
function PlayerService:GetLucky(player)
    return self.Lucky[player.UserId]
end

-- 初始化玩家能力
-- @param player Player 玩家
-- @param talent table 能力数据
function PlayerService:InitPlayerTalent(player, talent)
    if not talent then
        return
    end
    for talentId, talentData in pairs(talent) do
        local talentInfo = TalentTreeConfig:GetByTalentTreeId(tonumber(talentId))
        if talentInfo then
            if talentInfo.Type == GameConfig.TalentType.WalkSpeed then
                local initWalkSpeed = player:GetAttribute("InitWalkSpeed")
                if initWalkSpeed then
                    if talentInfo.ChildType == 1 then
                        self:ChangePlayerAttribute(player, "WalkSpeed", initWalkSpeed *  (1 + talentInfo.Value / 100))
                    else
                        self:ChangePlayerAttribute(player, "WalkSpeed", initWalkSpeed +  talentInfo.Value)
                    end
                end
            elseif talentInfo.Type == GameConfig.TalentType.MaxHealth then
                local initMaxHealth = player:GetAttribute("InitMaxHealth")
                if initMaxHealth then
                    if talentInfo.ChildType == 1 then
                        self:ChangePlayerAttribute(player, "MaxHealth", initMaxHealth * (1 + talentInfo.Value / 100))
                        self:ChangePlayerAttribute(player, "Health", initMaxHealth * (1 + talentInfo.Value / 100))
                    else
                        self:ChangePlayerAttribute(player, "MaxHealth", initMaxHealth + talentInfo.Value)
                        self:ChangePlayerAttribute(player, "Health", initMaxHealth + talentInfo.Value)
                    end
                end
            elseif talentInfo.Type == GameConfig.TalentType.Jump then
                local initJumpPower = player:GetAttribute("InitJumpPower")
                if initJumpPower then
                    if talentInfo.ChildType == 1 then
                        self:ChangePlayerAttribute(player, "JumpPower", initJumpPower * (1 + talentInfo.Value / 100))
                    else
                        self:ChangePlayerAttribute(player, "JumpPower", initJumpPower + talentInfo.Value)
                    end
                end
            elseif talentInfo.Type == GameConfig.TalentType.Weight then
                local initWeight = self:GetOverwhelmed(player)
                if initWeight then
                    if talentInfo.ChildType == 1 then
                        self:ChangePlayerAttribute(player, "Weight", initWeight * (1 + talentInfo.Value / 100))
                    else
                        self:ChangePlayerAttribute(player, "Weight", initWeight + talentInfo.Value)
                    end
                end
            elseif talentInfo.Type == GameConfig.TalentType.CollectSpeed then
                local initCollectSpeed = self:GetCollectSpeed(player)
                if initCollectSpeed then
                    if talentInfo.ChildType == 1 then
                        self:ChangePlayerAttribute(player, "CollectSpeed", initCollectSpeed * (1 + talentInfo.Value / 100))
                    else
                        self:ChangePlayerAttribute(player, "CollectSpeed", initCollectSpeed + talentInfo.Value)
                    end
                end
            elseif talentInfo.Type == GameConfig.TalentType.Lucky then
                local initLucky = self:GetLucky(player)
                if initLucky then
                    if talentInfo.ChildType == 1 then
                        self:ChangePlayerAttribute(player, "Lucky", initLucky * (1 + talentInfo.Value / 100))
                    else
                        self:ChangePlayerAttribute(player, "Lucky", initLucky + talentInfo.Value)
                    end
                end
            end
        end
    end
end

function PlayerService:ChangePlayerAttribute(player, attributeName, attributeValue)
    if not player or not player.Character then
        return
    end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if attributeValue then
        if attributeName == "Health" then
            humanoid.Health = attributeValue
        elseif attributeName == "WalkSpeed" then
            humanoid.WalkSpeed = attributeValue
        elseif attributeName == "MaxHealth" then
            humanoid.MaxHealth = attributeValue
        elseif attributeName == "JumpPower" then
            humanoid.JumpPower = attributeValue
        elseif attributeName == "Weight" then
            humanoid:SetAttribute("Weight", attributeValue)
        elseif attributeName == "CollectSpeed" then
            humanoid:SetAttribute("CollectSpeed", attributeValue)
        elseif attributeName == "Lucky" then
            humanoid:SetAttribute("Lucky", attributeValue)
        end
    else
        if attributeName == "Health" then
            humanoid.Health = humanoid:GetAttribute("InitHealth")
        elseif attributeName == "WalkSpeed" then
            humanoid.WalkSpeed = humanoid:GetAttribute("InitWalkSpeed")
        elseif attributeName == "MaxHealth" then
            humanoid.MaxHealth = humanoid:GetAttribute("InitMaxHealth")
        elseif attributeName == "JumpPower" then
            humanoid.JumpPower = humanoid:GetAttribute("InitJumpPower")
        elseif attributeName == "Weight" then
            humanoid:SetAttribute("Weight", self:GetOverwhelmed(player))
        elseif attributeName == "CollectSpeed" then
            humanoid:SetAttribute("CollectSpeed", self:GetCollectSpeed(player))
        elseif attributeName == "Lucky" then
            humanoid:SetAttribute("Lucky", self:GetLucky(player))
        end
    end
end

-- 播放挥舞动画
-- @param player Player 玩家对象
-- @param cd number 冷却时间，用于调整动画播放速度 (cd越小动画越快，cd越大动画越慢)
function PlayerService:PlaySwingAnimation(player, cd)
    if not self.AnimationTracks[player.UserId] or not self.AnimationTracks[player.UserId]["swing"] then
        return
    end
    
    local animationTrack = self.AnimationTracks[player.UserId]["swing"]
    
    -- 获取动画的总时长
    local animationLength = animationTrack.Length
    
    -- 根据cd参数和动画时长计算播放速度
    -- 目标：让动画在cd秒内播放完成
    local playbackSpeed = cd / animationLength
    animationTrack:AdjustSpeed(playbackSpeed)
    animationTrack:Play()
end

-- 播放挖掘动画函数（从下往上）
-- @param player Player 玩家对象
-- @param cd number 冷却时间，用于调整动画播放速度 (cd越小动画越快，cd越大动画越慢)
function PlayerService:PlayDigAnimation(player, cd)
    if not self.AnimationTracks[player.UserId] or not self.AnimationTracks[player.UserId]["dig"] then
        return
    end
    
    local animationTrack = self.AnimationTracks[player.UserId]["dig"]
    
    -- 获取动画的总时长
    local animationLength = animationTrack.Length
    
    -- 根据cd参数和动画时长计算播放速度
    -- 目标：让动画在cd秒内播放完成
    local playbackSpeed = cd / animationLength
    animationTrack:AdjustSpeed(playbackSpeed)
    animationTrack:Play()
end

function PlayerService:playAnimation(player, animationName, soundName, cd)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if animationName == "dig" then
        self:PlayDigAnimation(player, cd)
    else
        self:PlaySwingAnimation(player, cd)
    end

    local music = character:FindFirstChild(soundName)
    if music then
        music:Play()
    end
end

return PlayerService