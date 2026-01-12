--// WindyUI v3.1 RESIZABLE & WINDOW CONTROLS
--// Added: Resize Grip, Close/Min Buttons, Sharper Corners

local Windy = {}

-- ================= SERVICES =================
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Mouse = game.Players.LocalPlayer:GetMouse()

-- ================= CLEANUP OLD GUI =================
pcall(function()
	if CoreGui:FindFirstChild("WindyUI_V3_Resizable") then
		CoreGui:FindFirstChild("WindyUI_V3_Resizable"):Destroy()
	end
end)

-- ================= THEME & SETTINGS =================
local AnimeBackgroundID = "rbxassetid://78867414575565" -- Ảnh nền Anime

local Theme = {
	BG = Color3.fromRGB(20, 20, 28), 
	BG_Transparency = 0.2,
	Sidebar = Color3.fromRGB(15, 15, 20),
	Sidebar_Transparency = 0.5,
	Section = Color3.fromRGB(255, 255, 255),
	Section_Transparency = 0.95,
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(180, 180, 200),
	Main = Color3.fromRGB(255, 110, 150), -- Màu chủ đạo (Hồng)
	Search = Color3.fromRGB(0, 0, 0),
	Search_Transparency = 0.7,
	
	-- [NEW] Cài đặt bo góc (Giảm xuống để vuông hơn)
	CornerRadius = UDim.new(0, 6) 
}

-- ================= CONFIG SYSTEM =================
local ConfigFile = "WindyUI_Anime_Config.json"
local Config = { Toggles = {}, Keybind = "RightControl" }

pcall(function()
	if isfile(ConfigFile) then
		Config = HttpService:JSONDecode(readfile(ConfigFile))
	end
end)

local function SaveConfig()
	pcall(function()
		writefile(ConfigFile, HttpService:JSONEncode(Config))
	end)
end

-- ================= UTILS (ANIMATION) =================
local function Tween(obj, props, time, style, dir)
	TweenService:Create(obj, TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

-- ================= GUI SETUP =================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Neon X Hub : [Blox Fruit]"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Main CanvasGroup
local Main = Instance.new("CanvasGroup", ScreenGui) 
Main.Size = UDim2.new(0, 600, 0, 400) -- Kích thước mặc định
Main.Position = UDim2.new(0.5, -300, 0.5, -200)
Main.BackgroundColor3 = Theme.BG
Main.BackgroundTransparency = Theme.BG_Transparency
Main.BorderSizePixel = 0
Main.GroupTransparency = 0
Main.Visible = true

-- [UPDATE] Corner Radius nhỏ hơn
Instance.new("UICorner", Main).CornerRadius = Theme.CornerRadius
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.8

-- Anime Background
local BGImage = Instance.new("ImageLabel", Main)
BGImage.Name = "AnimeBG"
BGImage.Size = UDim2.new(1, 0, 1, 0)
BGImage.Image = AnimeBackgroundID
BGImage.ImageTransparency = 0.7
BGImage.ScaleType = Enum.ScaleType.Crop
BGImage.BackgroundTransparency = 1
BGImage.ZIndex = -1

-- ================= DRAG LOGIC (DI CHUYỂN GUI) =================
local DragFrame = Instance.new("Frame", Main) -- Vùng vô hình để kéo GUI
DragFrame.Size = UDim2.new(1, -100, 0, 40) -- Chừa chỗ cho nút tắt/nhỏ
DragFrame.BackgroundTransparency = 1
DragFrame.ZIndex = 10

do
	local drag, startPos, startInput
	DragFrame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			startInput = i.Position
			startPos = Main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					drag = false
				end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - startInput
			Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)
end

-- ================= [NEW] WINDOW CONTROLS (TẮT / THU NHỎ) =================
local ControlsContainer = Instance.new("Frame", Main)
ControlsContainer.Size = UDim2.new(0, 70, 0, 30)
ControlsContainer.Position = UDim2.new(1, -75, 0, 5)
ControlsContainer.BackgroundTransparency = 1
ControlsContainer.ZIndex = 20

