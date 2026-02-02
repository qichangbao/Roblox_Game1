local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local TalentTreeConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("TalentTreeConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local TweenInterface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("TweenInterface"))
local PlayerAttribute = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("PlayerAttribute"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local _talentData = nil
local _selectItem = nil
local _inventoryData = {}
local _curTalentInfo = nil
local _curTalentData = nil

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TalentUI")
local _frame = _screenGui:WaitForChild("Frame")
local _talentScrollingFrame = _frame:WaitForChild("ScrollingFrame")
local _talentTemplateFrame = _talentScrollingFrame:WaitForChild("TemplateFrame")
_talentTemplateFrame.Visible = false
local _infoFrame = _frame:WaitForChild("InfoFrame")
local _needItemFrame = _infoFrame:WaitForChild("NeedItemFrame")
local _itemScrollingFrame = _needItemFrame:FindFirstChild("ScrollingFrame")
local _itemTemplateFrame = _itemScrollingFrame:FindFirstChild("TemplateFrame")
_itemTemplateFrame.Visible = false
local _activeFrame = _infoFrame:WaitForChild("ActiveFrame")
local _buttonFrame = _frame:WaitForChild("ButtonFrame")
local _attributeFrame = _frame:WaitForChild("AttributeFrame")
local _msText = _attributeFrame:WaitForChild("MovementSpeedFrame"):WaitForChild("Frame"):WaitForChild("VauleLabel")
local _mhText = _attributeFrame:WaitForChild("MaxHealthFrame"):WaitForChild("Frame"):WaitForChild("VauleLabel")
local _jpText = _attributeFrame:WaitForChild("JumpPowerFrame"):WaitForChild("Frame"):WaitForChild("VauleLabel")
local _ccText = _attributeFrame:WaitForChild("CarryCapacityFrame"):WaitForChild("Frame"):WaitForChild("VauleLabel")
local _gtText = _attributeFrame:WaitForChild("GatheringFrame"):WaitForChild("Frame"):WaitForChild("VauleLabel")
local _lkText = _attributeFrame:WaitForChild("LuckFrame"):WaitForChild("Frame"):WaitForChild("VauleLabel")

-- 预先声明以避免在递归布局中被识别为未定义的全局（Lua 闭包会捕获同名局部变量）
local changeTalentId

-- 规范化模板尺寸，避免 UIAspectRatioConstraint 与不一致的 X/Y Scale 产生“尺寸被压缩”的副作用
-- 原因：模板的 Size 为 X.Scale=0.15、Y.Scale=0.063，同时又有 UIAspectRatioConstraint(AspectRatio=1、DominantAxis=Width)，
--       Roblox 在进行约束计算时会尝试满足宽高比，这会根据渲染时机将宽或高调小，导致你看到 AbsoluteSize 从 ~31px 继续缩小到 ~23px。
-- 方案：在运行时强制模板为“正方形”，让 Y.Scale 与 X.Scale 相同（或只驱动 X，再由约束推导 Y），并统一 DominantAxis=Width。
-- 调用时机：脚本加载后立即执行一次；同时在克隆节点时也对每个克隆执行一次，保证所有节点一致。
local function NormalizeTemplateFrameSize(frame)
	if not frame or not frame:IsA("Frame") then return end
	local sx = frame.Size.X
	local desiredScale = sx.Scale
	local desiredOffset = sx.Offset
	-- 令高度与宽度保持一致（正方形）
	frame.Size = UDim2.new(desiredScale, desiredOffset, desiredScale, desiredOffset)
	-- 若存在宽高比约束，统一设为“宽度为主轴，正方形”
	local aspect = frame:FindFirstChildOfClass("UIAspectRatioConstraint")
	if aspect then
		aspect.AspectRatio = 1
		aspect.DominantAxis = Enum.DominantAxis.Width
	end
end

-- 启动时先规范化一次模板尺寸
NormalizeTemplateFrameSize(_talentTemplateFrame)

-- 判断天赋是否已完成
local function isSelfCompleted(talentId)
	if _talentData[tostring(talentId)] and _talentData[tostring(talentId)].Complated then
		return true
	end
	return false
end

-- 判断前置天赋是否已完成
local function isPreComplated(talentId)
	local talents = {}
	for _, v in ipairs(TalentTreeConfig:GetAll()) do
		if type(v.NextTalent) == "table" then
			for _, v2 in ipairs(v.NextTalent) do
				if v2 == talentId then
					table.insert(talents, v.TalentTreeId)
				end
			end
		else
			if v.NextTalent == talentId then
				table.insert(talents, v.TalentTreeId)
			end
		end
	end

	for _, talentTreeId in ipairs(talents) do
		local id = tostring(talentTreeId)
		if not isSelfCompleted(id) then
			return false
		end
	end
	return true
end

-- 更新天赋树展示（树状结构）
-- 从 TalentTreeConfig 的第一个数据开始，在 _talentFrame 中心显示根节点，
-- 根据 NextTalent 递归布局子节点：
-- - 1 个子节点：居中（x = 0.5）
-- - 2 个子节点：x = 0.3, 0.7
-- - 3 个子节点：x = 0.2, 0.5, 0.8
-- 并使用“竖-横-竖”的连线方式连接父子节点。
-- @param data table 玩家天赋数据映射（用于显示等级等）
-- 更新天赋树展示（树状结构），并绘制“从父节点底部出现 → 水平分叉 → 竖直到子节点顶端中间”的连线
-- @param data table 玩家天赋数据映射（用于显示等级等）
local function updateTalentFrame(data)
	for i, v in ipairs(_talentScrollingFrame:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "TemplateFrame" then
			v:Destroy()
		end
	end

	-- 计算行内横向位置
	local function computeRowPositions(count)
		if count <= 1 then
			return {0.5}
		elseif count == 2 then
			return {0.3, 0.7}
		elseif count == 3 then
			return {0.2, 0.5, 0.8}
		else
			-- 超过3个的情况，均匀分布
			local positions = {}
			local step = 1 / (count + 1)
			for i = 1, count do
				table.insert(positions, i * step)
			end
			return positions
		end
	end
	-- 像素级画垂直线：传入绝对像素坐标（推荐）。
	-- @param xAbs number 像素级 X 中心位置
	-- @param yAbsStart number 像素级起始 Y（上或下）
	-- @param yAbsEnd number 像素级结束 Y（上或下）
	-- @param thickness number 线条粗细（像素）
	local function drawVerticalLinePx(xAbs, yAbsStart, yAbsEnd, thickness)
		local line = Instance.new("Frame")
		line.Name = "Line"
		line.BorderSizePixel = 0
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.AnchorPoint = Vector2.new(0.5, 0)
		line.ZIndex = 10
		local length = math.abs(yAbsEnd - yAbsStart)
		line.Size = UDim2.new(0, thickness or 3, 0, length)
		local relX = xAbs - _talentScrollingFrame.AbsolutePosition.X
		local relY = math.min(yAbsStart, yAbsEnd) - _talentScrollingFrame.AbsolutePosition.Y
		line.Position = UDim2.new(0, relX, 0, relY)
		line.Parent = _talentScrollingFrame
		return line
	end
	-- 像素级画水平线：传入绝对像素坐标（推荐）。
	-- @param xAbsStart number 左端像素 X
	-- @param xAbsEnd number 右端像素 X
	-- @param yAbs number 像素级 Y（中心对齐）
	-- @param thickness number 线条粗细（像素）
	local function drawHorizontalLinePx(xAbsStart, xAbsEnd, yAbs, thickness)
		local line = Instance.new("Frame")
		line.Name = "Line"
		line.BorderSizePixel = 0
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.ZIndex = 10
		local width = math.abs(xAbsEnd - xAbsStart)
		line.Size = UDim2.new(0, width, 0, thickness or 3)
		local relX = math.min(xAbsStart, xAbsEnd) - _talentScrollingFrame.AbsolutePosition.X
		local relY = yAbs - _talentScrollingFrame.AbsolutePosition.Y
		line.Position = UDim2.new(0, relX, 0, relY)
		line.Parent = _talentScrollingFrame
		return line
	end

	-- 添加一个天赋节点到指定位置
	-- @param talentInfo table 配置项
	-- @param xScale number 节点的水平位置（0~1）
	-- @param yOffset number 节点的垂直位置（像素）
	-- @param talentData table 玩家此天赋的进度（用于显示等级与选中）
	-- @return Frame 节点Frame，nil若失败
	local function addTalentNode(talentInfo, xScale, yOffset, talentData)
		if not talentInfo then return nil end
		local frame = _talentTemplateFrame:Clone()
		frame.Name = talentInfo.TalentTreeId
		frame.Visible = true
		frame.Parent = _talentScrollingFrame
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(xScale, 0, 0, yOffset)

		-- 规范化克隆节点尺寸，防止约束导致意外压缩
		NormalizeTemplateFrameSize(frame)

		-- 设置展示信息
		local iconImage = frame:FindFirstChild("IconImage")
		if talentInfo.Icon then
			iconImage.Image = talentInfo.Icon
		end
		local highFrame = frame:FindFirstChild("HighFrame")
		highFrame.Visible = false
		local kuangImage = frame:FindFirstChild("KuangImage")
		if isSelfCompleted(talentInfo.TalentTreeId) then
			kuangImage.ImageColor3 = Color3.fromRGB(0, 255, 0)
		else
			kuangImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end

		if isSelfCompleted(talentInfo.TalentTreeId) or isPreComplated(talentInfo.TalentTreeId) then
			iconImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
		else
			iconImage.ImageColor3 = Color3.fromRGB(70, 70, 70)
		end

		-- 交互
		local textButton = frame:FindFirstChild("TextButton")
		textButton.MouseButton1Down:Connect(function()
			changeTalentId(frame, talentInfo, talentData)
		end)
		TweenInterface.SetupHoverScale(frame, textButton)

		return frame
	end

	-- 递归布局
	local visited = {}
	local maxDepth = 0        -- 记录最大层级以计算滚动区域
	-- 垂直布局改为“像素”驱动，避免受到 ScrollingFrame 高度变化影响导致节点互相覆盖。
	-- 每层间距 = 模板高度 + 额外留白（40px），确保父节点底部与子节点顶部至少有 40px 的净距。
	-- 模板高度优先取 AbsoluteSize（兼容 Scale 尺寸，如 {0.15,0}），否则回退 Offset/默认
	local templateH = (_talentTemplateFrame.AbsoluteSize.Y > 0) and _talentTemplateFrame.AbsoluteSize.Y
		or (_talentTemplateFrame.Size.Y.Offset > 0 and _talentTemplateFrame.Size.Y.Offset or 60)
	local rowGapPx = templateH + 40
	local rootYOffset = 20   -- 根节点的起始 Y（像素），稍微下移一点

	-- 获取根节点（第一个配置数据）
	local rootInfo = TalentTreeConfig:GetByIndex(1)
	if not rootInfo then return end

    --[[
    -- 函数：layout(talentInfo, xScale, depth, existingFrame)
    -- 作用：以“像素驱动”的方式递归布局天赋树节点，并根据父节点与子节点的 X 轴关系绘制连线。
    --      - 当父子 X 对齐时：直接从父底部到子顶部画竖线，不绘制横线；
    --      - 当父子 X 不对齐时：父底部向下到分叉 Y，再横线到子 X，最后竖线到子顶部；
    --      - 支持一个父节点对应多个子节点，以及多个父节点指向同一个子节点（复用已存在的子节点 Frame）。
    -- 参数：
    --   talentInfo    table  当前节点的配置数据（含 TalentTreeId、NextTalent 等）
    --   xScale        number 当前节点的水平位置（0~1 的比例，最终会换算为绝对像素）
    --   depth         number 当前节点的深度（用于计算垂直像素偏移）
    --   existingFrame Frame? 若节点已存在（例如其他父节点已创建该子节点），则复用该 Frame
    -- 返回：无（通过创建 UI 元素与连线来体现结果）
    --]]
	-- 递归布局（优先创建子节点，再绘制连线，最后递归到子节点）
	local function layout(talentInfo, xScale, depth, existingFrame)
		if not talentInfo or visited[talentInfo.TalentTreeId] then return end
		visited[talentInfo.TalentTreeId] = true
		-- 当前节点的垂直位置（像素）
		local yOffset = rootYOffset + depth * rowGapPx
		if depth > maxDepth then
			maxDepth = depth
		end
		local parentData = data and data[talentInfo.TalentTreeId] or nil
		local parentFrame = existingFrame or addTalentNode(talentInfo, xScale, yOffset, parentData)
		if not parentFrame then return end

		-- 处理子节点
		local nextField = talentInfo.NextTalent
		local nextList = {}
		if type(nextField) == "number" then
			table.insert(nextList, nextField)
		elseif type(nextField) == "table" then
			nextList = nextField
		else
			nextList = {}
		end
		if #nextList == 0 then return end

		local positions = computeRowPositions(#nextList)
		local childFrames = {}

		-- 先创建/获取所有子节点，确保获取到准确的绝对坐标用于画线
		for idx, childId in ipairs(nextList) do
			local childInfo = TalentTreeConfig:GetByTalentTreeId(childId)
			-- 单子节点时，沿用父节点的 X 轴位置，避免与其它父的单子节点发生重叠
			local childXScale = (#nextList == 1) and xScale or positions[idx]
			local childYOffset = yOffset + rowGapPx
			local existing = _talentScrollingFrame:FindFirstChild(tostring(childId))
			local childFrame
			if existing and existing:IsA("Frame") then
				-- 若节点已存在（可能由其他父节点创建），直接使用现有 Frame
				childFrame = existing
			else
				childFrame = addTalentNode(childInfo, childXScale, childYOffset, data and data[childId] or nil)
			end
			if childFrame then
				table.insert(childFrames, {info = childInfo, xScale = childXScale, frame = childFrame})
			end
		end
		if #childFrames == 0 then return end

		-- 计算父节点底部中心（像素）
		local parentCenterXAbs = parentFrame.AbsolutePosition.X + parentFrame.AbsoluteSize.X / 2
		local parentBottomYAbs = parentFrame.AbsolutePosition.Y + parentFrame.AbsoluteSize.Y

		-- 计算子节点顶端中心（像素），用于逐子节点绘制“下→横→上”
		local childCenters = {}
		for _, child in ipairs(childFrames) do
			local frame = child.frame
			local cx = frame.AbsolutePosition.X + frame.AbsoluteSize.X / 2
			local ty = frame.AbsolutePosition.Y
			table.insert(childCenters, {info = child.info, xScale = child.xScale, xAbs = cx, topYAbs = ty, frame = frame})
		end

		-- 根据子节点数量采用不同策略：
		-- 1) 单个子节点：若父子 X 对齐，只画竖线；若不对齐，走“下→横→上”。
		-- 2) 多个子节点：竖线到“父底部与子顶部之间的垂直间距的中点”后画一条公共横线，再各自竖线到子节点顶部，保证分叉位于父子间距的正中而非靠近子节点底部。
		if #childCenters == 1 then
			local child = childCenters[1]
			local childX = child.xAbs
			local childTop = child.topYAbs
			local xDelta = math.abs(childX - parentCenterXAbs)
			if xDelta <= 1 then
				drawVerticalLinePx(parentCenterXAbs, parentBottomYAbs, childTop, 3)
			else
				local stem = math.max(24, math.floor(parentFrame.AbsoluteSize.Y * 0.25) + 8)
				local desiredY = parentBottomYAbs + stem
				local lowerBound = parentBottomYAbs + 8
				local upperBound = childTop - 1
				local junctionYAbs = math.max(lowerBound, math.min(upperBound, desiredY))
				if junctionYAbs >= childTop then
					junctionYAbs = childTop - 1
				end
				drawVerticalLinePx(parentCenterXAbs, parentBottomYAbs, junctionYAbs, 3)
				drawHorizontalLinePx(parentCenterXAbs, childX, junctionYAbs, 3)
				drawVerticalLinePx(childX, junctionYAbs, childTop, 3)
			end
			if not visited[child.info.TalentTreeId] then
				layout(child.info, child.xScale, depth + 1, child.frame)
			end
		else
			-- 多子节点：公共水平分叉线的 Y 取“父节点底部与子节点顶部之间垂直间距的中点”
			-- 说明：若所有子节点处于同一行，其 topYAbs 应一致；为稳健，取最小 topYAbs 作为该行子节点的顶部参考。
			local minChildTopYAbs = math.huge
			local minX, maxX = math.huge, -math.huge
			for _, c in ipairs(childCenters) do
				if c.topYAbs < minChildTopYAbs then minChildTopYAbs = c.topYAbs end
				if c.xAbs < minX then minX = c.xAbs end
				if c.xAbs > maxX then maxX = c.xAbs end
			end
			-- 父子间距的中点（确保位于父底与子顶之间，不贴边）
			local gapHalf = math.floor((minChildTopYAbs - parentBottomYAbs) / 2)
			local junctionYAbs = parentBottomYAbs + gapHalf
			if junctionYAbs <= parentBottomYAbs + 2 then junctionYAbs = parentBottomYAbs + 2 end
			if junctionYAbs >= minChildTopYAbs - 1 then junctionYAbs = minChildTopYAbs - 1 end
			drawVerticalLinePx(parentCenterXAbs, parentBottomYAbs, junctionYAbs, 3)
			drawHorizontalLinePx(minX, maxX, junctionYAbs, 3)
			for _, child in ipairs(childCenters) do
				drawVerticalLinePx(child.xAbs, junctionYAbs, child.topYAbs, 3)
				if not visited[child.info.TalentTreeId] then
					layout(child.info, child.xScale, depth + 1, child.frame)
				end
			end
		end
	end

	layout(rootInfo, 0.5, 0, nil)

	-- 根据最大深度调整滚动区域（更精确的估算）
	-- CanvasSize 按像素估算，包含最后一层节点的高度与一些缓冲
	local needHeight = rootYOffset + (maxDepth + 1) * rowGapPx + templateH + 40
	_talentScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, needHeight)
end

local _textButton = _buttonFrame:WaitForChild("TextButton")
_textButton.MouseButton1Click:Connect(function()
	if not _curTalentInfo then return end
	if _textButton:FindFirstChild("Frame").Visible then return end

	local needInventoryItem = {}
	for index, item in ipairs(_curTalentInfo.Need) do
		if item.Item and item.Num then
			table.insert(needInventoryItem, index)
		end
	end

	Knit.GetService("TalentService"):Learn(_curTalentInfo.TalentTreeId):andThen(function(succ)
		if succ then
			local uiSound = Interface.safeWaitPart(game:GetService("SoundService"), "UI")
			local music = Interface.safeWaitPart(uiSound, "TalentUp")
			if not music.IsLoaded then
				music.Loaded:Wait()
			end
			music.Looped = false
			music:Play()

			for _, index in ipairs(needInventoryItem) do
				local itemFrame = nil
				for _, child in ipairs(_itemScrollingFrame:GetChildren()) do
					if child:IsA("Frame") and child.Visible and child.Name == tostring(index) then
						itemFrame = child
						break
					end
				end

				if not itemFrame then continue end
				local iconImage = itemFrame:WaitForChild("IconImage")
				local backpackButton = localPlayer.PlayerGui.MainUI.right.BackpackFrame.TextButton
				Knit.GetController("UIController").ShowFlyItemUI:Fire(iconImage, backpackButton, itemFrame)
			end
		end
	end)
end)
TweenInterface.SetupHoverScale(_textButton, _textButton)

local _titleImage = _frame:WaitForChild("TitleImage")
local _closeButton = _titleImage:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local function updateLevelFrame()
	if not _curTalentInfo then return end

	if _curTalentInfo.Icon then
		_activeFrame:FindFirstChild("IconImage").Image = _curTalentInfo.Icon
	end
	if _curTalentInfo.DisplayName then
		_activeFrame:FindFirstChild("NameLabel").Text =  _curTalentInfo.DisplayName
	end
	if _curTalentInfo.Description then
		_activeFrame:FindFirstChild("DescriptionLabel").Text =  _curTalentInfo.Description
	end

	local function setValue(valueStr, childType)
		if not _curTalentInfo.Value then return end
		local valueLabel = _activeFrame:FindFirstChild("ValueLabel")
		if valueLabel then
			if childType == 1 then
				valueLabel.Text = valueStr .. "+" .. _curTalentInfo.Value .. "%"
			else
				valueLabel.Text = valueStr .. "+" .. _curTalentInfo.Value
			end
		end
	end
	if _curTalentInfo.Type == GameConfig.TalentType.WalkSpeed then
		setValue("Movement Speed: ", _curTalentInfo.ChildType)
	elseif _curTalentInfo.Type == GameConfig.TalentType.MaxHealth then
		setValue("Max Health: ", _curTalentInfo.ChildType)
	elseif _curTalentInfo.Type == GameConfig.TalentType.Jump then
		setValue("Jump Power: ", _curTalentInfo.ChildType)
	elseif _curTalentInfo.Type == GameConfig.TalentType.Weight then
		setValue("Carry Capacity: ", _curTalentInfo.ChildType)
	elseif _curTalentInfo.Type == GameConfig.TalentType.CollectSpeed then
		setValue("Gathering: ", _curTalentInfo.ChildType)
	elseif _curTalentInfo.Type == GameConfig.TalentType.Lucky then
		setValue("Luck: ", _curTalentInfo.ChildType)
	end
end

local function updateItemFrame()
	for _, child in ipairs(_itemScrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= _itemTemplateFrame then
			child:Destroy()
		end
	end

	-- 遍历需要的物品与数量（基于 TalentTreeConfig.Need 字段）
	local need = _curTalentInfo.Need or {}
	for i, item in ipairs(need) do
		local frame = _itemTemplateFrame:Clone()
		frame.Visible = true
		frame.Parent = _itemScrollingFrame
		if item.Item and item.Num then
			frame.Name = tostring(i)
			local itemId = item.Item
			local maxNum = item.Num
			local itemInfo = ItemConfig:GetByItemId(itemId)
			if itemInfo then
				frame:FindFirstChild("IconImage").Image = itemInfo.Icon
				frame:FindFirstChild("NumLabel").Text = maxNum
				local textButton = frame:FindFirstChild("TextButton")
				textButton.MouseButton1Down:Connect(function()
					Knit.GetController("UIController").ShowItemAttributeUI:Fire(itemId)
				end)
				TweenInterface.SetupHoverScale(frame, textButton)
			end
		elseif item.Gold then
			frame.Name = "Gold"
			frame:FindFirstChild("IconImage").Image = "rbxassetid://102600054562573"
			frame:FindFirstChild("NumLabel").Text = Interface.formatCurrency(item.Gold)
		end
	end
end

local function updateButtonText()
	if not _curTalentInfo then
		_textButton.Visible = false
		return
	end

	if _curTalentData and _curTalentData.Complated then
		_textButton.Visible = false
		return
	end

	if isSelfCompleted(_curTalentInfo.TalentTreeId) then
		_textButton.Visible = false
		return
	end

	if not isPreComplated(_curTalentInfo.TalentTreeId) then
		_textButton.Visible = false
		return
	end
	_textButton.Visible = true

	local isAllHave = true
	local need = _curTalentInfo.Need or {}
	for _, item in ipairs(need) do
		if item.Item and item.Num then
			local itemId = item.Item
			local maxNum = item.Num
			if not _inventoryData[itemId] or _inventoryData[itemId] < maxNum then
				isAllHave = false
				break
			end
		elseif item.Gold then
			if _G.ClientData.Gold < item.Gold then
				isAllHave = false
				break
			end
		end
	end

	_textButton:FindFirstChild("Frame").Visible = not isAllHave
end

-- 切换当前选中的天赋节点，并刷新右侧信息与按钮状态
-- @param frame Frame 被点击的节点 UI
-- @param talentInfo table 当前天赋的配置数据
-- @param talentData table 当前天赋的玩家数据（等级/已提交材料等）
changeTalentId = function(frame, talentInfo, talentData)
	if not localPlayer.Character then return end
	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
	if not humanoid then return end

	if _selectItem then
		local highFrame = _selectItem:FindFirstChild("HighFrame")
		if highFrame then
			highFrame.Visible = false
		end
	end
	_selectItem = frame
	_selectItem.Name = talentInfo.TalentTreeId
	_selectItem:FindFirstChild("HighFrame").Visible = true
	_curTalentInfo = talentInfo
	_curTalentData = talentData

	updateLevelFrame()
	updateItemFrame()
	updateButtonText()
end

--[[
-- 函数：updateData(data)
-- 作用：刷新背包计数与天赋树展示；当玩家天赋数据 data 为 nil 或空表 {} 时，默认高亮并选中第一个天赋节点。
-- 参数：
--   data table? 玩家天赋数据映射（key 为 TalentTreeId），可能为 nil 或空表
-- 返回：无
--]]
local function updateData(data)
	_inventoryData = {}
	for _, itemData in pairs(_G.ClientData.Inventory) do
		if not _inventoryData[itemData.ItemId] then
			_inventoryData[itemData.ItemId] = 1
		else
			_inventoryData[itemData.ItemId] += 1
		end
	end
	for _, itemData in pairs(_G.ClientData.ToolData) do
		if itemData.ItemId == 0 then continue end
		if not _inventoryData[itemData.ItemId] then
			_inventoryData[itemData.ItemId] = 1
		else
			_inventoryData[itemData.ItemId] += 1
		end
	end

	_talentData = data
	-- 展示天赋树
	updateTalentFrame(data)

	-- 若 data 为 nil 或 {}，默认选中并高亮第一个（根）节点
	local noData = (data == nil) or (type(data) == "table" and next(data) == nil)
	if noData then
		local firstInfo = TalentTreeConfig:GetByIndex(1)
		if firstInfo then
			local firstFrame = _talentScrollingFrame:FindFirstChild(tostring(firstInfo.TalentTreeId))
			if firstFrame then
				local td = nil
				if type(data) == "table" then
					td = data[firstInfo.TalentTreeId]
				end
				changeTalentId(firstFrame, firstInfo, td)
			end
		end
	else
		-- 根据“已学习的最深层”与父子关系选择下一个待学习节点
		-- 1) 构建配置信息映射与父关系映射
		local allInfos = TalentTreeConfig:GetAll()
		local infoMap = {}
		local parentMap = {}
		local function nextListOf(info)
			local nxt = info and info.NextTalent
			if type(nxt) == "number" then
				return {nxt}
			elseif type(nxt) == "table" then
				return nxt
			else
				return {}
			end
		end
		for _, inf in ipairs(allInfos) do
			infoMap[inf.TalentTreeId] = inf
			for _, cid in ipairs(nextListOf(inf)) do
				parentMap[cid] = parentMap[cid] or {}
				table.insert(parentMap[cid], inf.TalentTreeId)
			end
		end

		-- 2) 计算每个节点的层级（从根开始，最小层级）
		local rootInfo = TalentTreeConfig:GetByIndex(1)
		local rootId = rootInfo and rootInfo.TalentTreeId
		local depth = {}
		if rootId then
			local q = {rootId}
			depth[rootId] = 1
			local qi = 1
			while qi <= #q do
				local pid = q[qi]; qi = qi + 1
				local pinfo = infoMap[pid]
				for _, cid in ipairs(nextListOf(pinfo)) do
					if not depth[cid] then
						depth[cid] = depth[pid] + 1
						q[#q+1] = cid
					else
						depth[cid] = math.min(depth[cid], depth[pid] + 1)
					end
				end
			end
		end

		-- 3) 已学习集合与最深层级
		local learned = {}
		local maxLearnedDepth = 0
		for _, td in pairs(data) do
			learned[td.TalentTreeId] = true
			local d = depth[td.TalentTreeId] or 0
			if d > maxLearnedDepth then maxLearnedDepth = d end
		end

		-- 4) 在“已学习的父节点”下，按 NextTalent 顺序挑选第一个满足“所有父节点均已学习”的未学习子节点；
		--    若存在多个候选，以父节点层级更深者优先；若层级相同，以遍历顺序（通常为配置顺序/ID升序）优先。
		local targetId = nil
		local targetInfo = nil
		local bestParentDepth = -1
		for _, td in pairs(data) do
			local pid = td.TalentTreeId
			local pinfo = infoMap[pid]
			local pd = depth[pid] or 0
			for _, cid in ipairs(nextListOf(pinfo)) do
				if not learned[cid] then
					local ok = true
					local parents = parentMap[cid] or {}
					for _, p in ipairs(parents) do
						if not learned[p] then ok = false; break end
					end
					if ok then
						if pd > bestParentDepth then
							bestParentDepth = pd
							targetId = cid
							targetInfo = infoMap[cid]
							break
						end
					end
				end
			end
		end

		-- 5) 如果没有通过“父->子”找到候选，则退而在所有未学习节点中，
		--    找出“所有父已学习”的节点，选择层级（depth）最小且大于 maxLearnedDepth 的一个。
		if not targetId then
			local bestDepth = math.huge
			for id, inf in pairs(infoMap) do
				if not learned[id] then
					local parents = parentMap[id] or {}
					local ok = true
					for _, p in ipairs(parents) do
						if not learned[p] then ok = false; break end
					end
					local d = depth[id] or math.huge
					if ok and d > maxLearnedDepth and d < bestDepth then
						bestDepth = d
						targetId = id
						targetInfo = inf
					end
				end
			end
		end

		-- 6) 执行选中高亮（若找不到目标，则默认选中最后一个已学习节点或根）
		if targetId and targetInfo then
			local targetFrame = _talentScrollingFrame:FindFirstChild(tostring(targetId))
			if targetFrame then
				changeTalentId(targetFrame, targetInfo, data[targetId])
			else
				-- 框架未找到则退回默认根
				local firstInfo = TalentTreeConfig:GetByIndex(1)
				if firstInfo then
					local firstFrame = _talentScrollingFrame:FindFirstChild(tostring(firstInfo.TalentTreeId))
					if firstFrame then changeTalentId(firstFrame, firstInfo, data[firstInfo.TalentTreeId]) end
				end
			end
		else
			-- 无可选目标：选中最深的已学习节点（若存在），否则选根
			local selId, selInfo, selFrame
			local bestD = -1
			for _, td in pairs(data) do
				local d = depth[td.TalentTreeId] or 0
				if d > bestD then
					bestD = d
					selId = td.TalentTreeId
					selInfo = infoMap[selId]
					selFrame = _talentScrollingFrame:FindFirstChild(tostring(selId))
				end
			end
			if selFrame and selInfo then
				changeTalentId(selFrame, selInfo, data[selId])
			else
				local firstInfo = TalentTreeConfig:GetByIndex(1)
				if firstInfo then
					local firstFrame = _talentScrollingFrame:FindFirstChild(tostring(firstInfo.TalentTreeId))
					if firstFrame then changeTalentId(firstFrame, firstInfo, data[firstInfo.TalentTreeId]) end
				end
			end
		end
	end

	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
	_msText.Text = humanoid and humanoid.WalkSpeed or 0
	_mhText.Text = humanoid and humanoid.MaxHealth or 0
	_jpText.Text = humanoid and humanoid.JumpPower or 0
	_ccText.Text = PlayerAttribute.GetWeight(localPlayer)
	_gtText.Text = 0
	_lkText.Text = PlayerAttribute.GetLucky(localPlayer)
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").UpdateTalentData:Connect(function(data)
		if not _screenGui.Enabled then
			return
		end

		updateData(_G.ClientData.TalentData)
	end)

	Knit.GetController("UIController").ShowTalentUI:Connect(function(data)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_selectItem = nil

		updateData(_G.ClientData.TalentData)

		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)