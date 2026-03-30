-- Atomiko.Lua

--[[

Atomiko UI /
SugaBlaz's Executor UI Library (Lite Version)

Made with passion by SugaDev

SugaDev      | Programming + Design

Version 1.2

Update Log:
	- Version 1 : Finsihed Library Main Frames
	- Version 1.1 : Added Buttons, Toggles, Sliders
	- Version 1.2 : Added Textboxes, Added Labels, Added :Set() to Toggles, Sliders, TextBoxes
	
Future Plans:
	- None, Finsihed!
	
PS: Code might be a little messy

]]

local SBEUILite = {}
SBEUILite.__index = SBEUILite

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local utils = {
	WriteFile = function(self, config)
		local path = config.Path
		local data = config.Data or ""
		if config.IsJSON and type(data) == "table" then
			data = HS:JSONEncode(data)
		else
			data = tostring(data)
		end
		writefile(path, data)
	end,
	
	GetImage = function(self, config)
		local fileName = config.Name .. ".png"
		if not isfile(fileName) then
			local s, content = pcall(function() return game:HttpGet(config.Url) end)

			if s then 
				self:WriteFile({Path = fileName, Data = content, IsJSON = false}) 
			end
		end
		return getcustomasset(fileName)
	end,
	
	ProtectGui = function(self, gui)
		local success, coreGui = pcall(function()
			return game:GetService("CoreGui") 
		end)

		if gethui then
			gui.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(gui) gui.Parent = CoreGui
		elseif success and coreGui then
			gui.Parent = CoreGui
		else
			gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		end
	end
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SBEUILiteGUI"
ScreenGui.ResetOnSpawn = false

utils:ProtectGui(ScreenGui)

local function MakeDraggable(topbarObject, object)
	local dragging, dragInput, dragStart, startPos

	topbarObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbarObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Window Class
local WindowClass = {}
WindowClass.__index = WindowClass

function SBEUILite:Intro()
	self.Image = Instance.new("ImageLabel")
	self.Image.Size = UDim2.new(0, 500, 0, 500)
	self.Image.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.Image.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Image.Image = utils:GetImage({Name = "SBEUILib", Url = "https://i.ibb.co/xK20Pwph/SBEUILib.png"})
	self.Image.BackgroundTransparency = 1
	self.Image.ImageTransparency = 0
	self.Image.Parent = ScreenGui
	self.Image.ZIndex = 999

	task.wait(2)

	local fadeInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local fadeTween = TweenService:Create(self.Image, fadeInfo, {
		ImageTransparency = 1
	})

	fadeTween:Play()

	fadeTween.Completed:Connect(function()
		self.Image:Destroy()
	end)
end

function SBEUILite:CreateWindow(options)
	options = options or {}
	local Name = options.Name or "Atomiko UI"
	local Size = options.Size or UDim2.new(0, 300, 0, 400)
	local Position = options.Position or UDim2.new(0.5, -150, 0.5, -200)

	local Window = setmetatable({}, WindowClass)

	SBEUILite:Intro()

	task.wait(1)

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = Name
	MainFrame.Size = Size
	MainFrame.Position = Position
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true 
	MainFrame.Parent = ScreenGui

	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1, 0, 0, 30)
	Topbar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Topbar.BorderSizePixel = 0
	Topbar.ZIndex = 2
	Topbar.Parent = MainFrame
	MakeDraggable(Topbar, MainFrame)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(Name)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.FredokaOne
	Title.TextSize = 18
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 2
	Title.Parent = Topbar

	local MinButton = Instance.new("TextButton")
	MinButton.Size = UDim2.new(0, 30, 0, 30)
	MinButton.Position = UDim2.new(1, -60, 0, 0)
	MinButton.BackgroundTransparency = 1
	MinButton.Text = "▼"
	MinButton.TextColor3 = Color3.fromRGB(150, 150, 150)
	MinButton.TextSize = 14
	MinButton.ZIndex = 2
	MinButton.Parent = Topbar

	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -30, 0, 0)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
	CloseButton.TextSize = 16
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.ZIndex = 2
	CloseButton.Parent = Topbar

	local Container = Instance.new("ScrollingFrame")
	Container.Size = UDim2.new(1, 0, 1, -30)
	Container.Position = UDim2.new(0, 0, 0, 30)
	Container.BackgroundTransparency = 1
	Container.BorderSizePixel = 0
	Container.ScrollBarThickness = 4
	Container.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.Parent = Container

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingLeft = UDim.new(0, 10)
	UIPadding.PaddingRight = UDim.new(0, 10)
	UIPadding.PaddingTop = UDim.new(0, 10)
	UIPadding.Parent = Container

	UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
	end)

	local ConfirmOverlay = Instance.new("Frame")
	ConfirmOverlay.Size = UDim2.new(1, 0, 1, -30)
	ConfirmOverlay.Position = UDim2.new(0, 0, 0, 30)
	ConfirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ConfirmOverlay.BackgroundTransparency = 0.3
	ConfirmOverlay.Visible = false
	ConfirmOverlay.Active = true
	ConfirmOverlay.ZIndex = 10
	ConfirmOverlay.Parent = MainFrame

	local ConfirmBox = Instance.new("Frame")
	ConfirmBox.Size = UDim2.new(0, 200, 0, 100)
	ConfirmBox.Position = UDim2.new(0.5, -100, 0.5, -50)
	ConfirmBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	ConfirmBox.BorderSizePixel = 0
	ConfirmBox.ZIndex = 11
	ConfirmBox.Parent = ConfirmOverlay

	local ConfirmLabel = Instance.new("TextLabel")
	ConfirmLabel.Size = UDim2.new(1, 0, 0, 50)
	ConfirmLabel.BackgroundTransparency = 1
	ConfirmLabel.Text = "Close this window?"
	ConfirmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ConfirmLabel.Font = Enum.Font.GothamBold
	ConfirmLabel.TextSize = 14
	ConfirmLabel.ZIndex = 12
	ConfirmLabel.Parent = ConfirmBox

	local YesBtn = Instance.new("TextButton")
	YesBtn.Size = UDim2.new(0, 80, 0, 30)
	YesBtn.Position = UDim2.new(0, 15, 1, -40)
	YesBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	YesBtn.BorderSizePixel = 0
	YesBtn.Text = "Yes"
	YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	YesBtn.Font = Enum.Font.GothamBold
	YesBtn.TextSize = 14
	YesBtn.ZIndex = 12
	YesBtn.Parent = ConfirmBox

	local NoBtn = Instance.new("TextButton")
	NoBtn.Size = UDim2.new(0, 80, 0, 30)
	NoBtn.Position = UDim2.new(1, -95, 1, -40)
	NoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	NoBtn.BorderSizePixel = 0
	NoBtn.Text = "No"
	NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	NoBtn.Font = Enum.Font.GothamBold
	NoBtn.TextSize = 14
	NoBtn.ZIndex = 12
	NoBtn.Parent = ConfirmBox

	local minimized = false
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	MinButton.MouseButton1Click:Connect(function()
		minimized = not minimized
		MinButton.Text = minimized and "▶" or "▼"

		if minimized then
			ConfirmOverlay.Visible = false
		end

		local targetSize = minimized and UDim2.new(Size.X.Scale, Size.X.Offset, 0, 30) or Size
		TweenService:Create(MainFrame, tweenInfo, {Size = targetSize}):Play()
	end)

	CloseButton.MouseButton1Click:Connect(function()
		if minimized then
			minimized = false
			MinButton.Text = "▼"
			TweenService:Create(MainFrame, tweenInfo, {Size = Size}):Play()
		end
		ConfirmOverlay.Visible = true
	end)

	YesBtn.MouseButton1Click:Connect(function()
		MainFrame:Destroy()
	end)

	NoBtn.MouseButton1Click:Connect(function()
		ConfirmOverlay.Visible = false
	end)

	Window.Container = Container
	return Window
