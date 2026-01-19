local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Signal"))

local UIController = Knit.CreateController {
    Name = "UIController",
    
    ShowTip = Signal.new(),
    ShowMessageBoxUI = Signal.new(),
    ShowStoreUI = Signal.new(),
    ShowSellUI = Signal.new(),
    ShowTalentUI = Signal.new(),
    ShowRewardUI = Signal.new(),
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
    UpdateTalentData = Signal.new(),
    ShowItemAttributeUI = Signal.new(),
    ShowFlyItemUI = Signal.new(),
    ShowQuestUI = Signal.new(),
    UpdateQuestData = Signal.new(),
    ShowEquipmentUI = Signal.new(),
    UpdateEquipment = Signal.new(),
    UpdateOfflineTime = Signal.new(),
    RewardAction = Signal.new(),
    ShowJobUI = Signal.new(),
    UpdateJobData = Signal.new(),
    ChangeCurJobId = Signal.new(),
    SwitchRun = Signal.new(),
}

function UIController:KnitInit()
end

function UIController:KnitStart()
end

return UIController