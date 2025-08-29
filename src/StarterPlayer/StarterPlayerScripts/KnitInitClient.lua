-- KnitInitClient 客户端初始化模块
-- 负责在服务器启动完成后初始化Knit客户端监听函数
-- 避免服务器未加载完成时客户端调用Knit监听报错

local KnitInitClient = {}

local isServerStarted = false
local pendingListeners = {} -- 存储待执行的监听函数

-- 执行所有待执行的监听函数
-- @return void
function KnitInitClient.executePendingListeners()
    print("开始执行Knit客户端监听函数，共" .. #pendingListeners .. "个")
    isServerStarted = true
    for i, listenerFunc in ipairs(pendingListeners) do
        local success, errorMsg = pcall(listenerFunc)
        if not success then
            warn("执行监听函数失败 [" .. i .. "]: " .. tostring(errorMsg))
        end
    end
    
    -- 清空待执行列表
    pendingListeners = {}
    print("Knit客户端监听函数执行完成")
end

-- 添加监听函数到待执行队列
-- @param listenerFunc function 要添加的监听函数
-- @return void
function KnitInitClient.AddListener(listenerFunc)
    if type(listenerFunc) ~= "function" then
        warn("KnitInitClient.AddListener: 参数必须是函数类型")
        return
    end
    
    if isServerStarted then
        -- 服务器已启动，直接执行
        local success, errorMsg = pcall(listenerFunc)
        if not success then
            warn("执行监听函数失败: " .. tostring(errorMsg))
        end
    else
        -- 服务器未启动，添加到待执行队列
        table.insert(pendingListeners, listenerFunc)
        print("监听函数已添加到待执行队列，当前队列长度: " .. #pendingListeners)
    end
end

return KnitInitClient