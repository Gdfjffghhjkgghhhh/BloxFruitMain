--// WindyUI v3.0 ANIME + WIN 11 STYLE
--// Theme Anime Glassmorphism & Smooth Animations

local Windy = {}

-- ================= SERVICES =================
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- ================= CLEANUP OLD GUI =================
pcall(function()
	if CoreGui:FindFirstChild("WindyUI_V3_Anime") then
		CoreGui:FindFirstChild("WindyUI_V3_Anime"):Destroy()
	end
end)

-- ================= THEME & SETTINGS =================
-- Bạn có thể thay đổi ID hình nền Anime ở đây
local AnimeBackgroundID = "rbxassetid://13467882512" -- Ví dụ: Anime Scenery

local Theme = {
	-- Màu nền chính (kết hợp với ảnh nền)
	BG = Color3.fromRGB(20, 20, 28), 
	BG_Transparency = 0.2, -- Độ trong suốt kính (Win 11)
	
	-- Sidebar
	Sidebar = Color3.fromRGB(15, 15, 20),
	Sidebar_Transparency = 0.5,
	
	-- Elements
	Section = Color3.fromRGB(255, 255, 255),
	Section_Transparency = 0.95, -- Rất mờ để tạo hiệu ứng kính
	
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(180, 180, 200),
	
	-- Accent Color (Màu chủ đạo - Hồng Anime)
	Main = Color3.fromRGB(255, 110, 150), 
	MainGradient = Color3.fromRGB(180, 100, 255),
	
	Search = Color3.fromRGB(0, 0, 0),
	Search_Transparency = 0.7
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
ScreenGui.Name = "WindyUI_V3_Anime"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Main CanvasGroup (Dùng CanvasGroup để render GroupTransparency mượt mà)
local Main = Instance.new("CanvasGroup", ScreenGui) 
Main.Size = UDim2.new(0, 620, 0, 420)
Main.Position = UDim2.new(0.5, -310, 0.5, -210)
Main.BackgroundColor3 = Theme.BG
Main.BackgroundTransparency = Theme.BG_Transparency
Main.BorderSizePixel = 0
Main.GroupTransparency = 0 -- Bắt đầu hiển thị
Main.Visible = true -- Sẽ được toggle sau

-- Win 11 Corner & Stroke
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.8 -- Viền kính mờ

-- Anime Background Image
local BGImage = Instance.new("ImageLabel", Main)
BGImage.Name = "AnimeBG"
BGImage.Size = UDim2.new(1, 0, 1, 0)
BGImage.Image = AnimeBackgroundID
BGImage.ImageTransparency = 0.7 -- Làm mờ ảnh để dễ đọc chữ
BGImage.ScaleType = Enum.ScaleType.Crop
BGImage.BackgroundTransparency = 1
BGImage.ZIndex = -1

-- Drag Logic
do
	local drag, startPos, startInput
	Main.InputBegan:Connect(function(i)
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

-- ================= SIDEBAR =================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = Theme.Sidebar_Transparency
Sidebar.BorderSizePixel = 0
-- Đường kẻ dọc ngăn cách mờ
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
Title.Text = "WINDY HUB <font color=\"rgb(255,110,150)\">v3</font>" -- Rich Text
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Search Bar (Rounded Win 11)
local SearchFrame = Instance.new("Frame", Sidebar)
SearchFrame.Size = UDim2.new(1, -30, 0, 32)
SearchFrame.Position = UDim2.new(0, 15, 0, 60)
SearchFrame.BackgroundColor3 = Theme.Search
SearchFrame.BackgroundTransparency = Theme.Search_Transparency
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)
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
TabLayout.SortOrder = Enum.SortOrder.Name -- GIỮ NGUYÊN FIX CỦA BẠN

-- Search Logic
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
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0, 195, 0, 20)
Content.Size = UDim2.new(1, -210, 1, -40)
Content.BackgroundTransparency = 1

local CurrentTab = nil
local TabCountOrder = 0

-- ================= FUNCTIONS =================

-- 1. Create Tab
function Windy:CreateTab(name, iconId)
	TabCountOrder = TabCountOrder + 1
	local hiddenName = (TabCountOrder < 10 and "00" .. TabCountOrder) or (TabCountOrder < 100 and "0" .. TabCountOrder) or tostring(TabCountOrder)

	local Btn = Instance.new("TextButton", TabButtons)
	Btn.Size = UDim2.new(1, -20, 0, 38)
	Btn.Position = UDim2.new(0, 10, 0, 0) -- Canh lề
	Btn.Text = ""
	Btn.BackgroundTransparency = 1
	Btn.BackgroundColor3 = Theme.Main
	Btn.Name = hiddenName
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

	-- Glow Effect khi chọn tab
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
		Page.CanvasPosition = Vector2.new(0,0) -- Reset scroll
		
		Tween(Label, {TextColor3 = Theme.Text}) -- Sáng chữ
		Tween(Btn, {BackgroundTransparency = 0.85}) -- Nền sáng nhẹ
		Tween(BtnStroke, {Transparency = 0.5}) -- Hiện viền
		if Icon then Tween(Icon, {ImageColor3 = Theme.Main}) end -- Icon màu chủ đạo
		
		CurrentTab = {Page = Page, Label = Label, Btn = Btn, BtnStroke = BtnStroke, Icon = Icon}
	end

	Btn.MouseButton1Click:Connect(Activate)
	if not CurrentTab then Activate() end

	return Page
