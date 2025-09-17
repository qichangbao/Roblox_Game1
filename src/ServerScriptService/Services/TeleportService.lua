-- TeleportService 服务
-- 使用Knit框架管理位置触发传送系统

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local TeleportServiceModule = Knit.CreateService {
	Name = "TeleportService",
	Client = {
		-- 客户端远程信号：请求选择人数
		RequestPlayerCount = Knit.CreateSignal(),
	},
}

-- 触发区域状态数据
local triggerZoneStates = {}
local playerTriggered = {}

-- 在Part上方多少单位触发传送
local TRIGGER_HEIGHT_OFFSET = 5
local COUNTDOWN_DURATION = 15 -- 倒计时持续时间（秒）
local CREATE_COUNTDOWN_DURATION = 15 -- 创建倒计时持续时间（秒）

-- ReserveServer配置
local TARGET_PLACE_ID = 76972960957805  -- 目标传送场景ID（TestBoat_Fuben）

-- 检查是否在Studio环境中
-- @return boolean 是否在Studio环境
local function isInStudio()
	return RunService:IsStudio()
end

-- 记录详细日志的函数
-- @param level string 日志级别 (INFO, WARN, ERROR)
-- @param message string 日志消息
-- @param player Player 相关玩家（可选）
local function logMessage(level, message, player)
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local playerInfo = player and string.format(" [玩家:%s]", player.Name) or ""
	local logText = string.format("[%s] [%s]%s %s", timestamp, level, playerInfo, message)

	if level == "ERROR" then
		warn(logText)
	else
		warn(logText)
	end
end

-- 重置触发区域状态
-- @param modelName string 触发区域名称
-- @return void
local function resetTriggerZoneState(modelName)
	local zoneState = triggerZoneStates[modelName]
	if zoneState then
		zoneState.hasPlayerCountSelected = false
		zoneState.playersInZone = {}
		zoneState.requiredPlayerCount = 0
		zoneState.countdownTime = 0
		zoneState.isCountingDown = false
        zoneState.createCountdownTime = 0
		zoneState.isCreateCountingDown = false
	end
end

-- 初始化触发区域状态
-- @return void
local function initializeTriggerZoneStates()
	for _, modelName in ipairs(GameConfig.TeleportPartNames) do
        triggerZoneStates[modelName] = {}
		resetTriggerZoneState(modelName)
	end
end

local function getTriggerPart(modelName)
    local land = workspace:FindFirstChild(GameConfig.LandName)
    local triggerModel = land:FindFirstChild(modelName)
    if not triggerModel then
        return
    end

	local triggerPart = triggerModel:FindFirstChild("TriggerPart")
    if not triggerPart then
        return
    end
    return triggerPart
end

