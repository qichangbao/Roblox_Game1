local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local QuestConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("QuestConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local MonsterConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("MonsterConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local TweenInterface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("TweenInterface"))

local _questData = {}
local _inventoryData = {}
local _curTypeFlag = 1
local _curChildButton = nil
local _curChildIndex = 0
local _openType = 0		-- 1为NPC任务，2为按钮打开

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("QuestUI")
local _frame = _screenGui:WaitForChild("Frame")
local _taskFrame = _frame:WaitForChild("TaskFrame")
local _textButton1 = _taskFrame:WaitForChild("TextButton1")
local _textButton2 = _taskFrame:WaitForChild("TextButton2")
local _scrollingFrame = _frame:WaitForChild("ScrollingFrame")
local _listTemplateFrame = _scrollingFrame:WaitForChild("TemplateFrame")
_listTemplateFrame.Visible = false

local _browseTask = _frame:WaitForChild("BrowseTask")
_browseTask.Visible = false

local _AcceptButton = _browseTask:WaitForChild("AcceptButton")
_AcceptButton.MouseButton1Click:Connect(function()
	if _curTypeFlag == 1 then
		Knit.GetService("QuestService"):StartQuest(tostring(_curChildIndex)):andThen(function()

		end)
	else
		local questId = tostring(_curChildIndex)
		local quest = _questData[questId]
		local needInventoryItem = {}
		for _, tp in ipairs(quest.Tasks) do
			if tp.Type == GameConfig.TaskType.CollectItem and not tp.Done and tp.TargetCounts then
				-- 检查该子任务是否可被完全满足
				for itemId, needNum in pairs(tp.TargetCounts) do
					if tp.Counts[itemId] < needNum then
						if (_inventoryData[tonumber(itemId)] or 0) >= needNum then
							table.insert(needInventoryItem, tonumber(itemId))
						end
					end
				end
			end
		end
		local targetFrame = _browseTask:WaitForChild("TaskTargetFrame")
		local targetScrollingFrame = targetFrame:WaitForChild("ScrollingFrame")
		Knit.GetService("QuestService"):SubmitQuest(questId):andThen(function(returnFlag)
			if returnFlag == 1 then
				for _, itemId in ipairs(needInventoryItem) do
					local itemFrame = nil
					for _, child in ipairs(targetScrollingFrame:GetChildren()) do
						if child:IsA("Frame") and child.Visible and child.Name == tostring(itemId) then
							itemFrame = child
							break
						end
					end

					if not itemFrame then continue end
					local frame = itemFrame:FindFirstChild("Frame")
					local backpackButton = game.Players.LocalPlayer.PlayerGui.MainUI.right.BackpackFrame.TextButton
					Knit.GetController("UIController").ShowFlyItemUI:Fire(frame, backpackButton, itemFrame)
				end
			elseif returnFlag == 2 then

			end
		end)
	end
end)
TweenInterface.SetupHoverScale(_AcceptButton, _AcceptButton)

local function getMonsterValue(questId, valueInfo, quest)
	local t = {}
	for _, info in ipairs(valueInfo) do
		local isDone = false
		if quest then
			local monsterId = tostring(info.MonsterId)
			if quest.Counts[monsterId] >= quest.TargetCounts[monsterId] then
				isDone = true
			end
		end
		local monsterInfo = MonsterConfig:GetByMonsterId(info.MonsterId)
		if not monsterInfo then continue end
		table.insert(t, {IsDone = isDone, Text = string.format("Defeat %s x%d", 
			monsterInfo.DisplayName, info.Num)})
	end
	return t
end

local function getItemValue(questId, valueInfo, quest)
	local t = {}
	for _, info in ipairs(valueInfo) do
		local isDone = false
		if quest then
			local itemId = tostring(info.ItemId)
			if quest.Counts[itemId] >= quest.TargetCounts[itemId] then
				isDone = true
			end
		end
		local itemInfo = ItemConfig:GetByItemId(info.ItemId)
		if not itemInfo then continue end
		table.insert(t, {IsDone = isDone, ItemId = info.ItemId, Text = string.format("Deliver %s x%d", 
			itemInfo.DisplayName, info.Num)})
	end
	return t
end

