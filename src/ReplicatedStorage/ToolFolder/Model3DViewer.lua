--[[
    3D模型UI显示系统
    使用ViewportFrame在UI中显示3D模型
    支持模型旋转、缩放、光照等功能
    @author AI Assistant
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Model3DViewer = {}

--[[
    创建3D模型查看器
    @param parent GuiObject 父级UI对象
    @param config table 配置参数
    @return table 查看器实例
]]
function Model3DViewer.new(parent, config)
    config = config or {}
    
    local self = {
        -- UI组件
        viewportFrame = nil,
        camera = nil,
        
        -- 3D对象
        model = nil,
        worldModel = nil,
        
        -- 配置
        size = config.size or UDim2.new(0, 200, 0, 200),
        position = config.position or UDim2.new(0, 0, 0, 0),
        backgroundColor = config.backgroundColor or Color3.fromRGB(50, 50, 50),
        backgroundTransparency = config.backgroundTransparency or 0,
        
        -- 相机设置
        cameraDistance = config.cameraDistance or 6, -- 从10调整为6，让模型显示得更大
        cameraAngle = config.cameraAngle or Vector3.new(0, 0, 0),
        fieldOfView = config.fieldOfView or 70,
        
        -- 交互设置
        enableRotation = config.enableRotation ~= false, -- 默认启用
        enableZoom = config.enableZoom == true, -- 默认禁用，仅在明确设为true时启用
        autoRotate = config.autoRotate or false,
        rotationSpeed = config.rotationSpeed or 1,
        
        -- 光照设置
        ambientColor = config.ambientColor or Color3.fromRGB(100, 100, 100),
        lightDirection = config.lightDirection or Vector3.new(-1, -1, -1),
        lightColor = config.lightColor or Color3.fromRGB(255, 255, 255),
        
        -- 内部状态
        connections = {},
        isDestroyed = false,
        currentRotation = 0,
        zoomConnection = nil,
    }
    
    -- 设置metatable以便访问方法
    setmetatable(self, {__index = Model3DViewer})
    
    -- 创建UI组件
    self:_createUI(parent)
    
    -- 设置光照
    self:_setupLighting()
    
    -- 设置交互
    if self.enableRotation or self.enableZoom then
        self:_setupInteraction()
    end
    
    -- 设置自动旋转
    if self.autoRotate then
        self:_setupAutoRotation()
    end
    
    return self
end

--[[
    创建UI组件
    @param parent GuiObject 父级UI对象
]]
function Model3DViewer:_createUI(parent)
    -- 创建ViewportFrame
    self.viewportFrame = Instance.new("ViewportFrame")
    self.viewportFrame.Size = self.size
    self.viewportFrame.Position = self.position
    self.viewportFrame.BackgroundColor3 = self.backgroundColor
    self.viewportFrame.BackgroundTransparency = self.backgroundTransparency
    self.viewportFrame.BorderSizePixel = 0
    self.viewportFrame.Parent = parent
    
    -- 添加圆角（可选）
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.viewportFrame
    
    -- 创建WorldModel
    self.worldModel = Instance.new("WorldModel")
    self.worldModel.Parent = self.viewportFrame
    
    -- 创建相机
    self.camera = Instance.new("Camera")
    self.camera.Parent = self.worldModel
    self.viewportFrame.CurrentCamera = self.camera
    self.camera.FieldOfView = self.fieldOfView
end

--[[
    设置光照
    注意：ViewportFrame中不能直接使用Lighting对象
    我们使用PointLight和SurfaceLight来模拟光照效果
]]
function Model3DViewer:_setupLighting()
    -- 创建一个隐藏的Part来放置光源
    local lightPart = Instance.new("Part")
    lightPart.Name = "LightSource"
    lightPart.Size = Vector3.new(1, 1, 1)
    lightPart.Transparency = 1 -- 完全透明
    lightPart.CanCollide = false
    lightPart.Anchored = true
    lightPart.Position = Vector3.new(0, 5, 10) -- 放在模型前上方
    lightPart.Parent = self.worldModel
    
    -- 添加点光源
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 1
    pointLight.Color = self.lightColor
    pointLight.Range = 50
    pointLight.Parent = lightPart
    
    -- 添加环境光（使用另一个点光源模拟环境光）
    local ambientLight = Instance.new("PointLight")
    ambientLight.Brightness = 0.3
    ambientLight.Color = self.ambientColor
    ambientLight.Range = 100
    ambientLight.Parent = self.worldModel
    
    -- 保存引用以便后续调整
    self.lightSources = {
        lightPart = lightPart,
        pointLight = pointLight,
        ambientLight = ambientLight
    }
end

--[[
    设置交互功能
]]
function Model3DViewer:_setupInteraction()
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local lastMousePosition = nil
    
    -- 鼠标拖拽旋转
    if self.enableRotation then
        local connection1 = self.viewportFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                lastMousePosition = input.Position
            end
        end)
        
        local connection2 = self.viewportFrame.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - lastMousePosition
                self:rotateModel(delta.X * 0.01, delta.Y * 0.01)
                lastMousePosition = input.Position
            end
        end)
        
        local connection3 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        table.insert(self.connections, connection1)
        table.insert(self.connections, connection2)
        table.insert(self.connections, connection3)
    end
    
    -- 鼠标滚轮缩放（可开关，默认关闭）
    self:setEnableZoom(self.enableZoom)
