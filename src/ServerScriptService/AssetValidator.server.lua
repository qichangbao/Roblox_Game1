--[[
	AssetValidator.server.lua
	资源验证工具
	
	用于检查和报告游戏中的无效资源ID，帮助解决MeshContentProvider错误
]]

local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========================================
-- 🔍 资源验证函数
-- ========================================

--[[
	检查资源ID是否有效
	@param assetId string 资源ID
	@return boolean 是否为有效的资源ID
]]
local function IsValidAssetId(assetId)
	if not assetId or assetId == "" then
		return true -- 空ID被认为是有效的（使用默认资源）
	end
	
	-- 移除rbxassetid://前缀
	local cleanId = string.gsub(assetId, "^rbxassetid://", "")
	
	-- 检查是否为纯数字
	local numericId = tonumber(cleanId)
	if not numericId or numericId <= 0 then
		return false
	end
	
	-- 检查是否为已知的无效ID
	local invalidIds = {
		906451617, -- 报错中提到的ID
		906439491, -- 报错中提到的ID
	}
	
	for _, invalidId in pairs(invalidIds) do
		if numericId == invalidId then
			return false
		end
	end
	
	return true
end

--[[
	递归检查对象及其子对象的资源
	@param parent Instance 要检查的父对象
	@param path string 对象路径（用于报告）
]]
local function CheckObjectAssets(parent, path)
	local issues = {}
	
	-- 检查MeshPart的MeshId
	if parent:IsA("MeshPart") then
		local meshId = parent.MeshId
		if meshId and meshId ~= "" and not IsValidAssetId(meshId) then
			table.insert(issues, {
				Type = "MeshId",
				Object = parent,
				Path = path,
				AssetId = meshId,
				Property = "MeshId"
			})
		end
	end
	
	-- 检查SpecialMesh的MeshId和TextureId
	if parent:IsA("SpecialMesh") then
		local meshId = parent.MeshId
		local textureId = parent.TextureId
		
		if meshId and meshId ~= "" and not IsValidAssetId(meshId) then
			table.insert(issues, {
				Type = "MeshId",
				Object = parent,
				Path = path,
				AssetId = meshId,
				Property = "MeshId"
			})
		end
		
		if textureId and textureId ~= "" and not IsValidAssetId(textureId) then
			table.insert(issues, {
				Type = "TextureId",
				Object = parent,
				Path = path,
				AssetId = textureId,
				Property = "TextureId"
			})
		end
	end
	
	-- 检查Decal和Texture的Texture属性
	if parent:IsA("Decal") or parent:IsA("Texture") then
		local textureId = parent.Texture
		if textureId and textureId ~= "" and not IsValidAssetId(textureId) then
			table.insert(issues, {
				Type = "Texture",
				Object = parent,
				Path = path,
				AssetId = textureId,
				Property = "Texture"
			})
		end
	end
	
	-- 检查Sound的SoundId
	if parent:IsA("Sound") then
		local soundId = parent.SoundId
		if soundId and soundId ~= "" and not IsValidAssetId(soundId) then
			table.insert(issues, {
				Type = "SoundId",
				Object = parent,
				Path = path,
				AssetId = soundId,
				Property = "SoundId"
			})
		end
	end
	
	-- 递归检查子对象
	for _, child in pairs(parent:GetChildren()) do
		local childPath = path .. "." .. child.Name
		local childIssues = CheckObjectAssets(child, childPath)
		for _, issue in pairs(childIssues) do
			table.insert(issues, issue)
		end
	end
	
	return issues
end

--[[
	修复无效的资源ID
	@param issue table 问题信息
]]
local function FixAssetIssue(issue)
	local obj = issue.Object
	local property = issue.Property
	
	if not obj or not obj.Parent then
		return false
	end
	
	-- 根据资源类型设置默认值
	if property == "MeshId" then
		obj[property] = "" -- 使用默认网格
		print(string.format("🔧 已修复 %s 的 %s: %s -> (默认)", issue.Path, property, issue.AssetId))
	elseif property == "TextureId" or property == "Texture" then
		obj[property] = "" -- 使用默认贴图
		print(string.format("🔧 已修复 %s 的 %s: %s -> (默认)", issue.Path, property, issue.AssetId))
	elseif property == "SoundId" then
		obj[property] = "" -- 静音
		print(string.format("🔧 已修复 %s 的 %s: %s -> (静音)", issue.Path, property, issue.AssetId))
	end
	
	return true
end

-- ========================================
-- 🚀 主执行逻辑
-- ========================================

--[[
	扫描并报告所有资源问题
]]
local function ScanAllAssets()
	print("🔍 开始扫描资源问题...")
	
	local allIssues = {}
	local locations = {
		{name = "Workspace", object = Workspace},
		{name = "ServerStorage", object = ServerStorage},
		{name = "ReplicatedStorage", object = ReplicatedStorage}
	}
	
	-- 扫描各个位置
	for _, location in pairs(locations) do
		print(string.format("📂 扫描 %s...", location.name))
		local issues = CheckObjectAssets(location.object, location.name)
		
		for _, issue in pairs(issues) do
			table.insert(allIssues, issue)
		end
		
		print(string.format("   发现 %d 个问题", #issues))
	end
	
	-- 报告结果
	print(string.format("\n📊 扫描完成！总共发现 %d 个资源问题:", #allIssues))
	
	if #allIssues == 0 then
		print("✅ 没有发现资源问题！")
		return
	end
	
	-- 按类型分组显示问题
	local issuesByType = {}
	for _, issue in pairs(allIssues) do
		if not issuesByType[issue.Type] then
			issuesByType[issue.Type] = {}
		end
		table.insert(issuesByType[issue.Type], issue)
	end
	
	for issueType, issues in pairs(issuesByType) do
		print(string.format("\n❌ %s 问题 (%d 个):", issueType, #issues))
		for i, issue in pairs(issues) do
			print(string.format("   %d. %s - %s: %s", i, issue.Path, issue.Property, issue.AssetId))
		end
	end
	
	-- 询问是否自动修复
	print("\n🔧 是否自动修复这些问题？(将无效资源设为默认值)")
	print("   在控制台输入以下命令来修复:")
	print("   game.ServerScriptService.AssetValidator:SetAttribute('AutoFix', true)")
	
	return allIssues
end

-- 延迟执行扫描，确保所有资源都已加载
task.wait(2)

-- 执行扫描
local issues = ScanAllAssets()

-- 监听自动修复属性
script:GetAttributeChangedSignal("AutoFix"):Connect(function()
	if script:GetAttribute("AutoFix") then
		script:SetAttribute("AutoFix", false) -- 重置属性
		
		print("\n🔧 开始自动修复资源问题...")
		local fixedCount = 0
		
		for _, issue in pairs(issues or {}) do
			if FixAssetIssue(issue) then
				fixedCount = fixedCount + 1
			end
		end
		
		print(string.format("✅ 修复完成！共修复了 %d 个问题", fixedCount))
		print("🔄 建议重新启动游戏以确保修复生效")
	end
end)