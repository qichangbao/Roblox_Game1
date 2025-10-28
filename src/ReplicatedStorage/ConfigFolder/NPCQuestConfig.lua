
local NPCQuestConfig = {}

NPCQuestConfig.Data = {
    [1] = {
        QuestId = 1,
        DisplayName = "Tinker's Basics",
        QuestDescription = "The blacksmith needs some common scraps to practice his craft.",
        NeedItem = 1001,
        NeedNum = 1,
        RewardItem = 1004,
    },
    [2] = {
        QuestId = 2,
        DisplayName = "Beachcomber's Find",
        QuestDescription = "An old sailor pays for trinkets that remind him of the sea.",
        NeedItem = 1002,
        NeedNum = 1,
        RewardItem = 1018,
    },
    [3] = {
        QuestId = 3,
        DisplayName = "Ragged Supplies",
        QuestDescription = "The village doctor needs clean cloth and rope for bandages.",
        NeedItem = 1003,
        NeedNum = 1,
        RewardItem = 1005,
    },
    [4] = {
        QuestId = 4,
        DisplayName = "Clues from the Past",
        QuestDescription = "An archaeologist is piecing together evidence from a dig site.",
        NeedItem = 1004,
        NeedNum = 1,
        RewardItem = 1021,
    },
    [5] = {
        QuestId = 5,
        DisplayName = "Hidden Message",
        QuestDescription = "This old letter was hidden in a jar. Bring it to the scholar.",
        NeedItem = 1005,
        NeedNum = 1,
        RewardItem = 1023,
    },
    [6] = {
        QuestId = 6,
        DisplayName = "Pirate's Gear",
        QuestDescription = "The museum is collecting items for a new exhibit on pirates.",
        NeedItem = 1006,
        NeedNum = 1,
        RewardItem = 1024,
    },
    [7] = {
        QuestId = 7,
        DisplayName = "Taste of the East",
        QuestDescription = "An Eastern merchant is feeling homesick.",
        NeedItem = 1007,
        NeedNum = 1,
        RewardItem = 1014,
    },
    [8] = {
        QuestId = 8,
        DisplayName = "Traveler's Pack",
        QuestDescription = "An adventurer needs supplies for a long journey.",
        NeedItem = 1008,
        NeedNum = 1,
        RewardItem = 1028,
    },
    [9] = {
        QuestId = 9,
        DisplayName = "Carpenter's Aid",
        QuestDescription = "The carpenter ran out of wood and needs a pouch for his tools.",
        NeedItem = 1009,
        NeedNum = 1,
        RewardItem = 1006,
    },
    [10] = {
        QuestId = 10,
        DisplayName = "Masquerade",
        QuestDescription = "The grand ball is starting, but a guest is missing a costume!",
        NeedItem = 1010,
        NeedNum = 1,
        RewardItem = 1012,
    },
    [11] = {
        QuestId = 11,
        DisplayName = "Adventurer's Kit",
        QuestDescription = "No adventurer is complete without proper footwear and headwear.",
        NeedItem = 1011,
        NeedNum = 1,
        RewardItem = 4,
    },
    [12] = {
        QuestId = 12,
        DisplayName = "Engineer's Trinkets",
        QuestDescription = "An engineer collects old mechanical parts and protective gear.",
        NeedItem = 1012,
        NeedNum = 1,
        RewardItem = 1025,
    },
    [13] = {
        QuestId = 13,
        DisplayName = "Beastly Evidence",
        QuestDescription = "A biologist requests samples from a large, formidable beast.",
        NeedItem = 1013,
        NeedNum = 1,
        RewardItem = 1008,
    },
    [14] = {
        QuestId = 14,
        DisplayName = "Slime Research",
        QuestDescription = "The alchemist needs slime samples for his volatile experiments.",
        NeedItem = 1014,
        NeedNum = 1,
        RewardItem = 1017,
    },
    [15] = {
        QuestId = 15,
        DisplayName = "Sunken Treasure",
        QuestDescription = "Legends point to a captain's helmet and anchor from a famous shipwreck.",
        NeedItem = 1015,
        NeedNum = 1,
        RewardItem = 5,
    },
    [16] = {
        QuestId = 16,
        DisplayName = "Ancient Navigation",
        QuestDescription = "Learn the art of ancient seafaring with its key tools.",
        NeedItem = 1016,
        NeedNum = 1,
        RewardItem = 1030,
    },
    [17] = {
        QuestId = 17,
        DisplayName = "Warrior's Path",
        QuestDescription = "The weapon master says to master both the spear and the blade.",
        NeedItem = 1017,
        NeedNum = 1,
        RewardItem = 1029,
    },
    [18] = {
        QuestId = 18,
        DisplayName = "Dragon's Hoard",
        QuestDescription = "A single dragon orb is a start, but paired with a ruby, it's a real treasure.",
        NeedItem = 1018,
        NeedNum = 1,
        RewardItem = 1022,
    },
    [19] = {
        QuestId = 19,
        DisplayName = "Heart of the Ocean",
        QuestDescription = "These gems are the key to crafting a legendary piece of jewelry.",
        NeedItem = 1019,
        NeedNum = 1,
        RewardItem = 1015,
    },
    [20] = {
        QuestId = 20,
        DisplayName = "Fragmented History",
        QuestDescription = "Piece together clues from different eras.",
        NeedItem = 1020,
        NeedNum = 1,
        RewardItem = 1011,
    },
    [21] = {
        QuestId = 21,
        DisplayName = "Pirate's Legacy",
        QuestDescription = "Recreate the iconic look of a legendary sea rover.",
        NeedItem = 1021,
        NeedNum = 1,
        RewardItem = 1018,
    },
    [22] = {
        QuestId = 22,
        DisplayName = "Alchemist's Order",
        QuestDescription = "A large order of common materials for various potions.",
        NeedItem = 1022,
        NeedNum = 1,
        RewardItem = 8,
    },
    [23] = {
        QuestId = 23,
        DisplayName = "Sturdy Construction",
        QuestDescription = "These items are needed to build a solid foundation for a new shed.",
        NeedItem = 1023,
        NeedNum = 1,
        RewardItem = 1018,
    },
    [24] = {
        QuestId = 24,
        DisplayName = "Scholar's Research",
        QuestDescription = "The scholar needs artifacts from land, sea, and history for his thesis.",
        NeedItem = 1024,
        NeedNum = 1,
        RewardItem = 1031,
    },
    [25] = {
        QuestId = 25,
        DisplayName = "Message in a Bottle",
        QuestDescription = "The classic combination of a jar, a message, and a keepsake.",
        NeedItem = 1025,
        NeedNum = 1,
        RewardItem = 1029,
    },
    [26] = {
        QuestId = 26,
        DisplayName = "Eastern Merchant's Wares",
        QuestDescription = "A collection of fine goods from the Eastern lands.",
        NeedItem = 1026,
        NeedNum = 1,
        RewardItem = 1,
    },
    [27] = {
        QuestId = 27,
        DisplayName = "First Aid Kit",
        QuestDescription = "Compile a complete kit for treating wounds in the field.",
        NeedItem = 1027,
        NeedNum = 1,
        RewardItem = 1032,
    },
    [28] = {
        QuestId = 28,
        DisplayName = "Treasure Hunter's Clues",
        QuestDescription = "A map is useless without the tools to dig and a light to see.",
        NeedItem = 1028,
        NeedNum = 1,
        RewardItem = 3,
    },
    [29] = {
        QuestId = 29,
        DisplayName = "Gearwork Mechanism",
        QuestDescription = "These core components are needed to repair a complex clockwork device.",
        NeedItem = 1029,
        NeedNum = 1,
        RewardItem = 5,
    },
    [30] = {
        QuestId = 30,
        DisplayName = "Beast of Legend",
        QuestDescription = "Assemble the remains of a mythical creature for study.",
        NeedItem = 1030,
        NeedNum = 1,
        RewardItem = 5,
    },
}

-- 辅助函数
function NPCQuestConfig:GetByIndex(index)
    for i, item in pairs(self.Data) do
        if item.Index == index then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetByQuestId(value)
    for i, item in pairs(self.Data) do
        if item.QuestId == value then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetByDisplayName(value)
    for i, item in pairs(self.Data) do
        if item.DisplayName == value then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetByQuestDescription(value)
    for i, item in pairs(self.Data) do
        if item.QuestDescription == value then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetByNeedItem(value)
    for i, item in pairs(self.Data) do
        if item.NeedItem == value then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetByNeedNum(value)
    for i, item in pairs(self.Data) do
        if item.NeedNum == value then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetByRewardItem(value)
    for i, item in pairs(self.Data) do
        if item.RewardItem == value then
            return item
        end
    end
    return nil
end

function NPCQuestConfig:GetAll()
    return self.Data
end

function NPCQuestConfig:GetCount()
    local count = 0
    for _ in pairs(self.Data) do
        count = count + 1
    end
    return count
end

return NPCQuestConfig