local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local TweenInterface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('TweenInterface'))
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local _screenGui = PlayerGui:WaitForChild("MainUI")
_screenGui.Enabled = true
local _leftFrame = _screenGui:WaitForChild("left")
local _bottomFrame = _screenGui:WaitForChild("bottom")
local _rightFrame = _screenGui:WaitForChild("right")

local _questFrame = _leftFrame:WaitForChild("QuestFrame")
local _questButton = _questFrame:WaitForChild("QuestButton")
_questButton.MouseButton1Click:Connect(function()
	--Knit.GetController("UIController").ShowQuestUI:Fire(2)
	Knit.GetController("UIController").ShowJobUI:Fire()
end)
TweenInterface.SetupHoverScale(_questButton, _questButton)

local _bdButton = _leftFrame:WaitForChild("DBButton")
_bdButton.Visible = false
_bdButton.MouseButton1Click:Connect(function()
	Knit.GetController("UIController").ShowAdminUI:Fire()
end)
TweenInterface.SetupHoverScale(_bdButton, _bdButton)

local _goldFrame = _leftFrame:WaitForChild("GoldFrame")
local _goldLabel = _goldFrame:WaitForChild("GoldLabel")
_goldLabel.Text = "0"

local _backpackButton = _rightFrame:WaitForChild("BackpackFrame"):WaitForChild("TextButton")
_backpackButton.MouseButton1Click:Connect(function()
	Knit.GetController("UIController").ShowBackpackUI:Fire()
end)
TweenInterface.SetupHoverScale(_backpackButton, _backpackButton)

local _feedbackButton = _rightFrame:WaitForChild("FeedbackFrame"):WaitForChild("TextButton")
_feedbackButton.MouseButton1Click:Connect(function()
	Knit.GetController("UIController").ShowFeedbackUI:Fire()
end)
TweenInterface.SetupHoverScale(_feedbackButton, _feedbackButton)

local _equipmentButton = _rightFrame:WaitForChild("EquipmentFrame"):WaitForChild("TextButton")
_equipmentButton.MouseButton1Click:Connect(function()
	Knit.GetController("UIController").ShowEquipmentUI:Fire()
end)
TweenInterface.SetupHoverScale(_equipmentButton, _equipmentButton)

local _runButton = _rightFrame:WaitForChild("RunButton")
_runButton.Visible = Interface.isMobile()
_runButton.MouseButton1Down:Connect(function(x, y)
	Knit.GetController("UIController").SwitchRun:Fire(true)
end)

_runButton.MouseButton1Up:Connect(function(x, y)
	Knit.GetController("UIController").SwitchRun:Fire(false)
end)

local _slots = {}
local _toolData = {}
local _cdTween = {}

-- 拖拽相关变量
local _isDragging = false
local _dragConnection = nil
local _currentDragItem = nil
local _startDragIndex = 0
local _isWaitingForDrag = false
local _dragStartPosition = nil

local function stopCD(slotIndex)
	local parent = _slots[slotIndex]
	if not parent then
		return
	end
	if _cdTween[slotIndex] then
		_cdTween[slotIndex]:Cancel()
		_cdTween[slotIndex] = nil
	end
	local clipFrame = parent:FindFirstChild("DJSFrame")
	clipFrame.Visible = false
	clipFrame.Size = UDim2.new(1, 0, 1, 0)
end

local function startCD(slotIndex, endTime, CD)
	local parent = _slots[slotIndex]
	if not parent then
		return
	end

	stopCD(slotIndex)

	local curTime = tick()
	local duration = endTime - curTime
	if duration <= 0 then
		return
	end

	local clipFrame = parent:FindFirstChild("DJSFrame")
	clipFrame.Visible = true
	clipFrame.Size = UDim2.new(1, 0, duration / CD, 0)
	-- 倒计时动画（从上到下裁切）
	local tweenInfo = TweenInfo.new(
		duration, -- 倒计时总时长
		Enum.EasingStyle.Linear, -- 线性动画
		Enum.EasingDirection.InOut,
		0, -- 不重复
		false -- 不反向
	)
	_cdTween[slotIndex] = game:GetService("TweenService"):Create(clipFrame, tweenInfo, {
		Size = UDim2.new(1, 0, 0, 0)
	})

	_cdTween[slotIndex]:Play()

	-- 动画完成后清理
	_cdTween[slotIndex].Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			clipFrame.Visible = false
			_cdTween[slotIndex] = nil
		elseif playbackState == Enum.PlaybackState.Cancelled then
			print("动画被取消")
		end
	end)
end

