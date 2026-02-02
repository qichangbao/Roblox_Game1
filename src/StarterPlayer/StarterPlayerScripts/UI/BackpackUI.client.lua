local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local TweenInterface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('TweenInterface'))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("BackpackUI")
_screenGui.Enabled = false
local _frame = _screenGui:WaitForChild("Frame")
local _scrollingFrame = _frame:WaitForChild("ScrollingFrame")
local _templateFrame = _scrollingFrame:WaitForChild("TemplateFrame")
_templateFrame.Visible = false

local _titleImage = _frame:WaitForChild("TitleImage")
local _closeButton = _titleImage:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local _backpack = {}

-- 拖拽相关变量
local _isDragging = false
local _dragConnection = nil
local _currentDragItem = nil
local _isWaitingForDrag = false
local _curSelectIndex = 0

local _buttonFrame = _frame:WaitForChild("ButtonFrame")
local _lockButton = _buttonFrame:WaitForChild("TextButton")
local _lockImage = _lockButton:WaitForChild("LockedImage")
_lockImage.Visible = false
local _unlockImage = _lockButton:WaitForChild("UnLockedImage")
_unlockImage.Visible = false
_lockButton.MouseButton1Click:Connect(function()
	local itemData = _backpack[_curSelectIndex]
	if not itemData then return end
	local frame = nil
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if tonumber(child.Name) == _curSelectIndex then
			frame = child
			break
		end
	end

	if not frame then return end
	Knit.GetService("InventoryService"):LockItem(_curSelectIndex, itemData.Attribute.IsLocked == 0 and 1 or 0)
end)
TweenInterface.SetupHoverScale(_lockButton, _lockButton)

local function selectItem(item)
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= item then
			child:WaitForChild("HighFrame").Visible = false
		end
	end
end

-- 获取MainUI中的目标Frame
-- @return table 包含1-9号Frame的数组
local function getMainUISlots()
	local mainUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MainUI")
	if not mainUI then
		return {}
	end

	local bottomFrame = mainUI:FindFirstChild("bottom")
	if not bottomFrame then
		return {}
	end

	local toolFrame = bottomFrame:FindFirstChild("ToolFrame")
	if not toolFrame then
		return {}
	end

	local slots = {}
	for i = 1, GameConfig.SLOT_NUM do
		local slot = toolFrame:FindFirstChild(tostring(i))
		if slot then
			table.insert(slots, slot)
		end
	end

	return slots
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
local function startDrag(itemFrame, x, y)
	if _isDragging then
		return
	end
	
	_scrollingFrame.Active = false

	_isDragging = true
	_currentDragItem = itemFrame
	local icon = itemFrame:FindFirstChild("ImageLabel").Image

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
			local slots = getMainUISlots()
			local inSlot = false

			for _, slot in ipairs(slots) do
				if isMouseInFrame(slot, mousePosition) then
					inSlot = true
					break
				end
			end

			local isInFrame = isMouseInFrame(_frame, mousePosition)

			-- 显示或隐藏丢弃标签
			if inSlot or isInFrame then
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
	_scrollingFrame.Active = true

	-- 断开连接
	if _dragConnection then
		_dragConnection:Disconnect()
		_dragConnection = nil
	end

	-- 隐藏拖拽图像和丢弃标签
	Knit.GetController("UIController").HideDragUI:Fire()

	-- 检查是否放置在有效槽位
	local slots = getMainUISlots()
	local targetSlot = nil

	for _, slot in ipairs(slots) do
		if isMouseInFrame(slot, mousePosition) then
			targetSlot = slot
			break
		end
	end

	if targetSlot and _currentDragItem then
		local itemId = _currentDragItem:GetAttribute("ItemId")
		local itemInfo = ItemConfig:GetByItemId(itemId)
		if itemInfo.Type == GameConfig.ItemType.Explore
			or itemInfo.Type == GameConfig.ItemType.Weapon
			or itemInfo.Type == GameConfig.ItemType.Assistance
			or itemInfo.Type == GameConfig.ItemType.Treatment then
			Knit.GetController("UIController").AddToolUI:Fire({Index = tonumber(targetSlot.Name),
				ItemData = {ItemId = itemId, Attribute = GameConfig.GetItemAttribute(_currentDragItem)}})

			local uiSound = Interface.safeWaitPart(game:GetService("SoundService"), "UI")
			local sound = Interface.safeWaitPart(uiSound, "SwitchItem")
			sound.Looped = false
			sound:Play()
		end
	end

	_currentDragItem = nil
