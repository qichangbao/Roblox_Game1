
local MonsterConfig = {}

MonsterConfig.Data = {
    [1] = {
        MonsterId = 30001,
        Name = "狼人",
        DisplayName = "Wolf",
        Model = "wolf",
        Type = 1,
        HP = 50,
        Attack = 5,
        AttackSpeed = 0.8,
        MoveSpeed = 17,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 401,
        AnimationIdle = "86165926642946",
        AnimationRun = "102675215328247",
        AnimationAttack = "91758031306128",
        AnimationDeath = "118554650060974",
    },
    [2] = {
        MonsterId = 30002,
        Name = "野人",
        DisplayName = "Culuflu",
        Model = "culuflu",
        Type = 1,
        HP = 60,
        Attack = 7,
        AttackSpeed = 0.8,
        MoveSpeed = 18,
        VisionRange = 30,
        AttackRange = 5,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 402,
        AnimationIdle = "114563261272011",
        AnimationRun = "138867349575521",
        AnimationAttack = "98792934038893",
        AnimationDeath = "122311177197535",
    },
    [3] = {
        MonsterId = 30003,
        Name = "恐龙",
        DisplayName = "Dinosaur",
        Model = "dinosaur",
        Type = 1,
        HP = 150,
        Attack = 40,
        AttackSpeed = 2,
        MoveSpeed = 16,
        VisionRange = 100,
        AttackRange = 20,
        PatrolRadius = 30,
        MaxDisForSpawn = 100,
        RespawnTime = 0,
        DropPlanId = 403,
        AnimationIdle = "127174947382589",
        AnimationRun = "102931343411723",
        AnimationAttack = "86582808256856",
        AnimationDeath = "140562207405408",
    },
    [4] = {
        MonsterId = 30004,
        Name = "蝙蝠",
        DisplayName = "Bat",
        Model = "bat",
        Type = 1,
        HP = 50,
        Attack = 10,
        AttackSpeed = 1.5,
        MoveSpeed = 16,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 404,
        AnimationIdle = "93689641627662",
        AnimationRun = "82748594296370",
        AnimationAttack = "122008306800781",
        AnimationDeath = "80836640366389",
    },
    [5] = {
        MonsterId = 30005,
        Name = "蜘蛛",
        DisplayName = "Spider",
        Model = "spider",
        Type = 1,
        HP = 50,
        Attack = 10,
        AttackSpeed = 1.5,
        MoveSpeed = 16,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 404,
        AnimationIdle = "104063481809103",
        AnimationRun = "77248939202584",
        AnimationAttack = "136825612816422",
        AnimationDeath = "72430363791725",
    },
    [6] = {
        MonsterId = 30006,
        Name = "木乃伊",
        DisplayName = "Mummy",
        Model = "mummy",
        Type = 1,
        HP = 50,
        Attack = 10,
        AttackSpeed = 1.5,
        MoveSpeed = 16,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 404,
        AnimationIdle = "123483356813479",
        AnimationRun = "100138602451126",
        AnimationAttack = "137201071116707",
        AnimationDeath = "111162934278951",
    },
    [7] = {
        MonsterId = 30007,
        Name = "死亡法师",
        DisplayName = "DeathMage",
        Model = "deathmage",
        Type = 1,
        HP = 50,
        Attack = 10,
        AttackSpeed = 1.5,
        MoveSpeed = 16,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 404,
        AnimationIdle = "127803374573095",
        AnimationRun = "110813035692815",
        AnimationAttack = "110539601472559",
        AnimationDeath = "109400606566569",
    },
    [8] = {
        MonsterId = 30008,
        Name = "死神",
        DisplayName = "Death",
        Model = "death",
        Type = 1,
        HP = 50,
        Attack = 20,
        AttackSpeed = 1.5,
        MoveSpeed = 16,
        VisionRange = 30,
        AttackRange = 10,
        PatrolRadius = 15,
        MaxDisForSpawn = 30,
        RespawnTime = 0,
        DropPlanId = 404,
        AnimationIdle = "94726843506058",
        AnimationRun = "79617787051529",
        AnimationAttack = "140345455836615",
        AnimationDeath = "113366688881875",
    },
    [9] = {
        MonsterId = 30009,
        Name = "宝箱怪",
        DisplayName = "Chest",
        Model = "chest1",
        Type = 2,
        HP = 50,
        Attack = 5,
        AttackSpeed = 1.5,
        MoveSpeed = 0,
        VisionRange = 0,
        AttackRange = 10,
        PatrolRadius = 0,
        MaxDisForSpawn = 0,
        RespawnTime = 0,
        DropPlanId = 404,
        AnimationIdle = "118247989320995",
        AnimationRun = "135561101666772",
        AnimationAttack = "126571831119721",
        AnimationDeath = "115914249595193",
    },
}

-- 辅助函数
function MonsterConfig:GetByIndex(index)
    return self.Data[index]
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

function MonsterConfig:GetByAttack(value)
    for i, item in pairs(self.Data) do
        if item.Attack == value then
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

function MonsterConfig:GetByMoveSpeed(value)
    for i, item in pairs(self.Data) do
        if item.MoveSpeed == value then
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