local function getRetrieveAtLocationValue(questId, valueInfo, quest)
	local t = {}
	local isDone = false
	if quest and quest.Done then
		isDone = true
	end

	local itemInfo = ItemConfig:GetByItemId(valueInfo.ItemId)
	if not itemInfo then return {} end
	table.insert(t, {IsDone = isDone, Text = string.format("Place %s x%d at %d,%d,%d", 
		itemInfo.DisplayName, valueInfo.Num, valueInfo.Pos.X, valueInfo.Pos.Y, valueInfo.Pos.Z)})
	return t
end

local function getPlaceAtLocationValue(questId, valueInfo, quest)
	local t = {}
	local isDone = false
	if quest and quest.Done then
		isDone = true
	end

	local itemInfo = ItemConfig:GetByItemId(valueInfo.ItemId)
	if not itemInfo then return {} end
	table.insert(t, {IsDone = isDone, Text = string.format("Find %s x%d in %d,%d,%d", 
		itemInfo.DisplayName, valueInfo.Num, valueInfo.Pos.X, valueInfo.Pos.Y, valueInfo.Pos.Z)})
	return t
end

local function getScoutAreaValue(questId, valueInfo, quest)
	local t = {}
	local isDone = false
	if quest and quest.Done then
		isDone = true
	end

	table.insert(t, {IsDone = isDone, Text = string.format("Scout %d,%d,%d", 
		valueInfo.Pos.X, valueInfo.Pos.Y, valueInfo.Pos.Z)})
	return t
end

local function getUseSpecificItemOnTargetValue(questId, valueInfo, quest)
	local t = {}
	local isDone = false
	if quest and quest.Done then
		isDone = true
	end

	--table.insert(t, {IsDone = isDone, Text = string.format("Find %s x%d in %d,%d,%d", 
	--	itemInfo.DisplayName, valueInfo.Num, valueInfo.Pos.X, valueInfo.Pos.Y, valueInfo.Pos.Z)})
	return t
end

local function getValueInfo(taskInfo)
	local data = _questData[tostring(taskInfo.QuestId)]
	local childTasks = nil
	if data then
		childTasks = data.Tasks
	end
	if taskInfo.Type == GameConfig.TaskType.KillMonster then
		local quest = nil
		if childTasks then
			quest = childTasks[1]
		end
		return getMonsterValue(taskInfo.QuestId, taskInfo.Value, quest)
	elseif taskInfo.Type == GameConfig.TaskType.CollectItem then
		local quest = nil
		if childTasks then
			quest = childTasks[1]
		end
		return getItemValue(taskInfo.QuestId, taskInfo.Value, quest)
	elseif taskInfo.Type == GameConfig.TaskType.RetrieveAtLocation then
		local quest = nil
		if childTasks then
			quest = childTasks[1]
		end
		return getRetrieveAtLocationValue(taskInfo.QuestId, taskInfo.Value, quest)
	elseif taskInfo.Type == GameConfig.TaskType.PlaceAtLocation then
		local quest = nil
		if childTasks then
			quest = childTasks[1]
		end
		return getPlaceAtLocationValue(taskInfo.QuestId, taskInfo.Value, quest)
	elseif taskInfo.Type == GameConfig.TaskType.ScoutArea then
		local quest = nil
		if childTasks then
			quest = childTasks[1]
		end
		return getScoutAreaValue(taskInfo.QuestId, taskInfo.Value, quest)
	elseif taskInfo.Type == GameConfig.TaskType.UseSpecificItemOnTarget then
		local quest = nil
		if childTasks then
			quest = childTasks[1]
		end
		return getUseSpecificItemOnTargetValue(taskInfo.QuestId, taskInfo.Value, quest)
	elseif taskInfo.Type == GameConfig.TaskType.Composite then
		local tArray = {} -- 存储所有t变量的数组（数组的数组）
		for i, v in ipairs(taskInfo.Value) do
			local t = nil
			local quest = nil
			if childTasks then
				quest = childTasks[i]
			end
			if v.Type == GameConfig.TaskType.KillMonster then
				t = getMonsterValue(taskInfo.QuestId, v.Date, quest)
			elseif v.Type == GameConfig.TaskType.CollectItem then
				t = getItemValue(taskInfo.QuestId, v.Date, quest)
			elseif v.Type == GameConfig.TaskType.RetrieveAtLocation then
				t = getRetrieveAtLocationValue(taskInfo.QuestId, v.Date, quest)
			elseif v.Type == GameConfig.TaskType.PlaceAtLocation then
				t = getPlaceAtLocationValue(taskInfo.QuestId, v.Date, quest)
			elseif v.Type == GameConfig.TaskType.ScoutArea then
				t = getScoutAreaValue(taskInfo.QuestId, v.Date, quest)
			elseif v.Type == GameConfig.TaskType.UseSpecificItemOnTarget then
				t = getUseSpecificItemOnTargetValue(taskInfo.QuestId, v.Date, quest)
			end

			if t then
				for j, k in ipairs(t) do
					table.insert(tArray, k) -- 将t数组添加到tArray中
				end
			end
		end
		-- 返回合并后的数组（如果需要返回数组的数组，可以改为 return tArray）
		return tArray
	end
	return {}
