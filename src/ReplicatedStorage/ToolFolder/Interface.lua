local Interface = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

--[[
    深拷贝函数 - 递归复制表结构
    @param original table 原始表
    @return table 深拷贝后的新表
]]
function Interface.clone(original)
    if type(original) ~= "table" then
        return original
    end
    
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = Interface.clone(value)
    end
    
    return copy
end

function Interface.formatTimeMMSS(seconds)
	seconds = math.max(0, math.floor(seconds))
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

--[[
    格式化金币数字显示 - 将大数字转换为简洁格式
    @param amount number 金币数量
    @return string 格式化后的字符串 (如: 10000 -> "10K", 1500000 -> "1.5M")
]]
function Interface.formatCurrency(amount)
    if type(amount) ~= "number" then
        return "0"
    end
    
    amount = math.floor(amount)
    
    if amount < 1000 then
        return tostring(amount)
    elseif amount < 1000000 then
        -- 千位显示 (K)
        local thousands = amount / 1000
        if thousands == math.floor(thousands) then
            return string.format("%.0fK", thousands)
        else
            return string.format("%.1fK", thousands)
        end
    elseif amount < 1000000000 then
        -- 百万位显示 (M)
        local millions = amount / 1000000
        if millions == math.floor(millions) then
            return string.format("%.0fM", millions)
        else
            return string.format("%.1fM", millions)
        end
    else
        -- 十亿位显示 (B)
        local billions = amount / 1000000000
        if billions == math.floor(billions) then
            return string.format("%.0fB", billions)
        else
            return string.format("%.1fB", billions)
        end
    end
end

-- 使用多层射线检测获取真正的地面位置
-- @param startPosition Vector3 起始位置
-- @param ignoreList table 忽略的实例列表
-- @return Vector3 地面位置，如果没有检测到则返回原位置
function Interface.getGroundPosition(startPosition, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    
    local currentPosition = startPosition
    local totalHeightDrop = 0
    local maxLayers = 5 -- 最多检测5层
    local minHeightDrop = 3 -- 最小高度差要求
    
    for layer = 1, maxLayers do
        -- 从当前位置向下发射射线
        local rayDirection = Vector3.new(0, -100, 0)
        local raycastResult = workspace:Raycast(currentPosition, rayDirection, raycastParams)
        
        if raycastResult then
            local hitPosition = raycastResult.Position
            local layerHeightDrop = currentPosition.Y - hitPosition.Y
            totalHeightDrop = totalHeightDrop + layerHeightDrop
            
            -- 检查是否是足够厚的地面
            if layerHeightDrop >= minHeightDrop and totalHeightDrop >= minHeightDrop then
                local groundPosition = hitPosition + Vector3.new(0, 0.1, 0)
                return groundPosition
            elseif layerHeightDrop < 0.5 then
                -- 击中了很薄的结构，继续向下检测
                currentPosition = hitPosition - Vector3.new(0, 0.1, 0) -- 稍微向下偏移继续检测
                
                -- 将击中的物体加入忽略列表，避免重复击中
                if raycastResult.Instance then
                    table.insert(raycastParams.FilterDescendantsInstances, raycastResult.Instance)
                end
            else
                -- 找到了有一定厚度的地面
                if totalHeightDrop >= minHeightDrop then
                    local groundPosition = hitPosition + Vector3.new(0, 0.1, 0)
                    return groundPosition
                else
                    -- 高度差不够，继续检测
                    currentPosition = hitPosition - Vector3.new(0, 0.1, 0)
                end
            end
        else
            -- 没有击中任何物体
            print("第", layer, "层未击中任何物体")
            break
        end
    end
    
    -- 所有检测都失败，返回一个安全的地面位置
    local safeGroundPosition = Vector3.new(startPosition.X, startPosition.Y - 10, startPosition.Z)
    return safeGroundPosition
end

--[[
    更精确的手机检测（推荐使用）
    结合多种因素判断，包括屏幕尺寸、安全区域、输入方式等
    @return boolean 如果是手机设备返回true，否则返回false
]]
function Interface.isMobile()
    if game:GetService("RunService"):IsStudio() then
        return true
    end
    -- 必须有触摸屏
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and
           not UserInputService.MouseEnabled then
        return true
    end
    return false
end

--[[
    安全等待子对象出现
    @param parent Instance 父对象
    @param child string 子对象名称
    @param time number 超时时间（秒），默认1秒
    @return Instance 子对象，如果超时返回nil
]]
function Interface.safeWaitPart(parent, childName, time)
    time = time or 1
    local child = parent:FindFirstChild(childName)
    while not child do
        task.wait(time)
        child = parent:FindFirstChild(childName)
    end
    return child
end

function Interface.GetDuanWeiIcon(duanweiData)
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
    local duanweiConfig = GameConfig.DuanWeiType[duanwei]
    if not duanweiConfig then
        return
    end
    return duanweiConfig.icons[level]
end

--[[
    计算 DuanWei 升级
    @param duanWeiData table DuanWei 数据
    @param escapeSucc boolean 是否成功逃脱
    @return table 更新后的 DuanWei 数据
]]
function Interface.calculateDuanWei(duanWeiData, escapeSucc)
    local tempData = Interface.clone(duanWeiData)
    local DuanWeiType = GameConfig.DuanWeiType
    if escapeSucc then
        tempData.star += 1
        -- 到达当前升级星数
        if tempData.star > DuanWeiType[tempData.duanWei].levelStarNum
        and DuanWeiType[tempData.duanWei].levelStarNum ~= -1 then
            tempData.level += 1
            tempData.star = 1
        end

        -- 到达当前升段位标准
        if tempData.level > DuanWeiType[tempData.duanWei].levelNum
        and DuanWeiType[tempData.duanWei].levelNum ~= -1 then
            tempData.duanWei = math.min(tempData.duanWei + 1, #DuanWeiType)
            tempData.level = 1
            tempData.star = 1
        end
    else
        if DuanWeiType[tempData.duanWei].allowDeduction then
            tempData.star = tempData.star - 1
            if tempData.star <= 0 then
                tempData.level = tempData.level - 1
                if tempData.level <= 0 then
                    if tempData.duanWei > 1 then
                        tempData.duanWei = tempData.duanWei - 1
                        tempData.level = DuanWeiType[tempData.duanWei].levelNum
                        tempData.star = DuanWeiType[tempData.duanWei].levelStarNum
                    else
                        tempData.duanWei = 1
                        tempData.level = 1
                        tempData.star = 0
                    end
                else
                    tempData.star = DuanWeiType[tempData.duanWei].levelStarNum
                end
            end
        end
    end

    return tempData
end

return Interface