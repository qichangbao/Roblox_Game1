-- 工具动画处理客户端脚本
local TweenService = game:GetService("TweenService")

local PlayerAnimationHnadler = {}
-- 动画状态管理
local isAnimating = false
local currentTweens = {}

-- 播放挥舞动画函数
function PlayerAnimationHnadler.playSwingAnimation(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- 如果正在播放动画，直接返回，防止重复触发
    if isAnimating then
        return
    end
    
    isAnimating = true
    
    -- 获取右臂关节（根据实际角色模型结构）
    local rightShoulder = nil
    
    -- 在所有可能的位置查找右肩关节
    local searchLocations = {
        character,  -- 角色根目录
        character:FindFirstChild("UpperTorso"),  -- R15 上躯干
        character:FindFirstChild("Torso"),  -- R6 躯干
        character:FindFirstChild("RightUpperArm"),  -- R15 右上臂
        character:FindFirstChild("Right Arm")  -- R6 右臂
    }
    
    local jointNames = {"RightShoulder", "Right Shoulder", "RightUpperArm", "RightArm"}
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, jointName in pairs(jointNames) do
                local joint = location:FindFirstChild(jointName)
                if joint and joint:IsA("Motor6D") then
                    rightShoulder = joint

                    break
                end
            end
            if rightShoulder then break end
        end
    end
    
    if rightShoulder then
        -- 保存原始 C0 值
        local originalC0 = rightShoulder.C0
        
        -- 创建挥舞动作的 C0 值
        local swingC0 = originalC0 * CFrame.Angles(math.rad(-90), 0, 0)
        
        -- 创建动画信息
        local swingInfo = TweenInfo.new(
            0.15,  -- 持续时间
            Enum.EasingStyle.Quad,  -- 缓动样式
            Enum.EasingDirection.Out,  -- 缓动方向
            0,  -- 重复次数
            false,  -- 是否反向
            0  -- 延迟时间
        )
        
        local backInfo = TweenInfo.new(
            0.25,  -- 持续时间
            Enum.EasingStyle.Quad,  -- 缓动样式
            Enum.EasingDirection.InOut,  -- 缓动方向
            0,  -- 重复次数
            false,  -- 是否反向
            0  -- 延迟时间
        )
        
        -- 强制重置到原始位置（防止累积旋转）
        rightShoulder.C0 = originalC0
        
        -- 创建补间动画
        local swingTween = TweenService:Create(rightShoulder, swingInfo, {C0 = swingC0})
        local backTween = TweenService:Create(rightShoulder, backInfo, {C0 = originalC0})
        
        -- 保存当前动画引用
        currentTweens = {swingTween, backTween}
        
        -- 播放动画
        swingTween:Play()
        swingTween.Completed:Connect(function()
            if currentTweens[2] == backTween then  -- 确保是当前动画
                backTween:Play()
                backTween.Completed:Connect(function()
                    if currentTweens[2] == backTween then  -- 确保是当前动画
                        isAnimating = false
                        currentTweens = {}
                    end
                end)
            end
        end)
        
        -- 播放挥舞音效（使用有效的Roblox音效）
        local swingSound = Instance.new("Sound")
        swingSound.SoundId = "rbxassetid://12222030" -- 挥舞音效
        swingSound.Volume = 1
        swingSound.Pitch = 1.5
        swingSound.Parent = character:FindFirstChild("Head") or character
        swingSound:Play()
        
        -- 音效播放完后清理
        game:GetService("Debris"):AddItem(swingSound, 2)
    end
end

-- 播放挖掘动画函数（从下往上）
function PlayerAnimationHnadler.playDigAnimation(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- 如果正在播放动画，直接返回，防止重复触发
    if isAnimating then
        return
    end
    
    isAnimating = true
    
    -- 获取右臂关节（根据实际角色模型结构）
    local rightShoulder = nil
    
    -- 在所有可能的位置查找右肩关节
    local searchLocations = {
        character,  -- 角色根目录
        character:FindFirstChild("UpperTorso"),  -- R15 上躯干
        character:FindFirstChild("Torso"),  -- R6 躯干
        character:FindFirstChild("RightUpperArm"),  -- R15 右上臂
        character:FindFirstChild("Right Arm")  -- R6 右臂
    }
    
    local jointNames = {"RightShoulder", "Right Shoulder", "RightUpperArm", "RightArm"}
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, jointName in pairs(jointNames) do
                local joint = location:FindFirstChild(jointName)
                if joint and joint:IsA("Motor6D") then
                    rightShoulder = joint
                    break
                end
            end
            if rightShoulder then break end
        end
    end
    
    if rightShoulder then
        -- 保存原始 C0 值
        local originalC0 = rightShoulder.C0
        
        -- 创建挖掘动作的 C0 值（从下往上的动作）
        -- 先向下准备，然后向上挖掘
        local prepareC0 = originalC0 * CFrame.Angles(math.rad(45), math.rad(-15), math.rad(10))  -- 向下准备姿势
        local digC0 = originalC0 * CFrame.Angles(math.rad(-60), math.rad(15), math.rad(-10))     -- 向上挖掘姿势
        
        -- 创建动画信息
        local prepareInfo = TweenInfo.new(
            0.2,  -- 持续时间
            Enum.EasingStyle.Quad,  -- 缓动样式
            Enum.EasingDirection.Out,  -- 缓动方向
            0,  -- 重复次数
            false,  -- 是否反向
            0  -- 延迟时间
        )
        
        local digInfo = TweenInfo.new(
            0.25,  -- 持续时间
            Enum.EasingStyle.Quad,  -- 缓动样式
            Enum.EasingDirection.InOut,  -- 缓动方向
            0,  -- 重复次数
            false,  -- 是否反向
            0  -- 延迟时间
        )
        
        local backInfo = TweenInfo.new(
            0.3,  -- 持续时间
            Enum.EasingStyle.Quad,  -- 缓动样式
            Enum.EasingDirection.InOut,  -- 缓动方向
            0,  -- 重复次数
            false,  -- 是否反向
            0  -- 延迟时间
        )
        
        -- 强制重置到原始位置（防止累积旋转）
        rightShoulder.C0 = originalC0
        
        -- 创建补间动画
        local prepareTween = TweenService:Create(rightShoulder, prepareInfo, {C0 = prepareC0})
        local digTween = TweenService:Create(rightShoulder, digInfo, {C0 = digC0})
        local backTween = TweenService:Create(rightShoulder, backInfo, {C0 = originalC0})
        
        -- 保存当前动画引用
        currentTweens = {prepareTween, digTween, backTween}
        
        -- 播放动画序列
        prepareTween:Play()
        prepareTween.Completed:Connect(function()
            if currentTweens[2] == digTween then  -- 确保是当前动画
                digTween:Play()
                digTween.Completed:Connect(function()
                    if currentTweens[3] == backTween then  -- 确保是当前动画
                        backTween:Play()
                        backTween.Completed:Connect(function()
                            if currentTweens[3] == backTween then  -- 确保是当前动画
                                isAnimating = false
                                currentTweens = {}
                            end
                        end)
                    end
                end)
            end
        end)
        
        -- 播放挖掘音效（使用有效的Roblox音效）
        local digSound = Instance.new("Sound")
        digSound.SoundId = "rbxassetid://12222084" -- 挖掘音效
        digSound.Volume = 1
        digSound.Pitch = 1.2
        digSound.Parent = character:FindFirstChild("Head") or character
        digSound:Play()
        
        -- 音效播放完后清理
        game:GetService("Debris"):AddItem(digSound, 2)
    end
end

return PlayerAnimationHnadler