end

local function updateBackpack()
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= _templateFrame then
			child:Destroy()
		end
	end

	for index, itemData in ipairs(_backpack) do
		local itemId = itemData.ItemId
		if itemId == 0 then
			continue
		end
		local newFrame = _templateFrame:Clone()
		local itemInfo = ItemConfig:GetByItemId(itemId)
		if not itemInfo then
			continue
		end
		newFrame.Name = index
		newFrame.Visible = true
		newFrame.Parent = _scrollingFrame
		newFrame:SetAttribute("ItemId", itemId)
		GameConfig.SetItemAttribute(newFrame, itemData.Attribute)
		itemData.Attribute = GameConfig.GetItemAttribute(newFrame)
		newFrame:FindFirstChild("NameLabel").Text = itemInfo.DisplayName
		newFrame:FindFirstChild("ImageLabel").Image = itemInfo.Icon
		local useNumLabel = newFrame:FindFirstChild("UseNumLabel")
		if itemInfo.Duration > 0 then
			useNumLabel.Visible = true
			useNumLabel.Text = math.floor(math.max(0, itemInfo.Duration - itemData.Attribute.UsedTime or 0))
		elseif itemInfo.TimeUsed > 0 then
			useNumLabel.Visible = true
			useNumLabel.Text = math.floor(math.max(0, itemInfo.TimeUsed - itemData.Attribute.UsedNum or 0))
		else
			useNumLabel.Visible = false
		end

		local highFrame = newFrame:FindFirstChild("HighFrame")
		highFrame.Visible = false
		
		newFrame:FindFirstChild("LockImage").Visible = itemData.Attribute.IsLocked == 1

		local selectFrame = newFrame:FindFirstChild("SelectFrame")
		local selectButton = selectFrame:FindFirstChild("SelectButton")

		-- 点击选择事件
		selectButton.MouseButton1Click:Connect(function()
			if not highFrame.Visible then
				highFrame.Visible = true
				selectItem(newFrame)
				_curSelectIndex = index
				_lockImage.Visible = itemData.Attribute.IsLocked == 0
				_unlockImage.Visible = itemData.Attribute.IsLocked == 1
			end
		end)
		TweenInterface.SetupHoverScale(newFrame, selectButton)

		-- 拖拽事件
		selectButton.MouseButton1Down:Connect(function(x, y)
			-- 开始等待拖拽状态
			_isWaitingForDrag = true

			-- 设置0.5秒延迟计时器
			task.delay(0.3, function()
				if _isWaitingForDrag then
					_isWaitingForDrag = false
					startDrag(newFrame, x, y)
				end
			end)
		end)
		selectButton.MouseButton1Up:Connect(function(x, y)
			if _isWaitingForDrag then
				-- 如果在等待拖拽状态（0.5秒内松开），执行点击逻辑
				_isWaitingForDrag = false
				Knit.GetController("UIController").ShowItemAttributeUI:Fire(itemId)
			end
		end)
		
		if index == 1 then
			highFrame.Visible = true
			selectItem(newFrame)
			_curSelectIndex = index
			_lockImage.Visible = itemData.Attribute.IsLocked == 0
			_unlockImage.Visible = itemData.Attribute.IsLocked == 1
		end
	end
end

-- 监听鼠标释放事件
UserInputService.InputEnded:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch) then
		if _isDragging then
			-- 如果正在拖拽，结束拖拽
			local mousePosition = UserInputService:GetMouseLocation()
			endDrag(mousePosition)
		elseif _isWaitingForDrag then
			-- 如果在等待拖拽状态（0.5秒内松开），执行点击逻辑
			_isWaitingForDrag = false
		end
	end
end)

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").UpdateBackpack:Connect(function(data)
		_backpack = data
		if _screenGui.Enabled then
			updateBackpack()
		end
	end)

	Knit.GetController("UIController").ShowBackpackUI:Connect(function()
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		_backpack = _G.ClientData.Inventory
		updateBackpack()
		
		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)