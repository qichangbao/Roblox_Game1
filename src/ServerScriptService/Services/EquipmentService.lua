--[[
    EquipmentService
    玩家换装服务（服务器端）
    功能：
    - 保存并还原玩家原始外观（HumanoidDescription）
    - 安全地按类别替换帽子、衣服（Shirt/Pants）
    - 按左右部位装备/移除配件（左/右手臂、左/右腿、左/右肩膀、左/右鞋子）
    实现说明：
    - 使用 HumanoidDescription 管理衣服（Shirt/Pants），更稳定、官方支持
    - 使用 Accessory 判断与附件名匹配的方式来识别“属于哪个部位”（例如 Head、LeftUpperArm 等）
    - 仅移除与目标类别匹配的配件，避免误删其他装饰（如背包、腰带等）
    - 所有操作在服务器进行，保证状态一致性
]]

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

-- 定义左右部位组（R15命名）
local GROUPS = {
    LeftArm = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
    RightArm = { "RightUpperArm", "RightLowerArm", "RightHand" },
    LeftLeg = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
    RightLeg = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
    LeftShoulder = { "LeftUpperArm" }, -- 肩膀通常在上臂附近的 Attachment
    RightShoulder = { "RightUpperArm" },
    LeftShoe = { "LeftFoot" },
    RightShoe = { "RightFoot" },
}

local EquipmentService = Knit.CreateService {
	Name = "EquipmentService",
	Client = {
	},

    OriginalDescriptions = {}
}

function EquipmentService:KnitInit()
end

-- 服务启动时的初始化
-- @return void
function EquipmentService:KnitStart()
end

--[[
    等待并获取玩家角色与 Humanoid
    @param player Player 玩家对象
    @return Model, Humanoid 角色模型与 Humanoid（可能等待）
]]
local function getCharacterAndHumanoid(player: Player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
    return character, humanoid
end

function EquipmentService:PlayerAdded(player)
    local _, humanoid = getCharacterAndHumanoid(player)
    local ok, accountDesc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(player.UserId)
    end)
    local desc = ok and accountDesc or humanoid:GetAppliedDescription()
    self.OriginalDescriptions[player.UserId] = desc
end

function EquipmentService:PlayerRemoved(player)
    self.OriginalDescriptions[player.UserId] = nil
end

--[[
    从资产ID加载所有 Accessory（支持一个资产包含多个配件）
    @param assetId number 资产ID
    @return Accessory[] 返回未挂载、未父级化的 Accessory 列表（调用方负责克隆与清理）
]]
local function loadAccessoriesFromAsset(assetId: number): {Accessory}
    local result = {}
    local ok, asset = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    if not ok or not asset then
        warn(("InsertService:LoadAsset 失败，assetId=%s"):format(tostring(assetId)))
        return result
    end

    for _, descendant in ipairs(asset:GetDescendants()) do
        if descendant:IsA("Accessory") then
            descendant.Parent = nil
            table.insert(result, descendant)
        end
    end
    asset:Destroy()

    if #result == 0 then
        warn(("资产 %s 中未找到任何 Accessory"):format(tostring(assetId)))
    end
    return result
end

--[[
    判断 Accessory 是否为帽子类（优先使用 AccessoryType；回退通过附件名与 Head 对齐）
    @param accessory Accessory 待判断的配件
    @param character Model 玩家角色
    @return boolean true 表示该配件应被视为帽子
]]
local function isHatAccessory(accessory: Accessory, character: Model): boolean
    if accessory:IsA("Accessory") then
        local ok, typ = pcall(function()
            return accessory.AccessoryType
        end)
        if ok and typ == Enum.AccessoryType.Hat then
            return true
        end
    end

    local head = character:FindFirstChild("Head")
    local handle = accessory:FindFirstChild("Handle")
    if not head or not handle then return false end

    local headAttachNames = {
        HatAttachment = true,
        HairAttachment = true,
        FaceFrontAttachment = true,
        FaceCenterAttachment = true,
    }

    for _, child in ipairs(handle:GetChildren()) do
        if child:IsA("Attachment") then
            if headAttachNames[child.Name] or head:FindFirstChild(child.Name) then
                return true
            end
        end
    end
    return false
end

