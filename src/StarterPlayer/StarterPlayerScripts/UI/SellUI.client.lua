local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local TweenInterface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("TweenInterface"))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SellUI")
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

local updateUI = nil
local _items = {}
local _selectItem = nil

local _sellAllButton = _frame:WaitForChild("SellAllButton")
_sellAllButton.MouseButton1Click:Connect(function()
	Knit.GetService("StoreService"):SellAll():andThen(function(sellItems)
		if #sellItems > 0 then
			for i, sellItemData in ipairs(sellItems) do
				for j, itemData in ipairs(_items) do
					if itemData.ItemId == sellItemData.ItemId 
						and itemData.Attribute.CreateTime == sellItemData.Attribute.CreateTime
						and itemData.Attribute.IsLocked == 0 then
						table.remove(_items, j)
						break
					end
				end
			end
			updateUI()
		end
	end)
end)
TweenInterface.SetupHoverScale(_sellAllButton, _sellAllButton)

local function createNormalFrame(index, itemData)
	local itemInfo = ItemConfig:GetByItemId(itemData.ItemId)
	local item = _templateFrame:Clone()
	item.LayoutOrder = index
	item.Parent = _scrollingFrame
	item.Visible = true

	local frame = item:FindFirstChild("Frame")
	local infoFrame = frame:FindFirstChild("InfoFrame")
	infoFrame:FindFirstChild("IconImage").Image = itemInfo.Icon
	infoFrame:FindFirstChild("LockImage").Visible = itemData.Attribute.IsLocked == 1
	frame:FindFirstChild("NameLabel").Text = itemInfo.DisplayName
	local useNumLabel = frame:FindFirstChild("UseNumLabel")
	if itemInfo.Duration > 0 then
		useNumLabel.Visible = true
		useNumLabel.Text = math.floor(math.max(0, itemInfo.Duration - itemData.Attribute.UsedTime))
	elseif itemInfo.TimeUsed > 0 then
		useNumLabel.Visible = true
		useNumLabel.Text = math.floor(math.max(0, itemInfo.TimeUsed - itemData.Attribute.UsedNum))
	else
		useNumLabel.Visible = false
	end

	local priceFrame = frame:FindFirstChild("PriceFrame")
	priceFrame:FindFirstChild("PriceLabel").Text = itemData.Attribute.Gold
	local selectImage = frame:FindFirstChild("SelectImage")
	selectImage.Visible = false
	
	local sellButton = item:FindFirstChild("SellButton")
	sellButton.MouseButton1Click:Connect(function()
		Knit.GetService("StoreService"):Sell(itemData):andThen(function(itemData)
			if itemData then
				for i, itemDataTemp in ipairs(_items) do
					if itemDataTemp.ItemId == itemData.ItemId 
						and itemDataTemp.Attribute.CreateTime == itemData.Attribute.CreateTime
						and itemData.Attribute.IsLocked == 0 then
						table.remove(_items, i)
						break
					end
				end
				updateUI()
				local sound = Interface.safeWaitPart(game:GetService("SoundService"), "UI")
				local music = Interface.safeWaitPart(sound, "Buy")
				if not music.IsLoaded then
					music.Loaded:Wait()
				end
				music:Play()
			end
		end)
	end)
	TweenInterface.SetupHoverScale(sellButton, sellButton)

	local textButton = item:FindFirstChild("TextButton")
	textButton.MouseButton1Click:Connect(function()
		if _selectItem == item then
			return
		end
		
		if _selectItem then
			local selectFrame = _selectItem:FindFirstChild("Frame")
			local selectImage = selectFrame:FindFirstChild("SelectImage")
			selectImage.Visible = false
		end
		selectImage.Visible = not selectImage.Visible
		_selectItem = item
	end)
	TweenInterface.SetupHoverScale(item, textButton)

	return item
end

updateUI = function()
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= _templateFrame then
			child:Destroy()
		end
	end
	
	_selectItem = nil
	for index, itemData in ipairs(_items) do
		createNormalFrame(index, itemData)
	end
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").ShowSellUI:Connect(function(data)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		_items = _G.ClientData.Inventory
		updateUI()
		
		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)