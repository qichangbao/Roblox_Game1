local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local TweenInterface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('TweenInterface'))
local Players = game:GetService("Players")

local _curItemIndex = nil
local _curAssetID = nil
local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PlayerListUI")
local _frame = _screenGui:WaitForChild("Frame")
local _scrollingFrame = _frame:WaitForChild("ScrollingFrame")
local _normalFrame = _scrollingFrame:WaitForChild("NormalFrame")
_normalFrame.Visible = false

local _titleImage = _frame:WaitForChild("TitleImage")
local _closeButton = _titleImage:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
	_curItemIndex = nil
	_curAssetID = nil
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local function updatePlayerList()
	task.spawn(function()
		-- 清空现有物品槽（保留模板）
		for _, child in ipairs(_scrollingFrame:GetChildren()) do
			if child:IsA('Frame') and child ~= _normalFrame then
				child:Destroy()
			end
		end

		for i, player in ipairs(Players:GetPlayers()) do
			if player.UserId == Players.LocalPlayer.UserId then
				continue
			end
			local name = player.Name
			local newFrame = _normalFrame:Clone()
			newFrame.Name = player.Name
			newFrame.Visible = true
			newFrame.Parent = _scrollingFrame

			local nameLabel = newFrame:FindFirstChild("InfoFrame"):FindFirstChild("NameLabel")
			nameLabel.Text = player.Name

			local nameButton = newFrame:FindFirstChild("NameButton")
			nameButton.MouseButton1Click:Connect(function()
				Knit.GetService("StoreService"):RobBuyItem(_curItemIndex, _curAssetID, player.UserId):andThen(function(succ)
					print("购买商品 ", player.Name, succ)
				end)
			end)
			TweenInterface.SetupHoverScale(nameButton, nameButton)
		end
	end)
end

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").ShowPlayerListUI:Connect(function(itemIndex, assetID)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_scrollingFrame.CanvasPosition = Vector2.new(0, 0)

		_curItemIndex = itemIndex
		_curAssetID = assetID
		
		updatePlayerList()

		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
	
	-- 监听玩家加入事件
	Players.PlayerAdded:Connect(function(player)
		updatePlayerList()
	end)

	-- 监听玩家离开事件
	Players.PlayerRemoving:Connect(function(player)
		updatePlayerList()
	end)
end)