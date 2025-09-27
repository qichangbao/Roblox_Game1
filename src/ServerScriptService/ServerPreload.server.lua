--[[
	ServerPreloadService.lua
	服务器端资源预加载服务
	
	负责预加载ServerStorage和Workspace中的所有模型和Part
]]

local ContentProvider = game:GetService("ContentProvider")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- ========================================
-- 📦 收集ServerStorage和Workspace中的所有资源
-- ========================================

--[[
	收集ServerStorage中的所有模型和Part资源（递归搜索所有文件夹）
	@return table 包含所有模型和Part的数组
]]
local function CollectServerStorageAssets()
	local assets = {}
	
	--[[
		递归搜索函数
		@param parent Instance 要搜索的父对象
		@param depth number 当前搜索深度（用于日志缩进）
	]]
	local function SearchAssetsRecursively(parent, depth)
		for _, child in pairs(parent:GetChildren()) do
			if child:IsA("Model") then
				table.insert(assets, child)
			elseif child:IsA("Part") or child:IsA("MeshPart") or child:IsA("UnionOperation") then
				table.insert(assets, child)
			elseif child:IsA("Folder") then
				-- 递归搜索文件夹内容
				SearchAssetsRecursively(child, depth + 1)
			end
		end
	end
	
	SearchAssetsRecursively(ServerStorage, 0)
	return assets
end

--[[
	收集Workspace中的所有模型和Part资源
	@return table 包含所有模型和Part的数组
]]
local function CollectWorkspaceAssets()
	local assets = {}
	
	--[[
		递归搜索函数（跳过玩家和摄像机等系统对象）
		@param parent Instance 要搜索的父对象
	]]
	local function SearchWorkspaceRecursively(parent)
		for _, child in pairs(parent:GetChildren()) do
			-- 跳过系统对象
			if child.Name == "Camera" or child:IsA("Player") or child.Name == "Terrain" then
				continue
			end
			
			if child:IsA("Model") then
				table.insert(assets, child)
			elseif child:IsA("Part") or child:IsA("MeshPart") or child:IsA("UnionOperation") then
				table.insert(assets, child)
			elseif child:IsA("Folder") then
				-- 递归搜索文件夹内容
				SearchWorkspaceRecursively(child)
			end
		end
	end
	
	SearchWorkspaceRecursively(Workspace)
	return assets
end

--[[
	收集所有资源（ServerStorage + Workspace）
	@return table 包含所有资源的数组
]]
local function CollectAllAssets()
	local allAssets = {}
	
	-- 收集ServerStorage资源
	local serverAssets = CollectServerStorageAssets()
	for _, asset in pairs(serverAssets) do
		table.insert(allAssets, asset)
	end
	
	return allAssets
end

-- ========================================
-- ⚡ 预加载执行
-- ========================================

--[[
	预加载所有资源（模型和Part）
	@param assets table 要预加载的资源数组
]]
local function PreloadAssets(assets)
	if #assets == 0 then
		print("📦 没有找到需要预加载的资源")
		return
	end
	
	-- 验证并过滤资源
	local validAssets = {}
	
	for _, asset in pairs(assets) do
		table.insert(validAssets, asset)
	end
	
	if #validAssets == 0 then
		warn("❌ 没有有效的资源可以预加载")
		return
	end
	
	-- 分批预加载，避免一次性加载过多资源
	local batchSize = 50
	local totalBatches = math.ceil(#validAssets / batchSize)
	
	for i = 1, totalBatches do
		local startIndex = (i - 1) * batchSize + 1
		local endIndex = math.min(i * batchSize, #validAssets)
		local batch = {}
		
		for j = startIndex, endIndex do
			table.insert(batch, validAssets[j])
		end
		
		local success, errorMessage = pcall(function()
			ContentProvider:PreloadAsync(batch)
		end)
		
		if success then
			print(string.format("✅ 批次 %d/%d 预加载完成 (%d 个资源)", i, totalBatches, #batch))
		else
			warn(string.format("❌ 批次 %d/%d 预加载失败: %s", i, totalBatches, errorMessage))
		end
		
		-- 批次间稍作延迟，避免过载
		if i < totalBatches then
			task.wait(0.1)
		end
	end
end

-- 收集所有资源（ServerStorage + Workspace）
local assets = CollectAllAssets()

-- 异步预加载
task.spawn(function()
	print("⚡ 开始预加载资源...")
	PreloadAssets(assets)
	print("✅ 资源预加载完成！")
end)