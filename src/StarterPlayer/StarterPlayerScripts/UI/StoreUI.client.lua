local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local Shop1Config = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("Shop1Config"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local TweenInterface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("TweenInterface"))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StoreUI")
local _frame = _screenGui:WaitForChild("Frame")
local _scrollingFrame = _frame:WaitForChild("ScrollingFrame")
local _selectFrame = _scrollingFrame:WaitForChild("SelectFrame")
_selectFrame.Visible = false
local _normalFrame = _scrollingFrame:WaitForChild("NormalFrame")
_normalFrame.Visible = false

local _titleImage = _frame:WaitForChild("TitleImage")
local _closeButton = _titleImage:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local _createNormalFrame = nil
local _createSelectFrame = nil
local _selectItem = nil

local function updateSelectItem(item, index, itemIndex, assetID)
	if _selectItem == item then
		local buttonFrame = item:FindFirstChild("ButtonFrame")
		if buttonFrame then
			_createNormalFrame(index, itemIndex, assetID)
			_selectItem = nil
		else
			_selectItem = _createSelectFrame(index, itemIndex, assetID)
		end
	else
		if not _selectItem then
			_selectItem = _createSelectFrame(index, itemIndex, assetID)
		else
			_createNormalFrame(_selectItem:GetAttribute("Index"), _selectItem:GetAttribute("ItemIndex"), _selectItem:GetAttribute("AssetID"))
			_selectItem:Destroy()
			_selectItem = _createSelectFrame(index, itemIndex, assetID)
		end
	end

	item:Destroy()
end

_createNormalFrame = function(index, itemIndex, assetID)
	local itemInfo = ItemConfig:GetByItemId(itemIndex)
	if not itemInfo then
		return
	end
	local item = _normalFrame:Clone()
	item.LayoutOrder = index
	item.Parent = _scrollingFrame
	item.Visible = true
	item:SetAttribute("Index", index)
	item:SetAttribute("ItemIndex", itemIndex)
	item:SetAttribute("AssetID", assetID)

	local infoFrame = item:FindFirstChild("InfoFrame")
	local iconFrame = infoFrame:FindFirstChild("IconFrame")
	iconFrame:FindFirstChild("IconImage").Image = itemInfo.Icon
	infoFrame:FindFirstChild("NameLabel").Text = itemInfo.DisplayName
	infoFrame:FindFirstChild("DescribeLabel").Text = itemInfo.Description
	infoFrame:FindFirstChild("PriceLabel").Text = itemInfo.Price

	local textButton = infoFrame:FindFirstChild("TextButton")
	textButton.MouseButton1Click:Connect(function()
		updateSelectItem(item, index, itemIndex, assetID)
	end)
	TweenInterface.SetupHoverScale(item, textButton)
	
	return item
end

_createSelectFrame = function(index, itemIndex, assetID)
	local itemInfo = ItemConfig:GetByItemId(itemIndex)
	if not itemInfo then
		return
	end
	local item = _selectFrame:Clone()
	item.LayoutOrder = index
	item.Parent = _scrollingFrame
	item.Visible = true
	item:SetAttribute("Index", index)
	item:SetAttribute("ItemIndex", itemIndex)
	item:SetAttribute("AssetID", assetID)

	local infoFrame = item:FindFirstChild("InfoFrame")
	local iconFrame = infoFrame:FindFirstChild("IconFrame")
	local iconImage = iconFrame:FindFirstChild("IconImage")
	iconImage.Image = itemInfo.Icon
	infoFrame:FindFirstChild("NameLabel").Text = itemInfo.DisplayName
	infoFrame:FindFirstChild("DescribeLabel").Text = itemInfo.Description
	infoFrame:FindFirstChild("PriceLabel").Text = itemInfo.Price

	local textButton = infoFrame:FindFirstChild("TextButton")
	textButton.MouseButton1Click:Connect(function()
		updateSelectItem(item, index, itemIndex, assetID)
	end)
	TweenInterface.SetupHoverScale(item, textButton)

	local buttonFrame = item:FindFirstChild("ButtonFrame")
	buttonFrame:FindFirstChild("GoldButton").Text = itemInfo.Price
	buttonFrame:FindFirstChild("RobButton").Text = itemInfo.RobloxPrice

	local goldButton = buttonFrame:FindFirstChild("GoldButton")
	goldButton.MouseButton1Click:Connect(function()
		if itemInfo.Price > _G.ClientData.Gold then
			Knit.GetController("UIController").ShowTip:Fire({Type = 1, Text = "Not enough coins"})
			return
		end
		Knit.GetService("StoreService"):GoldBuyItem(itemIndex):andThen(function(str)
			local sound = Interface.safeWaitPart(game:GetService("SoundService"), "UI")
			local music = Interface.safeWaitPart(sound, "Buy")
			if not music.IsLoaded then
				music.Loaded:Wait()
			end
			music:Play()
			
			local backpackButton = game.Players.LocalPlayer.PlayerGui.MainUI.right.BackpackFrame.TextButton
			Knit.GetController("UIController").ShowFlyItemUI:Fire(iconImage, iconImage, backpackButton)
		end)
	end)
	TweenInterface.SetupHoverScale(goldButton, goldButton)

	local gifeButton = buttonFrame:FindFirstChild("GifeButton")
	gifeButton.MouseButton1Click:Connect(function()
		Knit.GetController("UIController").ShowPlayerListUI:Fire(itemIndex, assetID)
	end)
	TweenInterface.SetupHoverScale(gifeButton, gifeButton)

	local robButton = buttonFrame:FindFirstChild("RobButton")
	robButton.MouseButton1Click:Connect(function()
		Knit.GetService("StoreService"):RobBuyItem(itemIndex, assetID):andThen(function()

		end)
	end)
	TweenInterface.SetupHoverScale(robButton, robButton)
	
	return item
end

task.spawn(function()
	for i, shopInfo in ipairs(Shop1Config:GetAll()) do
		local itemIndex = shopInfo.Index
		local assetID = shopInfo.AssetId
		_createNormalFrame(i, itemIndex, assetID)
	end
end)

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").ShowStoreUI:Connect(function(data)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		
		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)