local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Knit"))
local Interface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('Interface'))
local TweenInterface = require(ReplicatedStorage:WaitForChild('ToolFolder'):WaitForChild('TweenInterface'))

local _screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("FeedbackUI")
local _frame = _screenGui:WaitForChild("Frame")
local _textBox = _frame:WaitForChild("TextBox")

local _titleImage = _frame:WaitForChild("TitleImage")
local _closeButton = _titleImage:WaitForChild("CloseButton")
_closeButton.MouseButton1Click:Connect(function()
	_screenGui.Enabled = false
end)
TweenInterface.SetupHoverScale(_closeButton, _closeButton)

local submitButton = _frame:WaitForChild("SubmitButton")
submitButton.MouseButton1Click:Connect(function()
	warn("Feedback:", _textBox.Text)
end)
TweenInterface.SetupHoverScale(submitButton, submitButton)

Knit.OnStart():andThen(function()
	local UIController = Knit.GetController("UIController")
	UIController.ShowFeedbackUI:Connect(function(gold)
		if _screenGui.Enabled then return end
		_screenGui.Enabled = true
		TweenInterface.AnimateUIShowScale(_frame)
		_textBox.Text = "Please enter the text"

		local ui = game:GetService("SoundService"):WaitForChild("UI")
		local sound = ui:WaitForChild("OpenUI")
		sound:Play()
	end)
end)