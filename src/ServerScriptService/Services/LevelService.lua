-- LevelService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local DuanWeiType = {
    [1] = {
        name = "新手",
        levelNum = 2,           -- 当前段位里有几个级别
        levelStarNum = 3,       -- 每级别有多少星级
        icons = {
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
        },
        allowDeduction = false,
    },
    [2] = {
        name = "幸存者",
        levelNum = 3,
        levelStarNum = 3,
        icons = {
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
        },
        allowDeduction = false,
    },
    [3] = {
        name = "猎手",
        levelNum = 3,
        levelStarNum = 3,
        icons = {
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
        },
        allowDeduction = false,
    },
    [4] = {
        name = "探索者",
        levelNum = 4,
        levelStarNum = 4,
        icons = {
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
        },
        allowDeduction = true,
    },
    [5] = {
        name = "袭击者",
        levelNum = 5,
        levelStarNum = 5,
        icons = {
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
        },
        allowDeduction = true,
    },
    [6] = {
        name = "大师",
        levelNum = 5,
        levelStarNum = 5,
        icons = {
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
            "rbxassetid://1234567890",
        },
        allowDeduction = true,
    },
    [7] = {
        name = "传奇",
        levelNum = -1,
        levelStarNum = -1,
        icons = "rbxassetid://1234567890",
        allowDeduction = true,
    },
}

-- Billboard样式配置
local BILLBOARD_CONFIG = {
	Size = UDim2.new(4, 0, 0.8, 0),
	StudsOffset = Vector3.new(0, 2, 0),
	LightInfluence = 0,
	AlwaysOnTop = true,
}

local LevelService = Knit.CreateService {
	Name = "LevelService",
	Client = {
	},

    DuanWeiData = {},
}

local function GetDuanWeiIcon(duanweiData)
    if not duanweiData then
        return
    end
    local duanwei = tonumber(duanweiData.duanWei)
    if not duanwei then
        return
    end
    local level = tonumber(duanweiData.level)
    if not level then
        return
    end
    local duanweiConfig = DuanWeiType[duanwei]
    if not duanweiConfig then
        return
    end
    return duanweiConfig.icons[level]
end

function LevelService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function LevelService:KnitStart()
end

function LevelService:playerAdd(player, levelData)
    self.DuanWeiData[player.UserId] = {}
    self.DuanWeiData[player.UserId].duanWei = levelData.duanWei or 1
    self.DuanWeiData[player.UserId].level = levelData.level or 1
    self.DuanWeiData[player.UserId].star = levelData.star or 0
    self.DuanWeiData[player.UserId].duanWei = tonumber(self.DuanWeiData[player.UserId].duanWei)
    self.DuanWeiData[player.UserId].level = tonumber(self.DuanWeiData[player.UserId].level)
    self.DuanWeiData[player.UserId].star = tonumber(self.DuanWeiData[player.UserId].star)
    self:CreatePlayerBillboard(player)

    player.Chatted:Connect(function(message)
        local lowerMessage = string.lower(message)
        
        if lowerMessage == "add star" then
	        Knit.GetService("LevelService"):Updata(player, true)
            return true
        elseif lowerMessage == "dec star" then
	        Knit.GetService("LevelService"):Updata(player, false)
            return true
        end
        
        return false
    end)
end

function LevelService:playerRemoved(player)
    self.DuanWeiData[player.UserId] = nil
end

-- 从DataStoreService初始化玩家工具栏数据
function LevelService:InitPlayerLevel(player, toolStore)
	local userId = player.UserId
	self.DuanWeiData[userId] = {}

	if toolStore then
		self.DuanWeiData[userId].duanWei = toolStore.duanWei or 1
		self.DuanWeiData[userId].level = toolStore.level or 1
		self.DuanWeiData[userId].star = toolStore.star or 0
        self.DuanWeiData[player.UserId].duanWei = tonumber(self.DuanWeiData[player.UserId].duanWei)
        self.DuanWeiData[player.UserId].level = tonumber(self.DuanWeiData[player.UserId].level)
        self.DuanWeiData[player.UserId].star = tonumber(self.DuanWeiData[player.UserId].star)
	end
    self:UpdateBillboard(player)
end

function LevelService:GetLevelFromDBService(userId, value)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	self:InitPlayerLevel(player, value)
end

function LevelService:GetLevelData(player)
    return self.DuanWeiData[player.UserId]
end

function LevelService:GetLevelIcon(player)
    if not player or not player.UserId then
        return
    end

    local levelData = self.DuanWeiData[player.UserId]
    if not levelData then
        return
    end

    local duanwei = levelData.duanWei
    local level = levelData.level
    if not duanwei or not level then
        return
    end

    local duanweiConfig = DuanWeiType[duanwei]
    if not duanweiConfig then
        return
    end

    if duanweiConfig.levelNum == -1 then
        return duanweiConfig.icons
    end
    return duanweiConfig.icons[level]
end

