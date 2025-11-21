-- TalentService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local TalentTreeConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("TalentTreeConfig"))
local EffectFolder = game:GetService("ServerStorage"):FindFirstChild("Effect")

local TalentService = Knit.CreateService {
	Name = "TalentService",
	Client = {
        UpdateTalentData = Knit.CreateSignal(),
	},

    TalentData = {},
}

function TalentService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function TalentService:KnitStart()
end

function TalentService:PlayerAdded(player)
	local userId = player.UserId
    local talentData = Knit.GetService("DBService"):Get(userId, "TalentData")
    self.TalentData[userId] = {}
    for id, talent in pairs(talentData) do
        self.TalentData[userId][id] = {}
        self.TalentData[userId][id].TalentTreeId = tonumber(id) or 0
        self.TalentData[userId][id].ItemNum = {}
        for itemId, itemNum in pairs(talent.ItemNum) do
			self.TalentData[userId][id].ItemNum[tonumber(itemId)] = tonumber(itemNum) or 0
        end
        self.TalentData[userId][id].Gold = tonumber(talent.Gold) or 0
        self.TalentData[userId][id].Complated = talent.Complated or false
    end
end

function TalentService:PlayerRemoved(player)
    self.TalentData[player.UserId] = nil
end

-- 从DataStoreService初始化玩家天赋数据
function TalentService:InitPlayerTalent(player, talentStore)
	local userId = player.UserId
	self.TalentData[userId] = {}

	if talentStore then
        for id, talent in pairs(talentStore) do
            self.TalentData[userId][id] = {}
            self.TalentData[userId][id].TalentTreeId = tonumber(talent.TalentTreeId) or 0
            self.TalentData[userId][id].ItemNum = {}
            for itemId, itemNum in pairs(talent.ItemNum) do
                self.TalentData[userId][id].ItemNum[tonumber(itemId)] = tonumber(itemNum) or 0
            end
            self.TalentData[userId][id].Gold = tonumber(talent.Gold) or 0
            self.TalentData[userId][id].Complated = talent.Complated or false
        end
	end
end

function TalentService:GetTalentFromDBService(userId, value)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	self:InitPlayerTalent(player, value)
end

function TalentService:GetTalentData(player)
    return self.TalentData[player.UserId]
end

function TalentService:Learn(player, talentId)
    local talent = self.TalentData[player.UserId]
    if not talent then
        return false
    end
    
    local talentInfo = TalentTreeConfig:GetByTalentTreeId(talentId)
    if not talentInfo then
        return false
	end

    talentId = tostring(talentId)
    local talentData = talent[talentId]
    if not talentData then
        talentData = {}
        talentData.TalentTreeId = talentId
        talentData.ItemNum = {}
		talentData.Gold = 0
        talentData.Complated = false
		talent[talentId] = talentData
	end
    
    local inventoryItems = Knit.GetService("InventoryService"):GetAllItemNum(player)
    local needItemInfo = {}
    local needGold = 0
    local isAllHave = true
    local need = talentInfo.Need
    for _, item in pairs(need) do
        if item.Item and item.Num then
            if not inventoryItems[item.Item] or inventoryItems[item.Item] < item.Num then
                isAllHave = false
                break
            end
            needItemInfo[item.Item] = item.Num
        elseif item.Gold then
            local curGold = Knit.GetService("GoldService"):GetGoldData(player)
            if curGold < item.Gold then
                isAllHave = false
                break
            end
            needGold += item.Gold
        end
    end

    if not isAllHave then
        return false
    end

    talentData.Gold = needGold
    Knit.GetService("GoldService"):ChangeGold(player, -needGold)

    if next(needItemInfo) then
        local isRemoveSuccess, removedItems = Knit.GetService("InventoryService"):RemoveItemsByNum(player, needItemInfo)
        if isRemoveSuccess then
            for itemId, num in pairs(removedItems) do
                if talentData.ItemNum[itemId] then
                    talentData.ItemNum[itemId] = num
                end
            end
        end
    end
    talentData.Complated = true
    Knit.GetService("DBService"):Set(player.UserId, "TalentData", self.TalentData[player.UserId])
    self.Client.UpdateTalentData:Fire(player, self.TalentData[player.UserId])

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

function TalentService.Client:Learn(player, talentId)
    return self.Server:Learn(player, talentId)
end

return TalentService