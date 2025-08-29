-- TeleportController 客户端控制器
-- 处理传送相关的客户端逻辑，包括选择人数UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer.PlayerGui

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Signal"))

local TeleportController = Knit.CreateController {
    Name = "TeleportController",
    Countdown = Signal.new(),
}

-- 控制器初始化
-- @return void
function TeleportController:KnitInit()
    local KnitInitClient = require(script.Parent.Parent:WaitForChild("KnitInitClient"))
    -- 监听KnitInit执行完成事件
    KnitInitClient.AddListener(function()
        -- 获取TeleportService服务
        local TeleportService = Knit.GetService("TeleportService")
    
        -- 监听服务器的选择人数请求
        TeleportService.RequestPlayerCount:Connect(function(partName)
            local SelectPlayerCountUI = PlayerGui:WaitForChild("SelectPlayerCountUI")
            SelectPlayerCountUI:SetAttribute("TeleportPartName", partName)
            SelectPlayerCountUI.Enabled = true
        end)
    end)
end

-- 控制器启动
-- @return void
function TeleportController:KnitStart()
end

return TeleportController