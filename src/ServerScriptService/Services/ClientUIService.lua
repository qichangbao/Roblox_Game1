local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local ClientUIService = Knit.CreateService({
    Name = 'ClientUIService',
    Client = {
        ShowTip = Knit.CreateSignal(),
        ShowUI = Knit.CreateSignal(),
    },
})

function ClientUIService:ShowTip(player, tip)
    self.Client.ShowTip:Fire(player, {Type = 1, Text = tip})
end

function ClientUIService:PickUpItem(player, itemId)
    self.Client.ShowTip:FireAll({Type = 2, Name = player.Name, ItemId = itemId})
end

function ClientUIService:Submit(player, gold)
    self.Client.ShowTip:FireAll({Type = 1, Text = string.format("%s submitted an item worth %d", player.Name, gold)})
end

function ClientUIService:ShowSingleUI(player, ui, data)
    self.Client.ShowUI:Fire(player, ui, data)
end

function ClientUIService:ShowUI(player, ui, data)
    self.Client.ShowUI:FireAll(ui, data)
end

function ClientUIService:KnitInit()
end

function ClientUIService:KnitStart()
end

return ClientUIService
