-- InventoryService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Debris = game:GetService("Debris")

local InventoryService = Knit.CreateService {
	Name = "InventoryService",
	Client = {
		SendBackpack = Knit.CreateSignal(),
		SendToolData = Knit.CreateSignal(),
	},

	Inventory = {},     -- 背包数据
	ToolData = {},      -- 工具栏数据
}

function InventoryService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function InventoryService:KnitStart()
end

function InventoryService:PlayerAdded(player)
    local DBService = Knit.GetService("DBService")
    local inventory = DBService:Get(player.UserId, "PlayerInventory")
    local tool = DBService:Get(player.UserId, "PlayerToolData")
	self.Inventory[player.UserId] = {}
	for _, v in pairs(inventory) do
        local attribute = GameConfig.GetItemAttribute()
        attribute.UsedTime = v.UsedTime
        attribute.UsedNum = v.UsedNum
		attribute.IsLocked = v.IsLocked or 0
        table.insert(self.Inventory[player.UserId], {
            ItemId = v.ItemId,
            Attribute = attribute,
        })
	end

	self.ToolData[player.UserId] = {}
    for i = 1, GameConfig.SLOT_NUM do
        local data = tool[i]
        local attribute = GameConfig.GetItemAttribute()
        if data then
            attribute.UsedTime = data.UsedTime
            attribute.UsedNum = data.UsedNum
            table.insert(self.ToolData[player.UserId], {
                ItemId = data.ItemId,
                Attribute = attribute
            })
        else
            table.insert(self.ToolData[player.UserId], {
                ItemId = 0,
                Attribute = attribute
            })
        end
    end
end

function InventoryService:PlayerRemoved(player)
	self.Inventory[player.UserId] = nil
	self.ToolData[player.UserId] = nil
end

function InventoryService:GetInventoryData(player)
	return self.Inventory[player.UserId]
end

-- 背包数据转换为数据库格式
-- @param player Player 玩家对象
-- @return void
function InventoryService:InventoryToDB(player)
	local DBService = Knit.GetService("DBService")
    local data = {}
    for _, v in pairs(self.Inventory[player.UserId]) do
        table.insert(data, {
            ItemId = v.ItemId,
            UsedTime = v.Attribute.UsedTime,
            UsedNum = v.Attribute.UsedNum,
			IsLocked = v.Attribute.IsLocked,
        })
    end
	DBService:Set(player.UserId, "PlayerInventory", data)
end

-- 工具栏数据转换为数据库格式
-- @param player Player 玩家对象
-- @return void
function InventoryService:ToolDataToDB(player)
	local DBService = Knit.GetService("DBService")
    local data = {}
    for _, v in pairs(self.ToolData[player.UserId]) do
        table.insert(data, {
            ItemId = v.ItemId,
            UsedTime = v.Attribute.UsedTime,
            UsedNum = v.Attribute.UsedNum,
        })
    end
	DBService:Set(player.UserId, "PlayerToolData", data)
end

function InventoryService:AddItem(player, itemData)
	table.insert(self.Inventory[player.UserId], {
		ItemId = itemData.ItemId,
		Attribute = itemData.Attribute or GameConfig.GetItemAttribute(),
	})
	self.Client.SendBackpack:Fire(player, self.Inventory[player.UserId])
	self:InventoryToDB(player)
end

function InventoryService.Client:AddItem(player, itemData)
	return self.Server:AddItem(player, itemData)
end

function InventoryService:RemoveItem(player, itemData)
	for i, v in ipairs(self.Inventory[player.UserId]) do
		if v.ItemId == itemData.ItemId and v.Attribute.CreateTime == itemData.Attribute.CreateTime then
			table.remove(self.Inventory[player.UserId], i)
			break
		end
	end
	self.Client.SendBackpack:Fire(player, self.Inventory[player.UserId])
	self:InventoryToDB(player)
end

function InventoryService.Client:RemoveItem(player, itemData)
	return self.Server:RemoveItem(player, itemData)
end

function InventoryService:RemoveItems(player, items)
	for _, itemData in ipairs(items) do
		for i, v in ipairs(self.Inventory[player.UserId]) do
			if v.ItemId == itemData.ItemId and v.Attribute.CreateTime == itemData.Attribute.CreateTime then
				table.remove(self.Inventory[player.UserId], i)
				break
			end
		end
	end
	self.Client.SendBackpack:Fire(player, self.Inventory[player.UserId])
	self:InventoryToDB(player)