local function updateTool(isSendMessage)
	for index = 1, GameConfig.SLOT_NUM do
		local slot = _slots[index]
		local itemData = _toolData[index]
		local iconImage = slot:WaitForChild("IconImage")
		local useNumLabel = slot:FindFirstChild("UseNumLabel")
		if itemData then
			local itemInfo = ItemConfig:GetByItemId(itemData.ItemId)
			if not itemInfo then
				iconImage.Visible = false
				useNumLabel.Visible = false
				slot:FindFirstChild("UIStroke").Enabled = false
				slot:SetAttribute("ItemId", nil)
				continue
			end
			iconImage.Visible = true
			iconImage.Image = itemInfo.Icon
			slot:FindFirstChild("UIStroke").Enabled = tonumber(itemData.Attribute.IsEquipped) == 1
			slot:SetAttribute("ItemId", itemData.ItemId)
			GameConfig.SetItemAttribute(slot, itemData.Attribute)

			if itemInfo.Duration > 0 then
				useNumLabel.Visible = true
				useNumLabel.Text = math.floor(math.max(0, itemInfo.Duration - itemData.Attribute.UsedTime))
			elseif itemInfo.TimeUsed > 0 then
				useNumLabel.Visible = true
				useNumLabel.Text = math.floor(math.max(0, itemInfo.TimeUsed - itemData.Attribute.UsedNum))
			else
				useNumLabel.Visible = false
			end
			
			local CDElapsedTime = itemData.Attribute.CDElapsedTime
			local currentTime = tick()
			if CDElapsedTime > currentTime then
				startCD(index, CDElapsedTime, itemInfo.CD)
			else
				stopCD(index)
			end
		else
			iconImage.Visible = false
			useNumLabel.Visible = false
			slot:FindFirstChild("UIStroke").Enabled = false
			slot:SetAttribute("ItemId", nil)
			stopCD(index)
		end
	end
	
	if isSendMessage then
		Knit.GetService("InventoryService"):UpdateToolData(_toolData)
	end
end

local function equipTool(slot)
	Knit.GetService("InventoryService"):PressKeyBind(slot):andThen(function(returnFlag, toolData)
		if returnFlag == 1 or returnFlag == 2 then
			for index, itemData in pairs(toolData) do
				_toolData[tonumber(index)] = itemData
			end
			updateTool(false)
		end
	end)
end

-- 检查鼠标位置是否在Slot范围内
-- @param slot Frame 要检查的Slot
-- @param mousePosition Vector2 鼠标位置
-- @return boolean 是否在范围内
local function isMouseInFrame(frame, mousePosition)
	local absolutePosition = frame.AbsolutePosition + game:GetService("GuiService"):GetGuiInset()
	local absoluteSize = frame.AbsoluteSize

	local inBounds = mousePosition.X >= absolutePosition.X and
		mousePosition.X <= absolutePosition.X + absoluteSize.X and
		mousePosition.Y >= absolutePosition.Y and
		mousePosition.Y <= absolutePosition.Y + absoluteSize.Y

	return inBounds
end

-- 开始拖拽
-- @param itemInfo table 物品信息
local function startDrag(slot, x, y)
	if _isDragging then
		return
	end

	_isDragging = true
	_currentDragItem = slot
	local icon = slot:FindFirstChild("IconImage").Image

	-- 显示拖拽图像
	Knit.GetController("UIController").ShowDragUI:Fire(icon, Vector2.new(x, y), false)

	-- 连接鼠标移动事件
	_dragConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local mousePosition = UserInputService:GetMouseLocation()

			-- 更新拖拽图像位置
			Knit.GetController("UIController").MoveDragUI:Fire(Vector2.new(mousePosition.X, mousePosition.Y))

			-- 检查是否在MainUI槽位范围内
			local inSlot = false

			for _, slot in ipairs(_slots) do
				if isMouseInFrame(slot, mousePosition) then
					inSlot = true
					break
				end
			end

			-- 显示或隐藏丢弃标签
			if inSlot then
				Knit.GetController("UIController").ShowDragUI:Fire(icon, Vector2.new(mousePosition.X, mousePosition.Y), false)
			else
				Knit.GetController("UIController").ShowDragUI:Fire(icon, Vector2.new(mousePosition.X, mousePosition.Y), true)
			end
		end
	end)
end