-- 1. Close Button (X)
local CloseBtn = Instance.new("TextButton", ControlsContainer)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function() 
	Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80), BackgroundTransparency = 0.2, TextColor3 = Color3.new(1,1,1)}) 
end)
CloseBtn.MouseLeave:Connect(function() 
	Tween(CloseBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 200, 200)}) 
end)

-- 2. Minimize Button (-)
local MinBtn = Instance.new("TextButton", ControlsContainer)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "−"
MinBtn.Font = Enum.Font.GothamMedium
MinBtn.TextSize = 24
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

MinBtn.MouseEnter:Connect(function() 
	Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(80, 80, 100), BackgroundTransparency = 0.5, TextColor3 = Color3.new(1,1,1)}) 
end)
MinBtn.MouseLeave:Connect(function() 
	Tween(MinBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 200, 200)}) 
end)

-- ================= [NEW] RESIZE HANDLE (KÉO GÓC ĐỂ CHỈNH TO NHỎ) =================
local ResizeHandle = Instance.new("ImageButton", Main)
ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Image = "rbxassetid://16447953250" -- Icon góc tam giác
ResizeHandle.ImageTransparency = 0.5
ResizeHandle.ImageColor3 = Theme.SubText
ResizeHandle.ZIndex = 20

local isResizing = false
local minSize = Vector2.new(450, 300) -- Kích thước tối thiểu

ResizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isResizing = true
	end
end)

ResizeHandle.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isResizing = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local newX = input.Position.X - Main.AbsolutePosition.X
		local newY = input.Position.Y - Main.AbsolutePosition.Y
		
		-- Giới hạn kích thước tối thiểu
		if newX < minSize.X then newX = minSize.X end
		if newY < minSize.Y then newY = minSize.Y end
		
		Main.Size = UDim2.new(0, newX, 0, newY)
	end
end)

ResizeHandle.MouseEnter:Connect(function() Tween(ResizeHandle, {ImageColor3 = Theme.Main, ImageTransparency = 0}) end)
ResizeHandle.MouseLeave:Connect(function() Tween(ResizeHandle, {ImageColor3 = Theme.SubText, ImageTransparency = 0.5}) end)


-- ================= SIDEBAR =================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = Theme.Sidebar_Transparency
Sidebar.BorderSizePixel = 0
local SideLine = Instance.new("Frame", Sidebar)
SideLine.Size = UDim2.new(0, 1, 1, 0)
SideLine.Position = UDim2.new(1, 0, 0, 0)
SideLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
SideLine.BackgroundTransparency = 0.9
SideLine.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, -20, 0, 50)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "<font color=\"rgb(230, 212, 217)\">Windy Hub </font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 25
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Search Bar
local SearchFrame = Instance.new("Frame", Sidebar)
SearchFrame.Size = UDim2.new(1, -30, 0, 32)
SearchFrame.Position = UDim2.new(0, 15, 0, 60)
SearchFrame.BackgroundColor3 = Theme.Search
SearchFrame.BackgroundTransparency = Theme.Search_Transparency
Instance.new("UICorner", SearchFrame).CornerRadius = Theme.CornerRadius -- [UPDATED]
local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = Color3.fromRGB(255,255,255)
SearchStroke.Transparency = 0.9
SearchStroke.Thickness = 1

local SearchIcon = Instance.new("ImageLabel", SearchFrame)
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://3926305904"
SearchIcon.ImageRectOffset = Vector2.new(964, 324)
SearchIcon.ImageRectSize = Vector2.new(36, 36)
SearchIcon.ImageColor3 = Theme.SubText

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1, -40, 1, 0)
SearchBox.Position = UDim2.new(0, 32, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.TextColor3 = Theme.Text
SearchBox.PlaceholderColor3 = Theme.SubText
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

-- Tab Container
local TabButtons = Instance.new("ScrollingFrame", Sidebar)
TabButtons.Position = UDim2.new(0, 0, 0, 105)
TabButtons.Size = UDim2.new(1, 0, 1, -110)
TabButtons.BackgroundTransparency = 1
TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
TabButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabButtons.ScrollBarThickness = 2
TabButtons.ScrollBarImageTransparency = 0.8
TabButtons.BorderSizePixel = 0

local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.Name

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local input = SearchBox.Text:lower()
	for _, btn in pairs(TabButtons:GetChildren()) do
		if btn:IsA("TextButton") then
			local label = btn:FindFirstChild("TabLabel")
			if label then
				btn.Visible = label.Text:lower():find(input) and true or false
			end
		end
	end
end)