end

-- 根据物品ID和数量移除玩家背包中的物品
-- @param player Player 玩家对象
-- @param items table 要移除的物品，格式为 {[itemId] = num, ...}
-- @return void
function InventoryService:RemoveItemsByNum(player, items)
	local inventory = self.Inventory[player.UserId]
	if not inventory then
		return
	end
	
	local isRemoveSuccess = false
	local removedItems = {}
	for itemId, num in pairs(items) do
		local removedCount = 0
		-- 倒序遍历避免索引错乱，提高效率
		for i = #inventory, 1, -1 do
			if inventory[i].ItemId == itemId then
				isRemoveSuccess = true
				table.remove(inventory, i)
				removedCount = removedCount + 1
				-- 达到移除数量则提前退出
				if removedCount >= num then
					break
				end
			end
		end
		removedItems[itemId] = removedCount
	end
		
	if isRemoveSuccess then
		self.Client.SendBackpack:Fire(player, self.Inventory[player.UserId])
		self:InventoryToDB(player)
	end
	return isRemoveSuccess, removedItems
end

-- 更新玩家工具栏数据并创建工具
-- @param player Player 玩家对象
-- @param data table 工具栏数据，格式为 {["1"] = itemId, ["2"] = itemId, ["3"] = itemId}
-- @return void
function InventoryService:UpdateToolData(player, data)
	self.ToolData[player.UserId] = {}
	for i = 1, GameConfig.SLOT_NUM do
		if data[i] then
			table.insert(self.ToolData[player.UserId], {ItemId = data[i].ItemId, Attribute = data[i].Attribute})
		else
			table.insert(self.ToolData[player.UserId], {ItemId = 0, Attribute = GameConfig.GetItemAttribute()})
		end
	end
	self:ToolDataToDB(player)

	-- 检查当前装备的工具是否在新的data中
	local character = player.Character
	if character then
		local currentTool = character:FindFirstChildOfClass("Tool")
		if currentTool then
			local currentItemId = currentTool:GetAttribute("ItemId")
			local toolInData = false

			-- 检查当前工具是否在新的data中
			for _, itemData in pairs(data) do
				if itemData.ItemId == currentItemId then
					toolInData = true
					break
				end
			end

			-- 如果当前工具不在新的data中，则取下工具
			if not toolInData then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:UnequipTools()
				end
			end
		end
	end
end

function InventoryService:GetToolData(player)
	return self.ToolData[player.UserId]
end

function InventoryService.Client:UpdateToolData(player, data)
	self.Server:UpdateToolData(player, data)
end

-- 从DataStoreService初始化玩家库存数据
function InventoryService:InitPlayerInventory(player, inventoryStore)
	local userId = player.UserId
	self.Inventory[userId] = {}

	if inventoryStore then
		for _, v in pairs(inventoryStore) do
			table.insert(self.Inventory[userId], v)
		end
	end
	self.Client.SendBackpack:Fire(player, self.Inventory[userId])
end

function InventoryService:GetInventoryFromDBService(userId, value)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	self:InitPlayerInventory(player, value)
end

-- 从DataStoreService初始化玩家工具栏数据
function InventoryService:InitPlayerTool(player, toolStore)
	local userId = player.UserId
	self.ToolData[userId] = {}

	if toolStore then
		for i = 1, GameConfig.SLOT_NUM do
			table.insert(self.ToolData[player.UserId], {
				ItemId = (toolStore[i] and toolStore[i].ItemId) or 0,
				Attribute = GameConfig.GetItemAttribute(),
			})
		end
	end
	self.Client.SendToolData:Fire(player, self.ToolData[userId])
end

function InventoryService:GetToolFromDBService(userId, value)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	self:InitPlayerTool(player, value)
end

