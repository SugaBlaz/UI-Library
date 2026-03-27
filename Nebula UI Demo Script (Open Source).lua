-- Demo.lua

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SugaBlaz/UI-Library/refs/heads/main/Nebula%20UI.lua"))()
-- If using locally in Studio, use: local Library = require(game.ReplicatedStorage.NebulaUI) or like that.

local Window = Library:CreateWindow({
	Name = "Nebula Demo",
	Theme = "Midnight",
	SaveName = "Nebula_Config",
	Size = UDim2.new(0.5, 0, 0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	KeySystem = true, 
	KeySettings = {
		Title = "Key System",
		Key = "1234",
		InsertKeyAtEnd = false,
		SaveKey = true, 
		KeyLink = "https://discord.gg/yourserver", 
		Callback = function()
			print("Authenticated!")
		end
	}
})

-- // TABS //
local Tab1 = Window:CreateTab("Tab 1")
local Tab2 = Window:CreateTab("Tab 2")
local Tab3 = Window:CreateTab("Tab 3")

-- // TAB 1 //
Tab1:CreateSection("Section 1")

local Toggle = Tab1:CreateToggle({
	Name = "Toggle",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(State)
		print("Toggle is:", State)
	end
})

local Keybind = Tab1:CreateKeybind({
	Name = "Keybind",
	CurrentKey = "E",
	Flag = "Keybind1",
	Callback = function(Key)
		print("Keybind pressed:", Key)
	end
})

local Slider = Tab1:CreateSlider({
	Name = "Slider",
	Range = {0, 100},
	CurrentValue = 50,
	Flag = "Slider1",
	Callback = function(Value)
		print("Slider value:", Value)
	end
})

local Dropdown = Tab1:CreateDropdown({
	Name = "Dropdown",
	Options = {"Option 1", "Option 2", "Option 3"},
	CurrentOption = "Option 1",
	Flag = "Dropdown1",
	Callback = function(Option)
		print("Selected:", Option)
	end
})

-- // TAB 2 //
Tab2:CreateSection("Section 2")

local MultiDropdown = Tab2:CreateMultiDropdown({
	Name = "Multi Dropdown",
	Options = {"Item A", "Item B", "Item C"},
	CurrentOptions = {"Item A"},
	Flag = "Multi1",
	Callback = function(Selected)
		print("Selected items:", table.concat(Selected, ", "))
	end
})

local ColorPicker = Tab2:CreateColorPicker({
	Name = "Color Picker",
	Color = Color3.fromRGB(255, 255, 255),
	Flag = "Color1",
	Callback = function(Color)
		print("Color picked:", Color)
	end
})

-- // TAB 3 //
Tab3:CreateSection("Section 3")

local Textbox = Tab3:CreateTextbox({
	Name = "Textbox",
	CurrentValue = "",
	PlaceholderText = "Type here...",
	Flag = "Text1",
	Callback = function(Text)
		print("Textbox input:", Text)
	end
})

local Label = Tab3:CreateLabel("This is a Label")

Tab3:CreateButton({
	Name = "Button 1 (Notify)",
	Callback = function()
		Library:Notify({
			Title = "Notification",
			Text = "This is a test notification.",
			Duration = 3
		})
	end
})

-- // SETTINGS //
Window.SettingsTab:CreateSection("Library Controls")

Window.SettingsTab:CreateButton({
	Name = "Destroy UI",
	Callback = function()
		Library:Destroy()
	end
})
