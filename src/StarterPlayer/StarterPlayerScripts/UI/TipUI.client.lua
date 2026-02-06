-- 消息队列和UI容器
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"):WaitForChild("Knit"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local TweenInterface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("TweenInterface"))

-- TIP队列管理
-- TIP队列拆分：文本与图文分别管理（函数级注释）
-- Type=1 使用 tipQueue1 / isShowingTip1 / TIP_INTERVAL_1
-- Type=2 使用 tipQueue2 / isShowingTip2 / TIP_INTERVAL_2
-- Type=3 使用 tipQueue3 / isShowingTip3 / TIP_INTERVAL_3
local tipQueue1 = {}
local tipQueue2 = {}
local tipQueue3 = {}
local isShowingTip1 = false
local isShowingTip2 = false
local isShowingTip3 = false
local TIP_INTERVAL_1 = 2.7 -- 文本TIP间隔（秒）
local TIP_INTERVAL_2 = 3 -- 图文TIP间隔（秒）
local TIP_INTERVAL_3 = 2.7 -- 图文TIP间隔（秒）

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TipUI")
_screenGui.Enabled = true
local _frame = _screenGui:WaitForChild("Frame")
-- 创建消息容器
local _messageContainer = _frame:WaitForChild("MessageContainer")

-- 飘窗UI模板
local _tipTemplate1 = _frame:WaitForChild("TipTemplate1")
_tipTemplate1.Visible = false
local _tipTemplate2 = _frame:WaitForChild("TipTemplate2")
_tipTemplate2.Visible = false
local _tipTemplate3 = _frame:WaitForChild("TipTemplate3")
_tipTemplate3.Visible = false

-- 显示单个TIP（前置声明）
local processQueue1
local processQueue2
local processQueue3

-- 添加TIP到队列
-- 添加TIP到对应队列（函数级注释）：
-- @param message table 消息对象，含 Type 字段（1=文本，2=图文）
-- 行为：根据类型分发到队列，并触发各自的处理器
local function addTipToQueue1(message)
	if not message.Text then return end
	table.insert(tipQueue1, message)
	processQueue1()
end

local function addTipToQueue2(message)
	if not message or message == "" then return end
	table.insert(tipQueue2, message)
	processQueue2()
end

local function addTipToQueue3(message)
	if not message.Text then return end
	table.insert(tipQueue3, message)
	processQueue3()
end

local FadeTime = 0.5
local WaitTime = 2

-- 在目标位置执行阻尼弹簧式上下振荡（函数级注释）：
-- @param guiObject GuiObject 需要做位置弹簧的 UI 对象
-- @param targetPos UDim2 目标位置（振荡最终收敛到此）
-- @param opts table 可选参数：
--   - initialAmplitude number 初始振幅（像素），默认 16
--   - damping number 阻尼系数（每轮衰减倍数 0-1），默认 0.6
--   - belowFactor number 向下超越比例（相对当前振幅的比例），默认 0.6
--   - upTime number 向上位移时长，默认 0.12 秒
--   - downTime number 向下位移时长，默认 0.14 秒
--   - minAmplitude number 终止阈值（像素），默认 2
-- @return void
local function PlayDampedSpringPosition(guiObject, targetPos, opts)
	if not guiObject or not guiObject:IsA("GuiObject") then
		return
	end
	opts = opts or {}
	local amplitude = opts.initialAmplitude or 16
	local damping = opts.damping or 0.6
	local belowFactor = opts.belowFactor or 0.6
	local upTime = opts.upTime or 0.12
	local downTime = opts.downTime or 0.14
	local minAmplitude = opts.minAmplitude or 2

	while amplitude > minAmplitude do
		local upPos = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, targetPos.Y.Offset - amplitude)
		local tweenUp = TweenInterface.TweenNodeMovePosition(guiObject, upPos, upTime)
		tweenUp.Completed:Wait()

		local downAmp = amplitude * belowFactor
		local downPos = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, targetPos.Y.Offset + downAmp)
		local tweenDown = TweenInterface.TweenNodeMovePosition(guiObject, downPos, downTime)
		tweenDown.Completed:Wait()

		amplitude = amplitude * damping
	end

	local settle = TweenInterface.TweenNodeMovePosition(guiObject, targetPos, 0.12)
	settle.Completed:Wait()
end

local function showTip1(message)
	local stayY = 0.4
	local tip = _tipTemplate1:Clone()
	tip.Visible = true
	tip.Position = UDim2.new(1, tip.AbsoluteSize.X, stayY, 0)
	tip.Parent = _messageContainer
	local textLabel = tip:FindFirstChild("TextLabel")
	textLabel.TextTransparency = 0
	textLabel.Text = message.Text

	-- Type=1：从屏幕右侧外滑入，停留3秒，渐变消失
	TweenInterface.TweenNodeMovePosition(tip, UDim2.new(1, 0, stayY, 0), 0.5, function()
		task.wait(WaitTime)
		TweenInterface.TweenNodeTransparencyFrame(tip, 1, FadeTime)
		TweenInterface.TweenNodeTransparency(tip:FindFirstChild("UIStroke"), 1, FadeTime)
		TweenInterface.TweenNodeTransparencyText(textLabel, 1, FadeTime, function()
			tip:Destroy()
		end)
	end)
