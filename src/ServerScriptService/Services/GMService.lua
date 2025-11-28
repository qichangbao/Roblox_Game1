local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("GameConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("ConfigFolder"):WaitForChild("ItemConfig"))
local Interface = require(ReplicatedStorage:WaitForChild("ToolFolder"):WaitForChild("Interface"))

local GMService = Knit.CreateService({
    Name = 'GMService',
    Client = {
    },
})

function GMService:KnitInit()
end

function GMService:KnitStart()
end

function GMService:PlayerAdded(player)
    self:GMCommand(player)
end

function GMService:PlayerRemoved(player)
end

-- 解析包含多个物品ID的字符串，支持空格或逗号分隔
-- @param idStr string 原始ID字符串（例如 "123 456,789"）
-- @return table 返回数字ID数组（例如 {123,456,789}）
function GMService:ParseItemIds(idStr)
    local ids = {}
    for num in string.gmatch(idStr or "", "%d+") do
        local n = tonumber(num)
        if n then
            table.insert(ids, n)
        end
    end
    return ids
end

function GMService:GMCommand(player)
    if game:GetService("RunService"):IsStudio() then
        player.Chatted:Connect(function(message)
            local lowerMessage = string.lower(message)
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            -- 解析 "heal [amount]" 命令 - 加血
            local healMatch = string.match(lowerMessage, "^hp (%d+)$")
            if healMatch then
                local amount = tonumber(healMatch)
                if amount and humanoid then
                    Interface.addHp(player.Character, amount)
                    print(string.format("玩家 %s 恢复了 %d 点生命值，当前生命值: %d/%d", 
                        player.Name, amount, humanoid.Health, humanoid.MaxHealth))
                    return true
                end
            end
            
            -- 解析 "heal" 命令 - 满血
            if lowerMessage == "hp" then
                if humanoid then
                    humanoid.Health = humanoid.MaxHealth
                    print(string.format("玩家 %s 生命值已恢复满血: %d/%d", 
                        player.Name, humanoid.Health, humanoid.MaxHealth))
                    return true
                end
            end
            
            -- 解析 "damage [amount]" 命令 - 减血
            local damageMatch = string.match(lowerMessage, "^damage (%d+)$")
            if damageMatch then
                local amount = tonumber(damageMatch)
                if amount and humanoid then
                    humanoid:TakeDamage(amount)
                    print(string.format("玩家 %s 受到了 %d 点伤害，当前生命值: %d/%d", 
                        player.Name, amount, humanoid.Health, humanoid.MaxHealth))
                    return true
                end
            end
            
            -- 解析 "speed [value]" 命令 - 设置移动速度
            local speedMatch = string.match(lowerMessage, "^speed (%d+)$")
            if speedMatch then
                local speed = tonumber(speedMatch)
                if speed and humanoid then
                    humanoid.WalkSpeed = speed
                    print(string.format("玩家 %s 移动速度设置为: %d", player.Name, speed))
                    return true
                end
            end
            
            -- 解析 "speed reset" 命令 - 重置移动速度
            if lowerMessage == "speed reset" then
                if humanoid then
                    local initSpeed = player:GetAttribute("InitWalkSpeed") or 16
                    humanoid.WalkSpeed = initSpeed
                    print(string.format("玩家 %s 移动速度已重置为: %d", player.Name, initSpeed))
                    return true
                end
            end
            
            -- 解析 "jump [value]" 命令 - 设置跳跃力
            local jumpMatch = string.match(lowerMessage, "^jump (%d+)$")
            if jumpMatch then
                local jumpPower = tonumber(jumpMatch)
                if jumpPower and humanoid then
                    humanoid.JumpPower = jumpPower
                    print(string.format("玩家 %s 跳跃力设置为: %d", player.Name, jumpPower))
                    return true
                end
            end
            
            -- 解析 "jump reset" 命令 - 重置跳跃力
            if lowerMessage == "jump reset" then
                if humanoid then
                    local initJump = player:GetAttribute("InitJumpPower") or 50
                    humanoid.JumpPower = initJump
                    print(string.format("玩家 %s 跳跃力已重置为: %d", player.Name, initJump))
                    return true
                end
            end

			-- 解析 "add item [id1 id2 ...]" 或 "add item [id1,id2,...]" 命令 - 支持多个ID
			local addMultiMatch = string.match(lowerMessage, "^add item%s+([%d%s,]+)$")
			if addMultiMatch then
				local ids = self:ParseItemIds(addMultiMatch)
				if #ids > 0 then
					for _, itemId in ipairs(ids) do
                        if GameConfig.LandName == "出生岛" then
                            Knit.GetService("InventoryService"):AddItem(player, {
                                ItemId = itemId,
                                Attribute = GameConfig.GetItemAttribute(),
                            })
                        else
                            local itemInfo = ItemConfig:GetByItemId(itemId)
                            Knit.GetService("InventoryService"):CreateItemToFloor(player, itemInfo, {
                                ItemId = itemId,
                                Attribute = GameConfig.GetItemAttribute(),
                            })
                        end
					end
					print(string.format("已为玩家 %s 添加物品 IDs: %s", player.Name, table.concat(ids, ", ")))
					return true
				end
			end
			
			-- 解析 "remove item [itemId]" 或 "dec item [itemId]" 命令
			local removeMatch = string.match(lowerMessage, "^remove item (%d+)$") or string.match(lowerMessage, "^dec item (%d+)$")
			if removeMatch then
				local itemId = tonumber(removeMatch)
				if itemId then
					local items = {}
					items[itemId] = 1
					Knit.GetService("InventoryService"):RemoveItemsByNum(player, items)
					print("已为玩家 " .. player.Name .. " 移除物品 ID: " .. itemId)
					return true
				end
			end

			if lowerMessage == "add star" then
				Knit.GetService("LevelService"):Updata(player, true)
				return true
			elseif lowerMessage == "dec star" then
				Knit.GetService("LevelService"):Updata(player, false)
				return true
			end

			local showTipMatch = string.match(lowerMessage, "^show tip (.+)$")
            if showTipMatch then
                local tip = showTipMatch
                Knit.GetService("ClientUIService"):ShowTip(player, tip)
                return true
            end

			local killMonsterMatch = string.match(lowerMessage, "^kill monster (%d+)$")
            if killMonsterMatch then
                local monsterId = tonumber(killMonsterMatch)
                if monsterId then
                    Knit.GetService("QuestService"):OnNPCKilled(player, tostring(monsterId))
                    Knit.GetService("ClientUIService"):ShowTip(player, "已击杀怪物 ID: " .. monsterId)
                    return true
                end
            end

			local equipMatch = string.match(lowerMessage, "^add equip (%d+)$")
            if equipMatch then
                local equipId = tonumber(equipMatch)
                if equipId then
                    Knit.GetService("EquipmentService"):AddEquip(player, equipId)
                    Knit.GetService("ClientUIService"):ShowTip(player, "已添加装备 ID: " .. equipId)
                    return true
                end
            end

			local equipRemoveMatch = string.match(lowerMessage, "^remove equip (%d+)$")
            if equipRemoveMatch then
                local equipId = tonumber(equipRemoveMatch)
                if equipId then
                    Knit.GetService("EquipmentService"):RemoveEquip(player, equipId)
                    Knit.GetService("ClientUIService"):ShowTip(player, "已移除装备 ID: " .. equipId)
                    return true
                end
            end
            
            -- 解析 "help" 命令 - 显示帮助信息
            if lowerMessage == "help" or lowerMessage == "debug help" then
                print("=== 调试命令帮助 ===")
                print("hp [amount] - 恢复指定生命值")
                print("hp - 恢复满血")
                print("damage [amount] - 造成指定伤害")
                print("speed [value] - 设置移动速度")
                print("speed reset - 重置移动速度")
                print("jump [value] - 设置跳跃力")
                print("jump reset - 重置跳跃力")
                print("add item [id1 id2 ...] 或 [id1,id2,...] - 添加多个物品")
                print("remove item [itemId] - 移除玩家指定物品")
                print("add star - 为玩家添加一颗星")
                print("dec star - 为玩家移除一颗星")
                print("show tip [tip] - 显示指定提示信息")
                print("kill monster [monsterId] - 击杀指定怪物")
                print("help - 显示此帮助信息")
                return true
            end
        
            return false
        end)
    end
end

return GMService
