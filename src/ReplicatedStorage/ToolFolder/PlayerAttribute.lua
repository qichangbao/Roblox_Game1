local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local PlayerAttribute = {}

local function perCondition(player)
    local jobEffect = Interface.GetJobEffect(player)
    if not jobEffect then return end
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    return jobEffect
end

-- 获取玩家攻击力
function PlayerAttribute.GetAttack(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.Attack end
    local attribute = jobEffect.Attribute
    local attack = GameConfig.PlayerInitAttribute.Attack
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.Attack then
            attack += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.AttackPoint then
            attack *= (1 + effect.Value / 100)
        end
    end
    print("玩家攻击力", attack)
    return attack
end

-- 获取玩家最大生命值
function PlayerAttribute.GetMaxHealth(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.Health end
    local attribute = jobEffect.Attribute
    local maxHealth = GameConfig.PlayerInitAttribute.Health
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.Health then
            maxHealth += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.HealthPoint then
            maxHealth *= (1 + effect.Value / 100)
        end
    end
    print("玩家最大生命值", maxHealth)
    return maxHealth
end

-- 获取玩家行走速度
function PlayerAttribute.GetWalkSpeed(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.WalkSpeed end
    local attribute = jobEffect.Attribute
    local walkSpeed = GameConfig.PlayerInitAttribute.WalkSpeed
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.WalkSpeed then
            walkSpeed += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.WalkSpeedPoint then
            walkSpeed *= (1 + effect.Value / 100)
        end
    end
    print("玩家行走速度", walkSpeed)
    return walkSpeed
end

-- 获取玩家奔跑速度
function PlayerAttribute.GetRunSpeed(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.RunSpeed end
    local attribute = jobEffect.Attribute
    local runSpeed = GameConfig.PlayerInitAttribute.RunSpeed
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.WalkSpeed then
            runSpeed += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.WalkSpeedPoint then
            runSpeed *= (1 + effect.Value / 100)
        end
    end
    print("玩家奔跑速度", runSpeed)
    return runSpeed
end

-- 获取玩家跳跃高度
function PlayerAttribute.GetJumpPower(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.JumpPower end
    local attribute = jobEffect.Attribute
    local jumpPower = GameConfig.PlayerInitAttribute.JumpPower
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.JumpPower then
            jumpPower += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.JumpPowerPoint then
            jumpPower *= (1 + effect.Value / 100)
        end
    end
    print("玩家跳跃高度", jumpPower)
    return jumpPower
end

-- 获取玩家耐力
function PlayerAttribute.GetEndurance(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.Endurance end
    local attribute = jobEffect.Attribute
    local endurance = GameConfig.PlayerInitAttribute.Endurance
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.Endurance then
            endurance += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.EndurancePoint then
            endurance *= (1 + effect.Value / 100)
        end
    end
    print("玩家耐力", endurance)
    return endurance
end

-- 获取玩家负重
function PlayerAttribute.GetWeight(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.Weight end
    local attribute = jobEffect.Attribute
    local weight = GameConfig.PlayerInitAttribute.Weight
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.Weight then
            weight += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.WeightPoint then
            weight *= (1 + effect.Value / 100)
        end
    end
    print("玩家负重", weight)
    return weight
end

-- 获取玩家幸运值
function PlayerAttribute.GetLucky(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.Lucky end
    local attribute = jobEffect.Attribute
    local lucky = GameConfig.PlayerInitAttribute.Lucky
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.Lucky then
            lucky += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.LuckyPoint then
            lucky *= (1 + effect.Value / 100)
        end
    end
    print("玩家幸运值", lucky)
    return lucky
end

-- 获取玩家暴击概率
function PlayerAttribute.GetCriticalProbability(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.CriticalProbability end
    local attribute = jobEffect.Attribute
    local criticalProbability = GameConfig.PlayerInitAttribute.CriticalProbability
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.CriticalProbability then
            criticalProbability += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.CriticalProbabilityPoint then
            criticalProbability *= (1 + effect.Value / 100)
        end
    end
    print("玩家暴击概率", criticalProbability)
    return criticalProbability
end

-- 获取玩家暴击伤害
function PlayerAttribute.GetCriticalValue(player)
    local jobEffect = perCondition(player)
    if not jobEffect then return GameConfig.PlayerInitAttribute.CriticalValue end
    local attribute = jobEffect.Attribute
    local criticalValue = GameConfig.PlayerInitAttribute.CriticalValue
    local value = math.random(tonumber(criticalValue[1]), tonumber(criticalValue[2]))
    for _, effect in ipairs(attribute) do
        if effect.AttributeId == GameConfig.PlayerAttributeId.CriticalValue then
            value += effect.Value
        elseif effect.AttributeId == GameConfig.PlayerAttributeId.CriticalValuePoint then
            value *= (1 + effect.Value / 100)
        end
    end
    print("玩家暴击伤害", value)
    return value
end


return PlayerAttribute