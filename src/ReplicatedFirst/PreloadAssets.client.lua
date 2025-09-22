-- --[[
-- 	PreloadAssets.client.lua
-- 	预加载游戏关键资源，减少游戏中的加载等待时间
-- ]]

-- local ContentProvider = game:GetService("ContentProvider")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- --[[
-- 	预加载关键游戏资源
-- 	在游戏开始前加载重要的模型、贴图、音频等
-- ]]
-- local function PreloadCriticalAssets()
-- 	print("开始预加载关键资源...")
	
-- 	-- 要预加载的资源列表
-- 	local assetsToPreload = {}
	
-- 	-- 添加工具文件夹中的所有工具
-- 	if ReplicatedStorage:FindFirstChild("ToolFolder") then
-- 		for _, tool in pairs(ReplicatedStorage.ToolFolder:GetChildren()) do
-- 			table.insert(assetsToPreload, tool)
-- 		end
-- 	end
	
-- 	-- 添加动画文件夹中的所有动画
-- 	if ReplicatedStorage:FindFirstChild("Animation") then
-- 		for _, animation in pairs(ReplicatedStorage.Animation:GetChildren()) do
-- 			table.insert(assetsToPreload, animation)
-- 		end
-- 	end
	
-- 	-- 添加配置文件夹中的资源
-- 	if ReplicatedStorage:FindFirstChild("ConfigFolder") then
-- 		for _, config in pairs(ReplicatedStorage.ConfigFolder:GetChildren()) do
-- 			table.insert(assetsToPreload, config)
-- 		end
-- 	end
	
-- 	-- 预加载音频资源（如果有的话）
-- 	local audioIds = {
-- 		-- 在这里添加你的音频ID
-- 		-- "rbxassetid://123456789",
-- 		-- "rbxassetid://987654321",
-- 	}
	
-- 	for _, audioId in pairs(audioIds) do
-- 		table.insert(assetsToPreload, audioId)
-- 	end
	
-- 	-- 执行预加载
-- 	if #assetsToPreload > 0 then
-- 		local success, errorMessage = pcall(function()
-- 			ContentProvider:PreloadAsync(assetsToPreload)
-- 		end)
		
-- 		if success then
-- 			print(string.format("成功预加载 %d 个资源", #assetsToPreload))
-- 		else
-- 			warn("预加载失败:", errorMessage)
-- 		end
-- 	else
-- 		print("没有找到需要预加载的资源")
-- 	end
-- end

-- --[[
-- 	创建自定义加载界面
-- 	在预加载期间显示自定义的加载提示
-- ]]
-- local function CreateCustomLoadingScreen()
-- 	local Players = game:GetService("Players")
-- 	local player = Players.LocalPlayer
-- 	local playerGui = player:WaitForChild("PlayerGui")
	
-- 	-- 创建加载界面
-- 	local loadingGui = Instance.new("ScreenGui")
-- 	loadingGui.Name = "CustomLoadingScreen"
-- 	loadingGui.ResetOnSpawn = false
-- 	loadingGui.Parent = playerGui
	
-- 	-- 背景框架
-- 	local background = Instance.new("Frame")
-- 	background.Size = UDim2.new(1, 0, 1, 0)
-- 	background.BackgroundColor3 = Color3.new(0, 0, 0)
-- 	background.BackgroundTransparency = 0.3
-- 	background.Parent = loadingGui
	
-- 	-- 加载文本
-- 	local loadingText = Instance.new("TextLabel")
-- 	loadingText.Size = UDim2.new(0, 300, 0, 50)
-- 	loadingText.Position = UDim2.new(0.5, -150, 0.5, -25)
-- 	loadingText.BackgroundTransparency = 1
-- 	loadingText.Text = "正在加载游戏资源..."
-- 	loadingText.TextColor3 = Color3.new(1, 1, 1)
-- 	loadingText.TextScaled = true
-- 	loadingText.Font = Enum.Font.SourceSansBold
-- 	loadingText.Parent = background
	
-- 	-- 加载进度条
-- 	local progressFrame = Instance.new("Frame")
-- 	progressFrame.Size = UDim2.new(0, 400, 0, 10)
-- 	progressFrame.Position = UDim2.new(0.5, -200, 0.5, 40)
-- 	progressFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
-- 	progressFrame.BorderSizePixel = 0
-- 	progressFrame.Parent = background
	
-- 	local progressBar = Instance.new("Frame")
-- 	progressBar.Size = UDim2.new(0, 0, 1, 0)
-- 	progressBar.BackgroundColor3 = Color3.new(0, 0.7, 1)
-- 	progressBar.BorderSizePixel = 0
-- 	progressBar.Parent = progressFrame
	
-- 	-- 动画进度条
-- 	local TweenService = game:GetService("TweenService")
-- 	local progressTween = TweenService:Create(
-- 		progressBar,
-- 		TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
-- 		{Size = UDim2.new(1, 0, 1, 0)}
-- 	)
	
-- 	progressTween:Play()
	
-- 	-- 3秒后移除加载界面
-- 	wait(3)
-- 	loadingGui:Destroy()
-- end

-- -- 主执行逻辑
-- spawn(function()
-- 	-- 显示自定义加载界面
-- 	CreateCustomLoadingScreen()
	
-- 	-- 预加载资源
-- 	PreloadCriticalAssets()
	
-- 	print("资源预加载完成！")
-- end)