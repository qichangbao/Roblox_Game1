local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ItemAttributeUI")
_screenGui.Enabled = false
local _frame = _screenGui:WaitForChild("Frame")
local _textLabel = _frame:WaitForChild("TextLabel")
if Interface.isMobile() then
	_textLabel.Text = "Tap anywhere to close"
else
	_textLabel.Text = "Click anywhere to close"
end

local _textButton = _screenGui:WaitForChild("TextButton")
_textButton.MouseButton1Down:Connect(function(x, y)
	_screenGui.Enabled = false
end)

local _nameFrame = _frame:WaitForChild("NameFrame")
local _nameLabel = _nameFrame:WaitForChild("NameLabel")
local _typeLabel = _nameFrame:WaitForChild("TypeLabel")
local _iconFrame = _frame:WaitForChild("IconFrame")
local _iconImage = _iconFrame:WaitForChild("IconImage")
local _descriptionFrame = _frame:WaitForChild("DescriptionFrame")
local _descriptionLabel = _descriptionFrame:WaitForChild("DescriptionLabel")
local _dropFrame = _frame:WaitForChild("DropFrame")
local _dropLabel = _dropFrame:WaitForChild("DropLabel")
local _weightValueLabel =_nameFrame:WaitForChild("WeightValueLabel")

local function updateItemAttribute(itemId, attribute)
	local itemInfo = ItemConfig:GetByItemId(itemId)
	if not itemInfo then
		return
	end
	
	_nameLabel.Text = itemInfo.DisplayName
	if itemInfo.Type == GameConfig.ItemType.Explore then
		_typeLabel.Text = "Explore"
	elseif itemInfo.Type == GameConfig.ItemType.Weapon then
		_typeLabel.Text = "Weapon"
	elseif itemInfo.Type == GameConfig.ItemType.Assistance then
		_typeLabel.Text = "Support"
	elseif itemInfo.Type == GameConfig.ItemType.Collect then
		_typeLabel.Text = "Collectible"
	elseif itemInfo.Type == GameConfig.ItemType.Chest then
		_typeLabel.Text = "Chest"
	elseif itemInfo.Type == GameConfig.ItemType.Mound then
		_typeLabel.Text = "DirtPile"
	elseif itemInfo.Type == GameConfig.ItemType.Buff then
		_typeLabel.Text = "Buff"
	elseif itemInfo.Type == GameConfig.ItemType.Treatment then
		_typeLabel.Text = "Treatment"
	end
	local weightValue = (attribute and attribute.Volume and attribute.Volume * itemInfo.Weight) or itemInfo.Weight
	_weightValueLabel.Text = Interface.formatValue(weightValue)
	_iconImage.Image = itemInfo.Icon
	_descriptionLabel.Text = itemInfo.Description or ""
	_dropLabel.Text = itemInfo.DropSources or ""
	_screenGui.Enabled = true

	local ui = game:GetService("SoundService"):WaitForChild("UI")
	local sound = ui:WaitForChild("OpenUI")
	sound:Play()
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").ShowItemAttributeUI:Connect(function(itemId, attribute)
		updateItemAttribute(itemId, attribute)
	end)
end)
