local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local HeroConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("HeroConfig"))
local MonsterConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("MonsterConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local AttributeConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("AttributeConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local _camera = workspace.CurrentCamera
local _originalCameraType = _camera.CameraType
local _originalCameraSubject = _camera.CameraSubject
local _originalCameraCFrame = _camera.CFrame

local _jobsData = {}
local _curJobId = 0
local _selectItem = nil
local _curModel = nil

local _screenGui = script.Parent
_screenGui.Enabled = false
local _frame = _screenGui:WaitForChild("Frame")
local _closeButton = _frame:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
	_selectItem = nil
	_camera.CameraType = _originalCameraType
	_camera.CameraSubject = _originalCameraSubject
	_camera.CFrame = _originalCameraCFrame
end)
Interface.SetupHoverScale(_closeButton, _closeButton)

local _jobsFrame = _frame:WaitForChild("JobsFrame")
local _scrollingFrame = _jobsFrame:WaitForChild("ScrollingFrame")
local _templateFrame = _scrollingFrame:WaitForChild("TemplateFrame")
_templateFrame.Visible = false

local _infoFrame = _frame:WaitForChild("InfoFrame")
local _infoNameLabel = _infoFrame:WaitForChild("NameLabel")
local _infoModelDesFrame = _infoFrame:WaitForChild("ModelDesFrame")
local _infoModelDesLabel = _infoModelDesFrame:WaitForChild("DescriptionLabel")
Interface.SetupHoverScale(_infoModelDesFrame)
local _infoStarFrame = _infoFrame:WaitForChild("StarFrame")
local _attributeChild = {}
local _attributeFrame = _infoFrame:WaitForChild("AttributeFrame")
for i = 1, 3 do
	local frame = _attributeFrame:WaitForChild("Frame" .. i)
	Interface.SetupHoverScale(frame)
	local attributeNameLabel = frame:WaitForChild("NameLabel")
	local attributeLockImage = frame:WaitForChild("LockImage")
	table.insert(_attributeChild, {Frame = frame, NameLabel = attributeNameLabel, LockImage = attributeLockImage})
end

local _levelUpButton = _frame:WaitForChild("LevelUpButton")
_levelUpButton.MouseButton1Click:Connect(function()
	if not _selectItem.Name then return end
	Knit.GetService("JobService"):LevelUp(_selectItem.Name):andThen(function()

	end)
end)
local _levelUpGold = _levelUpButton:WaitForChild("TextLabel")
_levelUpGold.Text = ""
local _goldImage = _levelUpButton:WaitForChild("GoldImage")
_goldImage.Visible = false
local _robImage = _levelUpButton:WaitForChild("RobImage")
_robImage.Visible = false

local _unlockTextLabel = _frame:WaitForChild("UnlockTextLabel")
_unlockTextLabel.Text = ""

local _activeButton = _frame:WaitForChild("ActiveButton")
_activeButton.MouseButton1Click:Connect(function()
	if not _selectItem.Name then return end
	Knit.GetService("JobService"):ChangeJob(_selectItem.Name):andThen(function(isActive)
	end)
end)
local _activeTextLabel = _activeButton:WaitForChild("TextLabel")
_activeTextLabel.Text = ""

local function setActiveText(jobId)
	if _curJobId == 0 then
		_activeTextLabel.Text = "Activate"
	elseif _curJobId == jobId then
		_activeTextLabel.Text = "Deactivate"
	else
		_activeTextLabel.Text = "Activate"
	end
end