end

local function showTip2(message)
	local tip = _tipTemplate2:Clone()
	tip.Visible = false
	tip.Position = UDim2.new(1, 0, 0.5, 0)
	tip.Parent = _messageContainer
	local imageLabel = tip:FindFirstChild("ImageLabel")
	imageLabel.Visible = false
	local textLabel = tip:FindFirstChild("TextLabel")
	textLabel.TextTransparency = 0
	textLabel.Text = message.Name
	local itemInfo = ItemConfig:GetByItemId(message.ItemId)
	if itemInfo and itemInfo.Icon then
		-- 为 ImageLabel 预加载图片，减少首次显示的网络延迟（函数级注释）
		-- 在设置可见之前进行预加载，提升即时显示效果
		--Interface.PreloadImageForLabel(imageLabel, itemInfo.Icon, 2.0)
		imageLabel.Image = itemInfo.Icon
		imageLabel.Visible = true
		local label = imageLabel:FindFirstChild("TextLabel")
		if message.ItemAttribute.Gold > 0 then
			label.Visible = true
			label.Text = message.ItemAttribute.Gold
		else
			label.Visible = false
		end
	end
	tip.Visible = true

	-- Type=2：保持现有“前快后慢移动 + 阻尼弹簧”动画序列
	TweenInterface.TweenNodeMovePosition(tip, UDim2.new(1, 0, 0, 0), 0.1, function()
		local targetPos = tip.Position
		PlayDampedSpringPosition(tip, targetPos, {
			initialAmplitude = 16,
			damping = 0.3,
			belowFactor = 0.6,
			upTime = 0.06,
			downTime = 0.07,
			minAmplitude = 1,
		})

		task.wait(WaitTime)
		TweenInterface.TweenNodeTransparencyText(textLabel, 1, FadeTime, function()
			tip:Destroy()
		end)
		if imageLabel and imageLabel.Visible then
			TweenInterface.TweenNodeTransparencyImage(imageLabel, 1, FadeTime)
			TweenInterface.TweenNodeTransparencyText(imageLabel:FindFirstChild("TextLabel"), 1, FadeTime, function()
				tip:Destroy()
			end)
		end
	end)
end

local function showTip3(message)
	local stayY = 0.6
	local tip = _tipTemplate3:Clone()
	tip.Visible = true
	tip.Position = UDim2.new(0.5, 0, stayY, 0)
	tip.Parent = _messageContainer
	local textLabel = tip:FindFirstChild("TextLabel")
	textLabel.TextTransparency = 0
	textLabel.Text = message.Text

	-- Type=3：从屏幕中心下方往上滑动，停留3秒，渐变消失
	TweenInterface.TweenNodeMovePosition(tip, UDim2.new(0.5, 0, stayY - 0.2, 0), 0.3, function()
		task.wait(WaitTime)
		TweenInterface.TweenNodeTransparencyText(textLabel, 1, FadeTime, function()
			tip:Destroy()
		end)
	end)
end

-- 处理队列
-- 处理文本TIP队列（函数级注释）：
-- 行为：串行播放队列中的 Type=1 TIP，按 TIP_INTERVAL_1 控制间隔
processQueue1 = function()
	if isShowingTip1 or #tipQueue1 == 0 then return end
	isShowingTip1 = true
	local message = table.remove(tipQueue1, 1)
	showTip1(message)
	task.wait(TIP_INTERVAL_1)
	isShowingTip1 = false
	processQueue1()
end

-- 处理图文TIP队列（函数级注释）：
-- 行为：串行播放队列中的 Type=2 TIP，按 TIP_INTERVAL_2 控制间隔
processQueue2 = function()
	if isShowingTip2 or #tipQueue2 == 0 then return end
	isShowingTip2 = true
	local message = table.remove(tipQueue2, 1)
	showTip2(message)
	task.wait(TIP_INTERVAL_2)
	isShowingTip2 = false
	processQueue2()
end

-- 处理屏幕中心文本（函数级注释）：
-- 行为：串行播放队列中的 Type=3 TIP，按 TIP_INTERVAL_3 控制间隔
processQueue3 = function()
	if isShowingTip3 or #tipQueue3 == 0 then return end
	isShowingTip3 = true
	local message = table.remove(tipQueue3, 1)
	showTip3(message)
	task.wait(TIP_INTERVAL_3)
	isShowingTip3 = false
	processQueue3()
end

Knit:OnStart():andThen(function()
	Knit.GetController('UIController').ShowTip:Connect(function(message)
		task.spawn(function()
			if not message then return end
			if message.Type == 1 then
				addTipToQueue1(message)
			elseif message.Type == 2 then
				addTipToQueue2(message)
			elseif message.Type == 3 then
				addTipToQueue3(message)
			end
		end)
	end)
end)