-- 根据物品ID创建工具实例
-- @param itemId number 物品ID
-- @return Tool|nil 创建的工具实例
function InventoryService:CreateToolFromItemId(itemData, slot)
	if itemData.ItemId == 0 then
		return
	end
	local itemInfo = ItemConfig:GetByItemId(tonumber(itemData.ItemId))
	if not itemInfo then
		warn("找不到物品ID: " .. tostring(itemData.ItemId))
		return
	end

    local itemFolder = ReplicatedStorage:FindFirstChild("ItemFolder")
    if not itemFolder then
        warn("Item folder not found")
        return
    end

    local folder = itemFolder:FindFirstChild(GameConfig.ItemTypeFolder[itemInfo.Type])
    if not folder then
        warn("Item type folder not found: " .. GameConfig.ItemTypeFolder[itemInfo.Type])
        return
    end

	local template = folder:FindFirstChild(itemInfo.Model)
	if not template then
		warn("Tool template not found:", itemInfo.Model)
		return
	end

	-- 创建新的Tool实例
	local tool = Instance.new("Tool")

	-- 设置工具基本属性
	tool.Name = itemInfo.Item
	tool.ToolTip = itemInfo.Description or ""
	tool.CanBeDropped = true
	tool.RequiresHandle = true
	tool:SetAttribute("ItemId", itemData.ItemId)
	GameConfig.SetItemAttribute(tool, itemData.Attribute)

	-- 设置工具图标（如果ItemConfig中有Icon）
	if itemInfo.Icon and itemInfo.Icon ~= "" then
		tool.TextureId = itemInfo.Icon
	end

	local handle = nil

	-- 根据模板类型处理（Model 或 Part）
	if template:IsA("Model") then
		-- 处理 Model 类型的模板
		local templateModel = template:Clone()

		-- 确保模型有 PrimaryPart，这是作为 Handle 的关键
		handle = templateModel.PrimaryPart
		if not handle then
			warn("Warning: Tool template '" .. itemInfo.Item .. "' does not have a PrimaryPart set.")
			-- 备用方案：选择第一个找到的 BasePart
			handle = templateModel:FindFirstChildOfClass("BasePart")
			if not handle then
				warn("Error: Tool template '" .. itemInfo.Item .. "' contains no parts to use as a handle.")
				return
			end
		end

		-- 遍历模型中的所有部件
		for _, part in ipairs(templateModel:GetDescendants()) do
			if part:IsA("BasePart") then
				-- 解除所有部件的锚定
				part.Anchored = false
				-- 将除 PrimaryPart 之外的所有部件焊接到 PrimaryPart
				if part ~= handle then
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = handle
					weld.Part1 = part
					weld.Parent = handle
				end
			end
		end

		-- 将 Handle 命名为 "Handle"，这是 Tool 识别握柄的要求
		handle.Name = "Handle"
		handle.Parent = tool

		-- 将模型中除了Handle之外的其他子项也移动到Tool下
		for _, child in ipairs(templateModel:GetChildren()) do
			if child ~= handle then
				child.Parent = tool
			end
		end

		-- 销毁空的模板模型
		templateModel:Destroy()
	elseif template:IsA("BasePart") then
		-- 处理 Part 类型的模板
		handle = template:Clone()
		handle.Name = "Handle"
		handle.Anchored = false
		handle.Parent = tool

		-- 遍历Part下的所有子Part并焊接到Handle
		for _, part in ipairs(handle:GetDescendants()) do
			if part:IsA("BasePart") and part ~= handle then
				-- 解除子Part的锚定
				part.Anchored = false
				-- 将子Part焊接到Handle
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = handle
				weld.Part1 = part
				weld.Parent = handle
			end
		end

		-- 将模型中除了Handle之外的其他子项也移动到Tool下
		for _, child in ipairs(handle:GetChildren()) do
			if child ~= handle then
				child.Parent = tool
			end
		end
	else
		warn("Error: Tool template '" .. itemInfo.Item .. "' is neither a Model nor a BasePart.")
		return
	end

    -- 直接设置Tool的Grip属性来控制握持方向
    if itemInfo.ItemId == 202 then
        tool.Grip = CFrame.Angles(0, math.rad(180), 0)  -- 只旋转，不偏移位置
    elseif itemInfo.ItemId == 203 then
        tool.Grip = CFrame.new(0, -0.6, 0) * CFrame.Angles(0, math.rad(90), 0)  -- y轴偏移0.6并旋转
    else
        tool.Grip = CFrame.Angles(0, 0, math.rad(90))  -- 只旋转，不偏移位置
    end

	-- 连接工具装备事件，重置状态
	tool.Equipped:Connect(function()
        local player = game.Players:GetPlayerFromCharacter(tool.Parent)
        if not player then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end

		local script = tool:FindFirstChild("ModuleScript")
		if script then
			local module = require(script)
			if module and module.Equipped then
				module:Equipped()
			end
		end
	end)

	-- 连接工具卸下事件，清理状态
	tool.Unequipped:Connect(function()
        local player = game.Players:GetPlayerFromCharacter(tool.Parent)
        if not player then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end

		local script = tool:FindFirstChild("ModuleScript")
		if script then
			local module = require(script)
			if module and module.Unequipped then
				module:Unequipped()
			end
		end
	end)

	-- 连接工具激活事件（服务器端处理）
	tool.Activated:Connect(function()
	end)

	return tool