-- 为模型播放攻击与Idle循环动作
-- @param model Model 需要播放动作的模型
local function playPreviewAnimations(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local animationController = model:FindFirstChildOfClass("AnimationController")
	local animatorParent = humanoid or animationController
	if not animatorParent then
		return
	end

	local animator = animatorParent:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = animatorParent
	end

	local players = game:GetService("Players")
	local localPlayer = players.LocalPlayer
	if not localPlayer then
		return
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local animateScript = character:FindFirstChild("Animate")
	if not animateScript then
		return
	end

	local idleFolder = animateScript:FindFirstChild("idle")
	if not idleFolder then
		return
	end

	local sourceIdleAnimation = idleFolder:FindFirstChildOfClass("Animation")
	if not sourceIdleAnimation or not sourceIdleAnimation.AnimationId or sourceIdleAnimation.AnimationId == "" then
		return
	end

	local idleAnimation = Instance.new("Animation")
	idleAnimation.AnimationId = sourceIdleAnimation.AnimationId
	local idleTrack = animator:LoadAnimation(idleAnimation)
	idleTrack.Looped = true

	local attackAnimationIds = GameConfig.AnimationMap.swing

	task.spawn(function()
		while model.Parent do
			local attackIndex = math.random(1, #attackAnimationIds)
			local attackAnimation = Instance.new("Animation")
			attackAnimation.AnimationId = attackAnimationIds[attackIndex]
			local attackTrack = animator:LoadAnimation(attackAnimation)
			attackTrack.Looped = false
			attackTrack:Play()

			local attackFinished = false
			attackTrack.Stopped:Connect(function()
				attackFinished = true
			end)

			local elapsed = 0
			while not attackFinished and elapsed < (attackTrack.Length + 0.5) do
				if not model.Parent then
					return
				end
				local dt = task.wait(0.1)
				elapsed += dt
			end

			if not model.Parent then
				return
			end

			idleTrack:Play()
			local idleDuration = math.random(3, 5)
			local idleElapsed = 0
			while idleElapsed < idleDuration do
				if not model.Parent then
					idleTrack:Stop()
					return
				end
				local dt = task.wait(0.1)
				idleElapsed += dt
			end

			idleTrack:Stop()
		end
	end)
end

-- 更新展示模型并播放预览动作
-- @param config table 职业配置数据
local function updateModel(config)
	local modelFolder = ReplicatedStorage:FindFirstChild("JobModel")
	if not modelFolder then return end
	local model = modelFolder:FindFirstChild(config.Model)
	if not model then return end

	if _curModel then
		_curModel:Destroy()
		_curModel = nil
	end

	local newModel = model:Clone()
	newModel.Name = config.Model
	local cframe = model:GetAttribute("CFrame")
	newModel:PivotTo(cframe)
	newModel.Parent = workspace
	_curModel = newModel

	playPreviewAnimations(newModel)
end

local function updateInfo(config)
	_infoNameLabel.Text = config.Name
	_infoModelDesLabel.Text = config.HeroDesc
	local jobData = _jobsData[tostring(config.Id)]
	for i, v in ipairs(config.EffectAction) do
		local effectAction = Interface.Split(v, "_")
		local str = ""
		local effectType = tonumber(effectAction[1])
		if effectType == GameConfig.JobAttributeType.Attribute then
			local attribute = AttributeConfig:GetById(tonumber(effectAction[2]))
			if attribute.NumValueType == 1 then
				str = string.format("%s+%s", attribute.DisplayName, effectAction[3])
			else
				str = string.format("%s+%s%%", attribute.DisplayName, effectAction[3])
			end
		elseif effectType == GameConfig.JobAttributeType.FreeRelive then
			str = string.format("Free relive count +%s", effectAction[2])
		elseif effectType == GameConfig.JobAttributeType.DoubleDamage then
			local itemId = tonumber(effectAction[2])
			local item = ItemConfig:GetByItemId(itemId)
			str = string.format("Deal double damage when using %s", item and item.DisplayName or "unknown item")
		elseif effectType == GameConfig.JobAttributeType.KillMonsterDoubleDrop then
			str = "Killing monsters has a chance to trigger double drops"
		end

		local attributeFrame = _attributeChild[i]
		attributeFrame.LockImage.Visible = jobData and jobData.Level <= i and not jobData.IsFinished
		attributeFrame.NameLabel.Text = str
		if attributeFrame.LockImage.Visible then
			attributeFrame.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			attributeFrame.NameLabel.TextColor3 = Color3.fromRGB(116, 116, 116)
		else
			attributeFrame.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			attributeFrame.NameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		end
	end

	local level = jobData.Level or 1
	for j = 1, 6 do
		local star = _infoStarFrame:FindFirstChild(tostring(j))
		star.Visible = j <= config.Star[level]
	end

	if jobData.IsFinished then
		_levelUpButton.Visible = false
		_unlockTextLabel.Text = ""
	else
		_levelUpButton.Visible = true
		local upgradeCost = Interface.Split(config.UpgradeCost[level], "_")
		if tonumber(upgradeCost[1]) == GameConfig.JobUpgradeCost.Gold then
			_goldImage.Visible = true
			_robImage.Visible = false
		elseif tonumber(upgradeCost[1]) == GameConfig.JobUpgradeCost.RobCoins then
			_goldImage.Visible = false
			_robImage.Visible = true
		else
			return
		end
		_levelUpGold.Text = upgradeCost[2]

		local str = ""
		local unlock = Interface.Split(config.Unlock[level], "_")
		local unlockType = tonumber(unlock[1])
		if unlockType == GameConfig.JobUnlockCondition.Gold then
			str = string.format("收集金币 %s(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.IslandLevel then
			str = string.format("达到岛屿第 %s 关(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.Relive then
			str = string.format("复活 %s 次(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.Escape then
			str = string.format("撤离 %s 次(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.RobCoins then
			str = string.format("消耗罗布币 %s(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.DamageNoWeapon then
			str = string.format("对怪物造成 %s 伤害(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.DamageNoWeaponNum then
			str = string.format("对怪物造成 %s 次伤害(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		elseif unlockType == GameConfig.JobUnlockCondition.DamageMonster then
			local monsterInfo = MonsterConfig:GetByMonsterId(tonumber(unlock[2]))
			str = string.format("对%s造成 %s 伤害(%s/%s)", monsterInfo.DisplayName, unlock[3], jobData.Unlock, unlock[3])
		elseif unlockType == GameConfig.JobUnlockCondition.DamageMonsterNum then
			local monsterInfo = MonsterConfig:GetByMonsterId(tonumber(unlock[2]))
			str = string.format("对%s造成 %s 次伤害(%s/%s)", monsterInfo.DisplayName, unlock[3], jobData.Unlock, unlock[3])
		elseif unlockType == GameConfig.JobUnlockCondition.CollectItemNum then
			local itemInfo = ItemConfig:GetByItemId(tonumber(unlock[2]))
			str = string.format("收集%s %s 个(%s/%s)", itemInfo.DisplayName, unlock[3], jobData.Unlock, unlock[3])
		elseif unlockType == GameConfig.JobUnlockCondition.TreatmentItemNum then
			local itemInfo = ItemConfig:GetByItemId(tonumber(unlock[2]))
			str = string.format("用%s治疗 %s 次(%s/%s)", itemInfo.DisplayName, unlock[3], jobData.Unlock, unlock[3])
		elseif unlockType == GameConfig.JobUnlockCondition.SaveTeammateNum then
			str = string.format("救人 %s 次(%s/%s)", unlock[2], jobData.Unlock, unlock[2])
		end
		_unlockTextLabel.Text = str
	end
end

local function updateData(data)
	_jobsData = data

	local index = 1
	if _selectItem then
		index = _selectItem:GetAttribute("Index")
		_selectItem = nil
	end

	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(_scrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= _templateFrame then
			child:Destroy()
		end
	end

	local function changeSelect(item, config)
		if _selectItem then
			_selectItem.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			_selectItem:FindFirstChild("NameLabel").TextColor3 = Color3.fromRGB(156, 156, 156)
		end

		_selectItem = item
		_selectItem.BackgroundColor3 = Color3.fromRGB(141, 125, 136)
		_selectItem:FindFirstChild("NameLabel").TextColor3 = Color3.fromRGB(240, 240, 240)
		updateInfo(config)
		setActiveText(config.Id)
		updateModel(config)
	end

	for i, config in ipairs(HeroConfig:GetAll()) do
		local newFrame = _templateFrame:Clone()
		newFrame.Visible = true
		newFrame.Name = config.Id
		newFrame.Parent = _scrollingFrame
		newFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		newFrame:SetAttribute("Index", i)
		local nameLabel = newFrame:FindFirstChild("NameLabel")
		nameLabel.TextColor3 = Color3.fromRGB(156, 156, 156)
		nameLabel.Text = config.Name
		local imageLabel = newFrame:FindFirstChild("IconFrame"):FindFirstChild("ImageLabel")
		imageLabel.Image = config.Icon

		local textButton = newFrame:FindFirstChild("TextButton")
		textButton.MouseButton1Click:Connect(function()
			changeSelect(newFrame, config)
		end)

		Interface.SetupHoverScale(newFrame, textButton)

		local starFrame = newFrame:FindFirstChild("StarFrame")
		local jobData = _jobsData[tostring(config.Id)]
		local level = jobData.Level or 1
		for j = 1, 6 do
			local star = starFrame:FindFirstChild(tostring(j))
			star.Visible = j <= config.Star[level]
		end

		if i == index then
			changeSelect(newFrame, config)
		end
	end
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").UpdateJobData:Connect(function(data)
		if _screenGui.Enabled then
			updateData(_G.ClientData.JobData)
		end
	end)

	-- 监听服务器的发送当前职业ID请求
	Knit.GetController("UIController").ChangeCurJobId:Connect(function(jobId)
		_curJobId = jobId or 0
		setActiveText(_curJobId)
	end)

	Knit.GetController("UIController").ShowJobUI:Connect(function(type)
		_screenGui.Enabled = true
		_originalCameraType = _camera.CameraType
		_originalCameraSubject = _camera.CameraSubject
		_originalCameraCFrame = _camera.CFrame
		_camera.CameraType = Enum.CameraType.Scriptable
		local position = Vector3.new(36.052, 12.65, 148.988)
		local rotation = CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
		_camera.CFrame = CFrame.new(position) * rotation

		_selectItem = nil
		updateData(_G.ClientData.JobData)

		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)
