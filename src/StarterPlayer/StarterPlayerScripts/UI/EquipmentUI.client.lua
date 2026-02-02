local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local EquipmentConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("EquipmentConfig"))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local TweenInterface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('TweenInterface'))
local Model3DViewer = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Model3DViewer"))
local player = Players.LocalPlayer

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EquipmentUI")
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

local _modelFrame = _frame:WaitForChild("ModelFrame")
-- 创建Model3DViewer实例
local viewer = Model3DViewer.new(_modelFrame, {
	size = UDim2.new(1, 0, 1, 0),
	position = UDim2.new(0, 0, 0, 0),
	backgroundColor = Color3.fromRGB(30, 30, 30),
	enableRotation = true,
	enableZoom = false,
	autoRotate = true,
	rotationSpeed = 0.5
})

local character = player.Character
local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
local desc = humanoid:GetAppliedDescription()
local rigType = humanoid.RigType -- Enum.HumanoidRigType.R6 或 R15
local _model = Players:CreateHumanoidModelFromDescription(desc, rigType)
_model.Name = player.Name .. "_Preview"
viewer:setModel(_model)

local _equipments = {}

local function selectItem(item)
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= item then
			child:WaitForChild("HighFrame").Visible = false
		end
	end
end

local function updateEquipment()
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= _templateFrame then
			child:Destroy()
		end
	end

	for _, equipData in ipairs(_equipments) do
		local equipId = equipData.EquipId
		if equipId == 0 then
			continue
		end
		local newFrame = _templateFrame:Clone()
		local equipInfo = EquipmentConfig:GetByEquipId(equipId)
		if not equipInfo then
			continue
		end
		newFrame.Name = equipId
		newFrame.Visible = true
		newFrame.Parent = _scrollingFrame
		newFrame:FindFirstChild("NameLabel").Text = equipInfo.DisplayName
		if equipInfo.Icon then
			newFrame:FindFirstChild("ImageLabel").Image = equipInfo.Icon
		else
			newFrame:FindFirstChild("ImageLabel").Visible = false
		end

		local highFrame = newFrame:FindFirstChild("HighFrame")
		highFrame.Visible = false

		local selectFrame = newFrame:FindFirstChild("SelectFrame")
		local selectButton = selectFrame:FindFirstChild("SelectButton")

		-- 点击选择事件
		selectButton.MouseButton1Click:Connect(function()
			if not highFrame.Visible then
				highFrame.Visible = true
				selectItem(newFrame)
			end
		end)
		TweenInterface.SetupHoverScale(newFrame, selectButton)
	end
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").UpdateEquipment:Connect(function(data)
		_equipments = data
		if _screenGui.Enabled then
			updateEquipment()
		end
	end)

	Knit.GetController("UIController").ShowEquipmentUI:Connect(function()
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		_equipments = _G.ClientData.EquipmentData
		updateEquipment()
		
		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)