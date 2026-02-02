local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local DesignConfig = require(ReplicatedStorage:WaitForChild('ConfigFolder'):WaitForChild('DesignConfig'))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local TweenInterface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('TweenInterface'))
local localPlayer = game:GetService("Players").LocalPlayer

local TRIGGER_HEIGHT_OFFSET = 5
local NORMAL_COLOR = Color3.fromRGB(25, 123, 134)
local SELECT_COLOR = Color3.fromRGB(14, 66, 72)

local _selectChild = nil
local _curModelName = nil

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ChoosePeopleNumUI")
_screenGui.Enabled = false
local _frame = _screenGui:WaitForChild("Frame")
local _buttonsFrame = _frame:WaitForChild("ButtonsFrame")

local function Reset()
	_selectChild = nil
	_curModelName = nil
	
	for i, child in _buttonsFrame:GetChildren() do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = NORMAL_COLOR
		end
	end
end

local function close()
	Reset()
	_screenGui.Enabled = false
end
close()

for i, child in _buttonsFrame:GetChildren() do
	if child:IsA("TextButton") then
		child.MouseButton1Click:Connect(function()
			if _selectChild then
				_selectChild.BackgroundColor3 = NORMAL_COLOR
			end
			child.BackgroundColor3 = SELECT_COLOR
			_selectChild = child
		end)
		TweenInterface.SetupHoverScale(child, child)
	end
end

local _imageLabel = _frame:WaitForChild("ImageLabel")
local _closeButton = _imageLabel:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	close()
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local createButton = _frame:WaitForChild("CreateButton")
createButton.MouseButton1Click:Connect(function()
	if not _selectChild then
		return
	end
	-- 这里可以添加后续逻辑，比如将选择结果发送到服务器
	local TeleportService = Knit.GetService("TeleportService")
	TeleportService.PlayerCountResponse(game.Players.LocalPlayer, _curModelName, _selectChild:GetAttribute("Count"))
	
	close()
end)
TweenInterface.SetupHoverScale(createButton, createButton)

-- 检查玩家是否在任何触发Part的上方
local function isPlayerInTriggerZone(modelName)
	if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
	local island = workspace:WaitForChild(tostring(GameConfig.IslandId))
	if not island then return false end
	local special = island:WaitForChild("Special")
	if not special then return false end
	local teleport = special:WaitForChild("Teleport")
	if not teleport then return false end
	local triggerModel = teleport:FindFirstChild(modelName)
	if not triggerModel then return false end
	
	local playerPosition = localPlayer.Character.HumanoidRootPart.Position
	local triggerPart = triggerModel:FindFirstChild("TriggerPart")
	if triggerPart then
		local partPosition = triggerPart.Position
		local partSize = triggerPart.Size

		-- 检查玩家是否在Part的X和Z范围内，且在Part上方指定高度内
		local xInRange = math.abs(playerPosition.X - partPosition.X) <= partSize.X / 2
		local zInRange = math.abs(playerPosition.Z - partPosition.Z) <= partSize.Z / 2
		local yAbovePart = playerPosition.Y >= partPosition.Y + partSize.Y / 2 and 
			playerPosition.Y <= partPosition.Y + partSize.Y / 2 + TRIGGER_HEIGHT_OFFSET

		if xInRange and zInRange and yAbovePart then
			return true
		end
	end

	return false
end

game:GetService("RunService").Heartbeat:Connect(function()
	if not _screenGui.Enabled or not _curModelName then
		return
	end
	
	if not isPlayerInTriggerZone(_curModelName) then
		close()
	end
end)

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").ShowChoosePeopleNumUI:Connect(function(modelName)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_curModelName = modelName

		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)