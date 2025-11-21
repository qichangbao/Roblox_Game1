local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local SimpleArrowNavigation = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("SimpleArrowNavigation"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))
local TalentTreeConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("TalentTreeConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local Module = {}

local function findNpc3()
    local island = Interface.safeWaitPart(workspace, GameConfig.LandName)
    local Special = Interface.safeWaitPart(island, "Special")
    local Npc = Interface.safeWaitPart(Special, "Npc")
    local npc3 = Interface.safeWaitPart(Npc, "Npc3")
    local npcPosition = npc3:GetPivot().Position
    return npcPosition
end

function Module:ShowGuide()
	local inventoryData = {}
	for _, itemData in pairs(_G.ClientData.Inventory) do
		if not inventoryData[itemData.ItemId] then
			inventoryData[itemData.ItemId] = 1
		else
			inventoryData[itemData.ItemId] += 1
		end
	end
	-- local talentData = _G.ClientData.TalentData
    -- local talent = TalentTreeConfig:GetAll()
    -- for _, talentInfo in pairs(talent) do
    --     local talentId = talentInfo.TalentId
        
    --     local needItemList = talentInfo.NeedItemList
    --     local needNumList = talentInfo.NeedNumList
    --     for i = 1, 4 do
    --         local needItem = needItemList[i][level]
    --         local needNum = needNumList[i][level]
    --         if needNum > 0 and inventoryData[needItem] and inventoryData[needItem] > 0 then
    --             local npcPosition = findNpc3()
    --             if npcPosition then
    --                 SimpleArrowNavigation.NavigateTo(npcPosition, nil, 10, true, 0.5)
    --                 Knit.GetController("UIController").ShowTip:Fire({Type = 1, Text = "Items collected! Upgrade your abilities now"})
    --                 return
    --             end
    --         end
    --     end
    -- end
end

return Module