local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Lighting = game:GetService("Lighting")

math.randomseed(os.time())

-- 初始化Knit框架
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"):WaitForChild("Knit"))
Knit.AddServices(ServerScriptService:WaitForChild("Services"))

-- 服务器启动状态标志
local isServerStarted = false

Knit.Start():andThen(function()
	-- Knit启动完成，标记服务器已启动
	isServerStarted = true
	print("服务器启动完成！")
end):catch(warn)

-- 时间系统配置
local _gameTime = 12 -- 游戏时间（小时，0-24）
local _lastUpdateTime = tick() -- 上次更新的真实时间
local Real_To_Game_Second = 288-- 现实1秒 = 游戏288秒

-- 时间系统更新函数
-- @param deltaTime number 距离上次更新的真实时间间隔（秒）
local function updateGameTime(deltaTime)
	-- 计算游戏时间增量（小时）
	local gameTimeIncrement = (deltaTime * Real_To_Game_Second) / 3600

	-- 更新游戏时间
	_gameTime = _gameTime + gameTimeIncrement

	-- 确保时间在0-24小时范围内循环
	if _gameTime >= 24 then
		_gameTime = _gameTime - 24
	elseif _gameTime < 0 then
		_gameTime = _gameTime + 24
	end

	-- 更新Lighting的ClockTime
	Lighting.ClockTime = _gameTime
end

---- 连接到Heartbeat事件进行实时更新
--game:GetService("RunService").Heartbeat:Connect(function(dt)
--	local currentTime = tick()
--	local deltaTime = currentTime - _lastUpdateTime

--	-- 更新游戏时间
--	updateGameTime(deltaTime)

--	-- 记录当前时间用于下次计算
--	_lastUpdateTime = currentTime
--end)

print("服务器JobID：", game.JobId)
print("服务器GameID：", game.GameId)
print("服务器PlaceID：", game.PlaceId)
print("服务器名称：", game.Name)
print("服务器PrivateServerId：", game.PrivateServerId)

-- 服务器启动状态检查事件
local serverStartCheckEvent = Instance.new("RemoteEvent")
serverStartCheckEvent.Name = "IsServerStartOver"
serverStartCheckEvent.Parent = ReplicatedStorage

-- 处理客户端的服务器启动状态查询
-- @param player Player 发送请求的玩家
serverStartCheckEvent.OnServerEvent:Connect(function(player)
	print("收到来自玩家 " .. player.Name .. " 的服务器启动状态查询")
	-- 向客户端发送服务器启动状态
	serverStartCheckEvent:FireClient(player, isServerStarted)
end)