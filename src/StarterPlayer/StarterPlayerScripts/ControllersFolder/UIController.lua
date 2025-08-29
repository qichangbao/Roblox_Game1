local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Signal"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local UIController = Knit.CreateController {
    Name = "UIController",
    
    ShowStoreUI = Signal.new(),
    ShowSellUI = Signal.new(),
    ShowTip = Signal.new(),
    ShowAdminUI = Signal.new(),
}

function UIController:KnitInit()
    local KnitInitClient = require(script.Parent.Parent:WaitForChild("KnitInitClient"))
    -- 监听KnitInit执行完成事件
    KnitInitClient.AddListener(function()
        -- 获取TeleportService服务
        local NPCTrggeredService = Knit.GetService("NPCTrggeredService")
    
        -- 监听服务器的选择人数请求
        NPCTrggeredService.Triggered:Connect(function(npcType)
            if npcType == GameConfig.NpcUIType.Store then
                self.ShowStoreUI:Fire()
            elseif npcType == GameConfig.NpcUIType.Sell then
                self.ShowSellUI:Fire()
            end
        end)
    end)
end

function UIController:KnitStart()
end

return UIController