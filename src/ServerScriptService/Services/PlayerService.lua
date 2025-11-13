-- PlayerService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local AbilityConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("AbilityConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local PlayerService = Knit.CreateService {
	Name = "PlayerService",
	Client = {
	},

    AbilityData = {},       -- 能力列表
    Overwhelmed = {},       -- 负重
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
                player:SetAttribute("InitHealth", humanoid.Health)
                player:SetAttribute("InitWalkSpeed", humanoid.WalkSpeed)
                player:SetAttribute("InitJumpPower", humanoid.JumpPower)
                player:SetAttribute("InitMaxHealth", humanoid.MaxHealth)
                player:SetAttribute("InitAttack", 1)
                
                if self.AbilityData[player.UserId] then
                    self:InitPlayerAbility(player, self.AbilityData[player.UserId])
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
        self.AbilityData[player.UserId] = nil

        local DBService = Knit.GetService("DBService")
        DBService:PlayerRemoving(player)
        Knit.GetService("InventoryService"):PlayerRemoved(player)
        Knit.GetService("GoldService"):PlayerRemoved(player)
        Knit.GetService("RankService"):PlayerRemoved(player)
        Knit.GetService("LevelService"):PlayerRemoved(player)
        Knit.GetService("AbilityService"):PlayerRemoved(player)
        Knit.GetService("GMService"):PlayerRemoved(player)
        Knit.GetService("QuestService"):PlayerRemoved(player)
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

    Knit.GetService("GoldService"):PlayerAdded(player)
    Knit.GetService("InventoryService"):PlayerAdded(player)
    Knit.GetService("RankService"):PlayerAdded(player)
    Knit.GetService("LevelService"):PlayerAdded(player)
    Knit.GetService("AbilityService"):PlayerAdded(player)
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
    local rankPersonalData = Knit.GetService("RankService"):GetPersonalDataWithRank(player)
    local rankData = Knit.GetService("RankService"):GetLeaderboard()
    local abilityData = Knit.GetService("AbilityService"):GetAbilityData(player)
    local questData = Knit.GetService("QuestService"):GetPlayerQuests(player)
    local isAdmin = Knit.GetService("DBService"):IsAdmin(player)
    local overwhelmed = DBService:Get(player.UserId, "Overwhelmed")
    self.AbilityData[player.UserId] = abilityData
    self:InitPlayerAbility(player, self.AbilityData[player.UserId])
    self.Overwhelmed[player.UserId] = overwhelmed

    return {
        Gold = gold,
        Inventory = inventoryData,
        ToolData = toolData,
        AbilityData = self.AbilityData[player.UserId],
        RankPersonalData = rankPersonalData,
        RankData = rankData,
        IsAdmin = isAdmin,
        IsFromFuben = isFromFuben,
        QuestData = questData,
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

-- 初始化玩家能力
-- @param player Player 玩家
-- @param ability table 能力数据
function PlayerService:InitPlayerAbility(player, ability)
    if not ability then
        return
    end
    for abilityId, abilityData in pairs(ability) do
        local level = abilityData.Level
        if not level or level <= 0 then
            continue
        end
        local abilityInfo = AbilityConfig:GetByAbilityId(abilityId)
        if abilityInfo then
            local value = 1
            if type(abilityInfo.Value) == "table" then
                value = (1 + abilityInfo.Value[level] / 100)
            else
                value = (1 + abilityInfo.Value * level / 100)
            end
            if abilityInfo.Type == GameConfig.AbilityType.WalkSpeed then
                local initWalkSpeed = player:GetAttribute("InitWalkSpeed")
                if initWalkSpeed then
                    self:ChangePlayerAttribute(player, "WalkSpeed", initWalkSpeed * value)
                end
            elseif abilityInfo.Type == GameConfig.AbilityType.MaxHealth then
                local initMaxHealth = player:GetAttribute("InitMaxHealth")
                if initMaxHealth then
                    self:ChangePlayerAttribute(player, "MaxHealth", initMaxHealth * value)
                    self:ChangePlayerAttribute(player, "Health", initMaxHealth * value)
                end
            elseif abilityInfo.Type == GameConfig.AbilityType.Jump then
                local initJumpPower = player:GetAttribute("InitJumpPower")
                if initJumpPower then
                    self:ChangePlayerAttribute(player, "JumpPower", initJumpPower * value)
                end
            elseif abilityInfo.Type == GameConfig.AbilityType.Attack then
                local initAttack = player:GetAttribute("InitAttack")
                if initAttack then
                    self:ChangePlayerAttribute(player, "Attack", initAttack * value)
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
        elseif attributeName == "Attack" then
            humanoid:SetAttribute("Attack", attributeValue)
        end
    else
        if attributeName == "Health" then
            humanoid.Health = player:GetAttribute("InitHealth")
        elseif attributeName == "WalkSpeed" then
            humanoid.WalkSpeed = player:GetAttribute("InitWalkSpeed")
        elseif attributeName == "MaxHealth" then
            humanoid.MaxHealth = player:GetAttribute("InitMaxHealth")
        elseif attributeName == "JumpPower" then
            humanoid.JumpPower = player:GetAttribute("InitJumpPower")
        elseif attributeName == "Attack" then
            humanoid:SetAttribute("Attack", player:GetAttribute("InitAttack"))
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