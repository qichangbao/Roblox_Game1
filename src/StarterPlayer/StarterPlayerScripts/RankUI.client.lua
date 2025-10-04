local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local DataRetryUtil = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('DataRetryUtil'))

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

-- 根据排名设置前三名的字体颜色
local function applyRankColor(index, frame)
    local color = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 1
    if index == 1 then
        color = Color3.fromRGB(255, 215, 0)
        frame.BackgroundTransparency = 0.75
    elseif index == 2 then
        -- 与白色区分更明显：使用更深的灰银色
        color = Color3.fromRGB(160, 160, 160)
        frame.BackgroundTransparency = 0.75
    elseif index == 3 then
        color = Color3.fromRGB(205, 127, 50)
        frame.BackgroundTransparency = 0.75
    end
    frame.BackgroundColor3 = color
end

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
            local time = math.floor(data.totalTime / data.successNum)
            avg.Text = Interface.formatTimeMMSS(time)
        else
            avg.Text = "0"
        end
        local value = clone:FindFirstChild("value")
        value.Text = data.totalValue
        -- 设置前三名的字体颜色（金/银/橙铜）
        applyRankColor(index, clone)
    end
end

-- 更新玩家自己的数据
local function UpdatePlayerInfo(playerInfo)
	MeFrame.Visible = true
	MeName.Text = Players.LocalPlayer.Name
	if playerInfo.escapeActionsRank > 0 then
		MeNumber.Text = playerInfo.escapeActionsRank
	else
		MeNumber.Text = "Unranked"
	end
	MeActions.Text = playerInfo.escapeActions.successNum
	if playerInfo.escapeActions.successNum > 0 then
		local time = math.floor(playerInfo.escapeActions.totalTime / playerInfo.escapeActions.successNum)
		MeAvg.Text = Interface.formatTimeMMSS(time)
	else
		MeAvg.Text = "0"
	end
	MeValue.Text = playerInfo.escapeActions.totalValue
    -- 设置前三名的字体颜色（金/银/橙铜）
    applyRankColor(playerInfo.escapeActionsRank, MeFrame)
end

Knit.OnStart():andThen(function()
    local RankService = Knit.GetService("RankService")
	-- RankService.GetPersonalData():andThen(function(playerInfo)
	-- 	if playerInfo then
	-- 		task.spawn(function()
	-- 			UpdatePlayerInfo(playerInfo)
	-- 		end)
	-- 	end
	-- end)
	RankService.SendPersonalData:Connect(function(playerInfo)
		if playerInfo then
			task.spawn(function()
				UpdatePlayerInfo(playerInfo)
			end)
		end
	end)
    -- RankService.GetLeaderboard():andThen(function(rankData)
	-- 	if rankData then
	-- 		task.spawn(function()
	-- 			UpdataRankUI(rankData)
	-- 		end)
	-- 	end
	-- end)
	RankService.UpdateLeaderboard:Connect(function(rankData)
		task.spawn(function()
			UpdataRankUI(rankData)
		end)
	end)

    
    local KnitInitClient = require(script.Parent:WaitForChild("KnitInitClient"))
    KnitInitClient.AddListener(function()
        -- 使用通用重试工具获取排行榜数据
        DataRetryUtil.RetryDataFetch(
            function()
                return RankService.GetPersonalData()
            end,
            {
                maxRetries = 15,
                retryDelay = 2,
                operationName = "玩家数据获取",
                dataValidator = function(data)
                    return data and type(data) == "table" and data.escapeActionsRank ~= nil and data.escapeActions ~= nil
                end,
                onSuccess = function(data)
                    task.spawn(function()
                        UpdatePlayerInfo(data)
                    end)
                end,
                onFailure = function(errorMsg)
                    warn("玩家数据获取失败:", errorMsg)
                end
            }
        )

        -- 使用通用重试工具获取排行榜数据
        DataRetryUtil.RetryDataFetch(
            function()
                return RankService.GetLeaderboard()
            end,
            {
                maxRetries = 15,
                retryDelay = 2,
                operationName = "排行榜数据获取",
                dataValidator = function(data)
                    return data and type(data) == "table" and #data > 0
                end,
                onSuccess = function(data)
                    task.spawn(function()
                        UpdataRankUI(data)
                    end)
                end,
                onFailure = function(errorMsg)
                    warn("排行榜数据获取失败:", errorMsg)
                end
            }
        )
    end)
end)