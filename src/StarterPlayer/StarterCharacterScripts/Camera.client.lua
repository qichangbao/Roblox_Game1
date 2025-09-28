-- 摄像机控制脚本
-- 在角色加载后设置摄像头朝向玩家的前方

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--[[
    重置摄像机到默认状态
    @return void
]]
local function resetCamera(character)
    camera.CameraType = Enum.CameraType.Scriptable
    task.wait(0.1)
    -- 重置摄像机类型为默认
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = character:FindFirstChild("Humanoid")
end

--[[
    处理角色加载事件
    @param character Model - 玩家角色模型
    @return void
]]
local function onCharacterAdded(character)
    print("角色已加载，设置摄像机...")
    
    resetCamera(character)
end

-- 连接角色加载和移除事件
player.CharacterAdded:Connect(onCharacterAdded)

-- 如果角色已经存在，立即处理
if player.Character then
    onCharacterAdded(player.Character)
end