-- ================= CONTENT AREA =================
-- [UPDATED] Kích thước Content tự động co giãn khi Resize Main
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0, 195, 0, 20)
Content.Size = UDim2.new(1, -210, 1, -40) 
Content.BackgroundTransparency = 1

local CurrentTab = nil
local TabCountOrder = 0

-- ================= FUNCTIONS =================

function Windy:CreateTab(name, iconId)
	TabCountOrder = TabCountOrder + 1
	local hiddenName = (TabCountOrder < 10 and "00" .. TabCountOrder) or (TabCountOrder < 100 and "0" .. TabCountOrder) or tostring(TabCountOrder)

	local Btn = Instance.new("TextButton", TabButtons)
	Btn.Size = UDim2.new(1, -20, 0, 38)
	Btn.Position = UDim2.new(0, 10, 0, 0)
	Btn.Text = ""
	Btn.BackgroundTransparency = 1
	Btn.BackgroundColor3 = Theme.Main
	Btn.Name = hiddenName
	Instance.new("UICorner", Btn).CornerRadius = Theme.CornerRadius -- [UPDATED]

	local BtnStroke = Instance.new("UIStroke", Btn)
	BtnStroke.Transparency = 1
	BtnStroke.Color = Theme.Main
	BtnStroke.Thickness = 1

	local Icon
	local TextOffset = 15
	if iconId then
		Icon = Instance.new("ImageLabel", Btn)
		Icon.Size = UDim2.new(0, 20, 0, 20)
		Icon.Position = UDim2.new(0, 10, 0.5, -10)
		Icon.BackgroundTransparency = 1
		Icon.Image = "rbxassetid://" .. tostring(iconId)
		Icon.ImageColor3 = Theme.SubText
		TextOffset = 40
	end

	local Label = Instance.new("TextLabel", Btn)
	Label.Name = "TabLabel"
	Label.Size = UDim2.new(1, -TextOffset, 1, 0)
	Label.Position = UDim2.new(0, TextOffset, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 13
	Label.TextColor3 = Theme.SubText
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Page = Instance.new("ScrollingFrame", Content)
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.ScrollBarThickness = 2
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.ScrollBarImageTransparency = 0.8

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0, 10)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function Activate()
		if CurrentTab then
			CurrentTab.Page.Visible = false
			Tween(CurrentTab.Label, {TextColor3 = Theme.SubText})
			Tween(CurrentTab.Btn, {BackgroundTransparency = 1})
			Tween(CurrentTab.BtnStroke, {Transparency = 1})
			if CurrentTab.Icon then Tween(CurrentTab.Icon, {ImageColor3 = Theme.SubText}) end
		end
		
		Page.Visible = true
		Page.CanvasPosition = Vector2.new(0,0)
		
		Tween(Label, {TextColor3 = Theme.Text})
		Tween(Btn, {BackgroundTransparency = 0.85})
		Tween(BtnStroke, {Transparency = 0.5})
		if Icon then Tween(Icon, {ImageColor3 = Theme.Main}) end
		
		CurrentTab = {Page = Page, Label = Label, Btn = Btn, BtnStroke = BtnStroke, Icon = Icon}
	end

	Btn.MouseButton1Click:Connect(Activate)
	if not CurrentTab then Activate() end

	return Page
end