end

-- ====================
-- ELEMENTS
-- ====================

function WindowClass:AddLabel(options)
	options = options or {}
	local Text = options.Text or "Label"

	local LabelFrame = Instance.new("Frame")
	LabelFrame.Size = UDim2.new(1, 0, 0, 25)
	LabelFrame.BackgroundTransparency = 1
	LabelFrame.Parent = self.Container

	local LabelText = Instance.new("TextLabel")
	LabelText.Size = UDim2.new(1, 0, 1, 0)
	LabelText.BackgroundTransparency = 1
	LabelText.Text = Text
	LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
	LabelText.Font = Enum.Font.GothamBold
	LabelText.TextSize = 14
	LabelText.TextXAlignment = Enum.TextXAlignment.Left
	LabelText.Parent = LabelFrame
end

function WindowClass:AddButton(options)
	options = options or {}
	local Text = options.Text or "Button"
	local Callback = options.Callback or function() end

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 0, 30)
	Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Button.BorderSizePixel = 0
	Button.Text = Text
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 14
	Button.Parent = self.Container

	Button.MouseButton1Click:Connect(Callback)
end

function WindowClass:AddToggle(options)
	options = options or {}
	local Text = options.Text or "Toggle"
	local Default = options.Default or false
	local Callback = options.Callback or function() end

	local ToggleObj = { State = Default }

	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
	ToggleFrame.BackgroundTransparency = 1
	ToggleFrame.Parent = self.Container

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -40, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local ToggleBox = Instance.new("TextButton")
	ToggleBox.Size = UDim2.new(0, 20, 0, 20)
	ToggleBox.Position = UDim2.new(1, -20, 0.5, -10)
	ToggleBox.BackgroundColor3 = Default and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(40, 40, 40)
	ToggleBox.BorderSizePixel = 0
	ToggleBox.Text = Default and "✔" or ""
	ToggleBox.TextColor3 = Color3.fromRGB(0, 0, 0)
	ToggleBox.Font = Enum.Font.GothamBlack
	ToggleBox.TextSize = 14
	ToggleBox.Parent = ToggleFrame

	function ToggleObj:Set(state)
		self.State = state
		ToggleBox.BackgroundColor3 = self.State and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(40, 40, 40)
		ToggleBox.Text = self.State and "✔" or ""
		Callback(self.State)
	end

	ToggleBox.MouseButton1Click:Connect(function()
		ToggleObj:Set(not ToggleObj.State)
	end)

	return ToggleObj
