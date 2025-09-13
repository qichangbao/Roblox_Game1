local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Signal = require(ReplicatedStorage.Packages.Knit.Signal)

local InventoryController = Knit.CreateController {
    Name = "InventoryController",
    UpdateBackpack = Signal.new(),
	UpdateToolData = Signal.new(),
}

function InventoryController:KnitInit()
end

function InventoryController:KnitStart()
end

function InventoryController:Event_UpdateBackpack(backpack)
    self.UpdateBackpack:Fire(backpack)
end

function InventoryController:Event_UpdateToolData(toolData)
	self.UpdateToolData:Fire(toolData)
end

return InventoryController