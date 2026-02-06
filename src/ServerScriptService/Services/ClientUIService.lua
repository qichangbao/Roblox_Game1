local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local ClientUIService = Knit.CreateService({
	Name = 'ClientUIService',
	Client = {
		ShowTip = Knit.CreateSignal(),
		ShowUI = Knit.CreateSignal(),
		HideUI = Knit.CreateSignal(),
		ResetUI = Knit.CreateSignal(),
		ShowArrow = Knit.CreateSignal(),
		HideArrow = Knit.CreateSignal(),
		ChangeHp = Knit.CreateSignal(),
	},
})

--[[
	向单个玩家显示提示文字
	@param player Player 目标玩家
	@param tip string 提示内容
]]
function ClientUIService:ShowTip(player, tip)
    self.Client.ShowTip:Fire(player, {Type = 1, Text = tip})
end

--[[
	向所有玩家广播提示文字
	@param tip string 提示内容
]]
function ClientUIService:ShowTipAll(tip)
    self.Client.ShowTip:FireAll({Type = 1, Text = tip})
end

--[[
	广播玩家上交物品的提示
	@param player Player 上交玩家
	@param itemAttributes table<ItemAttribute> 上交物品属性列表
]]
function ClientUIService:SubmitItems(player, itemAttributes)
    for _, v in ipairs(itemAttributes) do
        self.Client.ShowTip:FireAll({Type = 2, Name = player.Name, ItemAttribute = v})
    end
end

--[[
	向单个玩家显示指定UI
	@param player Player 目标玩家
	@param ui string UI标识
	@param data any 附带数据
]]
function ClientUIService:ShowUISingle(player, ui, data)
    self.Client.ShowUI:Fire(player, ui, data)
end

--[[
	隐藏单个玩家的指定UI
	@param player Player 目标玩家
	@param ui string UI标识
]]
function ClientUIService:HideSingleUI(player, ui)
    self.Client.HideUI:Fire(player, ui)
end

--[[
	重置单个玩家的指定UI
	@param player Player 目标玩家
	@param ui string UI标识
]]
function ClientUIService:ResetSingleUI(player, ui)
    self.Client.ResetUI:Fire(player, ui)
end

--[[
	向所有玩家显示指定UI
	@param ui string UI标识
	@param data any 附带数据
]]
function ClientUIService:ShowUIAll(ui, data)
    self.Client.ShowUI:FireAll(ui, data)
end

--[[
	向单个玩家显示指引箭头
	@param player Player 目标玩家
	@param targetPosition Vector3 目标位置
]]
function ClientUIService:BroadcastShowArrow(player, targetPosition)
    self.Client.ShowArrow:Fire(player, targetPosition)
end

--[[
	隐藏单个玩家的指引箭头
	@param player Player 目标玩家
]]
function ClientUIService:BroadcastHideArrow(player)
	self.Client.HideArrow:Fire(player)
end

--[[
	向所有玩家广播血量变化事件
	@param part BasePart 头部或根部件
	@param hp number 血量变化值
	@param isCrit boolean? 是否暴击
]]
function ClientUIService:BroadcastHpChange(part, hp, isCrit)
	self.Client.ChangeHp:FireAll(part, hp, isCrit)
end

function ClientUIService:KnitInit()
end

function ClientUIService:KnitStart()
end

return ClientUIService
