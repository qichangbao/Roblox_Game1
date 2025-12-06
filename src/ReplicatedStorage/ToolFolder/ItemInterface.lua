local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local WeaponConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("WeaponConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local ItemInterface = {}

-- 可视化检测区域（调试用）
-- @param cframe: 检测区域的CFrame
-- @param size: 检测区域的大小
local function _VisualizeDetectionArea(cframe, size)
	-- 创建可视化部件
	local visualPart = Instance.new("Part")
	visualPart.Name = "ToolDetectionArea"
	visualPart.Size = size
	visualPart.CFrame = cframe
	visualPart.Transparency = 0.7
	visualPart.Color = Color3.new(1, 0, 0) -- 红色
	visualPart.CanCollide = false
	visualPart.Anchored = true
	visualPart.Parent = workspace

	-- 0.2秒后移除可视化
	game:GetService("Debris"):AddItem(visualPart, 0.2)
end

local function _takeDamage(player, hitCharacter, damage)
    if not player or not hitCharacter or not player.Character or hitCharacter == player.Character then return end
    local sourceHumanoid = player.Character:FindFirstChild("Humanoid")
	if not sourceHumanoid then return end
	local targetHumanoid = hitCharacter:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then
		return false
	end

	local criticalProbability = Knit.GetService("PlayerService"):GetPlayerAttribute(player, "CriticalProbability") or 0
	local attack = sourceHumanoid:GetAttribute("Attack") or 1
	local humanoidType = hitCharacter:GetAttribute("HumanoidType")
	local normalDamage = damage * attack
	local isCrit = false
	local random = math.random(100)
	if random <= criticalProbability then			-- 暴击
		normalDamage = normalDamage * math.random(150, 250) % 100
		isCrit = true
	end
	if humanoidType == GameConfig.HumanoidType.Monster then
		Interface.decHp(hitCharacter, normalDamage, isCrit)
		if targetHumanoid.Health <= 0 then
            Knit.GetService("MonsterService"):KillMonster(player, hitCharacter)
		end
		return true
	elseif humanoidType == GameConfig.HumanoidType.Player then
		local isOnBoat = Interface.isPlayerOnBoat(player, Knit.GetService("IslandService"):GetIslandName())
		if isOnBoat then
			return
		end
		Interface.decHp(hitCharacter, normalDamage, isCrit)
    end
end

-- 执行区域检测
-- @param player: 使用工具的玩家
function ItemInterface.performAreaDetection(player, itemInfo, collisionCallback)
	local character = player.Character
	if not character then return false end
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	if not humanoidRootPart then return false end

	local curTool = nil
	for _, child in pairs(player.Character:GetChildren()) do
		if child:IsA("Tool") then
			curTool = child
			break
		end
	end
	
	if not curTool then
		return false
	end
	
	local handle = curTool:FindFirstChild("Handle")
	if not handle then
		warn("Tool没有Handle:", curTool.Name)
		return false
	end

	-- 计算检测区域（以角色为中心，向前方扩展）
	local centerPosition = humanoidRootPart.Position
	local lookDirection = humanoidRootPart.CFrame.LookVector

	local itemId = itemInfo.ItemId
	local weaponInfo = WeaponConfig:GetByItemId(itemId)
	-- 检测区域参数
	local detectionRange = weaponInfo.Position.X -- 检测距离
	local detectionWidth = weaponInfo.Position.Y -- 检测宽度
	local detectionHeight = weaponInfo.Position.Z -- 检测高度

	-- 计算检测区域的中心点（向前偏移）
	local detectionCenter = centerPosition + lookDirection * (detectionRange / 2)

	-- 创建检测区域的CFrame和大小
	local detectionCFrame = CFrame.lookAt(detectionCenter, detectionCenter + lookDirection)
	local detectionSize = Vector3.new(detectionWidth, detectionHeight, detectionRange)

	-- 使用GetPartBoundsInBox进行区域检测
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {character} -- 排除自己的角色

	local hitParts = workspace:GetPartBoundsInBox(detectionCFrame, detectionSize, overlapParams)

	-- 处理检测到的所有部件
	local processedObjects = {} -- 防止重复处理同一个对象

	for _, hit in ipairs(hitParts) do
		local hitParent = hit.Parent

		-- 避免重复处理同一个对象
		if hitParent and not processedObjects[hitParent] then
			processedObjects[hitParent] = true

			-- 处理碰撞
            if not _takeDamage(player, hitParent, weaponInfo.Damage) then
                if collisionCallback then
                    collisionCallback(player, hit, weaponInfo)
                end
            end
		end
	end

	-- 可视化检测区域（调试用，可选）
	if game:GetService("RunService"):IsStudio() then
		_VisualizeDetectionArea(detectionCFrame, detectionSize)
	end
	return true
end

return ItemInterface