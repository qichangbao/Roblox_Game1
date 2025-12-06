local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- 初始化Knit框架
local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'):waitForChild('Knit'))
local GameConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('GameConfig'))

local ClientData = {}
ClientData.Gold = 0
ClientData.Inventory = {}
ClientData.ToolData = {}
ClientData.EquipmentData = {}
ClientData.TalentData = {}
ClientData.QuestData = {}
ClientData.RankPersonalData = {}
ClientData.RankData = {}
ClientData.IsAdmin = false
ClientData.IsFromFuben = false
ClientData.Weight = 0
ClientData.CollectSpeed = 0
ClientData.Lucky = 0

local function setInitData(data)
    -- 安全地设置数据
    ClientData.Gold = data.Gold or 0
    ClientData.Inventory = data.Inventory or {}
    ClientData.ToolData = data.ToolData or {}
    ClientData.EquipmentData = data.EquipmentData or {}
    ClientData.TalentData = data.TalentData or {}
    ClientData.RankPersonalData = data.RankPersonalData or {}
    ClientData.RankData = data.RankData or {}
    ClientData.IsAdmin = data.IsAdmin or false
    ClientData.IsFromFuben = data.IsFromFuben or false
    ClientData.QuestData = data.QuestData or {}
    ClientData.Weight = data.Weight or 0
    ClientData.CollectSpeed = data.CollectSpeed or 0
    ClientData.Lucky = data.Lucky or 0
    local offlineTime = data.OfflineTime or 0
    -- local playerGui = Interface.safeWaitPart(game.Players.LocalPlayer, "PlayerGui")
	-- local loadingUI = Interface.safeWaitPart(playerGui, "LoadingUI")
	-- loadingUI.Enabled = false
    Knit.GetController("UIController").ChangeGoldUI:Fire(ClientData.Gold)
    Knit.GetController("UIController").UpdateBackpack:Fire(ClientData.Inventory)
    Knit.GetController("UIController").UpdateToolUI:Fire(ClientData.ToolData)
    Knit.GetController("UIController").UpdateEquipment:Fire(ClientData.EquipmentData)
    Knit.GetController("UIController").ShowAdminButton:Fire(ClientData.IsAdmin)
    Knit.GetController("UIController").UpdateRankPersonalData:Fire(ClientData.RankPersonalData)
    Knit.GetController("UIController").UpdateTalentData:Fire(ClientData.TalentData)
    Knit.GetController("UIController").UpdateRankData:Fire(ClientData.RankData)
    Knit.GetController("UIController").UpdateQuestData:Fire(ClientData.QuestData)
    Knit.GetController("UIController").UpdateOfflineTime:Fire(offlineTime)

    require(script.Parent:WaitForChild("PlayerGuide")):ShowGuide()
end

local function init()
    local KnitInitClient = require(script.Parent:WaitForChild("KnitInitClient"))
    KnitInitClient.AddListener(function()
        -- 监听服务器的发送初始化数据请求
        Knit.GetService("PlayerService").GetInitData():andThen(function(data)
            setInitData(data)
        end)

        -- 监听服务器的发送金币数据请求
        Knit.GetService("GoldService").ChangeGold:Connect(function(gold)
			ClientData.Gold = gold
			Knit.GetController("UIController").ChangeGoldUI:Fire(gold)
		end)

        -- 监听服务器的发送背包数据请求
		Knit.GetService("InventoryService").SendBackpack:Connect(function(inventory)
			ClientData.Inventory = inventory or {}
			Knit.GetController("UIController").UpdateBackpack:Fire(inventory or {})
		end)

        -- 监听服务器的发送工具数据请求
		Knit.GetService("InventoryService").SendToolData:Connect(function(toolData)
			ClientData.ToolData = toolData or {}
			Knit.GetController("UIController").UpdateToolUI:Fire(toolData or {})
		end)

        -- 监听服务器的发送装备数据请求
		Knit.GetService("EquipmentService").SendEquipment:Connect(function(equipmentData)
			ClientData.EquipmentData = equipmentData or {}
			Knit.GetController("UIController").UpdateEquipment:Fire(equipmentData or {})
		end)

        -- 监听服务器的发送开始传送请求
        Knit.GetService("TeleportService").SendStartTeleport:Connect(function()
			local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if not playerGui then
                return
            end
			local teleportUI = playerGui:FindFirstChild("TeleportUI")
            if not teleportUI then
                return
            end
			
			teleportUI.Enabled = true
		
            local ui = game:GetService("SoundService"):WaitForChild("UI")
            local sound = ui:WaitForChild("Loading")
            sound:Play()
        end)
    
        -- 监听服务器的显示传送界面请求
        Knit.GetService("TeleportService").RequestPlayerCount:Connect(function(partName)
			Knit.GetController("UIController").ShowChoosePeopleNumUI:Fire(partName)
        end)

        -- 监听服务器的更新个人排行榜请求
        Knit.GetService("RankService").UpdateRankPersonalData:Connect(function(rankPersonalData)
            ClientData.RankPersonalData = rankPersonalData or {}
            Knit.GetController("UIController").UpdateRankPersonalData:Fire(rankPersonalData or {})
        end)

        -- 监听服务器的更新排行榜请求
        Knit.GetService("RankService").UpdateLeaderboard:Connect(function(rankData)
            ClientData.RankData = rankData or {}
            Knit.GetController("UIController").UpdateRankData:Fire(rankData or {})
        end)
    
        -- 监听服务器的触发NPC事件
        Knit.GetService("NPCTrggeredService").Triggered:Connect(function(npcType, data)
            if npcType == GameConfig.NpcUIType.Store then
                Knit.GetController("UIController").ShowStoreUI:Fire(data)
            elseif npcType == GameConfig.NpcUIType.Sell then
                Knit.GetController("UIController").ShowSellUI:Fire(data)
            elseif npcType == GameConfig.NpcUIType.Talent then
                Knit.GetController("UIController").ShowTalentUI:Fire(data)
            elseif npcType == GameConfig.NpcUIType.Quest then
                Knit.GetController("UIController").ShowQuestUI:Fire(1, data)
            elseif npcType == GameConfig.NpcUIType.Reward then
                Knit.GetController("UIController").RewardAction:Fire(data)
            end
        end)

        -- 监听服务器的更新能力数据请求
        Knit.GetService("TalentService").UpdateTalentData:Connect(function(talentData)
            ClientData.TalentData = talentData or {}
            Knit.GetController("UIController").UpdateTalentData:Fire(ClientData.TalentData)
        end)

        -- 监听服务器的任务数据请求
        Knit.GetService("QuestService").QuestUpdated:Connect(function(questData)
            ClientData.QuestData = questData or {}
            Knit.GetController("UIController").UpdateQuestData:Fire(ClientData.QuestData)
        end)

        Knit.GetService("ClientUIService").ShowTip:Connect(function(tip)
            Knit.GetController("UIController").ShowTip:Fire(tip)
        end)
    end)
end

init()

return ClientData