-- 结束拖拽
-- @param mousePosition Vector2 鼠标位置
local function endDrag(mousePosition)
	if not _isDragging then
		return
	end

	_isDragging = false

	-- 断开连接
	if _dragConnection then
		_dragConnection:Disconnect()
		_dragConnection = nil
	end

	-- 隐藏拖拽图像和丢弃标签
	Knit.GetController("UIController").HideDragUI:Fire()

	-- 检查是否放置在有效槽位
	local targetSlot = nil

	for _, slot in ipairs(_slots) do
		if isMouseInFrame(slot, mousePosition) then
			targetSlot = slot
			break
		end
	end

	if targetSlot and _currentDragItem then
		local startSlot = _slots[_startDragIndex]
		if startSlot ~= targetSlot then
			local targetIndex = tonumber(targetSlot.Name)
			local startItemData = _toolData[_startDragIndex]
			local targetData = _toolData[targetIndex]
			if targetData.ItemId > 0 then	-- 如果目标槽有工具，则互换
				_toolData[_startDragIndex] = targetData
				_toolData[targetIndex] = startItemData
			else
				_toolData[_startDragIndex] = {ItemId = 0, Attribute = GameConfig.GetItemAttribute()}
				_toolData[targetIndex] = startItemData
			end
			updateTool(true)

			local uiSound = Interface.safeWaitPart(game:GetService("SoundService"), "UI")
			local sound = Interface.safeWaitPart(uiSound, "SwitchItem")
			sound.Looped = false
			sound:Play()
		end
	else
		-- 在范围外，执行放进背包逻辑
		Knit.GetService("InventoryService"):AddItem(_toolData[_startDragIndex])
		_toolData[_startDragIndex] = {ItemId = 0, Attribute = GameConfig.GetItemAttribute()}
		updateTool(true)

		local uiSound = Interface.safeWaitPart(game:GetService("SoundService"), "UI")
		local sound = Interface.safeWaitPart(uiSound, "SwitchItem")
		sound.Looped = false
		sound:Play()
	end

	_currentDragItem = nil
	_startDragIndex = 0
end

local _toolFrame = _bottomFrame:WaitForChild("ToolFrame")
for i = 1, GameConfig.SLOT_NUM do
	local slot = _toolFrame:WaitForChild(tostring(i))
	table.insert(_slots, slot)
	slot:SetAttribute("ItemId", 0)
	GameConfig.SetItemAttribute(slot)
	slot:FindFirstChild("UIStroke").Enabled = false
	local clipFrame = slot:FindFirstChild("DJSFrame")
	clipFrame.Visible = false
	
	-- 拖拽事件
	local iconImage = slot:WaitForChild("IconImage")
	iconImage.MouseButton1Down:Connect(function(x, y)
		if not iconImage.Visible then
			return
		end

		local itemId = slot:GetAttribute("ItemId")
		local itemInfo = ItemConfig:GetByItemId(itemId)
		if not itemInfo then
			return
		end

		-- 开始等待拖拽状态
		_isWaitingForDrag = true
		_startDragIndex = i
		_dragStartPosition = Vector2.new(x, y)

		-- 设置0.5秒延迟计时器
		task.spawn(function()
			task.wait(GameConfig.Item_DragTime)
			-- 如果0.5秒后仍在等待状态，开始拖拽
			if _isWaitingForDrag then
				_isWaitingForDrag = false
				startDrag(slot, _dragStartPosition.X, _dragStartPosition.Y)
			end
		end)
	end)
end

-- 监听鼠标释放事件
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		if _isDragging then
			-- 如果正在拖拽，结束拖拽
			local mousePosition = UserInputService:GetMouseLocation()
			endDrag(mousePosition)
		elseif _isWaitingForDrag then
			-- 如果在等待拖拽状态（0.5秒内松开），执行点击逻辑
			_isWaitingForDrag = false
			if _startDragIndex > 0 then
				equipTool(_startDragIndex)
				_startDragIndex = 0
			end
		end
	elseif input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.Three then
		local slot = nil
		-- 确定按键对应的槽位
		if input.KeyCode == Enum.KeyCode.One then
			slot = 1
		elseif input.KeyCode == Enum.KeyCode.Two then
			slot = 2
		elseif input.KeyCode == Enum.KeyCode.Three then
			slot = 3
		else
			return
		end
		equipTool(slot)
	end
end)

Knit.OnStart():andThen(function()
	_goldLabel.Text = _G.ClientData.Gold
	local UIController = Knit.GetController("UIController")
	UIController.ChangeGoldUI:Connect(function(gold)
		TweenInterface.AnimateNumberIncrease(_goldLabel, gold)
	end)
	UIController.UpdateToolUI:Connect(function(toolData)
		for index, itemData in pairs(toolData) do
			_toolData[tonumber(index)] = itemData
		end
		updateTool(false)
	end)
	Knit.GetController("UIController").UpdateToolData:Connect(function(toolData)
		for index, itemData in pairs(toolData) do
			_toolData[tonumber(index)] = itemData
		end
		updateTool(false)
	end)
	UIController.AddToolUI:Connect(function(addToolData)
		local addIndex = addToolData.Index
		-- 从背包拖物品到工具栏，如果工具栏上有工具，则替换，把原有的工具栏上的工具放进背包
		if _toolData[addIndex] and _toolData[addIndex].ItemId ~= 0 then
			local itemData = _toolData[addIndex]
			Knit.GetService("InventoryService"):AddItem(itemData)
		end

		_toolData[addIndex] = {ItemId = addToolData.ItemData.ItemId, Attribute = addToolData.ItemData.Attribute}
		Knit.GetService("InventoryService"):RemoveItem(addToolData.ItemData)
		updateTool(true)
	end)
	UIController.ShowAdminButton:Connect(function(isAdmin)
		_bdButton.Visible = isAdmin
	end)
end)