end

--[[
    设置自动旋转
]]
function Model3DViewer:_setupAutoRotation()
    local connection = RunService.Heartbeat:Connect(function(dt)
        if not self.isDestroyed and self.model then
            self.currentRotation = self.currentRotation + dt * self.rotationSpeed
            self:updateCameraPosition()
        end
    end)
    
    table.insert(self.connections, connection)
end

--[[
    设置要显示的3D模型
    @param model Model 要显示的模型
]]
function Model3DViewer:setModel(model)
    -- 检查必要的组件是否存在
    if not self.worldModel then
        warn("Model3DViewer: WorldModel不存在，无法设置模型")
        return
    end
    
    if not model then
        warn("Model3DViewer: 传入的模型为nil")
        return
    end
    
    -- 清理旧模型
    if self.model then
        self.model:Destroy()
    end
    
    self.model = model
    self.model.Parent = self.worldModel
    
    -- 自动调整相机距离并使相机对准模型中心
    self:_autoFitCamera()
    
    -- 更新相机位置
    self:updateCameraPosition()
end

--[[
    自动调整相机距离以适应模型大小
]]
--[[
    自动调整相机距离以适应模型大小（完整显示模型）
    - 根据ViewportFrame的宽高比和相机的垂直FOV，计算横向/纵向所需的距离
    - 取两者的最大值，并加上模型深度的一半作为前后缓冲，避免近裁剪导致“只显示一半”
]]
function Model3DViewer:_autoFitCamera()
    if not self.model or not self.camera or not self.viewportFrame then return end

    local cf, size = self.model:GetBoundingBox()

    -- 计算视口宽高比
    local vpSize = self.viewportFrame.AbsoluteSize
    local aspect = (vpSize.Y > 0) and (vpSize.X / vpSize.Y) or 1

    -- 垂直/水平视野角（弧度）
    local vFov = math.rad(self.camera.FieldOfView)
    local hFov = 2 * math.atan(math.tan(vFov / 2) * aspect)

    -- 横向和纵向分别需要的相机距离
    local halfWidth = size.X / 2
    local halfHeight = size.Y / 2
    local distH = halfWidth / math.tan(hFov / 2)
    local distV = halfHeight / math.tan(vFov / 2)

    -- 选择更大的距离，并加上深度缓冲避免近裁剪
    local baseDist = math.max(distH, distV)
    local depthPadding = size.Z / 2
    local paddingScale = 0.05 -- 额外5%的安全边距
    self.cameraDistance = math.max(1, baseDist + depthPadding) * (1 + paddingScale)
end