end

function InventoryService:SendToolData(player)
    self.Client.SendToolData:Fire(player, self.ToolData[player.UserId])
end

-- 设置玩家按键绑定
-- @param player Player 玩家对象
-- @return void
function InventoryService.Client:PressKeyBind(player, keyCode)
	return self.Server:EquipToolByKey(player, keyCode)
end

-- 根据按键装备对应工具
-- @param player Player 玩家对象
-- @param keyCode Enum.KeyCode 按键代码
-- 根据按键装备或卸下工具
-- @param player Player 玩家对象
-- @param slot number 工具槽位
-- @return void
function InventoryService:EquipToolByKey(player, slot)
	local character = player.Character
	if not character then
		return 0
	end

    local userId = player.UserId
    local slotNumber = tonumber(slot)
    
    -- 从ToolData中获取该槽位的物品ID
    local toolData = self.ToolData[userId]
    if not toolData then
        return 0
    end
    
    local itemData = toolData[slotNumber]
    if not itemData or itemData.ItemId == 0 then
        return 0
    end
    
    -- 获取当前装备的工具
    local currentTool = character:FindFirstChildOfClass("Tool")
    
    -- 检查当前工具是否是要装备的槽位对应的工具
    local isEquippingSameTool = false
    if currentTool then
        local currentItemId = currentTool:GetAttribute("ItemId")
		local attribute = GameConfig.GetItemAttribute(currentTool)
        if currentItemId == itemData.ItemId and attribute.CreateTime == itemData.Attribute.CreateTime then
            isEquippingSameTool = true
        end
    
		-- 如果是同一个工具，则取下工具
		if isEquippingSameTool then
			if currentTool then
                character.Humanoid:UnequipTools()
				for i, v in pairs(toolData) do
					if v.ItemId == currentItemId and v.Attribute.CreateTime == attribute.CreateTime then
						v.Attribute.IsEquipped = 0
						break
					end
				end
                GameConfig.UpdateItemAttribute(currentTool, "IsEquipped", 0)
        		Debris:AddItem(currentTool, 0.05)
			end
			return 1, toolData
		end
		
		character.Humanoid:UnequipTools()
		-- 否则，卸下当前工具并装备新工具
		for i, v in pairs(toolData) do
			if v.ItemId == currentItemId and v.Attribute.CreateTime == attribute.CreateTime then
				v.Attribute.IsEquipped = 0
				break
			end
		end
		GameConfig.UpdateItemAttribute(currentTool, "IsEquipped", 0)
        Debris:AddItem(currentTool, 0.05)
    end
    
    -- 按需创建新工具
    local newTool = self:CreateToolFromItemId(itemData, slotNumber)
    if newTool then
        newTool.Parent = character
        
        -- 确保工具被正确装备
        if character:FindFirstChild("Humanoid") then
        	itemData.Attribute.IsEquipped = 1
			GameConfig.UpdateItemAttribute(newTool, "IsEquipped", 1)
        end
        
        return 2, toolData
    end
    
    return 0
end

function InventoryService:GetAllItemNum(player)
	local items = {}
	for _, itemData in pairs(self.Inventory[player.UserId]) do
		if not items[itemData.ItemId] then
			items[itemData.ItemId] = 1
		else
			items[itemData.ItemId] += 1
		end
	end
	for _, itemData in pairs(self.ToolData[player.UserId]) do
		if itemData.ItemId == 0 then continue end
		if not items[itemData.ItemId] then
			items[itemData.ItemId] = 1
		else
			items[itemData.ItemId] += 1
		end
	end
	return items
end

function InventoryService:LockItem(player, slot, isLocked)
	if not self.Inventory[player.UserId] or not self.Inventory[player.UserId][slot] then return false end
	self.Inventory[player.UserId][slot].Attribute.IsLocked = isLocked
	self.Client.SendBackpack:Fire(player, self.Inventory[player.UserId])
	self:InventoryToDB(player)
	return true
end

function InventoryService.Client:LockItem(player, slot, isLocked)
	return self.Server:LockItem(player, slot, isLocked)
end

return InventoryService