end

function WindowClass:AddTextbox(options)
	options = options or {}
	local Text = options.Text or "Textbox"
	local Placeholder = options.Placeholder or ""
	local Callback = options.Callback or function() end

	local TextboxObj = {}

	local BoxFrame = Instance.new("Frame")
	BoxFrame.Size = UDim2.new(1, 0, 0, 30)
	BoxFrame.BackgroundTransparency = 1
	BoxFrame.Parent = self.Container

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.5, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = BoxFrame

	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(0.5, 0, 0, 24)
	Input.Position = UDim2.new(0.5, 0, 0.5, -12)
	Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Input.BorderSizePixel = 0
	Input.Text = ""
	Input.PlaceholderText = Placeholder
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.Font = Enum.Font.Gotham
	Input.TextSize = 13
	Input.Parent = BoxFrame

	function TextboxObj:Set(val)
		Input.Text = tostring(val)
		Callback(Input.Text)
	end

	Input.FocusLost:Connect(function()
		Callback(Input.Text)
	end)

	return TextboxObj
end

function WindowClass:AddSlider(options)
	options = options or {}
	local Text = options.Text or "Slider"
	local Min = options.Min or 0
	local Max = options.Max or 100
	local Default = options.Default or Min
	local Callback = options.Callback or function() end

	local SliderObj = { Value = Default }

	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, 0, 0, 45)
	SliderFrame.BackgroundTransparency = 1
	SliderFrame.Parent = self.Container

	local ValueBox = Instance.new("TextBox")
	ValueBox.Size = UDim2.new(0, 40, 0, 20)
	ValueBox.Position = UDim2.new(0, 0, 0, 0)
	ValueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	ValueBox.BorderSizePixel = 0
	ValueBox.Text = tostring(Default)
	ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	ValueBox.Font = Enum.Font.Gotham
	ValueBox.TextSize = 12
	ValueBox.Parent = SliderFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -50, 0, 20)
	Label.Position = UDim2.new(0, 50, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame

	local BarBg = Instance.new("Frame")
	BarBg.Size = UDim2.new(1, 0, 0, 10)
	BarBg.Position = UDim2.new(0, 0, 1, -15)
	BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	BarBg.BorderSizePixel = 0
	BarBg.Parent = SliderFrame

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	Fill.BorderSizePixel = 0
	Fill.Parent = BarBg

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.BackgroundTransparency = 1
	Button.Text = ""
	Button.Parent = BarBg

	function SliderObj:Set(val)
		val = math.clamp(tonumber(val) or Min, Min, Max)
		self.Value = val
		ValueBox.Text = tostring(math.floor(val))
		Fill.Size = UDim2.new((val - Min) / (Max - Min), 0, 1, 0)
		Callback(self.Value)
	end

	local dragging = false
	Button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = UserInputService:GetMouseLocation().X
			local barPos = BarBg.AbsolutePosition.X
			local barSize = BarBg.AbsoluteSize.X
			local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)

			local newValue = Min + (percent * (Max - Min))
			SliderObj:Set(newValue)
		end
	end)

	ValueBox.FocusLost:Connect(function()
		SliderObj:Set(ValueBox.Text)
	end)

	return SliderObj
end

return SBEUILite
