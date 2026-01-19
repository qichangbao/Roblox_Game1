local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

--[[
    初始化 Shift 键监听与耐力系统
    行为：
    - 监听 Shift 按下与松开
    - 按下时开始消耗耐力，松开时开始恢复
    - 启动耐力更新循环
    返回：void
]]
local function InitShiftAndEndurance()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			Knit.GetService("PlayerService"):SwitchWalkOrRun(1)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			Knit.GetService("PlayerService"):SwitchWalkOrRun(0)
		end
	end)
end

-- 在合适位置调用初始化（确保 _enduranceFrame 已经赋值）
InitShiftAndEndurance()

Knit.OnStart():andThen(function()
	Knit.GetController("UIController").SwitchRun:Connect(function(isRun)
		if isRun then
			Knit.GetService("PlayerService"):SwitchWalkOrRun(1)
		else
			Knit.GetService("PlayerService"):SwitchWalkOrRun(0)
		end
	end)
end)