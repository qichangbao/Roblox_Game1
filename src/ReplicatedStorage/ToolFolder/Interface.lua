local Interface = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

--[[
    深拷贝函数 - 递归复制表结构
    @param original table 原始表
    @return table 深拷贝后的新表
]]
function Interface.clone(original)
    if type(original) ~= "table" then
        return original
    end
    
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = Interface.clone(value)
    end
    
    return copy
end

function Interface.formatTimeMMSS(seconds)
	seconds = math.max(0, math.floor(seconds))
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

--[[
    格式化金币数字显示 - 将大数字转换为简洁格式
    @param amount number 金币数量
    @return string 格式化后的字符串 (如: 10000 -> "10K", 1500000 -> "1.5M")
]]
function Interface.formatCurrency(amount)
    if type(amount) ~= "number" then
        return "0"
    end
    
    amount = math.floor(amount)
    
    if amount < 1000 then
        return tostring(amount)
    elseif amount < 1000000 then
        -- 千位显示 (K)
        local thousands = amount / 1000
        if thousands == math.floor(thousands) then
            return string.format("%.0fK", thousands)
        else
            return string.format("%.1fK", thousands)
        end
    elseif amount < 1000000000 then
        -- 百万位显示 (M)
        local millions = amount / 1000000
        if millions == math.floor(millions) then
            return string.format("%.0fM", millions)
        else
            return string.format("%.1fM", millions)
        end
    else
        -- 十亿位显示 (B)
        local billions = amount / 1000000000
        if billions == math.floor(billions) then
            return string.format("%.0fB", billions)
        else
            return string.format("%.1fB", billions)
        end
    end
end

