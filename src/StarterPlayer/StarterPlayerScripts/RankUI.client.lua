local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local InitLand = workspace:FindFirstChild("出生岛")
while not InitLand do
	task.wait(1)
	InitLand = workspace:FindFirstChild("出生岛")
end

local Rank = InitLand:WaitForChild("排行榜")
local RankPart = Rank:WaitForChild("RankPart")
local SrufaceGui = RankPart:WaitForChild("SurfaceGui")
local ContentFrame = SrufaceGui:WaitForChild("ContentFrame")
local ScrollingFrame = ContentFrame:WaitForChild("ScrollingFrame")
local Template = ScrollingFrame:WaitForChild("Template")
Template.Visible = false
local MeFrame = ContentFrame:WaitForChild("MeFrame")
MeFrame.Visible = false
local MeName = MeFrame:WaitForChild("name")
local MeActions = MeFrame:WaitForChild("actions")
local MeAvg = MeFrame:WaitForChild("avg")
local MeNumber = MeFrame:WaitForChild("number")
local MeValue = MeFrame:WaitForChild("value")

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
		avg.Text = string.format("%.2f", data.totalTime / data.successNum)
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
	MeAvg.Text = string.format("%.2f", playerInfo.escapeActions.totalTime / playerInfo.escapeActions.successNum)
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