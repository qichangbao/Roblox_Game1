local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- 初始化Knit框架
local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'):waitForChild('Knit'))
local DataRetryUtil = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('DataRetryUtil'))

local ClientData = {}
ClientData.Gold = 0
ClientData.Inventory = {}
ClientData.ToolData = {}

local function init()
    local KnitInitClient = require(script.Parent:WaitForChild("KnitInitClient"))
    KnitInitClient.AddListener(function()
        print("ClientData AddListener")

        -- 使用通用重试工具获取登录数据
        DataRetryUtil.RetryDataFetch(
            function()
                return Knit.GetService("ServerDataService").GetInitData()
            end,
            {
                maxRetries = 5,
                retryDelay = 2,
                operationName = "登录数据获取",
                dataValidator = function(data)
                    return data and type(data) == "table" and data.Gold ~= nil and data.Inventory ~= nil and data.ToolData ~= nil
                end,
                onSuccess = function(data)
                    -- 安全地设置数据
                    ClientData.Gold = data.Gold or 0
					ClientData.Inventory = data.Inventory or {}
					ClientData.ToolData = data.ToolData or {}
					Knit.GetController("UIController").ChangeGoldUI:Fire(data.Gold)
                    Knit.GetController("InventoryController"):Event_UpdateBackpack(data.Inventory)
					Knit.GetController("UIController").UpdateToolUI:Fire(data.ToolData)
                    
                    require(script.Parent:WaitForChild("LoadingUI")).Hide()
                end,
                onFailure = function(errorMsg)
                    warn("登录数据获取失败:", errorMsg)
                end
            }
        )

        Knit.GetService("GoldService").ChangeGold:Connect(function(gold)
			ClientData.Gold = gold
			Knit.GetController("UIController").ChangeGoldUI:Fire(gold)
		end)

		Knit.GetService("InventoryService").UpdateBackpack:Connect(function(inventory)
			ClientData.Inventory = inventory or {}
			Knit.GetController("InventoryController"):Event_UpdateBackpack(inventory or {})
		end)
    end)
end

init()

return ClientData