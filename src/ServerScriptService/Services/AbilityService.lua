-- AbilityService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local AbilityConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("AbilityConfig"))
local EffectFolder = game:GetService("ServerStorage"):FindFirstChild("Effect")

local AbilityService = Knit.CreateService {
	Name = "AbilityService",
	Client = {
        UpdateAbilityData = Knit.CreateSignal(),
	},

    AbilityData = {},
}

function AbilityService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function AbilityService:KnitStart()
end

function AbilityService:PlayerAdded(player, abilityData)
    self.AbilityData[player.UserId] = {}
    for id, ability in pairs(abilityData) do
        self.AbilityData[player.UserId][id] = {}
        self.AbilityData[player.UserId][id].Level = tonumber(ability.Level) or 0
        self.AbilityData[player.UserId][id].ItemNum = {}
        for itemId, itemNum in pairs(ability.ItemNum) do
			self.AbilityData[player.UserId][id].ItemNum[tonumber(itemId)] = tonumber(itemNum) or 0
        end
        self.AbilityData[player.UserId][id].Gold = tonumber(ability.Gold) or 0
    end
end

function AbilityService:PlayerRemoved(player)
    self.AbilityData[player.UserId] = nil
end

-- 从DataStoreService初始化玩家工具栏数据
function AbilityService:InitPlayerAbility(player, toolStore)
	local userId = player.UserId
	self.AbilityData[userId] = {}

	if toolStore then
        for id, ability in pairs(toolStore) do
            self.AbilityData[player.UserId][id] = {}
            self.AbilityData[player.UserId][id].Level = tonumber(ability.Level) or 0
            self.AbilityData[player.UserId][id].ItemNum = {}
            for itemId, itemNum in pairs(ability.ItemNum) do
                self.AbilityData[player.UserId][id].ItemNum[itemId] = tonumber(itemNum) or 0
            end
            self.AbilityData[player.UserId][id].Gold = tonumber(ability.Gold) or 0
        end
	end
end

function AbilityService:GetAbilityFromDBService(userId, value)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	self:InitPlayerAbility(player, value)
end

function AbilityService:GetAbilityData(player)
    return self.AbilityData[player.UserId]
end

function AbilityService:SubmitItem(player, abilityId)
    local ability = self.AbilityData[player.UserId]
    if not ability then
        return false
    end
    
    local abilityInfo = AbilityConfig:GetByAbilityId(abilityId)
    if not abilityInfo then
        return false
	end

    local abilityData = ability[abilityId]
    if not abilityData then
        abilityData = {}
        abilityData.Level = 0
        abilityData.ItemNum = {}
		abilityData.Gold = 0
		ability[abilityId] = abilityData
	end
	
	if type(abilityInfo.Level) == "table" then
		if abilityData.Level >= #abilityInfo.Level then
			return false
		end
	else
		if abilityData.Level >= abilityInfo.Level then
			return false
		end
	end

    local level = abilityData.Level + 1
    local needItemList = abilityInfo.NeedItemList
    local needNumList = abilityInfo.NeedNumList
    local needItemInfo = {}
    for i = 1, 4 do
		local itemId = needItemList[i][level]
		if itemId and itemId > 0 then
			if not abilityData.ItemNum[itemId] then
				abilityData.ItemNum[itemId] = 0
			end
            local curNum = abilityData.ItemNum[itemId]
			local maxNum = needNumList[i][level]
            if type(maxNum) == "table" then
                maxNum = maxNum[level] or 0
            end

            if curNum < maxNum then
                needItemInfo[itemId] = maxNum - curNum
            end
        end
    end

    local isChanged = false
    if next(needItemInfo) then
        local isRemoveSuccess, removedItems = Knit.GetService("InventoryService"):RemoveItemsByNum(player, needItemInfo)
        if isRemoveSuccess then
            for itemId, num in pairs(removedItems) do
                if abilityData.ItemNum[itemId] then
                    abilityData.ItemNum[itemId] = abilityData.ItemNum[itemId] + num
                end
            end
            Knit.GetService("DBService"):Set(player.UserId, "AbilityData", self.AbilityData[player.UserId])
            isChanged = true
        end
    end

	local needGold = abilityInfo.Gold[level] - abilityData.Gold
    if needGold > 0 then
        local curGold = Knit.GetService("GoldService"):GetGoldData(player)
        if curGold < needGold then
            needGold = curGold
        end
        abilityData.Gold = abilityData.Gold + needGold
        Knit.GetService("GoldService"):ChangeGold(player, -needGold)
        Knit.GetService("DBService"):Set(player.UserId, "AbilityData", self.AbilityData[player.UserId])
        isChanged = true
    end

    if isChanged then
        self.Client.UpdateAbilityData:Fire(player, self.AbilityData[player.UserId])
        return true
    end
    return false
end

function AbilityService.Client:SubmitItem(player, abilityId)
    return self.Server:SubmitItem(player, abilityId)
end

function AbilityService:Upgrade(player, abilityId)
	self:SubmitItem(player, abilityId)
    local ability = self.AbilityData[player.UserId]
    if not ability then
        return false
    end
    
    local abilityInfo = AbilityConfig:GetByAbilityId(abilityId)
    if not abilityInfo then
        return false
	end
    
	local abilityData = ability[abilityId]

    local isUpgraded = true
    local level = 0
    if abilityData and abilityData.Level then
        level = abilityData.Level
    end
    level = math.min(level + 1, #abilityInfo.Level)
    local needItemList = abilityInfo.NeedItemList
    local needNumList = abilityInfo.NeedNumList
    for i = 1, 4 do
        local itemId = needItemList[i][level]
        if itemId and itemId > 0 then
			local maxNum = needNumList[i][level]
            if type(maxNum) == "table" then
                maxNum = maxNum[level] or 0
            end
            
            if abilityData.ItemNum[itemId] < maxNum then
                isUpgraded = false
                break
            end
        end
    end

    if isUpgraded then
        if abilityData.Gold < abilityInfo.Gold[level] then
            isUpgraded = false
        end
    end

    if isUpgraded then
        abilityData.Level = abilityData.Level + 1
        abilityData.ItemNum = {}
        abilityData.Gold = 0
        Knit.GetService("DBService"):Set(player.UserId, "AbilityData", self.AbilityData[player.UserId])
        self.Client.UpdateAbilityData:Fire(player, self.AbilityData[player.UserId])

        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local effect = EffectFolder:FindFirstChild("LevelUp")
                if effect then
					local cloneEffect = effect:Clone()
					cloneEffect:PivotTo(CFrame.new(humanoidRootPart.Position))
                    cloneEffect.Parent = humanoidRootPart
                    
                    -- 使用Debris服务在3秒后自动销毁特效
                    game:GetService("Debris"):AddItem(cloneEffect, 3)
                end
            end
        end
        return true
    end
    return false
end

function AbilityService.Client:Upgrade(player, abilityId)
    return self.Server:Upgrade(player, abilityId)
end

return AbilityService