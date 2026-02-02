local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local TweenInterface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("TweenInterface"))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("FlyItemUI")
_screenGui.Enabled = false
local _frame = _screenGui:WaitForChild("Frame")

-- 规范化飞行动画容器为全屏，避免比例误差与边界裁剪
-- @return void
_frame.Position = UDim2.new(0, 0, 0, 0)
_frame.Size = UDim2.new(1, 0, 1, 0)

-- 执行飞行动画，并打印关键位置信息用于调试比较
-- @param item GuiObject 要飞行的物体（源的图标）
-- @param source GuiObject 源控件（物品图标）
-- @param target GuiObject 目标控件（背包按钮）
-- @return void
local function flyAction(item, source, target)
	local itemTemp = item:Clone()
	itemTemp.Parent = _frame
	itemTemp.Size = UDim2.new(0, 30, 0, 30)
	itemTemp.AnchorPoint = Vector2.new(0.5, 0.5)

	-- 调试打印已移除

	-- 计算source的屏幕绝对中心位置
	local sourceAbsolutePos = source.AbsolutePosition
	local sourceAbsoluteSize = source.AbsoluteSize
	local sourceCenterX = sourceAbsolutePos.X + sourceAbsoluteSize.X * 0.5
	local sourceCenterY = sourceAbsolutePos.Y + sourceAbsoluteSize.Y * 0.5

	-- 计算target的屏幕绝对中心位置
	local targetAbsolutePos = target.AbsolutePosition
	local targetAbsoluteSize = target.AbsoluteSize
	local targetCenterX = targetAbsolutePos.X + targetAbsoluteSize.X * 0.5
	local targetCenterY = targetAbsolutePos.Y + targetAbsoluteSize.Y * 0.5

	-- 转换为_frame的相对位置
	local frameAbsolutePos = _frame.AbsolutePosition
	local frameAbsoluteSize = _frame.AbsoluteSize

	-- 使用像素偏移进行定位，避免因 _frame 尺寸变化导致比例不一致
	local pos1 = UDim2.new(
		0, sourceCenterX - frameAbsolutePos.X,
		0, sourceCenterY - frameAbsolutePos.Y
	)
	itemTemp.Position = pos1
	local pos2 = UDim2.new(
		0, targetCenterX - frameAbsolutePos.X,
		0, targetCenterY - frameAbsolutePos.Y
	)
	TweenInterface.TweenNodeMovePosition(itemTemp, pos2, 1, function()
		if itemTemp:IsA("ImageLabel") or itemTemp:IsA("ImageButton") then
			TweenInterface.TweenNodeTransparencyImage(itemTemp, 1, 0.5, function()
				itemTemp:Destroy()
			end)
		elseif itemTemp:IsA("TextLabel") or itemTemp:IsA("TextButton") then
			TweenInterface.TweenNodeTransparencyText(itemTemp, 1, 0.5, function()
				itemTemp:Destroy()
			end)
		elseif itemTemp:IsA("Frame") then
			TweenInterface.TweenNodeTransparencyFrame(itemTemp, 1, 0.5, function()
				itemTemp:Destroy()
			end)
		end
	end)
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").ShowFlyItemUI:Connect(function(item, source, target)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true

		flyAction(item, source, target)
	end)
end)