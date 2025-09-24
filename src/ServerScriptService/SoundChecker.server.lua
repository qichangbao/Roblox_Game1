--[[
	SoundChecker.server.lua
	声音路径输出工具
	
	用于扫描并输出Workspace和ServerStorage中的所有声音文件路径
]]

if not game:GetService("RunService"):IsStudio() then
	return
end

local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
	递归扫描对象及其子对象中的所有声音资源
	@param parent Instance 要扫描的父对象
	@param path string 对象路径
	@param results table 结果表
]]
local function ScanAllSounds(parent, path, results)
	-- 检查当前对象是否为声音对象
	if parent:IsA("Sound") then
		table.insert(results, {
			Object = parent,
			Path = path,
			Name = parent.Name,
			SoundId = parent.SoundId,
			Volume = parent.Volume,
			Playing = parent.IsPlaying,
			Looped = parent.Looped,
			Parent = parent.Parent,
			ParentType = parent.Parent and parent.Parent.ClassName or "None"
		})
	end
	
	-- 递归检查子对象
	for _, child in ipairs(parent:GetChildren()) do
		local childPath = path .. "." .. child.Name
		ScanAllSounds(child, childPath, results)
	end
end

--[[
	获取对象的完整路径
	@param obj Instance 对象
	@return string 完整路径
]]
local function GetFullPath(obj)
	local path = {}
	local current = obj
	
	while current and current ~= game do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end
	
	return "game." .. table.concat(path, ".")
end

--[[
	主执行函数
]]
local function Main()
	-- 扫描目标位置
	local locations = {
		{name = "Workspace", object = Workspace},
		{name = "ServerStorage", object = ServerStorage},
		{name = "ReplicatedStorage", object = ReplicatedStorage},
		{name = "SoundService", object = SoundService}
	}
	
	local allSounds = {}
	
	-- 扫描所有位置
	for _, location in ipairs(locations) do
		ScanAllSounds(location.object, location.name, allSounds)
	end
	
	if #allSounds == 0 then
		print("✅ 没有找到任何声音对象")
		return
	end
	
	-- 输出所有声音路径
	print("\n🔊 所有声音对象路径列表:")
	print("=" .. string.rep("=", 80))
	
	for i, soundInfo in ipairs(allSounds) do
		local fullPath = GetFullPath(soundInfo.Object)
		print(string.format("[%d] %s", i, fullPath))
	end
	print("=" .. string.rep("=", 80))
end

-- 延迟执行以确保所有服务已初始化
task.wait(3)
Main()