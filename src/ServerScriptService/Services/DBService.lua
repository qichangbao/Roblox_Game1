local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ProfileService = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ProfileService"):WaitForChild("ProfileService"))
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local _dataTemplate = {
	Gold = 0,					-- 金币
	PlayerInventory = {},		-- 背包数据
	PlayerToolData = {},		-- 工具栏数据
	EscapeActions = {},			-- 逃生数据
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerProfile",
	_dataTemplate
)

local DBService = Knit.CreateService({
    Name = 'DBService',
	Profiles = {},
    Client = {
    },
})

local AdminUserIds = {
	4803414780,
	7689724124,
	8691350792,
}

-- 获取是否管理员
local function IsAdmin(player)
	for _, v in ipairs(AdminUserIds) do
		if v == player.UserId then
			return true
		end
	end
	return false
end

function DBService.Client:AdminRequest(player, action, userId, ...)
    if IsAdmin(player) then
        return self.Server:ProcessAdminRequest(player, action, userId, ...)
    end

	return "不是管理员，无法执行该操作"
end

function DBService:ProcessAdminRequest(player, action, userId, ...)
	if not userId or type(userId) ~= "number" then
		return "无效的用户ID"
	end

	if not action or type(action) ~= "string" then
		return "无效的操作"
	end
	
	if action == "GetData" then
		local data = {}
		local statu = 0
		for i, v in pairs(_dataTemplate) do
			data[i], statu = self:GetToAllStore(userId, i)
		end
		return data, statu
	elseif action == "SetData" then
		if self:SetToAllStore(userId, ...) then
			return "数据更新成功"
		end
		return "找不到用户数据"
	end
end

function DBService:PlayerAdded(player)
	local userId = player.UserId
	if self.Profiles[userId] then
		return
	end

	local profileKey = "Player_"..userId
	local profile = ProfileStore:LoadProfileAsync(profileKey)
	if profile then
		profile:AddUserId(userId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			self.Profiles[userId] = nil

			player:Kick()
		end)

		if not player:IsDescendantOf(Players) then
			profile:Release()
		else
			self.Profiles[userId] = profile
		end
	else
		player:Kick()
	end
	
	self:GiveStats(player)
end

function DBService:PlayerRemoving(player)
	local userId = player.UserId

	if self.Profiles[userId] then
		self.Profiles[userId]:Release()
	end
end

function DBService:InitDataFromUserId(userId)
	if self.Profiles[userId] then
		return 1
	end

	local profileKey = "Player_"..userId
	local profile = ProfileStore:LoadProfileAsync(profileKey)
	if profile then
		profile:AddUserId(userId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			self.Profiles[userId] = nil
		end)

		self.Profiles[userId] = profile
	end
	return 0
end

function DBService:GetProfile(userId)
	return self.Profiles[userId]
end

-- getter/setter methods
function DBService:GetToAllStore(userId, key)
	local statu = self:InitDataFromUserId(userId)
	return self:Get(userId, key), statu
end

function DBService:SetToAllStore(userId, key, value)
	if key == "Gold" then
		local player = Players:GetPlayerByUserId(userId)
		if player then
			Knit.GetService("GoldService"):SetGold(player, value)
		end
	elseif key == "PlayerInventory" then
		Knit.GetService("InventoryService"):GetInventoryFromDBService(userId, value)
	end
	-- 初始化用户数据，确保用户数据存在，并且可以设置value
	self:InitDataFromUserId(userId)
	return self:Set(userId, key, value)
end

function DBService:Get(userId, key)
	local profile = self:GetProfile(userId)
	if not profile then
		return
	end

	return profile.Data[key]
end

function DBService:Set(userId, key, value)
	local profile = self:GetProfile(userId)
	if not profile then
		return false
	end

	profile.Data[key] = value
	profile:Save()
	print("数据已保存  ", userId, key, value)

	if key == "Gold" then
		local player = Players:GetPlayerByUserId(userId)
		if player then
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				leaderstats:FindFirstChild("Gold").Value = value
			end
		end
	end

	return true
end

function DBService:Update(userId, key, callback)
	local oldData = self:Get(userId, key)
	local newData = callback(oldData)

	self:Set(userId, key, newData)
end

function DBService:GiveStats(player)
	if not player or not player:IsA("Player") then
		warn("GiveStats function requires a valid player instance")
		return
	end

	local Leaderstats = Instance.new("Folder", player)
	Leaderstats.Name = "leaderstats"

	local totalActions = Instance.new("IntValue", Leaderstats)
	totalActions.Name = "TotalActions"
	local escapeActions = self:Get(player.UserId, "EscapeActions")
	if escapeActions and escapeActions.successNum then
		totalActions.Value = escapeActions.successNum
	else
		totalActions.Value = 0
	end
end

function DBService:KnitInit()
	print("DBService Init")
end

function DBService:KnitStart()
	print("DBService Start")
    -- for _, player in pairs(Players:GetPlayers()) do
	-- 	self:PlayerAdded(player)
    -- end
	
	-- -- 监听玩家加入事件
	-- Players.PlayerAdded:Connect(function(player)
	-- 	self:PlayerAdded(player)
	-- end)

	-- -- 监听玩家离开事件
	-- Players.PlayerRemoving:Connect(function(player)
	-- 	self:PlayerRemoving(player)
	-- end)
end

return DBService