--[[
    判断 Accessory 是否附着于某一部位组（例如左手臂/右腿）
    通过 Handle 下的 Attachment 名称在角色对应部位是否存在同名 Attachment 来确定归属
    @param accessory Accessory 待判断配件
    @param character Model 玩家角色
    @param partNames string[] 该部位组的部件名列表（例如 {"LeftUpperArm","LeftLowerArm","LeftHand"}）
    @return boolean 是否属于该部位组
]]
local function isAccessoryOnPartGroup(accessory: Accessory, character: Model, partNames: {string}): boolean
    local handle = accessory:FindFirstChild("Handle")
    if not handle then return false end

    -- 收集角色部位中的所有 Attachment 名称，用于快速匹配
    local targetAttachments = {}
    for _, partName in ipairs(partNames) do
        local part = character:FindFirstChild(partName)
        if part then
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Attachment") then
                    targetAttachments[child.Name] = true
                end
            end
        end
    end

    for _, child in ipairs(handle:GetChildren()) do
        if child:IsA("Attachment") and targetAttachments[child.Name] then
            return true
        end
    end
    return false
end

--[[
    移除角色上匹配谓词的 Accessory（安全移除）
    @param character Model 玩家角色
    @param predicate function(Accessory):boolean 判断函数，返回 true 则移除该配件
]]
local function removeAccessoriesByPredicate(character: Model, predicate)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            local ok, shouldRemove = pcall(function()
                return predicate(child)
            end)
            if ok and shouldRemove then
                child:Destroy()
            end
        end
    end
end

--[[
    移除指定部位组上的配件（左/右手臂、腿、肩膀、鞋子等）
    @param character Model 玩家角色
    @param groupName string 组名（例如 "LeftArm"）
]]
local function removeGroupAccessories(character: Model, groupName: string)
    local partNames = GROUPS[groupName]
    if not partNames then
        warn(("未知部位组：%s"):format(tostring(groupName)))
        return
    end
    removeAccessoriesByPredicate(character, function(acc)
        return isAccessoryOnPartGroup(acc, character, partNames)
    end)
end

--[[
    通过 HumanoidDescription 替换 Shirt（衣服）
    @param humanoid Humanoid
    @param shirtAssetId number 新 Shirt 的资产ID（0或nil表示移除）
]]
local function applyShirt(humanoid: Humanoid, shirtAssetId: number?)
    local desc = humanoid:GetAppliedDescription()
    desc.Shirt = shirtAssetId and tostring(shirtAssetId) or ""
    humanoid:ApplyDescription(desc)
end

--[[
    通过 HumanoidDescription 替换 Pants（裤子）
    @param humanoid Humanoid
    @param pantsAssetId number 新 Pants 的资产ID（0或nil表示移除）
]]
local function applyPants(humanoid: Humanoid, pantsAssetId: number?)
    local desc = humanoid:GetAppliedDescription()
    desc.Pants = pantsAssetId and tostring(pantsAssetId) or ""
    humanoid:ApplyDescription(desc)
end

