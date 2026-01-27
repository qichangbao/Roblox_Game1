local TweenService = game:GetService("TweenService")

local TweenInterface = {}

-- 存储每个TextLabel的动画状态，避免重复动画冲突
local animationStates = {}

--[[
    数字递增动画接口
    @param labelOrFrom TextLabel|number 如果是TextLabel则自动更新文本，如果是数字则作为起始值
    @param to number 目标值
    @return NumberValue 可监听Changed事件的数值容器
    @return Tween 动画对象（可用于控制暂停/取消）
]]
function TweenInterface.AnimateNumberIncrease(labelOrFrom, to)
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
    tween:Play()
    
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
function TweenInterface.AnimateUIShowScale(guiObject, opts)
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

    tween.Completed:Connect(function()
        -- 动画完成后清理状态记录
        uiScaleStates[guiObject] = nil
    end)
    tween:Play()

    return scale, tween
end

-- 启动Gui颜色黑色脉冲循环（函数级注释）：
-- @param gui GuiObject 需要循环变色的UI对象（Frame/ImageLabel/TextLabel等）
-- @param toBlackDuration number 变为黑色的时长（秒），默认1.0
-- @param backDuration number 从黑色恢复到原色的时长（秒），默认1.0
-- 行为：持续“到黑→回原”循环，直到调用 StopPulseGuiColorLoop 或对象销毁
function TweenInterface.StartPulseGuiColorLoop(gui, toColor, toBlackDuration, backDuration)
    if not gui or not gui:IsA("GuiObject") then
        return
    end
    -- 已在循环中则跳过
    if gui:GetAttribute("Interface_ColorPulseLoopRunning") then
        return
    end
    gui:SetAttribute("Interface_ColorPulseLoopRunning", true)

    toBlackDuration = toBlackDuration or 1.0
    backDuration = backDuration or 1.0

    local function getColorPropName(instance)
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            return "ImageColor3"
        elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
            return "TextColor3"
        else
            return "BackgroundColor3"
        end
    end

    local propName = getColorPropName(gui)
    -- 读取当前颜色（允许外部改变原色时能跟随）
    local ok1, initColor = pcall(function()
        return gui[propName]
    end)
    task.spawn(function()
        while gui.Parent and gui:GetAttribute("Interface_ColorPulseLoopRunning") do
            -- 读取当前颜色（允许外部改变原色时能跟随）
            local ok2, currentColor = pcall(function()
                return gui[propName]
            end)
            if not ok2 or typeof(currentColor) ~= "Color3" then
                break
            end

            local tweenToBlack = TweenService:Create(gui, TweenInfo.new(toBlackDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { [propName] = toColor })
            tweenToBlack:Play()
            tweenToBlack.Completed:Wait()

            -- 循环可能在到黑期间被停止
            if not gui.Parent or not gui:GetAttribute("Interface_ColorPulseLoopRunning") then
                break
            end

            local tweenBack = TweenService:Create(gui, TweenInfo.new(backDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { [propName] = currentColor })
            tweenBack:Play()
            tweenBack.Completed:Wait()
        end

        pcall(function()
            gui[propName] = initColor
        end)
        gui:SetAttribute("Interface_ColorPulseLoopRunning", false)
    end)
end

-- 停止Gui颜色黑色脉冲循环（函数级注释）：
-- @param gui GuiObject 待停止的UI对象
-- 行为：将运行标记置为false，正在进行的当前补间完成后退出循环
function TweenInterface.StopPulseGuiColorLoop(gui)
    if not gui or not gui:IsA("GuiObject") then
        return
    end
    if gui:GetAttribute("Interface_ColorPulseLoopRunning") then
        gui:SetAttribute("Interface_ColorPulseLoopRunning", false)
    end
end

-- 节点移动补间动画接口
-- @param node BasePart|Model 要移动的节点（通常为模型根或基础部分）
-- @param targetPos Vector3 目标位置
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeMovePosition(node, targetPos, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        Position = targetPos,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点移动补间动画接口
-- @param node BasePart|Model 要移动的节点（通常为模型根或基础部分）
-- @param targetFrame CFrame 目标框架
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeMoveFrame(node, targetFrame, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        CFrame = targetFrame,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点缩放补间动画接口
-- @param node BasePart|Model 要缩放的节点（通常为模型根或基础部分）
-- @param targetScale Vector3 目标缩放比例
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeScale(node, targetScale, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        Scale = targetScale,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点旋转补间动画接口
-- @param node BasePart|Model 要旋转的节点（通常为模型根或基础部分）
-- @param targetAngle Vector3 目标旋转角度（单位：度）
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeRotation(node, targetAngle, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        Rotation = targetAngle,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点大小补间动画接口
-- @param node BasePart|Model 要缩放的节点（通常为模型根或基础部分）
-- @param targetSize Vector3 目标大小比例
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeSize(node, targetSize, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        Size = targetSize,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点透明度补间动画接口
-- @param node BasePart|Model 要透明度的节点（通常为模型根或基础部分）
-- @param targetTransparency number 目标透明度（0-1）
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeTransparencyFrame(node, targetTransparency, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        BackgroundTransparency = targetTransparency,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 文本透明度补间动画接口
-- @param node TextLabel 要透明度的文本标签（通常为 TextLabel）
-- @param targetTransparency number 目标透明度（0-1）
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeTransparencyText(node, targetTransparency, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        TextTransparency = targetTransparency,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 图片透明度补间动画接口
-- @param node ImageLabel 要透明度的图片标签（通常为 ImageLabel）
-- @param targetTransparency number 目标透明度（0-1）
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeTransparencyImage(node, targetTransparency, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        ImageTransparency = targetTransparency,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点透明度补间动画接口
-- @param node BasePart|Model 要透明度的节点（通常为模型根或基础部分）
-- @param targetTransparency number 目标透明度（0-1）
-- @param duration number 动画时长（秒）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNodeTransparency(node, targetTransparency, duration, callFunc)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(node, info, {
        Transparency = targetTransparency,
    })
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 将进度条通过补间动画平滑更新（函数级注释）：
-- @param bar GuiObject 进度条UI对象（通常为 Frame 或 ImageLabel）
-- @param targetRatio number 目标比例（0-1），会被 clamp 到 [0,1]
-- @param duration number 动画时长（秒），可选，默认 0.35 秒
-- @return void
function TweenInterface.TweenProgressBarSize(bar, targetRatio, duration, callFunc)
    duration = duration or 0.35
    targetRatio = math.clamp(targetRatio or 0, 0, 1)
    local currentSize = bar.Size
    local goal = {
        Size = UDim2.new(targetRatio, 0, currentSize.Y.Scale, currentSize.Y.Offset),
    }
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(bar, info, goal)
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

-- 节点补间动画接口
-- @param node BasePart|Model 要补间的节点（通常为模型根或基础部分）
-- @param info TweenInfo 补间信息（包含时长、缓动样式等）
-- @param goal table 目标属性值（例如 { Position = Vector3.new(0, 5, 0) }）
-- @param callFunc function 动画完成时调用的回调函数，可选
-- @return Tween 动画对象（可用于控制暂停/取消）
function TweenInterface.TweenNode(node, info, goal, callFunc)
    local tween = TweenService:Create(node, info, goal)
    if callFunc then
        tween.Completed:Connect(function()
            callFunc()
        end)
    end
    tween:Play()
    return tween
end

return TweenInterface