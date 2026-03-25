-- Nebula.lua

--[[

Nebula UI

Made with passion by SugaDev

SugaDev      | Programming + Design
AzkaDev      | Design

Version 1.3

Whats special about this is that it can work in roblox studio,
so you can test your scripts in studio

Update Log:
	Verison 1:
		- Main UI Framework completed

	Version 1.1:
    - Code revamp

  Version 1.2:
    - Added Key system
    - Added Intro

  Version 1.3:
    - Made Size configurable
    - Made Position configurable

  Version 1.4:
	- Added Close, Minimize buttons
	- Added Close Cofirmation Popup
		
Future Improvments:
    - None for the moment

]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local isStudio = RunService:IsStudio()
local isExploit = (writefile ~= nil) or (gethui ~= nil)

local ParentGui
if isStudio then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
else
    ParentGui = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(CoreGui) and CoreGui) or CoreGui
end

local Utility = {}
function Utility:Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then inst[k] = v end
    end
    if properties.Parent then inst.Parent = properties.Parent end
    return inst
end

function Utility:Tween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:GetImage(config)
    if isStudio then return "" end 
    local fileName = config.Name .. ".png"
    if isfile and not isfile(fileName) then
        local s, content = pcall(function() return game:HttpGet(config.Url) end)
        if s and writefile then writefile(fileName, content) end
    end
    if getcustomasset and isfile and isfile(fileName) then
        return getcustomasset(fileName)
    end
    return ""
end

local Library = {
    Themes = {
        Custom = { Main = Color3.fromRGB(20, 20, 25), Sidebar = Color3.fromRGB(15, 15, 20), Element = Color3.fromRGB(30, 30, 35), Accent = Color3.fromRGB(100, 255, 100), Text = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(150, 150, 150) },
        Dark = { Main = Color3.fromRGB(25, 25, 30), Sidebar = Color3.fromRGB(20, 20, 25), Element = Color3.fromRGB(35, 35, 40), Accent = Color3.fromRGB(100, 100, 255), Text = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(150, 150, 150) },
        Light = { Main = Color3.fromRGB(240, 240, 245), Sidebar = Color3.fromRGB(220, 220, 225), Element = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(80, 80, 200), Text = Color3.fromRGB(20, 20, 20), TextDark = Color3.fromRGB(100, 100, 100) },
        Midnight = { Main = Color3.fromRGB(18, 18, 28), Sidebar = Color3.fromRGB(12, 12, 20), Element = Color3.fromRGB(30, 30, 45), Accent = Color3.fromRGB(138, 43, 226), Text = Color3.fromRGB(230, 230, 240), TextDark = Color3.fromRGB(130, 130, 150) },
        Mint = { Main = Color3.fromRGB(25, 28, 25), Sidebar = Color3.fromRGB(18, 20, 18), Element = Color3.fromRGB(35, 40, 35), Accent = Color3.fromRGB(0, 255, 150), Text = Color3.fromRGB(240, 255, 240), TextDark = Color3.fromRGB(120, 150, 120) }
    },
    CurrentTheme = "Midnight",
    ThemeObjects = {},
    Flags = {},
    FlagCallbacks = {},
    SaveFileName = "Nebula_Save.json",
    KeyFileName = "Nebula_Key.txt"
}

function Library:AddCustomTheme(name, colorTable) self.Themes[name] = colorTable end

function Library:RegisterTheme(instance, prop, colorKey)
    table.insert(self.ThemeObjects, {Inst = instance, Prop = prop, Key = colorKey})
    instance[prop] = self.Themes[self.CurrentTheme][colorKey]
end

function Library:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.CurrentTheme = themeName
    local t = self.Themes[themeName]
    for _, obj in ipairs(self.ThemeObjects) do
        if obj.Inst and obj.Inst.Parent then Utility:Tween(obj.Inst, {[obj.Prop] = t[obj.Key]}, 0.3) end
    end
end

function Library:CheckKey(key, target, insertAtEnd)
    if isStudio then return true end
    if key == "" or key == nil then return false end
    if not string.find(target, "http://") and not string.find(target, "https://") then
        return key == target
    end

    local url = target
    if insertAtEnd then url = url .. key end

    local s, res = pcall(function() return game:HttpGet(url) end)
    if s and res then
        local jsonSuccess, data = pcall(function() return HttpService:JSONDecode(res) end)
        if jsonSuccess and type(data) == "table" then
            return data.success == true or data.valid == true
        else
            return key == string.gsub(res, "%s+", "")
        end
    end
    return false
end

function Library:Save()
    local success, json = pcall(function() return HttpService:JSONEncode(self.Flags) end)
    if success then
        if isStudio then
        elseif isExploit and writefile then writefile(self.SaveFileName, json) end
    end
