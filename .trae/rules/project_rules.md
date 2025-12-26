用驼峰法命名规范，所有的变量、函数、类、文件等都用驼峰法命名。
模块内的变量用下划线开始命名，函数内的变量也用不要下划线。
参考下面示例：
local module = {}
local GameConfig = require(script.Parent.GameConfig)
local _jobData = {}
local function unlockJob(data, unlockType, unlock, jobValue)
    if unlockType == GameConfig.JobUnlockCondition.DamageMonster
    or unlockType == GameConfig.JobUnlockCondition.DamageMonsterNum then
        local monsterId = tonumber(unlock[2])
        if monsterId == jobValue.monsterId then
            data.Unlock += jobValue.count
        end
    elseif unlockType == GameConfig.JobUnlockCondition.CollectItemNum then
        local itemId = tonumber(unlock[2])
        if itemId == jobValue.itemId then
            data.Unlock += jobValue.count
        end
    else
        data.Unlock += jobValue
    end
end

function module:UnlockJob(data, unlockType, unlock, jobValue)
    unlockJob(data, unlockType, unlock, jobValue)
end

return module