--[[
    从输入解析并为角色挂载一个或多个 Accessory（支持资产ID、单实例、文件夹/模型容器、数组）
    @param humanoid Humanoid 玩家人形
    @param accessoryOrAssetId Accessory|Instance|number|table Accessory/容器/资产ID/数组
    @param predicate function?(Accessory, Model):boolean 可选过滤器，仅当返回 true 时才挂载该配件
    @return Accessory[] 成功返回挂载后的 Accessory 克隆列表
    说明：
    - 如果传入的是文件夹或模型，会收集其中所有的 Accessory 并批量挂载
    - 如果传入资产ID，且资产中包含多个 Accessory，也会全部挂载
    - 可选的 predicate 用于在挂载前按条件筛选（例如仅帽子或仅某部位）
]]
local function addAccessories(humanoid: Humanoid, accessoryOrAssetId, predicate): {Accessory}
    local clones: {Accessory} = {}
    local toEquip: {Accessory} = {}
    local character: Model? = humanoid.Parent

    -- 收集输入中的所有 Accessory
    if typeof(accessoryOrAssetId) == "number" then
        toEquip = loadAccessoriesFromAsset(accessoryOrAssetId)
    elseif typeof(accessoryOrAssetId) == "Instance" then
        -- 支持直接传入 Accessory 或者包含多个 Accessory 的容器（Folder/Model）
        local container: Instance = accessoryOrAssetId
        if container:IsA("Accessory") then
            table.insert(toEquip, container)
        else
            for _, d in ipairs(container:GetDescendants()) do
                if d:IsA("Accessory") then
                    table.insert(toEquip, d)
                end
            end
        end
    elseif type(accessoryOrAssetId) == "table" then
        -- 支持数组批量输入：{Accessory|Instance|number, ...}
        for _, item in ipairs(accessoryOrAssetId) do
            if typeof(item) == "number" then
                local accs = loadAccessoriesFromAsset(item)
                for _, acc in ipairs(accs) do table.insert(toEquip, acc) end
            elseif typeof(item) == "Instance" then
                if item:IsA("Accessory") then
                    table.insert(toEquip, item)
                else
                    for _, d in ipairs(item:GetDescendants()) do
                        if d:IsA("Accessory") then
                            table.insert(toEquip, d)
                        end
                    end
                end
            end
        end
    else
        warn("addAccessories: 不支持的参数类型，期望为资产ID/Instance/数组")
    end

    -- 执行挂载（按谓词过滤）
    for _, srcAcc in ipairs(toEquip) do
        local pass = true
        if predicate and character then
            local ok, res = pcall(function()
                return predicate(srcAcc, character)
            end)
            pass = ok and res
        end
        if pass then
            local clone = srcAcc:Clone()
            humanoid:AddAccessory(clone)
            table.insert(clones, clone)
        end
    end

    -- 资源清理：对于通过 InsertService 取出的 Accessory（Parent=nil），在克隆后销毁原始实例
    for _, srcAcc in ipairs(toEquip) do
        if srcAcc.Parent == nil then
            srcAcc:Destroy()
        end
    end

    return clones
end

--[[
    兼容函数：挂载单个 Accessory（内部调用批量函数，返回第一个）
    @param humanoid Humanoid
    @param accessoryOrAssetId any
    @return Accessory? 返回第一个成功挂载的克隆实例
]]
local function addAccessory(humanoid: Humanoid, accessoryOrAssetId): Accessory?
    local list = addAccessories(humanoid, accessoryOrAssetId)
    return list[1]
end

--[[
    手动更新缓存为当前外观（例如玩家更改外观后调用）
    @param player Player
]]
function EquipmentService:SaveCurrentAsOriginal(player: Player)
    local _, humanoid = getCharacterAndHumanoid(player)
    self.OriginalDescriptions[player.UserId] = humanoid:GetAppliedDescription()
end

--[[
    还原玩家为原始外观
    @param player Player
]]
function EquipmentService:RestoreOriginal(player: Player)
    local _, humanoid = getCharacterAndHumanoid(player)
    local desc = self.OriginalDescriptions[player.UserId]
    if not desc then
        warn(("玩家 %s 无原始外观缓存，使用当前外观作为原始值"):format(player.Name))
        desc = humanoid:GetAppliedDescription()
        self.OriginalDescriptions[player.UserId] = desc
    end 
    humanoid:ApplyDescription(desc)
end

--[[
    强制以玩家账号默认外观作为“原始外观”并立即还原
    @param player Player
    说明：
    - 优先调用 Players:GetHumanoidDescriptionFromUserId 获取账号默认外观
    - 如果失败，回退为当前应用外观
]]
function EquipmentService:RestoreAccountDefault(player: Player)
    local _, humanoid = getCharacterAndHumanoid(player)
    local ok, accountDesc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(player.UserId)
    end)
    local desc = ok and accountDesc or humanoid:GetAppliedDescription()
    self.OriginalDescriptions[player.UserId] = desc
    humanoid:ApplyDescription(desc)
end

--[[
    仅缓存账号默认外观为“原始外观”，不立即应用
    @param player Player
]]
function EquipmentService:CacheAccountOriginal(player: Player)
    local _, humanoid = getCharacterAndHumanoid(player)
    local ok, accountDesc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(player.UserId)
    end)
    self.OriginalDescriptions[player.UserId] = ok and accountDesc or humanoid:GetAppliedDescription()
end

