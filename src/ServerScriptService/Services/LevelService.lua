-- LevelService 服务
-- 使用Knit框架管理服务器数据

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local DuanWeiType = {
    [1] = {
        name = "新手",
        levelNum = 2,           -- 当前段位里有几个级别
        levelStarNum = 3,       -- 每级别有多少星级
        allowDeduction = false,
    },
    [2] = {
        name = "幸存者",
        levelNum = 3,
        levelStarNum = 3,
        allowDeduction = false,
    },
    [3] = {
        name = "猎手",
        levelNum = 3,
        levelStarNum = 3,
        allowDeduction = false,
    },
    [4] = {
        name = "探索者",
        levelNum = 4,
        levelStarNum = 4,
        allowDeduction = true,
    },
    [5] = {
        name = "袭击者",
        levelNum = 5,
        levelStarNum = 5,
        allowDeduction = true,
    },
    [6] = {
        name = "大师",
        levelNum = 5,
        levelStarNum = 5,
        allowDeduction = true,
    },
    [7] = {
        name = "传奇",
        levelNum = -1,
        levelStarNum = -1,
        allowDeduction = true,
    },
}

local LevelService = Knit.CreateService {
	Name = "LevelService",
	Client = {
	},

    DuanWeiData = {},
}

function LevelService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function LevelService:KnitStart()
end

function LevelService:playerAdd(player, levelData)
    self.DuanWeiData[player.UserId].duanWei = levelData.duanWei or 1
    self.DuanWeiData[player.UserId].level = levelData.level or 1
    self.DuanWeiData[player.UserId].star = levelData.star or 0
end

function LevelService:playerRemoved(player)
    self.DuanWeiData[player.UserId] = nil
end

function LevelService:GetLevelData(player)
    return self.DuanWeiData[player.UserId]
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
    print("Updata", player.UserId, self.DuanWeiData[player.UserId].duanWei, self.DuanWeiData[player.UserId].level, self.DuanWeiData[player.UserId].star)
end

return LevelService