--[[
    更新相机位置
]]
--[[
    更新相机位置
    - 相机始终看向模型的包围盒中心，避免仅显示模型的一部分
]]
function Model3DViewer:updateCameraPosition()
    if not self.camera or not self.model then return end

    local angle = self.cameraAngle + Vector3.new(0, self.currentRotation, 0)
    local x = math.sin(angle.Y) * self.cameraDistance
    local z = math.cos(angle.Y) * self.cameraDistance
    local y = math.sin(angle.X) * self.cameraDistance

    -- 获取模型中心点
    local center, size = self:_getModelCenterAndSize()

    -- 让相机围绕中心点旋转与缩放
    local cameraPosition = center + Vector3.new(x, y, z)
    self.camera.CFrame = CFrame.lookAt(cameraPosition, center)

    -- 让主光源跟随模型中心（提升观看效果，可选）
    if self.lightSources and self.lightSources.lightPart then
        -- 将光源放在模型前上方位置
        local lightOffset = Vector3.new(0, size.Y * 0.8, math.max(6, size.Z))
        self.lightSources.lightPart.Position = center + lightOffset
    end
end

--[[
    获取模型的中心点与尺寸（包围盒）
    @return Vector3 center, Vector3 size
]]
function Model3DViewer:_getModelCenterAndSize()
    local cf, size = self.model:GetBoundingBox()
    return cf.Position, size
end

--[[
    旋转模型
    @param deltaX number X轴旋转增量
    @param deltaY number Y轴旋转增量
]]
function Model3DViewer:rotateModel(deltaX, deltaY)
    self.cameraAngle = self.cameraAngle + Vector3.new(deltaY, deltaX, 0)
    self:updateCameraPosition()
end

--[[
    缩放相机（改变距离）
    @param factor number 缩放因子
]]
function Model3DViewer:zoomCamera(factor)
    self.cameraDistance = math.clamp(self.cameraDistance * factor, 1, 100)
    self:updateCameraPosition()
end

--[[
    开关滚轮缩放功能（默认关闭）
    @param enabled boolean 是否启用滚轮缩放
    说明：
    - 启用时，绑定鼠标滚轮事件，使用 zoomCamera 调整相机距离
    - 关闭时，解绑事件，滚轮不再影响相机
]]
function Model3DViewer:setEnableZoom(enabled)
    self.enableZoom = enabled == true
    
    -- 先解绑已有的缩放事件
    if self.zoomConnection then
        self.zoomConnection:Disconnect()
        self.zoomConnection = nil
    end
    
    -- 如需启用并且视图存在，则重新绑定
    if self.enableZoom and self.viewportFrame then
        self.zoomConnection = self.viewportFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local zoomFactor = input.Position.Z > 0 and 0.9 or 1.1
                self:zoomCamera(zoomFactor)
            end
        end)
    end
end

--[[
    设置相机视野
    @param fov number 视野角度
]]
function Model3DViewer:setFieldOfView(fov)
    self.fieldOfView = fov
    if self.camera then
        self.camera.FieldOfView = fov
    end
end

--[[
    播放模型动画（如果模型有Humanoid）
    @param animationId string 动画ID
]]
function Model3DViewer:playAnimation(animationId)
    if not self.model then return end
    
    local humanoid = self.model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animationId
        
        local track = animator:LoadAnimation(animation)
        track:Play()
        
        return track
    end
end

--[[
    销毁查看器
]]
function Model3DViewer:destroy()
    self.isDestroyed = true
    
    -- 断开所有连接
    for _, connection in ipairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
    
    -- 断开缩放连接
    if self.zoomConnection then
        self.zoomConnection:Disconnect()
        self.zoomConnection = nil
    end
    
    -- 销毁UI组件
    if self.viewportFrame then
        self.viewportFrame:Destroy()
    end
    
    -- 清理引用
    self.model = nil
    self.worldModel = nil
    self.camera = nil
    self.viewportFrame = nil
    self.lightSources = nil
end

return Model3DViewer