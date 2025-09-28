local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local InitLand = Interface.safeWaitPart(workspace, "出生岛")
local SpecialFolder = Interface.safeWaitPart(InitLand, "Special")
local RankFolder = Interface.safeWaitPart(SpecialFolder, "Rank")
local Rank = Interface.safeWaitPart(RankFolder, "排行榜")
local RankPart = Interface.safeWaitPart(Rank, "RankPart")
local SrufaceGui = Interface.safeWaitPart(RankPart, "SurfaceGui")
local ContentFrame = Interface.safeWaitPart(SrufaceGui, "ContentFrame")
local ScrollingFrame = Interface.safeWaitPart(ContentFrame, "ScrollingFrame")
local Template = Interface.safeWaitPart(ScrollingFrame, "Template")
Template.Visible = false
local MeFrame = Interface.safeWaitPart(ContentFrame, "MeFrame")
MeFrame.Visible = false
local MeName = Interface.safeWaitPart(MeFrame, "name")
local MeActions = Interface.safeWaitPart(MeFrame, "actions")
local MeAvg = Interface.safeWaitPart(MeFrame, "avg")
local MeNumber = Interface.safeWaitPart(MeFrame, "number")
local MeValue = Interface.safeWaitPart(MeFrame, "value")

local function UpdataRankUI(rankData)
	-- 清空现有物品槽（保留模板）
	for _, child in ipairs(ScrollingFrame:GetChildren()) do
		if child:IsA('Frame') and child ~= Template then
			child:Destroy()
		end
	end

	for index, data in ipairs(rankData) do
		local clone = Template:Clone()
		clone.Visible = true
		clone.Name = "Rank" .. index
		clone.Parent = ScrollingFrame

		local number = clone:FindFirstChild("number")
		number.Text = index
		local name = clone:FindFirstChild("name")
		name.Text = data.playerName
		local actions = clone:FindFirstChild("actions")
		actions.Text = data.successNum
		local avg = clone:FindFirstChild("avg")
		if data.successNum > 0 then
			avg.Text = string.format("%.2f", data.totalTime / data.successNum)
		else
			avg.Text = "0"
		end
		local value = clone:FindFirstChild("value")
		value.Text = data.totalValue
	end
end

-- 更新玩家自己的数据
local function UpdatePlayerInfo(playerInfo)
	MeFrame.Visible = true
	MeName.Text = Players.LocalPlayer.Name
	MeNumber.Text = playerInfo.escapeActionsRank
	MeActions.Text = playerInfo.escapeActions.successNum
	if playerInfo.escapeActions.successNum > 0 then
		MeAvg.Text = string.format("%.2f", playerInfo.escapeActions.totalTime / playerInfo.escapeActions.successNum)
	else
		MeAvg.Text = "0"
	end
	MeValue.Text = playerInfo.escapeActions.totalValue
end

Knit.OnStart():andThen(function()
	Knit.GetService("RankService").GetPersonalData():andThen(function(playerInfo)
		if playerInfo then
			task.spawn(function()
				UpdatePlayerInfo(playerInfo)
			end)
		end
	end)
	Knit.GetService("RankService").SendPersonalData:Connect(function(playerInfo)
		if playerInfo then
			task.spawn(function()
				UpdatePlayerInfo(playerInfo)
			end)
		end
	end)
	Knit.GetService("RankService").UpdateLeaderboard:Connect(function(rankData)
		task.spawn(function()
			UpdataRankUI(rankData)
		end)
	end)
end)