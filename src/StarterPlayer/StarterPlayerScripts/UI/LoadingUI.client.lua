local _screenUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("LoadingUI")

task.delay(5, function()
	_screenUI.Enabled = false
end)