--[[
    替换帽子（仅删除帽子类配件，再挂载新的帽子）
    @param player Player
    @param accessoryOrAssetId Accessory|number 新帽子（模板或资产ID）
]]
function EquipmentService:EquipHat(player: Player, accessoryOrAssetId)
    local character, humanoid = getCharacterAndHumanoid(player)
    
    removeAccessoriesByPredicate(character, function(acc)
        return isHatAccessory(acc, character)
    end)
    -- 仅挂载“帽子”类型的配件（支持文件夹/模型/资产ID中包含多个配件的情况）
    addAccessories(humanoid, accessoryOrAssetId, function(acc, char)
        return isHatAccessory(acc, char)
    end)
end

--[[
    替换衣服（Shirt）
    @param player Player
    @param shirtAssetId number Shirt 资产ID（经典衣服）
]]
function EquipmentService:EquipShirt(player: Player, shirtAssetId: number)
    local _, humanoid = getCharacterAndHumanoid(player)
    applyShirt(humanoid, shirtAssetId)
end

--[[
    替换裤子（Pants）
    @param player Player
    @param pantsAssetId number Pants 资产ID（经典裤子）
]]
function EquipmentService:EquipPants(player: Player, pantsAssetId: number)
    local _, humanoid = getCharacterAndHumanoid(player)
    applyPants(humanoid, pantsAssetId)
end

--[[
    替换左/右手臂上的配件（不影响其他部位）
    @param player Player
    @param side string "Left" 或 "Right"
    @param accessoryOrAssetId Accessory|number 配件模板或资产ID
]]
function EquipmentService:EquipArm(player: Player, side: string, accessoryOrAssetId)
    local character, humanoid = getCharacterAndHumanoid(player)
    local groupName = side == "Left" and "LeftArm" or "RightArm"
    removeGroupAccessories(character, groupName)
    -- 仅挂载属于该手臂组的配件（支持容器/资产含多配件）
    local partNames = GROUPS[groupName]
    addAccessories(humanoid, accessoryOrAssetId, function(acc, char)
        return isAccessoryOnPartGroup(acc, char, partNames)
    end)
end

--[[
    替换左/右腿上的配件（不影响其他部位）
    @param player Player
    @param side string "Left" 或 "Right"
    @param accessoryOrAssetId Accessory|number 配件模板或资产ID
]]
function EquipmentService:EquipLeg(player: Player, side: string, accessoryOrAssetId)
    local character, humanoid = getCharacterAndHumanoid(player)
    local groupName = side == "Left" and "LeftLeg" or "RightLeg"
    removeGroupAccessories(character, groupName)
    -- 仅挂载属于该腿部组的配件（支持容器/资产含多配件）
    local partNames = GROUPS[groupName]
    addAccessories(humanoid, accessoryOrAssetId, function(acc, char)
        return isAccessoryOnPartGroup(acc, char, partNames)
    end)
end

--[[
    替换左/右肩膀上的配件（不影响其他部位）
    @param player Player
    @param side string "Left" 或 "Right"
    @param accessoryOrAssetId Accessory|number 配件模板或资产ID
]]
function EquipmentService:EquipShoulder(player: Player, side: string, accessoryOrAssetId)
    local character, humanoid = getCharacterAndHumanoid(player)
    local groupName = side == "Left" and "LeftShoulder" or "RightShoulder"
    removeGroupAccessories(character, groupName)
    -- 仅挂载属于该肩膀组的配件（支持容器/资产含多配件）
    local partNames = GROUPS[groupName]
    addAccessories(humanoid, accessoryOrAssetId, function(acc, char)
        return isAccessoryOnPartGroup(acc, char, partNames)
    end)
end

--[[
    替换左/右鞋子（脚部）上的配件（不影响其他部位）
    @param player Player
    @param side string "Left" 或 "Right"
    @param accessoryOrAssetId Accessory|number 配件模板或资产ID
]]
function EquipmentService:EquipShoe(player: Player, side: string, accessoryOrAssetId)
    local character, humanoid = getCharacterAndHumanoid(player)
    local groupName = side == "Left" and "LeftShoe" or "RightShoe"
    removeGroupAccessories(character, groupName)
    -- 仅挂载属于该脚部组的配件（支持容器/资产含多配件）
    local partNames = GROUPS[groupName]
    addAccessories(humanoid, accessoryOrAssetId, function(acc, char)
        return isAccessoryOnPartGroup(acc, char, partNames)
    end)
end

return EquipmentService