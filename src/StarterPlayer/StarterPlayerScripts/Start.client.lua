--require(game:GetService('StarterPlayer'):WaitForChild("StarterPlayerScripts"):WaitForChild("ClientData"))

-- -- 禁用滚轮缩放
-- local contextActionService = game:GetService('ContextActionService')
-- contextActionService:BindAction("BlockZoom",
--     function()
--         return Enum.ContextActionResult.Sink
--     end,
--     false,
--     Enum.UserInputType.MouseWheel
-- )

-- local camera = game.Workspace.CurrentCamera
-- local function onCharacterAdded(character)
--     local humanoid = character:WaitForChild("Humanoid")
--     -- 玩家坐下时，相机会拉远与玩家的距离，因此需要在玩家坐下时，将相机会拉远与玩家的距离恢复到初始值
--     humanoid.Seated:Connect(function(isSeated, seat)
--         camera.CameraSubject = humanoid
--     end)
-- end

-- local localPlayer = game.Players.LocalPlayer
-- if localPlayer.Character then
--     onCharacterAdded(localPlayer.Character)
-- else
--     localPlayer.CharacterAdded:Connect(function(character)
--         onCharacterAdded(character)
--     end)
-- end
print("客户端启动")

math.randomseed(os.time())
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- 初始化Knit框架
local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'):waitForChild('Knit'))
Knit.AddControllers(script.Parent:WaitForChild('ControllersFolder'))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local DesignConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("DesignConfig"))

-- local playerGui = Interface.safeWaitPart(game.Players.LocalPlayer, "PlayerGui")
-- local loadingUI = Interface.safeWaitPart(playerGui, "LoadingUI")
-- loadingUI.Enabled = true

_G.ClientData = require(game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ClientData"))

-- 等待RemoteEvent创建
local isServerStartOverEvent = ReplicatedStorage:WaitForChild("IsServerStartOver")

-- 向服务器发送启动状态查询
-- @return void
local function checkServerStartStatus()
    print("向服务器发送启动状态查询...")
    isServerStartOverEvent:FireServer()
end

-- 处理服务器返回的启动状态
-- @param isStarted boolean 服务器是否已启动完成
isServerStartOverEvent.OnClientEvent:Connect(function(isStarted)
    if isStarted then
        print("服务器已启动完成！")
        
        -- 通知KnitInit服务器已启动完成
        local success, KnitInitClient = pcall(function()
            return require(script.Parent:WaitForChild("KnitInitClient"))
        end)
        
        if success and KnitInitClient then
            print("通知KnitInit执行监听器")
            KnitInitClient.executePendingListeners()
        else
            warn("KnitInitClient执行失败")
        end
    else
        print("服务器尚未启动完成，继续等待...")
        -- 等待1秒后重新查询
        task.wait(1)
        checkServerStartStatus()
    end
end)

Knit.Start():andThen(function()
    -- 开始检查服务器启动状态
    checkServerStartStatus()
end):catch(warn)

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)

local mapConfig = DesignConfig:GetByMapId(GameConfig.IslandId)
local land = Interface.safeWaitPart(game.Workspace, mapConfig.MapName)
local spawnPoint = Interface.safeWaitPart(land, "SpawnLocation")
workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
if not workspace.CurrentCamera.CameraSubject then
    workspace.CurrentCamera.CameraSubject = spawnPoint
end