end

-- 2. Add Section
function Windy:AddSection(Page, text)
	local SectionFrame = Instance.new("Frame", Page)
	SectionFrame.Size = UDim2.new(1, -5, 0, 30)
	SectionFrame.BackgroundTransparency = 1
	
	local Label = Instance.new("TextLabel", SectionFrame)
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Main -- Dùng màu hồng anime cho tiêu đề section
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	
	return SectionFrame
end

-- 3. Add Button (Hover Animation)
function Windy:AddButton(Page, text, callback)
	local BtnFrame = Instance.new("Frame", Page)
	BtnFrame.Size = UDim2.new(1, -5, 0, 40)
	BtnFrame.BackgroundColor3 = Theme.Section
	BtnFrame.BackgroundTransparency = Theme.Section_Transparency
	Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 8)
	
	-- Viền nút
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
	
	-- Animations
	Btn.MouseEnter:Connect(function()
		Tween(Stroke, {Transparency = 0.5, Color = Theme.Main})
		Tween(Btn, {TextColor3 = Theme.Main})
	end)
	
	Btn.MouseLeave:Connect(function()
		Tween(Stroke, {Transparency = 0.9, Color = Color3.fromRGB(255,255,255)})
		Tween(Btn, {TextColor3 = Theme.Text})
	end)

	Btn.MouseButton1Click:Connect(function()
		-- Click effect (Nhỏ lại xíu)
		Tween(BtnFrame, {Size = UDim2.new(1, -15, 0, 36)}, 0.05)
		task.wait(0.05)
		Tween(BtnFrame, {Size = UDim2.new(1, -5, 0, 40)}, 0.1)
		callback()
	end)
end

-- 4. Add Toggle (Smooth Slider)
function Windy:AddToggle(Page, text, default, callback)
	local state = Config.Toggles[text]
	if state == nil then state = default end

	local Frame = Instance.new("Frame", Page)
	Frame.Size = UDim2.new(1, -5, 0, 40)
	Frame.BackgroundColor3 = Theme.Section
	Frame.BackgroundTransparency = Theme.Section_Transparency
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
	
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
	
	-- Glow cho Circle
	local Glow = Instance.new("UIStroke", Circle)
	Glow.Thickness = 2
	Glow.Transparency = 1
	Glow.Color = Theme.Main

	local function Refresh()
		if state then
			Tween(ToggleBtn, {BackgroundColor3 = Theme.Main})
			Tween(Circle, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255,255,255)})
			Tween(Glow, {Transparency = 0.6})
			Tween(Stroke, {Color = Theme.Main, Transparency = 0.7}) -- Viền khung sáng lên
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

-- 5. Add Dropdown (Win 11 Style)
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
	Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)
	
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

-- ================= GUI TOGGLE (WIN 11 POP-UP) =================
local GUI_VISIBLE = true
local OriginalSize = UDim2.new(0, 620, 0, 420)
local MinimizedSize = UDim2.new(0, 620 * 0.9, 0, 420 * 0.9) -- Nhỏ hơn xíu

local function ToggleGUI(state)
	GUI_VISIBLE = state
	if GUI_VISIBLE then
		Main.Visible = true
		-- Animation Mở: Từ nhỏ -> Lớn, Mờ -> Rõ
		Main.Size = MinimizedSize
		Main.GroupTransparency = 1
		
		Tween(Main, {Size = OriginalSize, GroupTransparency = 0}, 0.35, Enum.EasingStyle.Back)
	else
		-- Animation Đóng: Lớn -> Nhỏ, Rõ -> Mờ
		Tween(Main, {Size = MinimizedSize, GroupTransparency = 1}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.25)
		if not GUI_VISIBLE then Main.Visible = false end
	end
end

-- Float Button (Tròn + Anime Style)
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 30, 0.5, -25)
FloatBtn.BackgroundColor3 = Theme.Main
FloatBtn.Text = ""
FloatBtn.ZIndex = 999
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- Float Glow
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

-- Hiệu ứng nút nổi
FloatBtn.MouseEnter:Connect(function()
	Tween(FloatBtn, {Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 27, 0.5, -28)})
end)
FloatBtn.MouseLeave:Connect(function()
	Tween(FloatBtn, {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 30, 0.5, -25)})
end)

FloatBtn.MouseButton1Click:Connect(function()
	ToggleGUI(not GUI_VISIBLE)
end)

-- Keybind
local ToggleKey = Enum.KeyCode[Config.Keybind] or Enum.KeyCode.RightControl
UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == ToggleKey then
		ToggleGUI(not GUI_VISIBLE)
	end
end)

return Windy
