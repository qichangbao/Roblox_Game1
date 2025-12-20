local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'):waitForChild('Knit'))
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local GameConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('GameConfig'))
local ItemConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('ItemConfig'))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local DesignConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('DesignConfig'))

-- 找到场景中的“神树”作为演出来源位置
local land = Interface.safeWaitPart(workspace, tostring(GameConfig.IslandId))
local special = Interface.safeWaitPart(land, "Special")
local npc = Interface.safeWaitPart(special, "Npc")
local treeModel = Interface.safeWaitPart(npc, "DivineTree")

local function UpdateOfflineTime(offlineTime)
    local Large = Interface.safeWaitPart(treeModel, "Large")
    local UI = Interface.safeWaitPart(Large, "UI")
    local BillboardGui = Interface.safeWaitPart(UI, "BillboardGui")
    local Frame = Interface.safeWaitPart(BillboardGui, "Frame")
    local TextLabel = Interface.safeWaitPart(Frame, "TextLabel")

    TextLabel.Text = string.format("Offline %s", Interface.formatTimeMMSS(offlineTime))
end

-- 奖励演出：边抖动边掉落奖励，落地后停留一秒，再飞向玩家并添加到背包
-- @param rewards table 奖励物品ID数组，例如 {1001, 1002, 1003}
-- @return void
local function RewardAction(rewards)
    -- 兼容：如果服务端没有传入，使用默认演示奖励
    if type(rewards) ~= "table" or #rewards == 0 then
        rewards = {1001, 1001, 1001, 1002, 1004}
    end

    treeModel:FindFirstChild("ProximityPrompt"):Destroy()
    UpdateOfflineTime(0)

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
    -- 启用神树火焰效果
    setEffectEnabled(true)
    tweenScale(0.8, 0.05)

    -- 掉落与飞行表现：为每个奖励创建一个可见的本地特效，然后飞向玩家并发放物品
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer and localPlayer.Character
    local ignoreList = { treeModel }

    -- 从上方投射获取“地表”高度（优先命中最上层表面）
    -- @function getSurfaceGround
    -- @param lateral Vector3 水平目标点
    -- @param ignoreList table? 忽略实例列表
    -- @return Vector3 命中的地表位置（附加微小抬升），若失败回退到 Interface.getGroundPosition
    local function getSurfaceGround(lateral, ignore)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = ignore or {}
        -- 从上方 60 向下 300，优先取最上层命中
        local origin = lateral + Vector3.new(0, 60, 0)
        local dir = Vector3.new(0, -300, 0)
        local result = workspace:Raycast(origin, dir, params)
        if result then
            local hitPos = result.Position
            return hitPos + Vector3.new(0, 0.2, 0)
        end
        return Interface.getGroundPosition(lateral, ignore)
    end

    -- 工具函数：为图标创建一个世界掉落可视对象
    -- 为奖励创建一个靠近地面的可视模型（起始高度贴地，避免过大Y差）
    -- @function createDropVisual
    -- @param itemInfo table 物品配置
    -- @return Model|nil 创建的模型
    local function createDropVisual(itemInfo)
        -- 在树周围随机一个起点（仅水平偏移），随后贴地取高度
        local offsetXZ = Vector3.new(math.random(-7, 7), 0, math.random(-7, 7))
        if offsetXZ.Magnitude ~= offsetXZ.Magnitude then -- NaN 防御
            offsetXZ = Vector3.new(0, 0, 1.2)
        end
        local lateralStart = dropOrigin + offsetXZ
        local groundStart = getSurfaceGround(lateralStart, ignoreList)
        -- 起始高度提高 20（贴地基础上抬高），满足“出发点提高20”的需求
        local pos = Vector3.new(lateralStart.X, groundStart.Y + 15, lateralStart.Z)
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

    -- 为模型创建或获取拖尾 Trail（默认禁用）
    -- @function ensureDropTrail
    -- @param model Model 掉落的可视模型（需有 PrimaryPart）
    -- @return Trail 返回 Trail 实例，调用方负责启用/禁用与生命周期管理
    local function ensureDropTrail(model)
        local primary = model.PrimaryPart
        if not primary then
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                    model.PrimaryPart = d
                    primary = d
                    break
                end
            end
        end
        if not primary then return nil end

        local trail = primary:FindFirstChild("DropTrail")
        if trail and trail:IsA("Trail") then
            return trail
        end

        local a0 = primary:FindFirstChild("DropTrailA0")
        local a1 = primary:FindFirstChild("DropTrailA1")
        if not a0 then
            a0 = Instance.new("Attachment")
            a0.Name = "DropTrailA0"
            a0.Parent = primary
            a0.Position = Vector3.new(0, 0, 0)
        end
        if not a1 then
            a1 = Instance.new("Attachment")
            a1.Name = "DropTrailA1"
            a1.Parent = primary
            a1.Position = Vector3.new(0, 0, -0.6)
        end

        trail = Instance.new("Trail")
        trail.Name = "DropTrail"
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Enabled = false
        trail.Lifetime = 0.5
        trail.MinLength = 0.1
        trail.LightInfluence = 0
        trail.TextureMode = Enum.TextureMode.Stretch
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0.2)
        })
        trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 10),
            NumberSequenceKeypoint.new(1, 1)
        })
        trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        trail.Parent = primary
        return trail
    end

    -- 前向弹射到地面（零初始上抛，受重力下落）
    -- @function tweenToGround
    -- @param model Model 掉落的可视模型（已设置 PrimaryPart，且部件 Anchored）
    -- @return Tween 返回内部驱动的 Tween（用于 Completed 监听），路径为物理近似：
    --          p(t) = p0 + vForward * t + 0.5 * g * t^2，其中 vForward 沿树的局部 X+ 方向，初始竖直速度为 0。
    -- @details 保证“先向前抛、弧线低、距离远”，最终精确到达目标方向的地面。
    local function tweenToGround(model)
        local startCf = model:GetPivot()
        local startPos = startCf.Position

        -- 抛射方向与目标地面（使用树的局部 RightVector 投影到水平面，并加入轻微侧向）
        local right = tree:GetPivot().RightVector
        local horiz = Vector3.new(right.X, 0, right.Z)
        if horiz.Magnitude < 1e-4 then
            local look = tree:GetPivot().LookVector
            horiz = Vector3.new(look.X, 0, look.Z)
        end
        local forwardUnit = horiz.Magnitude > 0 and horiz.Unit or Vector3.new(1, 0, 0)
        local sideUnit = Vector3.new(-forwardUnit.Z, 0, forwardUnit.X) -- 水平面上与前向正交
        local preOffset = math.random(15, 25) -- 主前向距离（按你的要求 30-50）
        local sideOffset = math.random(-10, 10) -- 轻微横向扰动
        local lateralTarget = startPos + forwardUnit * preOffset + sideUnit * sideOffset
        local groundTop = getSurfaceGround(lateralTarget, ignoreList)
        local groundPos = Vector3.new(lateralTarget.X, groundTop.Y + 0.4, lateralTarget.Z)

        -- 物理近似计算总时间与有效重力（零初始上抛）：确保在 tTotal 内恰好下降到地面
        -- y(t) = y0 - 0.5 * gEff * t^2 = groundY
        local gBase = workspace.Gravity or 196.2
        local dropHeight = math.max(0.05, startPos.Y - groundPos.Y)
        local tNatural = math.sqrt(2 * dropHeight / gBase)
        local tTotal = math.clamp(tNatural, 0.16, 0.32) -- 快速弹射的时间范围
        local gEff = 2 * dropHeight / (tTotal * tTotal)

        -- 为了在 tTotal 时间内走完位移，计算水平速度（严格沿水平 forward/side 合成方向）
        local totalForwardDisp = forwardUnit * preOffset + sideUnit * sideOffset
        local vForward = totalForwardDisp / tTotal

        -- 在前向弹射阶段启用拖尾，完成后关闭
        local trail = ensureDropTrail(model)
        if trail then trail.Enabled = true end

        -- 用 NumberValue 驱动时间参数（0→tTotal），保证 Completed 可用
        local alpha = Instance.new("NumberValue")
        alpha.Value = 0
        local tw = TweenService:Create(alpha, TweenInfo.new(tTotal, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Value = tTotal })

        -- 函数级注释：在 alpha 变化时，按物理近似计算当前位置并设置模型 Pivot
        -- @param currT number 当前时间（秒），范围 [0,tTotal]
        -- @return void
        local conn = alpha.Changed:Connect(function(currT)
            currT = math.clamp(currT, 0, tTotal)
            local forwardOffset = vForward * currT
            local verticalOffset = Vector3.new(0, -0.5 * gEff * (currT * currT), 0)
            local pos = startPos + forwardOffset + verticalOffset
            model:PivotTo(CFrame.new(pos))
        end)

        tw.Completed:Connect(function()
            conn:Disconnect()
            alpha:Destroy()
            -- 收尾对齐到精确地面位置，避免数值误差
            print("Start pos:", model:GetPivot().Position)
            print("Align to ground:", groundPos)
            model:PivotTo(CFrame.new(groundPos))
            if trail then trail.Enabled = false end
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

        -- 在飞向玩家阶段启用拖尾，完成后关闭
        local trail2 = ensureDropTrail(model)
        if trail2 then trail2.Enabled = true end

        local tw = TweenService:Create(cfv, ti, { Value = CFrame.new(targetPos) })
        local conn = cfv.Changed:Connect(function(v)
            if typeof(v) == "CFrame" then
                model:PivotTo(v)
            end
        end)
        tw.Completed:Connect(function()
            conn:Disconnect()
            cfv:Destroy()
            if trail2 then trail2.Enabled = false end
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
    
    tweenScale(1.1, 0.02)
    tweenScale(1, 0.1)

    _tickets.Enabled = false
    task.delay(1.2, function()
        setEffectEnabled(false)
    end)
end

Knit.OnStart():andThen(function()
    Knit.GetController("UIController").RewardAction:Connect(function(rewards)
        local sound = Interface.safeWaitPart(treeModel, "DivineTreeSound")
        sound:Play()

        RewardAction(rewards)
    end)
    Knit.GetController("UIController").UpdateOfflineTime:Connect(function(offlineTime)
        UpdateOfflineTime(offlineTime)
    end)
end)