end

function Library:Load()
    if isStudio then return end
    if isExploit and readfile and isfile and isfile(self.SaveFileName) then
        local success, json = pcall(function() return readfile(self.SaveFileName) end)
        if success then
            local data = HttpService:JSONDecode(json)
            for flag, value in pairs(data) do
                self.Flags[flag] = value
                if self.FlagCallbacks[flag] then self.FlagCallbacks[flag](value) end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr) if plr == LocalPlayer then Library:Save() end end)

function Library:CreateWindow(options)
    local title = options.Name or "Nebula UI"
    self.CurrentTheme = options.Theme or "Midnight"
    self.SaveFileName = (options.SaveName or "Nebula")..".json"
    self.KeyFileName = (options.SaveName or "Nebula").."_Key.txt"

    local uiSize = type(options.Size) == "userdata" and options.Size or UDim2.new(0, 600, 0, 400)
    local xOffset = uiSize.X.Offset
    local yOffset = uiSize.Y.Offset
    local uiPos = type(options.Position) == "userdata" and options.Position or UDim2.new(0.5, -(xOffset/2), 0.5, -(yOffset/2))

    local oldGui = ParentGui:FindFirstChild("Nebula")
    if oldGui then oldGui:Destroy() end

    local NebulaGui = Utility:Create("ScreenGui", { Name = "Nebula", Parent = ParentGui, ResetOnSpawn = false, DisplayOrder = 999 })
    
    local NotifContainer = Utility:Create("Frame", { Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -320, 0, 20), BackgroundTransparency = 1, Parent = NebulaGui })
    local NotifLayout = Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = NotifContainer })

    function Library:Notify(notifOptions)
        local NFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = self.Themes[self.CurrentTheme].Element, Parent = NotifContainer, BackgroundTransparency = 1 })
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = NFrame })
        self:RegisterTheme(NFrame, "BackgroundColor3", "Element")
        
        local TitleLbl = Utility:Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = notifOptions.Title or "Notification", TextColor3 = self.Themes[self.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, Parent = NFrame })
        self:RegisterTheme(TitleLbl, "TextColor3", "Accent")
        
        local DescLbl = Utility:Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, Text = notifOptions.Text or "", TextColor3 = self.Themes[self.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1, Parent = NFrame })
        self:RegisterTheme(DescLbl, "TextColor3", "Text")

        Utility:Tween(NFrame, {BackgroundTransparency = 0}, 0.3)
        Utility:Tween(TitleLbl, {TextTransparency = 0}, 0.3)
        Utility:Tween(DescLbl, {TextTransparency = 0}, 0.3)

        task.delay(notifOptions.Duration or 3, function()
            local fade = Utility:Tween(NFrame, {BackgroundTransparency = 1}, 0.3)
            Utility:Tween(TitleLbl, {TextTransparency = 1}, 0.3)
            Utility:Tween(DescLbl, {TextTransparency = 1}, 0.3)
            fade.Completed:Connect(function() NFrame:Destroy() end)
        end)
    end

    local MainFrame = Utility:Create("Frame", { Size = uiSize, Position = uiPos, BackgroundColor3 = self.Themes[self.CurrentTheme].Main, Parent = NebulaGui, ClipsDescendants = true, Visible = false })
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    Library:RegisterTheme(MainFrame, "BackgroundColor3", "Main")

    local Sidebar = Utility:Create("Frame", { Size = UDim2.new(0, 140, 1, 0), BackgroundColor3 = self.Themes[self.CurrentTheme].Sidebar, Parent = MainFrame })
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Sidebar })
    local SidebarPatch = Utility:Create("Frame", { Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0, BackgroundColor3 = self.Themes[self.CurrentTheme].Sidebar, Parent = Sidebar })
    Library:RegisterTheme(Sidebar, "BackgroundColor3", "Sidebar")
    Library:RegisterTheme(SidebarPatch, "BackgroundColor3", "Sidebar")
    
    local TitleLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = title, TextColor3 = self.Themes[self.CurrentTheme].Text, Font = Enum.Font.GothamBold, TextSize = 16, Parent = Sidebar })
    Library:RegisterTheme(TitleLabel, "TextColor3", "Text")

    local TabContainer = Utility:Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar })
    local TabListLayout = Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = TabContainer })

    local ContentContainer = Utility:Create("Frame", { Size = UDim2.new(1, -140, 1, 0), Position = UDim2.new(0, 140, 0, 0), BackgroundTransparency = 1, Parent = MainFrame })
    Utility:MakeDraggable(TitleLabel, MainFrame)

    local WindowControls = Utility:Create("Frame", { Size = UDim2.new(0, 60, 0, 30), Position = UDim2.new(1, -65, 0, 5), BackgroundTransparency = 1, Parent = MainFrame, ZIndex = 10 })
    local MinBtn = Utility:Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "-", TextColor3 = self.Themes[self.CurrentTheme].TextDark, Font = Enum.Font.GothamBold, TextSize = 18, Parent = WindowControls, ZIndex = 10 })
    local CloseBtn = Utility:Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, Text = "X", TextColor3 = self.Themes[self.CurrentTheme].TextDark, Font = Enum.Font.GothamBold, TextSize = 14, Parent = WindowControls, ZIndex = 10 })
    Library:RegisterTheme(MinBtn, "TextColor3", "TextDark")
    Library:RegisterTheme(CloseBtn, "TextColor3", "TextDark")

    local MinIcon = Utility:Create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 20, 0, 20), BackgroundColor3 = self.Themes[self.CurrentTheme].Main, Text = "N", TextColor3 = self.Themes[self.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 18, Parent = NebulaGui, Visible = false })
    Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = MinIcon })
    Utility:MakeDraggable(MinIcon, MinIcon)
    Library:RegisterTheme(MinIcon, "BackgroundColor3", "Main")
    Library:RegisterTheme(MinIcon, "TextColor3", "Accent")

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MinIcon.Visible = true
    end)

    MinIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinIcon.Visible = false
    end)

    local PromptOverlay = Utility:Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.5, Parent = MainFrame, Visible = false, ZIndex = 50 })
    local PromptBox = Utility:Create("Frame", { Size = UDim2.new(0, 250, 0, 120), Position = UDim2.new(0.5, -125, 0.5, -60), BackgroundColor3 = self.Themes[self.CurrentTheme].Main, Parent = PromptOverlay, ZIndex = 51 })
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = PromptBox })
    Library:RegisterTheme(PromptBox, "BackgroundColor3", "Main")

    local PromptLbl = Utility:Create("TextLabel", { Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Text = "Close Nebula UI?", TextColor3 = self.Themes[self.CurrentTheme].Text, Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = PromptBox, ZIndex = 52 })
    Library:RegisterTheme(PromptLbl, "TextColor3", "Text")

    local PromptYes = Utility:Create("TextButton", { Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0, 15, 0, 70), BackgroundColor3 = self.Themes[self.CurrentTheme].Accent, Text = "Yes", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 13, Parent = PromptBox, ZIndex = 52 })
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = PromptYes })
    Library:RegisterTheme(PromptYes, "BackgroundColor3", "Accent")

    local PromptNo = Utility:Create("TextButton", { Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(1, -115, 0, 70), BackgroundColor3 = self.Themes[self.CurrentTheme].Element, Text = "No", TextColor3 = self.Themes[self.CurrentTheme].Text, Font = Enum.Font.GothamBold, TextSize = 13, Parent = PromptBox, ZIndex = 52 })
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = PromptNo })
    Library:RegisterTheme(PromptNo, "BackgroundColor3", "Element")
    Library:RegisterTheme(PromptNo, "TextColor3", "Text")

    CloseBtn.MouseButton1Click:Connect(function() PromptOverlay.Visible = true end)
    PromptNo.MouseButton1Click:Connect(function() PromptOverlay.Visible = false end)
    PromptYes.MouseButton1Click:Connect(function() NebulaGui:Destroy() end)

    local Window = { Tabs = {}, CurrentTab = nil }

    task.spawn(function()
        local function OpenMainUI()
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            Utility:Tween(MainFrame, {Size = uiSize}, 0.4)
            Library:Load()
        end

        if options.Intro and options.Intro.Enabled then
            local IntroImg = Utility:Create("ImageLabel", { Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.5, -150, 0.5, -150), BackgroundTransparency = 1, ImageTransparency = 1, Parent = NebulaGui })
            
            local assetUrl = Utility:GetImage({Name = options.Intro.Name or "IntroLogo", Url = options.Intro.ImageUrl})
            if assetUrl ~= "" then IntroImg.Image = assetUrl end

            Utility:Tween(IntroImg, {ImageTransparency = 0}, 1)
            task.wait(2.5)
            local fadeOut = Utility:Tween(IntroImg, {ImageTransparency = 1}, 1)
            fadeOut.Completed:Connect(function() IntroImg:Destroy() end)
            task.wait(1)
        end

        if options.KeySystem and options.KeySettings then
            local ks = options.KeySettings
            local savedKey = (isfile and isfile(Library.KeyFileName)) and readfile(Library.KeyFileName) or nil
            
            if savedKey and Library:CheckKey(savedKey, ks.Key, ks.InsertKeyAtEnd) then
                OpenMainUI()
                return
            end

            local KeyFrame = Utility:Create("Frame", { Size = UDim2.new(0, 340, 0, 180), Position = UDim2.new(0.5, -170, 0.5, -90), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Main, Parent = NebulaGui })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = KeyFrame })
            Library:RegisterTheme(KeyFrame, "BackgroundColor3", "Main")

            local KeyTitle = Utility:Create("TextLabel", { Size = UDim2.new(1, -20, 0, 35), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = (ks.Title or "Key System"), TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = KeyFrame })
            Library:RegisterTheme(KeyTitle, "TextColor3", "Text")

            local KeyBox = Utility:Create("TextBox", { Size = UDim2.new(0.9, 0, 0, 40), Position = UDim2.new(0.05, 0, 0.35, 0), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, TextColor3 = Library.Themes[Library.CurrentTheme].Text, PlaceholderText = "Paste Key...", Font = Enum.Font.GothamMedium, TextSize = 14, Text = "", Parent = KeyFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyBox })
            Library:RegisterTheme(KeyBox, "BackgroundColor3", "Sidebar")
            Library:RegisterTheme(KeyBox, "TextColor3", "Text")

            local BtnContainer = Utility:Create("Frame", { Size = UDim2.new(0.9, 0, 0, 35), Position = UDim2.new(0.05, 0, 0.7, 0), BackgroundTransparency = 1, Parent = KeyFrame })
            local BtnLayout = Utility:Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = BtnContainer })

            local VerifyBtn = Utility:Create("TextButton", { Size = UDim2.new(0.48, 0, 1, 0), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent, Text = "Verify", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 14, Parent = BtnContainer })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = VerifyBtn })
            Library:RegisterTheme(VerifyBtn, "BackgroundColor3", "Accent")

            local GetKeyBtn = Utility:Create("TextButton", { Size = UDim2.new(0.48, 0, 1, 0), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Text = "Get Key", TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.GothamBold, TextSize = 14, Parent = BtnContainer })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = GetKeyBtn })
            Library:RegisterTheme(GetKeyBtn, "BackgroundColor3", "Element")
            Library:RegisterTheme(GetKeyBtn, "TextColor3", "Text")

            GetKeyBtn.MouseButton1Click:Connect(function()
                if not setclipboard then return end
                local url = ks.KeyLink or ""
                if ks.Addons and type(ks.Addons) == "table" then
                    local isFirst = not string.find(url, "?")
                    for k, v in pairs(ks.Addons) do
                        url = url .. (isFirst and "?" or "&") .. tostring(k) .. "=" .. tostring(v)
                        isFirst = false
                    end
                end
                setclipboard(url)
                Library:Notify({ Title = "Link Copied", Text = "The Key Link has been copied to your clipboard.", Duration = 3 })
            end)

            VerifyBtn.MouseButton1Click:Connect(function()
                VerifyBtn.Text = "Checking..."
                if Library:CheckKey(KeyBox.Text, ks.Key, ks.InsertKeyAtEnd) then
                    VerifyBtn.Text = "Success!"
                    VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    if ks.SaveKey and writefile then writefile(Library.KeyFileName, KeyBox.Text) end
                    task.wait(0.5)
                    Utility:Tween(KeyFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3).Completed:Connect(function()
                        KeyFrame:Destroy()
                        OpenMainUI()
                        if ks.Callback then ks.Callback() end
                    end)
                else
                    VerifyBtn.Text = "Invalid"
                    VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    task.wait(1)
                    VerifyBtn.Text = "Verify"
                    Library:RegisterTheme(VerifyBtn, "BackgroundColor3", "Accent")
                end
            end)

            Utility:MakeDraggable(KeyTitle, KeyFrame)
        else
            OpenMainUI()
        end
    end)

    function Window:CreateTab(name)
        local TabBtn = Utility:Create("TextButton", { Size = UDim2.new(0.9, 0, 0, 30), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Text = "  " .. name, TextColor3 = Library.Themes[Library.CurrentTheme].TextDark, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = TabContainer, BackgroundTransparency = 1 })
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })
        Library:RegisterTheme(TabBtn, "TextColor3", "TextDark")

        local TabContent = Utility:Create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Themes[Library.CurrentTheme].Accent, Visible = false, Parent = ContentContainer })
        Library:RegisterTheme(TabContent, "ScrollBarImageColor3", "Accent")
        local ContentLayout = Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = TabContent })

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10) end)

        local TabObj = { Name = name, Btn = TabBtn, Content = TabContent }

        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Utility:Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = Library.Themes[Library.CurrentTheme].TextDark}, 0.2)
            end
            TabContent.Visible = true
            Utility:Tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = Library.Themes[Library.CurrentTheme].Text}, 0.2)
            Window.CurrentTab = TabObj
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        table.insert(Window.Tabs, TabObj)
        if #Window.Tabs == 1 then SelectTab() end

        function TabObj:CreateSection(secName)
            local SecFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = TabContent })
            local SecLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = secName, TextColor3 = Library.Themes[Library.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = SecFrame })
            Library:RegisterTheme(SecLabel, "TextColor3", "Accent")
        end

        function TabObj:CreateLabel(text)
            local LblFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = LblFrame })
            Library:RegisterTheme(LblFrame, "BackgroundColor3", "Element")
            local Label = Utility:Create("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = LblFrame })
            Library:RegisterTheme(Label, "TextColor3", "Text")
            return { Set = function(self, newText) Label.Text = newText end }
        end

        function TabObj:CreateButton(btnOptions)
            local BtnFrame = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Text = "", AutoButtonColor = false, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = BtnFrame })
            Library:RegisterTheme(BtnFrame, "BackgroundColor3", "Element")
            local BtnLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = " " .. btnOptions.Name, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.GothamSemibold, TextSize = 13, Parent = BtnFrame })
            Library:RegisterTheme(BtnLabel, "TextColor3", "Text")
            
            BtnFrame.MouseButton1Down:Connect(function() Utility:Tween(BtnFrame, {Size = UDim2.new(0.98, 0, 0, 33)}, 0.1) end)
            BtnFrame.MouseButton1Up:Connect(function() Utility:Tween(BtnFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.1); if btnOptions.Callback then btnOptions.Callback() end end)
        end

        function TabObj:CreateToggle(toggleOptions)
            local flag = toggleOptions.Flag or toggleOptions.Name
            local state = toggleOptions.CurrentValue or false
            Library.Flags[flag] = state

            local TogFrame = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Text = "", AutoButtonColor = false, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TogFrame })
            Library:RegisterTheme(TogFrame, "BackgroundColor3", "Element")
            local TogLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 35, 0, 0), BackgroundTransparency = 1, Text = toggleOptions.Name, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TogFrame })
            Library:RegisterTheme(TogLabel, "TextColor3", "Text")

            local OuterCircle = Utility:Create("Frame", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 10, 0.5, -8), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Parent = TogFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = OuterCircle })
            Library:RegisterTheme(OuterCircle, "BackgroundColor3", "Sidebar")
            
            local InnerCircle = Utility:Create("Frame", { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent, Parent = OuterCircle })
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = InnerCircle })
            Library:RegisterTheme(InnerCircle, "BackgroundColor3", "Accent")

            local function Fire(newState)
                state = newState
                Library.Flags[flag] = state
                if state then Utility:Tween(InnerCircle, {Size = UDim2.new(0, 10, 0, 10)}, 0.2) else Utility:Tween(InnerCircle, {Size = UDim2.new(0, 0, 0, 0)}, 0.2) end
                if toggleOptions.Callback then toggleOptions.Callback(state) end
            end

            TogFrame.MouseButton1Click:Connect(function() Fire(not state) end)
            Library.FlagCallbacks[flag] = Fire
            Fire(state)
            return { Set = function(self, val) Fire(val) end }
        end

        function TabObj:CreateSlider(sliderOptions)
            local flag = sliderOptions.Flag or sliderOptions.Name
            local min, max = sliderOptions.Range[1], sliderOptions.Range[2]
            local val = sliderOptions.CurrentValue or min
            Library.Flags[flag] = val

            local SldFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SldFrame })
            Library:RegisterTheme(SldFrame, "BackgroundColor3", "Element")

            local TopFrame = Utility:Create("Frame", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Parent = SldFrame })
            local TopLayout = Utility:Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, Parent = TopFrame })
            
            local ValueBox = Utility:Create("TextBox", { Size = UDim2.new(0, 40, 0, 20), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Text = tostring(val), Font = Enum.Font.Gotham, TextSize = 12, Parent = TopFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ValueBox })
            Library:RegisterTheme(ValueBox, "BackgroundColor3", "Sidebar")
            Library:RegisterTheme(ValueBox, "TextColor3", "Text")

            local Title = Utility:Create("TextLabel", { Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, Text = sliderOptions.Name, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopFrame })
            Library:RegisterTheme(Title, "TextColor3", "Text")

            local SliderBg = Utility:Create("TextButton", { Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Text = "", AutoButtonColor = false, Parent = SldFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBg })
            Library:RegisterTheme(SliderBg, "BackgroundColor3", "Sidebar")

            local SliderFill = Utility:Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent, Parent = SliderBg })
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFill })
            Library:RegisterTheme(SliderFill, "BackgroundColor3", "Accent")

            local function Fire(newVal)
                newVal = math.clamp(tonumber(newVal) or min, min, max)
                local increment = sliderOptions.Increment or 1
                newVal = math.floor(newVal / increment + 0.5) * increment
                val = newVal
                Library.Flags[flag] = val
                ValueBox.Text = tostring(val)
                local percent = (val - min) / (max - min)
                Utility:Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                if sliderOptions.Callback then sliderOptions.Callback(val) end
            end

            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local dragging = true
                    local function update()
                        local pct = math.clamp((Mouse.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                        Fire(min + ((max - min) * pct))
                    end
                    update()
                    local move, release
                    move = Mouse.Move:Connect(update)
                    release = UserInputService.InputEnded:Connect(function(e) if e.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; move:Disconnect(); release:Disconnect() end end)
                end
            end)
            ValueBox.FocusLost:Connect(function() Fire(ValueBox.Text) end)
            Library.FlagCallbacks[flag] = Fire
            Fire(val)
            return { Set = function(self, newVal) Fire(newVal) end }
        end

        function TabObj:CreateDropdown(dropOptions)
            local flag = dropOptions.Flag or dropOptions.Name
            local options = dropOptions.Options or {}
            local val = dropOptions.CurrentOption or options[1]
            Library.Flags[flag] = val

            local DropFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, ClipsDescendants = true, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DropFrame })
            Library:RegisterTheme(DropFrame, "BackgroundColor3", "Element")

            local DropBtn = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "", Parent = DropFrame })
            local DropLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = dropOptions.Name .. ": " .. tostring(val), TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropBtn })
            Library:RegisterTheme(DropLabel, "TextColor3", "Text")

            local OptionsContainer = Utility:Create("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -40), Position = UDim2.new(0, 5, 0, 35), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = DropFrame })
            local OptionsLayout = Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = OptionsContainer })
            
            local isOpen = false
            local function toggleDrop()
                isOpen = not isOpen
                local targetHeight = isOpen and math.clamp(#options * 28 + 45, 35, 150) or 35
                Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
            end
            DropBtn.MouseButton1Click:Connect(toggleDrop)

            local function Fire(newVal)
                val = newVal
                Library.Flags[flag] = val
                DropLabel.Text = dropOptions.Name .. ": " .. tostring(val)
                if dropOptions.Callback then dropOptions.Callback(val) end
            end

            local function Refresh(newOptions)
                options = newOptions or {}
                for _, child in pairs(OptionsContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for _, opt in ipairs(options) do
                    local OptBtn = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Text = opt, TextColor3 = Library.Themes[Library.CurrentTheme].TextDark, Font = Enum.Font.Gotham, TextSize = 12, Parent = OptionsContainer })
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })
                    Library:RegisterTheme(OptBtn, "BackgroundColor3", "Sidebar")
                    Library:RegisterTheme(OptBtn, "TextColor3", "TextDark")
                    OptBtn.MouseButton1Click:Connect(function() Fire(opt); toggleDrop() end)
                end
                OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
                if isOpen then DropFrame.Size = UDim2.new(1, 0, 0, math.clamp(#options * 28 + 45, 35, 150)) end
            end

            Library.FlagCallbacks[flag] = Fire
            Refresh(options)
            if val then Fire(val) end
            return { Set = function(self, v) Fire(v) end, Update = function(self, opts) Refresh(opts) end }
        end

        function TabObj:CreateMultiDropdown(mDropOptions)
            local flag = mDropOptions.Flag or mDropOptions.Name
            local options = mDropOptions.Options or {}
            local selected = mDropOptions.CurrentOptions or {}
            Library.Flags[flag] = selected

            local DropFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, ClipsDescendants = true, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DropFrame })
            Library:RegisterTheme(DropFrame, "BackgroundColor3", "Element")

            local DropBtn = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "", Parent = DropFrame })
            local DropLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = mDropOptions.Name .. ": [...]", TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropBtn })
            Library:RegisterTheme(DropLabel, "TextColor3", "Text")

            local OptionsContainer = Utility:Create("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -40), Position = UDim2.new(0, 5, 0, 35), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = DropFrame })
            local OptionsLayout = Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = OptionsContainer })

            local isOpen = false
            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, isOpen and math.clamp(#options * 28 + 45, 35, 150) or 35)}, 0.2)
            end)

            local function UpdateLabel()
                local txt = table.concat(selected, ", ")
                DropLabel.Text = mDropOptions.Name .. ": " .. (txt == "" and "None" or txt)
            end

            local function Fire(newSelected)
                selected = newSelected
                Library.Flags[flag] = selected
                UpdateLabel()
                if mDropOptions.Callback then mDropOptions.Callback(selected) end
            end

            local function Refresh(newOptions)
                options = newOptions or {}
                for _, child in pairs(OptionsContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for _, opt in ipairs(options) do
                    local isSel = table.find(selected, opt)
                    local OptBtn = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Text = opt, TextColor3 = isSel and Library.Themes[Library.CurrentTheme].Accent or Library.Themes[Library.CurrentTheme].TextDark, Font = Enum.Font.Gotham, TextSize = 12, Parent = OptionsContainer })
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })
                    Library:RegisterTheme(OptBtn, "BackgroundColor3", "Sidebar")
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        local idx = table.find(selected, opt)
                        if idx then table.remove(selected, idx) else table.insert(selected, opt) end
                        OptBtn.TextColor3 = table.find(selected, opt) and Library.Themes[Library.CurrentTheme].Accent or Library.Themes[Library.CurrentTheme].TextDark
                        Fire(selected)
                    end)
                end
                OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
                if isOpen then DropFrame.Size = UDim2.new(1, 0, 0, math.clamp(#options * 28 + 45, 35, 150)) end
            end

            Library.FlagCallbacks[flag] = Fire
            Refresh(options)
            Fire(selected)
            return { Set = function(self, v) Fire(v); Refresh(options) end, Update = function(self, opts) Refresh(opts) end }
        end

        function TabObj:CreateTextbox(txtOptions)
            local flag = txtOptions.Flag or txtOptions.Name
            local val = txtOptions.CurrentValue or ""
            Library.Flags[flag] = val

            local BoxFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = BoxFrame })
            Library:RegisterTheme(BoxFrame, "BackgroundColor3", "Element")

            local BoxLabel = Utility:Create("TextLabel", { Size = UDim2.new(0.5, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txtOptions.Name, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = BoxFrame })
            Library:RegisterTheme(BoxLabel, "TextColor3", "Text")

            local TextBox = Utility:Create("TextBox", { Size = UDim2.new(0.5, -10, 0, 25), Position = UDim2.new(0.5, 0, 0.5, -12.5), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Text = val, PlaceholderText = txtOptions.PlaceholderText or "Type here...", TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 12, Parent = BoxFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TextBox })
            Library:RegisterTheme(TextBox, "BackgroundColor3", "Sidebar")
            Library:RegisterTheme(TextBox, "TextColor3", "Text")

            local function Fire(newVal)
                val = newVal
                TextBox.Text = val
                Library.Flags[flag] = val
                if txtOptions.Callback then txtOptions.Callback(val) end
            end

            TextBox.FocusLost:Connect(function() Fire(TextBox.Text) end)
            Library.FlagCallbacks[flag] = Fire
            Fire(val)

            return { Set = function(self, v) Fire(v) end }
        end

        function TabObj:CreateColorPicker(cpOptions)
            local flag = cpOptions.Flag or cpOptions.Name
            local val = cpOptions.Color or Color3.fromRGB(255, 255, 255)
            Library.Flags[flag] = val.ToHex and "#"..val:ToHex() or val

            local CPFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, ClipsDescendants = true, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CPFrame })
            Library:RegisterTheme(CPFrame, "BackgroundColor3", "Element")

            local CPBtn = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "", Parent = CPFrame })
            local CPLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = cpOptions.Name, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = CPBtn })
            Library:RegisterTheme(CPLabel, "TextColor3", "Text")

            local DisplayColor = Utility:Create("Frame", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -34, 0, 5.5), BackgroundColor3 = val, Parent = CPFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DisplayColor })

            local PickerArea = Utility:Create("Frame", { Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Parent = CPFrame })
            local PickerLayout = Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = PickerArea })
            
            local R, G, B = val.R * 255, val.G * 255, val.B * 255

            local function Fire(newCol)
                val = newCol
                DisplayColor.BackgroundColor3 = val
                Library.Flags[flag] = string.format("#%02X%02X%02X", math.round(val.R*255), math.round(val.G*255), math.round(val.B*255))
                if cpOptions.Callback then cpOptions.Callback(val) end
            end

            local function CreateRgbSlider(titleTxt, colorProp, initialVal)
                local SldFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Parent = PickerArea })
                local TopFrame = Utility:Create("Frame", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Parent = SldFrame })
                local TopLayout = Utility:Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, Parent = TopFrame })
                
                local ValueBox = Utility:Create("TextBox", { Size = UDim2.new(0, 35, 0, 20), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Text = tostring(math.floor(initialVal)), Font = Enum.Font.Gotham, TextSize = 12, Parent = TopFrame })
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ValueBox })
                Library:RegisterTheme(ValueBox, "BackgroundColor3", "Sidebar")
                Library:RegisterTheme(ValueBox, "TextColor3", "Text")
                
                local Title = Utility:Create("TextLabel", { Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, Text = titleTxt, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopFrame })
                Library:RegisterTheme(Title, "TextColor3", "Text")

                local SldBg = Utility:Create("TextButton", { Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 28), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Text = "", AutoButtonColor = false, Parent = SldFrame })
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SldBg })
                Library:RegisterTheme(SldBg, "BackgroundColor3", "Sidebar")
                
                local Fill = Utility:Create("Frame", { Size = UDim2.new(initialVal/255, 0, 1, 0), BackgroundColor3 = colorProp, Parent = SldBg })
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                
                local function SetVal(v)
                    v = math.clamp(v, 0, 255)
                    Fill.Size = UDim2.new(v/255, 0, 1, 0)
                    ValueBox.Text = tostring(math.floor(v))
                    if titleTxt == "Red" then R = v elseif titleTxt == "Green" then G = v else B = v end
                end

                SldBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local dragging = true
                        local move, release
                        local function update()
                            local pct = math.clamp((Mouse.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
                            SetVal(pct * 255)
                            Fire(Color3.fromRGB(R, G, B))
                        end
                        update()
                        move = Mouse.Move:Connect(update)
                        release = UserInputService.InputEnded:Connect(function(e)
                            if e.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; move:Disconnect(); release:Disconnect() end
                        end)
                    end
                end)
                ValueBox.FocusLost:Connect(function() SetVal(tonumber(ValueBox.Text) or 0); Fire(Color3.fromRGB(R, G, B)) end)
                return SetVal
            end
            
            local setR = CreateRgbSlider("Red", Color3.new(1,0,0), R)
            local setG = CreateRgbSlider("Green", Color3.new(0,1,0), G)
            local setB = CreateRgbSlider("Blue", Color3.new(0,0,1), B)

            local isOpen = false
            CPBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Utility:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, isOpen and 180 or 35)}, 0.2)
            end)

            Library.FlagCallbacks[flag] = function(savedHex)
                if type(savedHex) == "string" and savedHex:sub(1,1) == "#" then
                    local hex = savedHex:gsub("#","")
                    local c = Color3.fromRGB(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
                    setR(c.R*255); setG(c.G*255); setB(c.B*255); Fire(c)
                end
            end
            Fire(val)
            return { Set = function(self, c) setR(c.R*255); setG(c.G*255); setB(c.B*255); Fire(c) end }
        end

        function TabObj:CreateKeybind(kbOptions)
            local flag = kbOptions.Flag or kbOptions.Name
            local key = kbOptions.CurrentKeypad or kbOptions.CurrentKey or "None"
            Library.Flags[flag] = key

            local KbFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element, Parent = TabContent })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KbFrame })
            Library:RegisterTheme(KbFrame, "BackgroundColor3", "Element")

            local KbLabel = Utility:Create("TextLabel", { Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = kbOptions.Name, TextColor3 = Library.Themes[Library.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = KbFrame })
            Library:RegisterTheme(KbLabel, "TextColor3", "Text")

            local BindBtn = Utility:Create("TextButton", { Size = UDim2.new(0, 80, 0, 25), Position = UDim2.new(1, -90, 0.5, -12.5), BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar, Text = key, TextColor3 = Library.Themes[Library.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 12, Parent = KbFrame })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BindBtn })
            Library:RegisterTheme(BindBtn, "BackgroundColor3", "Sidebar")
            Library:RegisterTheme(BindBtn, "TextColor3", "Accent")

            local isBinding = false

            local function Fire(newKey)
                if typeof(newKey) == "EnumItem" then newKey = newKey.Name end
                key = newKey
                Library.Flags[flag] = key
                BindBtn.Text = key
            end

            BindBtn.MouseButton1Click:Connect(function()
                isBinding = true
                BindBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if isBinding then
                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
                        Fire("None")
                    elseif input.UserInputType == Enum.UserInputType.Keyboard then
                        Fire(input.KeyCode.Name)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                        Fire(input.UserInputType.Name)
                    end
                    isBinding = false
                else
                    if not gpe and key ~= "None" then
                        if input.KeyCode.Name == key or input.UserInputType.Name == key then
                            if kbOptions.Callback then kbOptions.Callback(key) end
                        end
                    end
                end
            end)

            Library.FlagCallbacks[flag] = Fire
            Fire(key)

            return { Set = function(self, k) Fire(k) end }
        end

        return TabObj
    end

    Window.SettingsTab = Window:CreateTab("⚙ Settings")
    Window.SettingsTab:CreateSection("Custom Theme Builder")
    local colorKeys = {"Main", "Sidebar", "Element", "Accent", "Text", "TextDark"}
    for _, key in ipairs(colorKeys) do
        Window.SettingsTab:CreateColorPicker({ Name = key .. " Color", Color = Library.Themes["Custom"][key], Flag = "Nebula_CustomTheme_" .. key, Callback = function(color)
            Library.Themes["Custom"][key] = color
            Library:SetTheme("Custom") 
        end})
    end

    return Window
end

return Library
