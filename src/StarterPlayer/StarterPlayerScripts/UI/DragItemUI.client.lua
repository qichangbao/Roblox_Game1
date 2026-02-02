local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("DragItemUI")
_screenGui.Enabled = false

local _frame = _screenGui:WaitForChild("Frame")
local _dragImage = _frame:WaitForChild("DragImage")
local _discardLabel = _frame:WaitForChild("DiscardLabel")

Knit.OnStart():andThen(function()
	local UIController = Knit.GetController("UIController")
	UIController.ShowDragUI:Connect(function(icon, pos, discardLabelShow)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		_dragImage.Image = icon
		_discardLabel.Visible = false

		local absoluteSize = _dragImage.AbsoluteSize
		_frame.Position = UDim2.new(0, pos.X - absoluteSize.X / 2, 0, pos.Y - absoluteSize.Y)
	end)
	UIController.MoveDragUI:Connect(function(pos)
		local absoluteSize = _dragImage.AbsoluteSize
		_frame.Position = UDim2.new(0, pos.X - absoluteSize.X / 2, 0, pos.Y - absoluteSize.Y)
	end)
	UIController.HideDragUI:Connect(function()
		_screenGui.Enabled = false
	end)
end)