function Windy:AddSection(Page, text)
	local Section = Instance.new("Frame", Page)
	Section.Size = UDim2.new(1, -5, 0, 0)
	Section.BackgroundTransparency = 1
	Section.AutomaticSize = Enum.AutomaticSize.Y

	local Layout = Instance.new("UIListLayout", Section)
	Layout.Padding = UDim.new(0, 8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	local Title = Instance.new("TextLabel", Section)
	Title.Size = UDim2.new(1, 0, 0, 24)
	Title.BackgroundTransparency = 1
	Title.Text = text
	Title.TextColor3 = Theme.Main
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 12
	Title.TextXAlignment = Enum.TextXAlignment.Left

	return Section
end


function Windy:AddButton(Page, text, callback)
	local BtnFrame = Instance.new("Frame", Page)
	BtnFrame.Size = UDim2.new(1, -5, 0, 40)
	BtnFrame.BackgroundColor3 = Theme.Section
	BtnFrame.BackgroundTransparency = Theme.Section_Transparency
	Instance.new("UICorner", BtnFrame).CornerRadius = Theme.CornerRadius -- [UPDATED]
	
	local Stroke = Instance.new("UIStroke", BtnFrame)
	Stroke.Color = Color3.fromRGB(255,255,255)
	Stroke.Transparency = 0.9
	Stroke.Thickness = 1
	
	local Btn = Instance.new("TextButton", BtnFrame)
	Btn.Size = UDim2.new(1, 0, 1, 0)
	Btn.BackgroundTransparency = 1
	Btn.Text = text
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamSemibold
	Btn.TextSize = 13
	
	Btn.MouseEnter:Connect(function()
		Tween(Stroke, {Transparency = 0.5, Color = Theme.Main})
		Tween(Btn, {TextColor3 = Theme.Main})
	end)
	
	Btn.MouseLeave:Connect(function()
		Tween(Stroke, {Transparency = 0.9, Color = Color3.fromRGB(255,255,255)})
		Tween(Btn, {TextColor3 = Theme.Text})
	end)

	Btn.MouseButton1Click:Connect(function()
		Tween(BtnFrame, {Size = UDim2.new(1, -15, 0, 36)}, 0.05)
		task.wait(0.05)
		Tween(BtnFrame, {Size = UDim2.new(1, -5, 0, 40)}, 0.1)
		callback()
	end)
end

function Windy:AddToggle(Page, text, default, callback)
	local state = Config.Toggles[text]
	if state == nil then state = default end

	local Frame = Instance.new("Frame", Page)
	Frame.Size = UDim2.new(1, -5, 0, 40)
	Frame.BackgroundColor3 = Theme.Section
	Frame.BackgroundTransparency = Theme.Section_Transparency
	Instance.new("UICorner", Frame).CornerRadius = Theme.CornerRadius -- [UPDATED]
	
	local Stroke = Instance.new("UIStroke", Frame)
	Stroke.Color = Color3.fromRGB(255,255,255)
	Stroke.Transparency = 0.9
	Stroke.Thickness = 1

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1, -60, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local ToggleBtn = Instance.new("TextButton", Frame)
	ToggleBtn.Size = UDim2.new(0, 44, 0, 24)
	ToggleBtn.Position = UDim2.new(1, -55, 0.5, -12)
	ToggleBtn.Text = ""
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

	local Circle = Instance.new("Frame", ToggleBtn)
	Circle.Size = UDim2.new(0, 20, 0, 20)
	Circle.Position = UDim2.new(0, 2, 0.5, -10)
	Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
	
	local Glow = Instance.new("UIStroke", Circle)
	Glow.Thickness = 2
	Glow.Transparency = 1
	Glow.Color = Theme.Main

	local function Refresh()
		if state then
			Tween(ToggleBtn, {BackgroundColor3 = Theme.Main})
			Tween(Circle, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255,255,255)})
			Tween(Glow, {Transparency = 0.6})
			Tween(Stroke, {Color = Theme.Main, Transparency = 0.7})
		else
			Tween(ToggleBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
			Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Color3.fromRGB(150,150,150)})
			Tween(Glow, {Transparency = 1})
			Tween(Stroke, {Color = Color3.fromRGB(255,255,255), Transparency = 0.9})
		end
		Config.Toggles[text] = state
		SaveConfig()
		callback(state)
	end

	Refresh()
	ToggleBtn.MouseButton1Click:Connect(function()
		state = not state
		Refresh()
	end)
end

