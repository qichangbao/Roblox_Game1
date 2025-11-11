
local QuestConfig = {}

QuestConfig.Data = {
    [1] = {
        QuestId = 40001,
        QuestName = "Monster Elimination Objective",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Eliminate specified monsters (Monster 30001 and Monster 30002) to complete this objective.",
        Type = 1,
        Preparation = {
            ItemId = 1011,
            Num = 1
        },
        Value = {
            {
                MonsterId = 30001,
                Num = 1
            },
            {
                MonsterId = 30002,
                Num = 1
            }
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 0,
    },
    [2] = {
        QuestId = 40002,
        QuestName = "Resource Gathering Objective",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Collect required items (Item 1001 and Item 1004) from the environment.",
        Type = 2,
        Preparation = {
            {
                ItemId = 201,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        Value = {
            {
                ItemId = 1001,
                Num = 1
            },
            {
                ItemId = 1004,
                Num = 1
            }
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 40001,
    },
    [3] = {
        QuestId = 40003,
        QuestName = "Secure Item Retrieval",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Retrieve specific item (Item 1001) from the designated location (X:50, Y:30, Z:100) within 10 units range.",
        Type = 3,
        Preparation = {
            ItemId = 203,
            Num = 4
        },
        Value = {
            ItemId = 1001,
            Num = 1,
            Pos = {
                X = 50,
                Y = 30,
                Z = 100
            },
            Range = 10,
            ChildType = 1
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 40002,
    },
    [4] = {
        QuestId = 40004,
        QuestName = "Strategic Item Placement",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Place or interact with item (Item 1001) at the specified coordinates (X:50, Y:30, Z:100).",
        Type = 4,
        Preparation = 0,
        Value = {
            ItemId = 1001,
            Num = 1,
            Pos = {
                X = 50,
                Y = 30,
                Z = 100
            },
            ChildType = 2
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 40003,
    },
    [5] = {
        QuestId = 40005,
        QuestName = "Reconnaissance Zone",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Reach and secure the designated area around coordinates (X:50, Y:30, Z:100) within 10 units radius.",
        Type = 5,
        Preparation = 0,
        Value = {
            Pos = {
                X = 50,
                Y = 30,
                Z = 100
            },
            Range = 10
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 40004,
    },
    [6] = {
        QuestId = 40006,
        QuestName = "Specialized Equipment Use",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Use specific item (Item 202) on target monster (Monster 30001) to complete the objective.",
        Type = 6,
        Preparation = {
            {
                ItemId = 201,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        Value = {
            {
                ItemId = 202,
                Num = 1
            },
            {
                MonsterId = 30001,
                Num = 1
            }
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 40005,
    },
    [7] = {
        QuestId = 40007,
        QuestName = "Combined Operations Mission",
        Map = "Dinosaur Island",
        NPC = "Captain",
        QuestDescription = "Complete multiple objectives: eliminate monsters (30001, 30002) and retrieve items from specified locations.",
        Type = 7,
        Preparation = {
            ItemId = 203,
            Num = 4
        },
        Value = {
            {
                Type = 1,
                Date = {
                    {
                        MonsterId = 30001,
                        Num = 1
                    },
                    {
                        MonsterId = 30002,
                        Num = 1
                    }
                }
            },
            {
                Type = 3,
                Date = {
                    ItemId = 1001,
                    Num = 1,
                    Pos = {
                        X = 50,
                        Y = 30,
                        Z = 100
                    },
                    Range = 10
                }
            }
        },
        RewardItem = {
            {
                ItemId = 1011,
                Num = 1
            },
            {
                ItemId = 1029,
                Num = 1
            }
        },
        PreQuestId = 40006,
    },
}

-- 辅助函数
function QuestConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByQuestId(value)
    for i, item in pairs(self.Data) do
        if item.QuestId == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByQuestName(value)
    for i, item in pairs(self.Data) do
        if item.QuestName == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByMap(value)
    for i, item in pairs(self.Data) do
        if item.Map == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByNPC(value)
    for i, item in pairs(self.Data) do
        if item.NPC == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByQuestDescription(value)
    for i, item in pairs(self.Data) do
        if item.QuestDescription == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByType(value)
    for i, item in pairs(self.Data) do
        if item.Type == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByPreparation(value)
    for i, item in pairs(self.Data) do
        if item.Preparation == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByValue(value)
    for i, item in pairs(self.Data) do
        if item.Value == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByRewardItem(value)
    for i, item in pairs(self.Data) do
        if item.RewardItem == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetByPreQuestId(value)
    for i, item in pairs(self.Data) do
        if item.PreQuestId == value then
            return item
        end
    end
    return nil
end

function QuestConfig:GetAll()
    return self.Data
end

function QuestConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

function QuestConfig:GetAllByType(itemType)
    local result = {}
    for i, item in pairs(self.Data) do
        if item.Type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

return QuestConfig