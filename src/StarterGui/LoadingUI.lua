-- LoadingUI 模块
-- 用于管理游戏加载界面的显示和隐藏

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local LoadingUI = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 加载界面GUI实例
local loadingScreenGui = nil
local loadingFrame = nil
local loadingLabel = nil

-- 创建加载界面
-- @return void
local function createLoadingScreen()
    -- 创建ScreenGui
    loadingScreenGui = Instance.new("ScreenGui")
    loadingScreenGui.Name = "LoadingScreen"
    loadingScreenGui.ResetOnSpawn = false
    loadingScreenGui.IgnoreGuiInset = true
    loadingScreenGui.Parent = playerGui
    
    -- 创建背景Frame
    loadingFrame = Instance.new("Frame")
    loadingFrame.Name = "LoadingFrame"
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.Position = UDim2.new(0, 0, 0, 0)
    loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Parent = loadingScreenGui
    
    -- 创建加载文本
    loadingLabel = Instance.new("TextLabel")
    loadingLabel.Name = "LoadingLabel"
    loadingLabel.Size = UDim2.new(0, 300, 0, 50)
    loadingLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "游戏加载中..."
    loadingLabel.TextColor3 = Color3.new(1, 1, 1)
    loadingLabel.TextScaled = true
    loadingLabel.Font = Enum.Font.SourceSansBold
    loadingLabel.Parent = loadingFrame
end

-- 显示加载界面
-- @param duration number 显示持续时间（秒），如果为nil则持续显示直到手动隐藏
-- @return void
function LoadingUI.Show(duration)
    if not loadingScreenGui then
        createLoadingScreen()
    end
    
    loadingScreenGui.Enabled = true
    print("显示加载界面")
    
    -- 如果指定了持续时间，则自动隐藏
    if duration and duration > 0 then
        task.wait(duration)
        LoadingUI.Hide()
    end
end

-- 隐藏加载界面
-- @return void
function LoadingUI.Hide()
    if loadingScreenGui then
        -- 创建淡出动画
        local fadeInfo = TweenInfo.new(
            0.5, -- 持续时间
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local fadeTween = TweenService:Create(
            loadingFrame,
            fadeInfo,
            {BackgroundTransparency = 1}
        )
        
        local textFadeTween = TweenService:Create(
            loadingLabel,
            fadeInfo,
            {TextTransparency = 1}
        )
        
        fadeTween:Play()
        textFadeTween:Play()
        
        fadeTween.Completed:Connect(function()
            loadingScreenGui.Enabled = false
            print("隐藏加载界面")
        end)
    end
end

-- 更新加载文本
-- @param text string 新的加载文本
-- @return void
function LoadingUI.UpdateText(text)
    if loadingLabel then
        loadingLabel.Text = text
    end
end

return LoadingUI