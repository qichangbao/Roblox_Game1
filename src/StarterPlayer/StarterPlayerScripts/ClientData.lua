local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
-- 初始化Knit框架
local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'):waitForChild('Knit'))
local GameConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('GameConfig'))
local ItemConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('ItemConfig'))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))

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

    require(script.Parent:WaitForChild("PlayerGuide")):ShowGuide()
end

-- 奖励演出：边抖动边掉落奖励，落地后停留一秒，再飞向玩家并添加到背包
-- @param rewards table 奖励物品ID数组，例如 {1001, 1002, 1003}
-- @return void
local function RewardAction(rewards)
    -- 兼容：如果服务端没有传入，使用默认演示奖励
    if type(rewards) ~= "table" or #rewards == 0 then
        rewards = {1001, 1001, 1001, 1002, 1004}
    end

    -- 找到场景中的“神树”作为演出来源位置
    local land = Interface.safeWaitPart(workspace, GameConfig.LandName)
    local special = Interface.safeWaitPart(land, "Special")
    local npc = Interface.safeWaitPart(special, "Npc")
    local treeModel = Interface.safeWaitPart(npc, "DivineTree")

    local _effects = {}
    table.insert(_effects, treeModel:FindFirstChild("F - RAGING PILLAR"):FindFirstChild("FLAMEPILLAR"))
    table.insert(_effects, treeModel:FindFirstChild("F - RAGING PILLAR"):FindFirstChild("GLOW"))
    table.insert(_effects, treeModel:FindFirstChild("F - RAGING PILLAR"):FindFirstChild("SPECKS"))
    table.insert(_effects, treeModel:FindFirstChild("F - RAGING PILLAR"):FindFirstChild("SPIKES"))

    local _tickets = treeModel:FindFirstChild("ChaChing"):FindFirstChild("Tickets")
    _tickets.Enabled = false

    local function setEffectEnabled(enable)
        for _, v in ipairs(_effects) do
            v.Enabled = enable
        end
    end

    local tree = Interface.safeWaitPart(treeModel, "Tree")
    local basePivot = tree:GetPivot()

    -- 抖动参数
    local ROUNDS = 10
    local LIFT_ANGLE_DEG = 2
    local HOLD_TIME = 0.03
    local leftAngle = math.rad(LIFT_ANGLE_DEG)
    local rightAngle = -math.rad(LIFT_ANGLE_DEG)

    -- 找到神树的主部位作为掉落起点
    local function getTreePrimaryPart()
        local primary = tree.PrimaryPart
        if primary and primary:IsA("BasePart") then return primary end
        for _, d in ipairs(tree:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
        return nil
    end
    local treePart = getTreePrimaryPart()
    local dropOrigin = treePart and treePart.Position or (tree:GetPivot().Position)

    -- 播放树的抖动与轻微缩放（并行进行）
    task.spawn(function()
        setEffectEnabled(false)
        _tickets.Enabled = true
        for _ = 1, ROUNDS do
            tree:PivotTo(basePivot * CFrame.Angles(0, 0, leftAngle))
            task.wait(HOLD_TIME)
            tree:PivotTo(basePivot)
            task.wait(HOLD_TIME)
            tree:PivotTo(basePivot * CFrame.Angles(0, 0, rightAngle))
            task.wait(HOLD_TIME)
            tree:PivotTo(basePivot)
            task.wait(HOLD_TIME)
        end
        -- 复位
        tree:PivotTo(basePivot)
        -- 轻微缩放弹动
        local function tweenScale(targetScale, duration)
            local startScale = tree:GetScale()
            local steps = 10
            local stepTime = duration / steps
            local scaleDelta = (targetScale - startScale) / steps
            for i = 1, steps do
                local newScale = startScale + scaleDelta * i
                tree:ScaleTo(newScale)
                task.wait(stepTime)
            end
        end
        tweenScale(0.8, 0.05)
        tweenScale(1.1, 0.02)
        tweenScale(1, 0.1)

        -- 启用神树火焰效果
        setEffectEnabled(true)
        _tickets.Enabled = false
        task.delay(1.2, function()
            setEffectEnabled(false)
        end)
    end)

    -- 掉落与飞行表现：为每个奖励创建一个可见的本地特效，然后飞向玩家并发放物品
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer and localPlayer.Character
    local ignoreList = { treeModel }

    -- 工具函数：为图标创建一个世界掉落可视对象
    local function createDropVisual(itemInfo)
        -- 在树周围随机一个起点（半径5）
        local offset = Vector3.new(math.random(-7, 7), 0.6, math.random(-7, 7))
        if offset.Magnitude ~= offset.Magnitude then -- NaN 防御
            offset = Vector3.new(0, 0.6, 1.2)
        end
        local pos = dropOrigin + offset
        local typeFolder = ReplicatedStorage:FindFirstChild("ItemFolder") and ReplicatedStorage.ItemFolder:FindFirstChild(GameConfig.ItemTypeFolder[itemInfo.Type])
        if not typeFolder then return nil end
        local template = typeFolder:FindFirstChild(itemInfo.Model)
        if not template then return nil end
        local model = template:Clone()
        if not model.PrimaryPart then
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                    model.PrimaryPart = d
                    break
                end
            end
        end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
            end
        end
        model.Parent = workspace
        model:PivotTo(CFrame.new(pos))
        model:ScaleTo(2)
        return model
    end

    -- 工具函数：将掉落物移动到地面
    local function tweenToGround(model)
        local startCf = model:GetPivot()
        local startPos = startCf.Position
        local groundPos = Interface.getGroundPosition(startPos, ignoreList)
        local dropDistance = (startPos - groundPos).Magnitude
        local duration = dropDistance / 10
        local ti = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local cfv = Instance.new("CFrameValue")
        cfv.Value = startCf
        local tw = TweenService:Create(cfv, ti, { Value = CFrame.new(groundPos) })
        local conn = cfv.Changed:Connect(function(v)
            if typeof(v) == "CFrame" then
                model:PivotTo(v)
            end
        end)
        tw.Completed:Connect(function()
            conn:Disconnect()
            cfv:Destroy()
        end)
        tw:Play()
        return tw
    end

    -- 将掉落物飞向玩家指定身体部位
    -- @param part BasePart 掉落可视 Part
    -- @param target BasePart|string? 目标身体部位（实例或名称），默认 "Head"，支持 R6/R15
    -- @return Tween|nil 创建的飞行 Tween
    local function tweenToPlayer(model, target)
        if not character then return nil end
        local targetPart = nil

        if typeof(target) == "Instance" and target:IsA("BasePart") then
            targetPart = target
        elseif typeof(target) == "string" then
            local found = character:FindFirstChild(target, true)
            if found and found:IsA("BasePart") then
                targetPart = found
            end
        end

        if not targetPart then
            targetPart = character:FindFirstChild("HumanoidRootPart")
                or character:FindFirstChild("Head")
                or character:FindFirstChild("UpperTorso")
                or character:FindFirstChild("Torso")
        end
        if not targetPart then return nil end

        local startCf = model:GetPivot()
        local startPos = startCf.Position
        local targetPos = targetPart.Position + Vector3.new(0, 0.8, 0)
        local dist = (startPos - targetPos).Magnitude
        local duration = dist / 80
        local ti = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local cfv = Instance.new("CFrameValue")
        cfv.Value = startCf
        local tw = TweenService:Create(cfv, ti, { Value = CFrame.new(targetPos) })
        local conn = cfv.Changed:Connect(function(v)
            if typeof(v) == "CFrame" then
                model:PivotTo(v)
            end
        end)
        tw.Completed:Connect(function()
            conn:Disconnect()
            cfv:Destroy()
        end)
        tw:Play()
        return tw
    end

    -- 逐个掉落奖励（与抖动并行），每个间隔少许时间
    for i, itemId in ipairs(rewards) do
        task.delay(0.08 * (i - 1), function()
            local itemInfo = ItemConfig:GetByItemId(tonumber(itemId))
            if not itemInfo then return end

            local model = createDropVisual(itemInfo)
            local dropTw = tweenToGround(model)
            dropTw.Completed:Connect(function()
                -- 落地停留 1 秒
                task.delay(1, function()
                    local flyTw = tweenToPlayer(model, "HumanoidRootPart")
                    if flyTw then
                        flyTw.Completed:Connect(function()
                            -- 到达玩家后，移除特效并添加到背包
                            Debris:AddItem(model, 0.05)
                            -- 调用服务器添加物品到背包
                            local attr = GameConfig.GetItemAttribute()
                            Knit.GetService("InventoryService"):AddItem({ ItemId = itemInfo.ItemId, Attribute = attr })
                        end)
                    else
                        Debris:AddItem(model, 0.05)
                    end
                end)
            end)
        end)
    end
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
                RewardAction(data)
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
