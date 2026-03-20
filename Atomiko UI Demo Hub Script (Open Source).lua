-- Demo.lua

function safeloadstring(url)
	local code = game:HttpGet(url)
	local func, errorMessage = loadstring(code)

	if func then
		print("Script compiled! Executing...")
		return func()
	else
		warn("LOADSTRING FAILED: " .. tostring(errorMessage))
		return nil
	end
end

local ui = safeloadstring("https://raw.githubusercontent.com/SugaBlaz/UI-Library/refs/heads/main/Atomiko%20UI.lua")

local window1 = ui:CreateWindow({
	Name = "Demo", 
	Size = UDim2.new(0, 250, 0, 250), 
	Position = UDim2.new(0.5, 0, 0.5, 0)
})

local Toggle = window1:AddToggle({
	Text = "Toggle", 
	Default = true, 
	Callback = function(state)
		print(state)
	end
})

local Slider = window1:AddSlider({
	Text = "Slider", 
	Min = 0, 
	Max = 60, 
	Default = 9, 
	Callback = function(val)
		print(val)
	end
})

local button = window1:AddButton({
	Text = "Button", 
	Callback = function()
		print("clicked")
	end
})

local textbox = window1:AddTextbox({
	Text = "Something",
	Placeholder = "Enter",
	Callback = function(text)
		print(text)
	end
})

local label = window1:AddLabel({
	Text = "Testing"
})