end

local function updateBase(taskInfo)
	local infoFrame = _browseTask:WaitForChild("TaskInfoFrame")
	infoFrame:WaitForChild("NameLabel").Text = taskInfo.QuestName
	infoFrame:WaitForChild("DescriptionLabel").Text = taskInfo.QuestDescription

	local prepareFrame = _browseTask:WaitForChild("PrepareFrame")
	local prepareScrollingFrame = prepareFrame:WaitForChild("ScrollingFrame")
	local prepareTemplateFrame = prepareScrollingFrame:WaitForChild("TemplateFrame")
	prepareTemplateFrame.Visible = false
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(prepareScrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= prepareTemplateFrame then
			child:Destroy()
		end
	end
	if taskInfo.Preparation ~= 0 and type(taskInfo.Preparation) == "table" then
		for _, prepareInfo in ipairs(taskInfo.Preparation) do
			local frame = prepareTemplateFrame:Clone()
			frame.Visible = true
			frame.Parent = prepareScrollingFrame
			local itemInfo = ItemConfig:GetByItemId(prepareInfo.ItemId)
			if not itemInfo then continue end
			frame:WaitForChild("IconImage").Image = itemInfo.Icon
			frame:WaitForChild("DescribeLabel").Text = itemInfo.DisplayName .. " x" .. prepareInfo.Num
		end
	end

	local targetFrame = _browseTask:WaitForChild("TaskTargetFrame")
	local targetScrollingFrame = targetFrame:WaitForChild("ScrollingFrame")
	local targetTemplateFrame = targetScrollingFrame:WaitForChild("TemplateFrame")
	targetTemplateFrame.Visible = false
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(targetScrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= targetTemplateFrame then
			child:Destroy()
		end
	end

	local valueTable = getValueInfo(taskInfo)
	for _, valueInfo in ipairs(valueTable) do
		local frame = targetTemplateFrame:Clone()
		if valueInfo.ItemId then
			frame.Name = valueInfo.ItemId
		end
		frame.Visible = true
		frame.Parent = targetScrollingFrame
		if valueInfo.IsDone then
			frame:FindFirstChild("Frame").BackgroundColor3 = Color3.fromRGB(218, 187, 61)
		else
			frame:FindFirstChild("Frame").BackgroundColor3 = Color3.fromRGB(255, 250, 243)
		end
		frame:FindFirstChild("DescribeLabel").Text = valueInfo.Text
	end

	local rewardFrame = _browseTask:WaitForChild("RewardFrame")
	local rewardScrollingFrame = rewardFrame:WaitForChild("ScrollingFrame")
	local rewardTemplateFrame = rewardScrollingFrame:WaitForChild("TemplateFrame")
	rewardTemplateFrame.Visible = false
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(rewardScrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= rewardTemplateFrame then
			child:Destroy()
		end
	end

	for _, reward in ipairs(taskInfo.RewardItem) do
		local item = rewardTemplateFrame:Clone()
		item.Visible = true
		item.Parent = rewardScrollingFrame

		local itemInfo = ItemConfig:GetByItemId(reward.ItemId)
		if not itemInfo then continue end
		item:FindFirstChild("IconImage").Image = itemInfo.Icon
		item:FindFirstChild("NumLabel").Text = reward.Num
		local textButton = item:FindFirstChild("TextButton")
		textButton.MouseButton1Click:Connect(function()
			Knit.GetController("UIController").ShowItemAttributeUI:Fire(reward.ItemId)
		end)
		TweenInterface.SetupHoverScale(item, textButton)
	end
end

local function updateAccept(taskInfo)
	_browseTask.Visible = true
	_AcceptButton.Text = "Accept Quest"
	updateBase(taskInfo)
end

local function updateBrowse(taskInfo)
	_browseTask.Visible = true
	_AcceptButton.Text = "Submit Quest"
	updateBase(taskInfo)
end

-- 功能函数：判断某个子任务是否完成
-- 针对不同任务类型做细化判断：
-- CollectItem/KillMonster 使用 Counts/TargetCounts 比较；
-- PlaceAtLocation/ScoutArea 使用状态标记（Done）；
-- 其它类型以 Done 为准。
-- @param tp table 子任务进度对象
-- @return boolean 子任务是否完成
local function isChildTaskFinished(tp)
	if tp.Done then return true end
	if tp.Type == GameConfig.TaskType.CollectItem then
		if tp.TargetCounts and tp.Counts then
			for itemId, needNum in pairs(tp.TargetCounts) do
				local keyStr = tostring(itemId)
				local curNum = tp.Counts[itemId] or tp.Counts[keyStr] or 0
				if curNum < (needNum or 0) then
					return false
				end
			end
			return true
		end
		return false
	elseif tp.Type == GameConfig.TaskType.KillMonster then
		if tp.TargetCounts and tp.Counts then
			for monsterId, needNum in pairs(tp.TargetCounts) do
				local keyStr = tostring(monsterId)
				local curNum = tp.Counts[monsterId] or tp.Counts[keyStr] or 0
				if curNum < (needNum or 0) then
					return false
				end
			end
			return true
		end
		return false
	elseif tp.Type == GameConfig.TaskType.PlaceAtLocation then
		return tp.Done == true
	elseif tp.Type == GameConfig.TaskType.ScoutArea then
		return tp.Done == true
	else
		return tp.Done == true
	end
end

-- 功能函数：判断列表项的提示图标（ImageLabel）是否需要显示
-- 情况一（更新）：任务所有子任务均完成（即使 quest.Completed 仍为 false）
-- 情况二：背包已有可提交的采集物品
-- @param questId number 任务ID
-- @return boolean 是否显示提示图标
local function shouldShowQuestIndicator(questId)
	local quest = _questData[tostring(questId)]
	if not quest or not quest.Tasks then return false end

	-- 情况一：所有子任务均完成
	local allDone = true
	for _, tp in ipairs(quest.Tasks) do
		if not isChildTaskFinished(tp) then
			allDone = false
			break
		end
	end
	if allDone then return true end

	-- 情况二：背包中存在可提交的采集物品（基于现有 Submit 逻辑判断）
	for _, tp in ipairs(quest.Tasks) do
		if tp.Type == GameConfig.TaskType.CollectItem and not isChildTaskFinished(tp) and tp.TargetCounts then
			for itemId, needNum in pairs(tp.TargetCounts) do
				local keyStr = tostring(itemId)
				local curNum = tp.Counts[itemId] or tp.Counts[keyStr] or 0
				if curNum < (needNum or 0) then
					local invNum = _inventoryData[tonumber(itemId)] or 0
					if invNum >= (needNum or 0) then
						return true
					end
				end
			end
		end
	end
	return false
end

local function updateButton(button)
	if button == _textButton1 then
		_textButton1.BackgroundColor3 = Color3.fromRGB(248, 133, 71)
		_textButton2.BackgroundColor3 = Color3.fromRGB(139, 123, 134)
	else
		_textButton2.BackgroundColor3 = Color3.fromRGB(248, 133, 71)
		_textButton1.BackgroundColor3 = Color3.fromRGB(139, 123, 134)
	end
end

local function updateChildButton(button)
	if _curChildButton then
		_curChildButton.BackgroundColor3 = Color3.fromRGB(141, 125, 136)
	end
	_curChildButton = button
	_curChildIndex = tonumber(button.Name)
	_curChildButton.BackgroundColor3 = Color3.fromRGB(248, 133, 71)

	local frame = button.Parent
	local questId = tonumber(frame.Name)
	local questInfo = QuestConfig:GetByQuestId(questId)
	if not questInfo then return end

	if _curTypeFlag == 1 then
		updateAccept(questInfo)
	else
		updateBrowse(questInfo)
	end
end

local function isPreQuestComplated(questId)
	if true then return true end
	local questInfo = QuestConfig:GetByQuestId(questId)
	if not questInfo then return false end
	local preQuestId = questInfo.PreQuestId
	if preQuestId == 0 then return true end
	local data = _questData[tostring(preQuestId)]
	if not data or not data.Completed then return false end
	return true
end

local function updateList(type)
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= _listTemplateFrame then
			child:Destroy()
		end
	end

	_curChildButton = nil
	_curTypeFlag = type
	_textButton1:FindFirstChild("ImageLabel").Visible = false
	_textButton2:FindFirstChild("ImageLabel").Visible = false
	if _openType == 1 then
		for _, taskInfo in ipairs(QuestConfig:GetAll()) do
			local questId = taskInfo.QuestId
			if _questData[tostring(questId)] or not isPreQuestComplated(questId) then
				continue
			end
			_textButton1:FindFirstChild("ImageLabel").Visible = true
			break
		end
		for _, taskInfo in ipairs(QuestConfig:GetAll()) do
			local questId = taskInfo.QuestId
			if not _questData[tostring(questId)] or not isPreQuestComplated(questId) then
				continue
			end
			_textButton2:FindFirstChild("ImageLabel").Visible = true
			break
		end
	end

	local index = 0
	for _, taskInfo in ipairs(QuestConfig:GetAll()) do
		local questId = taskInfo.QuestId
		if type == 1 then
			if _questData[tostring(questId)] or not isPreQuestComplated(questId) then
				continue
			end
		else
			if not _questData[tostring(questId)] or _questData[tostring(questId)].Completed then
				continue
			end
		end
		local frame = _listTemplateFrame:Clone()
		frame.Name = questId
		frame.Visible = true
		frame.Parent = _scrollingFrame

		local textButton = frame:WaitForChild("TextButton")
		textButton.Name = questId
		local nameLabel = textButton:WaitForChild("NameLabel")
		nameLabel.Text = taskInfo.QuestName
		local mapLabel = textButton:WaitForChild("MapLabel")
		mapLabel.Text = taskInfo.Map
		local imageLabel = textButton:WaitForChild("ImageLabel")
		-- 列表项的提示图标：仅在“任务已完成或可提交物品存在”时显示
		if _curTypeFlag == 2 and _openType == 1 then
			imageLabel.Visible = shouldShowQuestIndicator(questId)
		else
			imageLabel.Visible = false
		end

		textButton.MouseButton1Click:Connect(function()
			updateChildButton(textButton)
		end)
		TweenInterface.SetupHoverScale(frame, textButton)

		index += 1
		if _curChildIndex == 0 and index == 1 then
			updateChildButton(textButton)
		elseif index == _curChildIndex then
			updateChildButton(textButton)
		end
	end

	_browseTask.Visible = index > 0
end

_textButton1.MouseButton1Click:Connect(function()
	if _curTypeFlag == 1 then return end
	if _openType ~= 1 then return end
	updateButton(_textButton1)
	updateList(1)
end)
TweenInterface.SetupHoverScale(_textButton1, _textButton1)
_textButton2.MouseButton1Click:Connect(function()
	if _curTypeFlag == 2 then
		return
	end
	updateButton(_textButton2)
	updateList(2)
end)
TweenInterface.SetupHoverScale(_textButton2, _textButton2)

local _titleImage = _frame:WaitForChild("TitleImage")
local _closeButton = _titleImage:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
	_curTypeFlag = 1
	_curChildButton = nil
	_curChildIndex = 0
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local function updateData(data)
	_questData = data
	_inventoryData = {}
	for _, itemData in pairs(_G.ClientData.Inventory) do
		if not _inventoryData[itemData.ItemId] then
			_inventoryData[itemData.ItemId] = 1
		else
			_inventoryData[itemData.ItemId] += 1
		end
	end

	updateList(_curTypeFlag)
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").UpdateQuestData:Connect(function(data)
		if not _screenGui.Enabled then
			return
		end

		updateData(_G.ClientData.QuestData)
	end)

	Knit.GetController("UIController").ShowQuestUI:Connect(function(type)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_openType = type
		-- Reset scrolling frame position when opening UI
		_scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		local targetFrame = _browseTask:WaitForChild("TaskTargetFrame")
		local targetScrollingFrame = targetFrame:WaitForChild("ScrollingFrame")
		targetScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		local prepareFrame = _browseTask:WaitForChild("PrepareFrame")
		local prepareScrollingFrame = prepareFrame:WaitForChild("ScrollingFrame")
		prepareScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		local rewardFrame = _browseTask:WaitForChild("RewardFrame")
		local rewardScrollingFrame = rewardFrame:WaitForChild("ScrollingFrame")
		rewardScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		if _openType == 1 then 
			updateButton(_textButton1)
			_curTypeFlag = 1
			_AcceptButton.Visible = true
		else
			updateButton(_textButton2)
			_curTypeFlag = 2
			_AcceptButton.Visible = false
		end
		updateData(_G.ClientData.QuestData)

		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)