-- 使用多层射线检测获取真正的地面位置
-- @param startPosition Vector3 起始位置
-- @param ignoreList table 忽略的实例列表
-- @return Vector3 地面位置，如果没有检测到则返回原位置
function Interface.getGroundPosition(startPosition, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    
    local currentPosition = startPosition
    local totalHeightDrop = 0
    local maxLayers = 5 -- 最多检测5层
    local minHeightDrop = 3 -- 最小高度差要求
    
    for layer = 1, maxLayers do
        -- 从当前位置向下发射射线
        local rayDirection = Vector3.new(0, -100, 0)
        local raycastResult = workspace:Raycast(currentPosition, rayDirection, raycastParams)
        
        if raycastResult then
            local hitPosition = raycastResult.Position
            local layerHeightDrop = currentPosition.Y - hitPosition.Y
            totalHeightDrop = totalHeightDrop + layerHeightDrop
            
            -- 检查是否是足够厚的地面
            if layerHeightDrop >= minHeightDrop and totalHeightDrop >= minHeightDrop then
                local groundPosition = hitPosition + Vector3.new(0, 0.1, 0)
                return groundPosition
            elseif layerHeightDrop < 0.5 then
                -- 击中了很薄的结构，继续向下检测
                currentPosition = hitPosition - Vector3.new(0, 0.1, 0) -- 稍微向下偏移继续检测
                
                -- 将击中的物体加入忽略列表，避免重复击中
                if raycastResult.Instance then
                    table.insert(raycastParams.FilterDescendantsInstances, raycastResult.Instance)
                end
            else
                -- 找到了有一定厚度的地面
                if totalHeightDrop >= minHeightDrop then
                    local groundPosition = hitPosition + Vector3.new(0, 0.1, 0)
                    return groundPosition
                else
                    -- 高度差不够，继续检测
                    currentPosition = hitPosition - Vector3.new(0, 0.1, 0)
                end
            end
        else
            -- 没有击中任何物体
            print("第", layer, "层未击中任何物体")
            break
        end
    end
    
    -- 所有检测都失败，返回一个安全的地面位置
    local safeGroundPosition = Vector3.new(startPosition.X, startPosition.Y - 10, startPosition.Z)
    return safeGroundPosition
end

--[[
    更精确的手机检测（推荐使用）
    结合多种因素判断，包括屏幕尺寸、安全区域、输入方式等
    @return boolean 如果是手机设备返回true，否则返回false
]]
function Interface.isMobile()
    if game:GetService("RunService"):IsStudio() then
        return true
    end
    -- 必须有触摸屏
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and
           not UserInputService.MouseEnabled then
        return true
    end
    return false
end

--[[
    安全等待子对象出现
    @param parent Instance 父对象
    @param child string 子对象名称
    @param time number 超时时间（秒），默认1秒
    @return Instance 子对象，如果超时返回nil
]]
function Interface.safeWaitPart(parent, childName, time)
    time = time or 1
    local child = parent:FindFirstChild(childName)
    while not child do
        task.wait(time)
        child = parent:FindFirstChild(childName)
    end
    return child
end

function Interface.GetDuanWeiIcon(duanweiData)
    if not duanweiData then
        return
    end
    local duanwei = tonumber(duanweiData.duanWei)
    if not duanwei then
        return
    end
    local level = tonumber(duanweiData.level)
    if not level then
        return
    end
    local duanweiConfig = GameConfig.DuanWeiType[duanwei]
    if not duanweiConfig then
        return
    end
    return duanweiConfig.icons[level]
end

--[[
    计算 DuanWei 升级
    @param duanWeiData table DuanWei 数据
    @param escapeSucc boolean 是否成功逃脱
    @return table 更新后的 DuanWei 数据
]]
function Interface.calculateDuanWei(duanWeiData, escapeSucc)
    local tempData = Interface.clone(duanWeiData)
    local DuanWeiType = GameConfig.DuanWeiType
    if escapeSucc then
        tempData.star += 1
        -- 到达当前升级星数
        if tempData.star > DuanWeiType[tempData.duanWei].levelStarNum
        and DuanWeiType[tempData.duanWei].levelStarNum ~= -1 then
            tempData.level += 1
            tempData.star = 1
        end

        -- 到达当前升段位标准
        if tempData.level > DuanWeiType[tempData.duanWei].levelNum
        and DuanWeiType[tempData.duanWei].levelNum ~= -1 then
            tempData.duanWei = math.min(tempData.duanWei + 1, #DuanWeiType)
            tempData.level = 1
            tempData.star = 1
        end
    else
        if DuanWeiType[tempData.duanWei].allowDeduction then
            tempData.star = tempData.star - 1
            if tempData.star <= 0 then
                tempData.level = tempData.level - 1
                if tempData.level <= 0 then
                    if tempData.duanWei > 1 then
                        tempData.duanWei = tempData.duanWei - 1
                        tempData.level = DuanWeiType[tempData.duanWei].levelNum
                        tempData.star = DuanWeiType[tempData.duanWei].levelStarNum
                    else
                        tempData.duanWei = 1
                        tempData.level = 1
                        tempData.star = 0
                    end
                else
                    tempData.star = DuanWeiType[tempData.duanWei].levelStarNum
                end
            end
        end
    end

    return tempData
end

-- 存储每个TextLabel的动画状态，避免重复动画冲突
local animationStates = {}

--[[
    数字递增动画接口
    @param labelOrFrom TextLabel|number 如果是TextLabel则自动更新文本，如果是数字则作为起始值
    @param to number 目标值
    @return NumberValue 可监听Changed事件的数值容器
    @return Tween 动画对象（可用于控制暂停/取消）
]]
function Interface.AnimateNumberIncrease(labelOrFrom, to)
    local label = nil
    local from = 0
    local target = 0

    if typeof(labelOrFrom) == "Instance" and labelOrFrom:IsA("TextLabel") then
        label = labelOrFrom
        from = tonumber(label.Text) or 0
        target = tonumber(to) or from
        
        -- 如果该TextLabel已有动画在运行，先取消旧动画
        if animationStates[label] then
            local oldState = animationStates[label]
            if oldState.tween then
                oldState.tween:Cancel()
            end
            if oldState.num then
                oldState.num:Destroy()
            end
            -- 从当前动画值开始新动画，保持连贯性
            from = oldState.num and oldState.num.Value or from
        end
    else
        from = tonumber(labelOrFrom) or 0
        target = tonumber(to) or from
    end

    -- 使用NumberValue承载动画数值，便于外部监听数值变化
    local num = Instance.new("NumberValue")
    num.Name = "Interface_AnimateNumber"
    num.Value = from

    -- 根据数值差计算时长：保持统一速度，限定上下限
    local delta = math.abs(target - from)
    local duration = math.clamp(delta / 100, 0.3, 1)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(num, tweenInfo, { Value = target })

    -- 如果传入了TextLabel，则自动更新文本显示（取整）
    if label then
        -- 记录当前动画状态
        animationStates[label] = {
            num = num,
            tween = tween
        }
        
        num.Changed:Connect(function(v)
            label.Text = tostring(math.floor(v))
        end)
    end

    tween:Play()
    
    -- 动画完成时的清理工作
    tween.Completed:Connect(function()
        num.Value = target
        if label then
            label.Text = tostring(math.floor(target))
            -- 清理动画状态记录
            animationStates[label] = nil
        end
        -- 清理NumberValue对象
        num:Destroy()
    end)
    
    return num, tween
end

-- 存储每个GuiObject的缩放动画状态，避免重复动画冲突
local uiScaleStates = {}

--[[
    UI显示动画：使用 UIScale 将尺寸从 0 缩放到 1
    @param guiObject GuiObject|ScreenGui 目标UI元素（Frame、ImageLabel、TextLabel等）或屏幕容器
    @param opts table? 可选配置
        - duration number 动画时长（秒），默认 0.1
        - easingStyle Enum.EasingStyle 缓动类型，默认 Quad
        - easingDirection Enum.EasingDirection 缓动方向，默认 Out
        - setVisible boolean 是否在播放前设置为可见：
            GuiObject 使用 Visible=true，ScreenGui/SurfaceGui/BillboardGui 使用 Enabled=true，默认 true
        - center boolean 是否将 AnchorPoint 设为居中 (0.5,0.5)，仅 GuiObject 生效，默认 false
    @return UIScale, Tween 返回 UIScale 与 Tween 对象（便于外部控制/监听）
    说明：
    - 优先使用 UIScale 缩放，不会破坏原始 Size/Position 布局
    - 若目标下不存在 UIScale，会自动创建一个
]]
function Interface.AnimateUIShowScale(guiObject, opts)
    if typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiBase2d") then
        warn("AnimateUIShowScale: 需要传入 GuiObject 或 ScreenGui（GuiBase2d）")
        return nil, nil
    end

    opts = opts or {}
    local duration = typeof(opts.duration) == "number" and opts.duration or 0.1
    local easingStyle = opts.easingStyle or Enum.EasingStyle.Quad
    local easingDirection = opts.easingDirection or Enum.EasingDirection.Out
    local setVisible = (opts.setVisible == nil) and true or opts.setVisible
    local center = opts.center == true
    local isGuiObject = guiObject:IsA("GuiObject")

    if center and isGuiObject then
        guiObject.AnchorPoint = Vector2.new(0.5, 0.5)
    end
    if setVisible then
        if isGuiObject then
            guiObject.Visible = true
        else
            if guiObject:IsA("ScreenGui") or guiObject:IsA("SurfaceGui") or guiObject:IsA("BillboardGui") then
                guiObject.Enabled = true
            end
        end
    end

    local scale = guiObject:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Scale = 0
        scale.Parent = guiObject
    else
        -- 从 0 开始，保证有缩放过渡
        scale.Scale = 0
    end

    -- 如果该 GuiObject 有动画在运行，先取消旧动画
    if uiScaleStates[guiObject] then
        local old = uiScaleStates[guiObject]
        if old.tween then old.tween:Cancel() end
    end

    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(scale, tweenInfo, { Scale = 1 })

    -- 记录当前动画状态
    uiScaleStates[guiObject] = {
        scale = scale,
        tween = tween,
    }

    tween:Play()
    tween.Completed:Connect(function()
        -- 动画完成后清理状态记录
        uiScaleStates[guiObject] = nil
    end)

    return scale, tween
end

function Interface.Split(str, delim)
	local result = {}
	local pattern = string.format("([^%s]+)", delim)
	for part in string.gmatch(str, pattern) do
		table.insert(result, part)
	end
	return result
end


-- 设置鼠标悬停时的缩放效果
-- @param frame Frame 需要缩放的UI容器
-- @param button GuiButton 负责接收鼠标事件的按钮
function Interface.SetupHoverScale(frame, button)
	local uiScale = frame:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = 1
		uiScale.Parent = frame
	end

	local tweenIn
	local tweenOut
    if not button then
        button = Instance.new("TextButton")
        button.BackgroundTransparency = 1
        button.Parent = frame
        button.Text = ""
        button.Size = UDim2.new(1, 0, 1, 0)
    end

	button.MouseEnter:Connect(function()
		if tweenOut then
			tweenOut:Cancel()
		end
		tweenIn = TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1.1,
		})
		tweenIn:Play()
	end)

	button.MouseLeave:Connect(function()
		if tweenIn then
			tweenIn:Cancel()
		end
		tweenOut = TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1,
		})
		tweenOut:Play()
	end)
end

return Interface