-- 检查玩家是否在任何触发Part的上方
-- @param player Player 要检查的玩家
-- @return boolean, BasePart 是否在触发范围内以及触发的Part
local function isPlayerInTriggerZone(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return false, nil
	end

	local playerPosition = player.Character.HumanoidRootPart.Position

	local land = workspace:FindFirstChild(GameConfig.LandName)
	if not land then
		logMessage("ERROR", string.format("未找到LandName: %s", GameConfig.LandName))
		return false, nil
	end
	-- 检查每个触发Part
	for _, modelName in ipairs(GameConfig.TeleportPartNames) do
		local triggerPart = getTriggerPart(modelName)
		if triggerPart then
			local partPosition = triggerPart.Position
			local partSize = triggerPart.Size

			-- 检查玩家是否在Part的X和Z范围内，且在Part上方指定高度内
			local xInRange = math.abs(playerPosition.X - partPosition.X) <= partSize.X / 2
			local zInRange = math.abs(playerPosition.Z - partPosition.Z) <= partSize.Z / 2
			local yAbovePart = playerPosition.Y >= partPosition.Y + partSize.Y / 2 and 
				playerPosition.Y <= partPosition.Y + partSize.Y / 2 + TRIGGER_HEIGHT_OFFSET

			if xInRange and zInRange and yAbovePart then
				return true, modelName
			end
		end
	end

	return false, nil
end

-- 获取触发区域内的实际玩家数量
-- @param partName string 触发区域名称
-- @return number 区域内的玩家数量
local function getPlayersCountInZone(modelName)
	local zoneState = triggerZoneStates[modelName]
	if not zoneState then return 0 end
	
	local count = 0
	for _, _ in pairs(zoneState.playersInZone) do
        count = count + 1
	end
	return count
end

-- 更新BillboardGui显示
-- @param modelName string 触发区域名称
-- @param playerCount number 当前玩家数量
-- @param maxCount number 最大允许玩家数量
local function updateBillboardGuiPlayerCount(modelName, playerCount, maxCount)
    local triggerPart = getTriggerPart(modelName)
    if triggerPart then
        local billboard = triggerPart:FindFirstChild("BillboardGui")
        if billboard then
            local frame = billboard:FindFirstChild("PlayerCountFrame")
            local textLabel = frame:FindFirstChild("TextLabel")
            textLabel.Text = string.format("%d/%d", playerCount, maxCount)
        end
    end
end

local function updateBillboardGuiCountdown(modelName, countdown)
    local triggerPart = getTriggerPart(modelName)
    if triggerPart then
        local billboard = triggerPart:FindFirstChild("BillboardGui")
        if billboard then
            local frame = billboard:FindFirstChild("TimeFrame")
			frame.Visible = true
            local textLabel = frame:FindFirstChild("TextLabel")
            textLabel.Text = countdown
        end
    end
end

-- 检查玩家位置并处理传送
-- @param player Player 要检查的玩家
-- @return void
local function checkPlayerPosition(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local userId = player.UserId
	-- 检查玩家是否在触发区域内
	local isInTrigger, modelName = isPlayerInTriggerZone(player)
	if isInTrigger then
        if playerTriggered[userId] then
            return
        end
        local partName = modelName
        local zoneState = triggerZoneStates[partName]
        if not zoneState then
            return
        end

        playerTriggered[userId] = true
        if not zoneState.playersInZone[userId]then
            -- 将玩家添加到区域内玩家列表
            zoneState.playersInZone[userId] = true
            -- 检查是否已选择人数
            local playerCount = getPlayersCountInZone(partName)
            if not zoneState.hasPlayerCountSelected and playerCount == 1 then
                -- 发送选择人数请求给客户端
                TeleportServiceModule.Client.RequestPlayerCount:Fire(player, partName)
            end
        end
	else
        if playerTriggered[userId] then
            playerTriggered[userId] = nil
        end
        -- 从所有区域的玩家列表中移除该玩家
        for partName, zoneState in pairs(triggerZoneStates) do
            if zoneState.playersInZone[userId] then
                zoneState.playersInZone[userId] = nil
                
			    local actualPlayerCount = getPlayersCountInZone(partName)
                -- 检查区域是否还有玩家，如果没有则重置状态
                if actualPlayerCount == 0 then
                    resetTriggerZoneState(partName)
                end
            end
        end
	end
end

-- 创建预留服务器副本
-- @param player Player 触发的玩家
-- @return string|nil 预留服务器访问码，失败时返回nil
local function createReserveServer()
	-- 创建预留服务器
	local success, result = pcall(function()
		-- 创建预留服务器访问码（使用目标场景ID）
		local accessCode = TeleportService:ReserveServer(TARGET_PLACE_ID)
		return accessCode
	end)

	if success and result then
		return result
	end

	logMessage("ERROR", string.format("预留服务器创建失败: %s", tostring(result)))
	return nil
end

-- 传送玩家到预留服务器副本
-- @param player Player 要传送的玩家
-- @return void
local function teleportToReserveServer(players)
    if isInStudio() then
        return
    end
    
	-- 创建预留服务器
	local accessCode = createReserveServer()
	if not accessCode then
		logMessage("ERROR", "无法创建预留服务器")
		return
	end

	-- 准备传送数据
	local teleportOptions = Instance.new("TeleportOptions")
	
	-- 收集所有玩家的工具数据
	local playersToolData = {}
	local InventoryService = Knit.GetService("InventoryService")
	
	for _, player in ipairs(players) do
		local toolData = InventoryService:GetToolData(player)
		if toolData then
			playersToolData[player.UserId] = toolData
		end
	end
	
	-- 将工具数据添加到传送选项中
	if next(playersToolData) then
		teleportOptions:SetTeleportData({
			PlayersToolData = playersToolData,
			TaskGold = 10000,
		})
		logMessage("INFO", string.format("已为 %d 个玩家准备工具数据传送", #players))
	end

	-- 执行传送到预留服务器
	local teleportSuccess, teleportError = pcall(function()
		TeleportService:TeleportAsync(
			TARGET_PLACE_ID,
			players,
			teleportOptions
		)
	end)

	if not teleportSuccess then
		logMessage("ERROR", string.format("传送到预留服务器失败: %s", tostring(teleportError)))
	end
end

-- 传送触发区域内的所有玩家
-- @param modelName string 触发区域名称
-- @return void
local function teleportAllPlayersInZone(modelName)
	local zoneState = triggerZoneStates[modelName]
	if not zoneState then
		logMessage("ERROR", string.format("未找到触发区域状态: %s", modelName))
		return
	end
	
	local playersToTeleport = {}
    local playerCount = 0
	
	-- 收集区域内的所有有效玩家
	for userId, _ in pairs(zoneState.playersInZone) do
		local player = Players:GetPlayerByUserId(userId)
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local isInTrigger, triggerModel = isPlayerInTriggerZone(player)
			if isInTrigger and triggerModel.Name == modelName then
                playerCount += 1
                if playerCount > zoneState.requiredPlayerCount then
                    break
                end
				table.insert(playersToTeleport, player)
			end
		end
	end
	
	-- 传送所有收集到的玩家
    teleportToReserveServer(playersToTeleport)
	
	-- 重置触发区域状态
	resetTriggerZoneState(modelName)
end

-- 初始化BillboardGui
local function initializeBillboad()
	local land = workspace:WaitForChild(GameConfig.LandName)
	if not land then
		return
	end
	-- 检查每个触发Part
	for _, partName in ipairs(GameConfig.TeleportPartNames) do
		local triggerModel = land:WaitForChild(partName)
		local triggerPart = triggerModel:WaitForChild("TriggerPart")
		local billboard = triggerPart:WaitForChild("BillboardGui")
		local frame = billboard:FindFirstChild("TimeFrame")
		frame.Visible = false
    end
end

-- 处理客户端选择人数响应
-- @param player Player 响应的玩家
-- @param partName string 触发区域名称
-- @param playerCount number 选择的人数
-- @return void
function TeleportServiceModule.Client:PlayerCountResponse(player, partName, playerCount)
	local zoneState = triggerZoneStates[partName]
	if not zoneState then
		logMessage("ERROR", string.format("未找到触发区域状态: %s", partName), player)
		return
	end
	
	-- 保存客户端响应的人数
	zoneState.requiredPlayerCount = playerCount
	zoneState.hasPlayerCountSelected = true
end

function TeleportServiceModule:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function TeleportServiceModule:KnitStart()
	-- 初始化触发区域状态
	initializeTriggerZoneStates()
    initializeBillboad()

    for _, player in pairs(Players:GetPlayers()) do
    end
	
	-- 监听玩家加入事件
	Players.PlayerAdded:Connect(function(player)
	end)

	-- 监听玩家离开事件
	Players.PlayerRemoving:Connect(function(player)
        playerTriggered[player.UserId] = nil
		-- 从所有触发区域中移除该玩家
		for partName, zoneState in pairs(triggerZoneStates) do
			if zoneState.playersInZone[player.UserId] then
				zoneState.playersInZone[player.UserId] = nil
				
				local actualPlayerCount = getPlayersCountInZone(partName)
				-- 检查区域是否还有玩家，如果没有则重置状态
				if actualPlayerCount == 0 then
					resetTriggerZoneState(partName)
				end
			end
		end
	end)

	-- 启动位置检测循环
	RunService.Heartbeat:Connect(function(dt)
		for _, player in pairs(Players:GetPlayers()) do
			checkPlayerPosition(player)
		end
		
		-- 检查所有触发区域的状态并更新Billboard GUI
		for modelName, zoneState in pairs(triggerZoneStates) do
			local actualPlayerCount = getPlayersCountInZone(modelName)
			
			-- 如果区域内有玩家
			if actualPlayerCount > 0 then
				if not zoneState.hasPlayerCountSelected then
					-- 玩家进入但还未选择人数，显示"创建中"
					updateBillboardGuiCountdown(modelName, "Creating")
                    if not zoneState.isCreateCountingDown then
                        zoneState.isCreateCountingDown = true
                        zoneState.createCountdownTime = CREATE_COUNTDOWN_DURATION
                    end
                    zoneState.createCountdownTime -= dt
                    local remainingTime = math.max(0, zoneState.createCountdownTime)
                    -- 检查倒计时是否结束
                    if remainingTime <= 0 then
                        for userId, _ in pairs(zoneState.playersInZone) do
                            local player = Players:GetPlayerByUserId(userId)
		                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local currentPos = player.Character:GetPivot().Position
								local triggerPart = getTriggerPart(modelName)
								if triggerPart then
									local targetZ = triggerPart.Position.Z - 10
									local newPos = Vector3.new(currentPos.X, currentPos.Y, targetZ)
									player.Character:PivotTo(CFrame.new(newPos))
								end
                            end
                        end
                    end
				else
					-- 已选择人数，显示人数信息
					updateBillboardGuiPlayerCount(modelName, actualPlayerCount, zoneState.requiredPlayerCount)
                    if not zoneState.isCountingDown then
                        zoneState.isCountingDown = true
                        zoneState.countdownTime = COUNTDOWN_DURATION
                    end
                    
                    -- 计算剩余时间并更新Billboard GUI倒计时显示
                    local timeScale = 1
                    if actualPlayerCount == zoneState.requiredPlayerCount then
                        timeScale = 5
                    end
                    zoneState.countdownTime -= dt * timeScale
                    local remainingTime = math.max(0, zoneState.countdownTime)
                    -- 检查倒计时是否结束
                    if remainingTime <= 0 then
					    updateBillboardGuiCountdown(modelName, "Transmitting")
                        teleportAllPlayersInZone(modelName)
                    else
                        updateBillboardGuiCountdown(modelName, math.ceil(remainingTime))
                    end
				end
			else
				-- 区域内没有玩家，隐藏Billboard GUI
				local triggerPart = getTriggerPart(modelName)
				if triggerPart then
					local billboard = triggerPart:FindFirstChild("BillboardGui")
					if billboard then
						local frame = billboard:FindFirstChild("TimeFrame")
						frame.Visible = false
					end
				end
			end
		end
	end)
end

return TeleportServiceModule