local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Signal"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))

local UIController = Knit.CreateController {
    Name = "UIController",
    
    ShowStoreUI = Signal.new(),
    ShowSellUI = Signal.new(),
    ShowTip = Signal.new(),
	ShowAdminUI = Signal.new(),
    ShowAdminButton = Signal.new(),
	ShowBackpackUI = Signal.new(),
	ChangeGoldUI = Signal.new(),
	ShowChoosePeopleNumUI = Signal.new(),
    ShowFeedbackUI = Signal.new(),
    ShowPlayerListUI = Signal.new(),
    ShowDragUI = Signal.new(),
    MoveDragUI = Signal.new(),
    HideDragUI = Signal.new(),
	UpdateToolUI = Signal.new(),
	AddToolUI = Signal.new(),
    UpdateRankPersonalData = Signal.new(),
    UpdateRankData = Signal.new(),
    UpdateBackpack = Signal.new(),
	UpdateToolData = Signal.new(),
}

function UIController:KnitInit()
end

function UIController:KnitStart()
end

return UIController