function Windy:AddDropdown(Page, text, options, default, callback)
	local isDropdownOpen = false
	local currentOption = default or options[1] or "Select..."
	
	local OptionHeight = 32
	local ClosedHeight = 40
	local OpenHeight = ClosedHeight + (#options * OptionHeight) + 6

	local DropFrame = Instance.new("Frame", Page)
	DropFrame.Size = UDim2.new(1, -5, 0, ClosedHeight)
	DropFrame.BackgroundColor3 = Theme.Section
	DropFrame.BackgroundTransparency = Theme.Section_Transparency
	DropFrame.ClipsDescendants = true
	Instance.new("UICorner", DropFrame).CornerRadius = Theme.CornerRadius -- [UPDATED]
	
	local Stroke = Instance.new("UIStroke", DropFrame)
	Stroke.Color = Color3.fromRGB(255,255,255)
	Stroke.Transparency = 0.9
	Stroke.Thickness = 1

	local HeaderBtn = Instance.new("TextButton", DropFrame)
	HeaderBtn.Size = UDim2.new(1, 0, 0, ClosedHeight)
	HeaderBtn.BackgroundTransparency = 1
	HeaderBtn.Text = ""
	
	local Title = Instance.new("TextLabel", HeaderBtn)
	Title.Size = UDim2.new(1, -40, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = text .. ": <font color=\"rgb(255,110,150)\">" .. tostring(currentOption) .. "</font>"
	Title.RichText = true
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.Gotham
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Arrow = Instance.new("ImageLabel", HeaderBtn)
	Arrow.Size = UDim2.new(0, 20, 0, 20)
	Arrow.Position = UDim2.new(1, -35, 0.5, -10)
	Arrow.BackgroundTransparency = 1
	Arrow.Image = "rbxassetid://6034818372"
	Arrow.ImageColor3 = Theme.SubText
	
	local OptionContainer = Instance.new("Frame", DropFrame)
	OptionContainer.Size = UDim2.new(1, 0, 0, #options * OptionHeight)
	OptionContainer.Position = UDim2.new(0, 0, 0, ClosedHeight)
	OptionContainer.BackgroundTransparency = 1
	
	local OptionLayout = Instance.new("UIListLayout", OptionContainer)
	OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	OptionLayout.Padding = UDim.new(0,0)
	
	local function ToggleDropdown()
		isDropdownOpen = not isDropdownOpen
		if isDropdownOpen then
			Tween(DropFrame, {Size = UDim2.new(1, -5, 0, OpenHeight)}, 0.35, Enum.EasingStyle.Quart)
			Tween(Arrow, {Rotation = 180})
			Tween(Stroke, {Color = Theme.Main, Transparency = 0.6})
		else
			Tween(DropFrame, {Size = UDim2.new(1, -5, 0, ClosedHeight)}, 0.3, Enum.EasingStyle.Quart)
			Tween(Arrow, {Rotation = 0})
			Tween(Stroke, {Color = Color3.fromRGB(255,255,255), Transparency = 0.9})
		end
	end
	
	HeaderBtn.MouseButton1Click:Connect(ToggleDropdown)

	for _, opt in pairs(options) do
		local OptBtn = Instance.new("TextButton", OptionContainer)
		OptBtn.Size = UDim2.new(1, 0, 0, OptionHeight)
		OptBtn.BackgroundTransparency = 1
		OptBtn.Text = opt
		OptBtn.TextColor3 = Theme.SubText
		OptBtn.Font = Enum.Font.GothamMedium
		OptBtn.TextSize = 12
		
		OptBtn.MouseEnter:Connect(function()
			Tween(OptBtn, {TextColor3 = Theme.Main, BackgroundTransparency = 0.9, BackgroundColor3 = Theme.Main})
		end)
		OptBtn.MouseLeave:Connect(function()
			if opt ~= currentOption then
				Tween(OptBtn, {TextColor3 = Theme.SubText, BackgroundTransparency = 1})
			end
		end)

		OptBtn.MouseButton1Click:Connect(function()
			currentOption = opt
			Title.Text = text .. ": <font color=\"rgb(255,110,150)\">" .. tostring(currentOption) .. "</font>"
			callback(opt)
			ToggleDropdown()
		end)
	end
end

-- ================= GUI TOGGLE LOGIC =================
local GUI_VISIBLE = true

-- Float Button
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 30, 0.5, -25)
FloatBtn.BackgroundColor3 = Theme.Main
FloatBtn.Text = ""
FloatBtn.ZIndex = 999
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 2
FloatStroke.Color = Color3.fromRGB(255,255,255)
FloatStroke.Transparency = 0.5

local FIcon = Instance.new("ImageLabel", FloatBtn)
FIcon.Size = UDim2.new(0, 28, 0, 28)
FIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
FIcon.BackgroundTransparency = 1
FIcon.Image = "rbxassetid://3926305904"
FIcon.ImageRectOffset = Vector2.new(324, 124)
FIcon.ImageRectSize = Vector2.new(36, 36)

local function ToggleGUI(state)
	GUI_VISIBLE = state
	if GUI_VISIBLE then
		Main.Visible = true
		Tween(Main, {GroupTransparency = 0}, 0.3)
		Tween(FloatBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
		Tween(FloatStroke, {Transparency = 1}, 0.3)
		Tween(FIcon, {ImageTransparency = 1}, 0.3)
		FloatBtn.Visible = false
	else
		-- Thu nhỏ
		Tween(Main, {GroupTransparency = 1}, 0.2)
		task.wait(0.2)
		if not GUI_VISIBLE then Main.Visible = false end
		
		FloatBtn.Visible = true
		Tween(FloatBtn, {BackgroundTransparency = 0}, 0.3)
		Tween(FloatStroke, {Transparency = 0.5}, 0.3)
		Tween(FIcon, {ImageTransparency = 0}, 0.3)
	end
end

-- Hook Events cho nút Close/Min
CloseBtn.MouseButton1Click:Connect(function()
	ToggleGUI(false)
end)

MinBtn.MouseButton1Click:Connect(function()
	ToggleGUI(false)
end)

FloatBtn.MouseButton1Click:Connect(function()
	ToggleGUI(true)
end)

-- Keybind
local ToggleKey = Enum.KeyCode[Config.Keybind] or Enum.KeyCode.RightControl
UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == ToggleKey then
		ToggleGUI(not GUI_VISIBLE)
	end
end)
-- Player Profile Section (Bottom Sidebar)
local ProfileFrame = Instance.new("Frame", Sidebar)
ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
ProfileFrame.Position = UDim2.new(0, 10, 1, -60)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
ProfileFrame.BackgroundTransparency = 0.6
Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)

local Avatar = Instance.new("ImageLabel", ProfileFrame)
Avatar.Size = UDim2.new(0, 34, 0, 34)
Avatar.Position = UDim2.new(0, 8, 0.5, -17)
Avatar.BackgroundTransparency = 1
-- Lấy ảnh Avatar người chơi
Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..game.Players.LocalPlayer.UserId.."&width=420&height=420&format=png"
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

local NameTag = Instance.new("TextLabel", ProfileFrame)
NameTag.Size = UDim2.new(1, -60, 0, 18)
NameTag.Position = UDim2.new(0, 50, 0, 8)
NameTag.BackgroundTransparency = 1
NameTag.Text = game.Players.LocalPlayer.DisplayName
NameTag.Font = Enum.Font.GothamBold
NameTag.TextColor3 = Theme.Text
NameTag.TextSize = 13
NameTag.TextXAlignment = Enum.TextXAlignment.Left

local StatsTag = Instance.new("TextLabel", ProfileFrame)
StatsTag.Size = UDim2.new(1, -60, 0, 15)
StatsTag.Position = UDim2.new(0, 50, 0, 26)
StatsTag.BackgroundTransparency = 1
StatsTag.Text = "FPS: 60 • Ping: 50ms"
StatsTag.Font = Enum.Font.Gotham
StatsTag.TextColor3 = Theme.Main
StatsTag.TextSize = 11
StatsTag.TextXAlignment = Enum.TextXAlignment.Left

-- Script cập nhật FPS/Ping liên tục
task.spawn(function()
	local RunService = game:GetService("RunService")
	local StatsService = game:GetService("Stats")
	while task.wait(1) do
		local fps = math.floor(1 / RunService.RenderStepped:Wait()) -- Cách tính FPS đơn giản
		local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
		StatsTag.Text = "FPS: " .. fps .. " • Ping: " .. ping .. "ms"
	end
end)
return Windy
