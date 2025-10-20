-- PlayerService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local AbilityConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("AbilityConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local PlayerService = Knit.CreateService {
	Name = "PlayerService",
	Client = {
	},

    AbilityData = {},
}

function PlayerService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function PlayerService:KnitStart()
    local function playerAdd(player)
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
        Knit.GetService("AbilityService"):playerRemoved(player)
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

function PlayerService:GetInitData(player)
    local DBService = Knit.GetService("DBService")
    DBService:PlayerAdded(player)

    local gold = DBService:Get(player.UserId, "Gold")
    local inventory = DBService:Get(player.UserId, "PlayerInventory")
    local tool = DBService:Get(player.UserId, "PlayerToolData")
    local duanWei = DBService:Get(player.UserId, "DuanWeiData")
    local ability = DBService:Get(player.UserId, "AbilityData")
    Knit.GetService("GoldService"):playerAdd(player, gold)
    Knit.GetService("InventoryService"):playerAdd(player, inventory, tool)
    Knit.GetService("RankService"):playerAdd(player)
    Knit.GetService("LevelService"):playerAdd(player, duanWei)
    Knit.GetService("AbilityService"):playerAdd(player, ability)
    
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
    local abilityData = Knit.GetService("AbilityService"):GetAbilityData(player)
    local isAdmin = Knit.GetService("DBService"):IsAdmin(player)

    if ability then
        self.AbilityData[player.UserId] = ability
        self:InitPlayerAbility(player, ability)
    end

    return {
        Gold = gold,
        Inventory = inventoryData,
        ToolData = toolData,
        AbilityData = abilityData,
        RankPersonalData = rankPersonalData,
        RankData = rankData,
        IsAdmin = isAdmin,
    }
end

-- 客户端远程方法：获取玩家数据
-- @param player Player 请求数据的玩家
-- @return table 玩家数据
function PlayerService.Client:GetInitData(player)
    return self.Server:GetInitData(player)
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

return PlayerService