function LevelService:Updata(player, escapeSucc)
    if escapeSucc then
        self.DuanWeiData[player.UserId].star += 1
        -- 到达当前升级星数
        if self.DuanWeiData[player.UserId].star > DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelStarNum
        and DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelStarNum ~= -1 then
            self.DuanWeiData[player.UserId].level += 1
            self.DuanWeiData[player.UserId].star = 1
        end

        -- 到达当前升段位标准
        if self.DuanWeiData[player.UserId].level > DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelNum
        and DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelNum ~= -1 then
            self.DuanWeiData[player.UserId].duanWei = math.min(self.DuanWeiData[player.UserId].duanWei + 1, #DuanWeiType)
            self.DuanWeiData[player.UserId].level = 1
            self.DuanWeiData[player.UserId].star = 1
        end
    else
        if DuanWeiType[self.DuanWeiData[player.UserId].duanWei].allowDeduction then
            self.DuanWeiData[player.UserId].star = self.DuanWeiData[player.UserId].star - 1
            if self.DuanWeiData[player.UserId].star <= 0 then
                self.DuanWeiData[player.UserId].level = self.DuanWeiData[player.UserId].level - 1
                if self.DuanWeiData[player.UserId].level <= 0 then
                    if self.DuanWeiData[player.UserId].duanWei > 1 then
                        self.DuanWeiData[player.UserId].duanWei = self.DuanWeiData[player.UserId].duanWei - 1
                        self.DuanWeiData[player.UserId].level = DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelNum
                        self.DuanWeiData[player.UserId].star = DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelStarNum
                    else
                        self.DuanWeiData[player.UserId].duanWei = 1
                        self.DuanWeiData[player.UserId].level = 1
                        self.DuanWeiData[player.UserId].star = 0
                    end
                else
                    self.DuanWeiData[player.UserId].star = DuanWeiType[self.DuanWeiData[player.UserId].duanWei].levelStarNum
                end
            end
        end
    end
    Knit.GetService("DBService"):Set(player.UserId, "DuanWeiData", self.DuanWeiData[player.UserId])
    self:UpdateBillboard(player)
    
    print("Updata", player.UserId, self.DuanWeiData[player.UserId].duanWei, self.DuanWeiData[player.UserId].level, self.DuanWeiData[player.UserId].star)
end

--[[
	创建玩家头顶Billboard
	@param player Player 玩家对象
	@return BillboardGui Billboard对象
]]
function LevelService:CreatePlayerBillboard(player)
    local duanweiData = self.DuanWeiData[player.UserId]
    if not duanweiData then
        return
    end
	-- 等待玩家角色加载
	local character = player.Character
	if not character then
		return
	end
	local head = character:WaitForChild("Head")
	if not head then
		return
	end
	
	-- 创建BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerInfoBillboard"
	billboard.Size = BILLBOARD_CONFIG.Size
	billboard.StudsOffset = BILLBOARD_CONFIG.StudsOffset
	billboard.LightInfluence = BILLBOARD_CONFIG.LightInfluence
	billboard.AlwaysOnTop = BILLBOARD_CONFIG.AlwaysOnTop
	billboard.ClipsDescendants = false -- 允许内容超出边界显示
	billboard.Parent = head
	
	-- 创建主框架
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = billboard
	
	-- 创建段位图标
	local rankIcon = Instance.new("ImageLabel")
	rankIcon.Name = "RankIcon"
	rankIcon.Size = UDim2.new(0.3, 0, 1, 0) -- 增大图标尺寸
	rankIcon.Position = UDim2.new(0, 0, 0, 0) -- 左侧固定位置，垂直居中
	rankIcon.BackgroundTransparency = 1
	rankIcon.Image = GetDuanWeiIcon(self.DuanWeiData[player.UserId])
	rankIcon.ScaleType = Enum.ScaleType.Fit
	rankIcon.ImageColor3 = Color3.fromRGB(255, 255, 255) -- 默认白色
	rankIcon.Parent = mainFrame
	
	-- 创建名字标签
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.65, 0, 1, 0) -- 为图标留出更多空间
	nameLabel.Position = UDim2.new(0.35, 0, 0, 0) -- 图标右侧位置
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.FontFace = GameConfig.FontFace
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left -- 左对齐
	nameLabel.Parent = mainFrame
	
	return billboard
end

function LevelService:UpdateBillboard(player)
    local duanweiData = self.DuanWeiData[player.UserId]
    if not duanweiData then
        return
    end
	-- 等待玩家角色加载
	local character = player.Character
	if not character then
		return
	end
	local head = character:WaitForChild("Head")
	if not head then
		return
	end
	local billboard = head:FindFirstChild("PlayerInfoBillboard")
	if not billboard then
		return
	end
	local rankIcon = billboard:FindFirstChild("RankIcon")
	if not rankIcon then
		return
	end
	rankIcon.Image = GetDuanWeiIcon(self.DuanWeiData[player.UserId])
end

return LevelService