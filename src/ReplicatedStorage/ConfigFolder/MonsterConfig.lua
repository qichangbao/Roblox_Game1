
local MonsterConfig = {}

MonsterConfig.Data = {
    [1] = {
        MonsterId = 30001,
        Name = "wolf",
        DisplayName = "wolf",
        Model = "wolf",
        Type = 1,
        HP = 50,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        Attack = 30,
        MoveSpeed = 15,
        AttackSpeed = 3.5,
        DropPlanId = 5011,
        AnimationIdle = 86165926642946,
        AnimationRun = 102675215328247,
        AnimationAttack = 91758031306128,
        AnimationDeath = 118554650060974,
    },
    [2] = {
        MonsterId = 30002,
        Name = "culuflu",
        DisplayName = "culuflu",
        Model = "culuflu",
        Type = 1,
        HP = 70,
        VisionRange = 30,
        AttackRange = 5,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        Attack = 10,
        MoveSpeed = 15,
        AttackSpeed = 1.5,
        DropPlanId = 5012,
        AnimationIdle = 114563261272011,
        AnimationRun = 138867349575521,
        AnimationAttack = 98792934038893,
        AnimationDeath = 122311177197535,
    },
    [3] = {
        MonsterId = 30003,
        Name = "dinosaur",
        DisplayName = "dinosaur",
        Model = "dinosaur",
        Type = 1,
        HP = 200,
        VisionRange = 100,
        AttackRange = 20,
        PatrolRadius = 30,
        MaxDisForSpawn = 100,
        RespawnTime = 0,
        Attack = 80,
        MoveSpeed = 15,
        AttackSpeed = 5.5,
        DropPlanId = 5010,
        AnimationIdle = 127174947382589,
        AnimationRun = 102931343411723,
        AnimationAttack = 86582808256856,
        AnimationDeath = 140562207405408,
    },
}

-- 辅助函数
function MonsterConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByMonsterId(value)
    for i, item in pairs(self.Data) do
        if item.MonsterId == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByName(value)
    for i, item in pairs(self.Data) do
        if item.Name == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByModel(value)
    for i, item in pairs(self.Data) do
        if item.Model == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByHP(value)
    for i, item in pairs(self.Data) do
        if item.HP == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByVisionRange(value)
    for i, item in pairs(self.Data) do
        if item.VisionRange == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAttackRange(value)
    for i, item in pairs(self.Data) do
        if item.AttackRange == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByPatrolRadius(value)
    for i, item in pairs(self.Data) do
        if item.PatrolRadius == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByMaxDisForSpawn(value)
    for i, item in pairs(self.Data) do
        if item.MaxDisForSpawn == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByRespawnTime(value)
    for i, item in pairs(self.Data) do
        if item.RespawnTime == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAttack(value)
    for i, item in pairs(self.Data) do
        if item.Attack == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByMoveSpeed(value)
    for i, item in pairs(self.Data) do
        if item.MoveSpeed == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAttackSpeed(value)
    for i, item in pairs(self.Data) do
        if item.AttackSpeed == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByDropPlanId(value)
    for i, item in pairs(self.Data) do
        if item.DropPlanId == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAnimationIdle(value)
    for i, item in pairs(self.Data) do
        if item.AnimationIdle == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAnimationRun(value)
    for i, item in pairs(self.Data) do
        if item.AnimationRun == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAnimationAttack(value)
    for i, item in pairs(self.Data) do
        if item.AnimationAttack == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetByAnimationDeath(value)
    for i, item in pairs(self.Data) do
        if item.AnimationDeath == value then
            return item
        end
    end
    return nil
end

function MonsterConfig:GetAll()
    return self.Data
end

function MonsterConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function MonsterConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return MonsterConfig