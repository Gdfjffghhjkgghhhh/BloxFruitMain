--// WindyUI v2.6 UPDATED
--// Added: Section, Search, Tab Icon

local Windy = {}

-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Remove old
pcall(function()
	if CoreGui:FindFirstChild("WindyUI_V2") then
		CoreGui:FindFirstChild("WindyUI_V2"):Destroy()
	end
end)

-- ================= THEME =================
local Theme = {
	BG = Color3.fromRGB(25,25,30),
	Sidebar = Color3.fromRGB(20,20,25),
	Section = Color3.fromRGB(35,35,40), -- Màu nền Button/Toggle
	SectionText = Color3.fromRGB(255, 255, 255), -- Màu chữ Section
	Text = Color3.fromRGB(240,240,240),
	SubText = Color3.fromRGB(150,150,150),
	Main = Color3.fromRGB(45,120,255),
	Search = Color3.fromRGB(30,30,35)
}

-- ================= CONFIG =================
local ConfigFile = "WindyUI_Config.json"
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

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "WindyUI_V2"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ================= MAIN =================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,600,0,400)
Main.Position = UDim2.new(0.5,-300,0.5,-200)
Main.BackgroundColor3 = Theme.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

-- Drag Functionality
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
			Main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ================= SIDEBAR =================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,170,1,0) -- Tăng nhẹ size sidebar
Sidebar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)
local SidebarCover = Instance.new("Frame", Sidebar) -- Che góc tròn bên phải để liền mạch
SidebarCover.Size = UDim2.new(0,10,1,0)
SidebarCover.Position = UDim2.new(1,-10,0,0)
SidebarCover.BackgroundColor3 = Theme.Sidebar
SidebarCover.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1,-20,0,40)
Title.Position = UDim2.new(0,10,0,5)
Title.BackgroundTransparency = 1
Title.Text = "WINDY HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Theme.Main
Title.TextXAlignment = Enum.TextXAlignment.Left

-- [NEW] SEARCH BAR
local SearchFrame = Instance.new("Frame", Sidebar)
SearchFrame.Size = UDim2.new(1,-20,0,30)
SearchFrame.Position = UDim2.new(0,10,0,50)
SearchFrame.BackgroundColor3 = Theme.Search
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0,6)

local SearchIcon = Instance.new("ImageLabel", SearchFrame)
SearchIcon.Size = UDim2.new(0,16,0,16)
SearchIcon.Position = UDim2.new(0,8,0.5,-8)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://3926305904" -- Search Icon
SearchIcon.ImageRectOffset = Vector2.new(964, 324)
SearchIcon.ImageRectSize = Vector2.new(36, 36)
SearchIcon.ImageColor3 = Theme.SubText

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1,-35,1,0)
SearchBox.Position = UDim2.new(0,30,0,0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.TextColor3 = Theme.Text
SearchBox.PlaceholderColor3 = Theme.SubText
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

-- TAB CONTAINER
local TabButtons = Instance.new("ScrollingFrame", Sidebar)
TabButtons.Position = UDim2.new(0,0,0,90) -- Hạ xuống để nhường chỗ cho Search
TabButtons.Size = UDim2.new(1,0,1,-95)
TabButtons.BackgroundTransparency = 1
TabButtons.CanvasSize = UDim2.new(0,0,0,0)
TabButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabButtons.ScrollBarImageTransparency = 0.8
TabButtons.ScrollBarThickness = 2
TabButtons.BorderSizePixel = 0

local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.Padding = UDim.new(0,4)

-- Search Logic
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local input = SearchBox.Text:lower()
	for _, btn in pairs(TabButtons:GetChildren()) do
		if btn:IsA("TextButton") then
			local label = btn:FindFirstChild("TabLabel")
			if label then
				if label.Text:lower():find(input) then
					btn.Visible = true
				else
					btn.Visible = false
				end
			end
		end
	end
end)

-- ================= CONTENT =================
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,180,0,15)
Content.Size = UDim2.new(1,-190,1,-30)
Content.BackgroundTransparency = 1

local CurrentTab

-- ================= CREATE TAB =================
-- [UPDATED] Added Icon parameter
function Windy:CreateTab(name, iconId)
	local Btn = Instance.new("TextButton", TabButtons)
	Btn.Size = UDim2.new(1,0,0,36)
	Btn.Text = ""
	Btn.BackgroundTransparency = 1
	Btn.Name = name -- For organization

	-- Active Indicator (Bar bên trái)
	local Indicator = Instance.new("Frame", Btn)
	Indicator.Size = UDim2.new(0,4,0,16)
	Indicator.Position = UDim2.new(0,0,0.5,-8)
	Indicator.BackgroundColor3 = Theme.Main
	Indicator.Visible = false
	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0,2)

	local Icon
	local TextOffset = 15

	-- [NEW] Icon Handling
	if iconId then
		Icon = Instance.new("ImageLabel", Btn)
		Icon.Size = UDim2.new(0,20,0,20)
		Icon.Position = UDim2.new(0,15,0.5,-10)
		Icon.BackgroundTransparency = 1
		Icon.Image = "rbxassetid://" .. tostring(iconId)
		Icon.ImageColor3 = Theme.SubText
		TextOffset = 45 -- Đẩy chữ sang phải nếu có icon
	end

	local Label = Instance.new("TextLabel", Btn)
	Label.Name = "TabLabel"
	Label.Size = UDim2.new(1,-TextOffset,1,0)
	Label.Position = UDim2.new(0,TextOffset,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 13
	Label.TextColor3 = Theme.SubText
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Page = Instance.new("ScrollingFrame", Content)
	Page.Size = UDim2.new(1,0,1,0)
	Page.CanvasSize = UDim2.new(0,0,0,0)
	Page.ScrollBarThickness = 2
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.ScrollBarImageTransparency = 0.5

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0,8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function Activate()
		if CurrentTab then
			CurrentTab.Page.Visible = false
			CurrentTab.Label.TextColor3 = Theme.SubText
			CurrentTab.Indicator.Visible = false
			if CurrentTab.Icon then
				CurrentTab.Icon.ImageColor3 = Theme.SubText
			end
			TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		end
		
		Page.Visible = true
		Label.TextColor3 = Theme.Text
		Indicator.Visible = true
		if Icon then
			Icon.ImageColor3 = Theme.Text
		end
		TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.95, BackgroundColor3 = Theme.Main}):Play()
		
		CurrentTab = {Page = Page, Label = Label, Indicator = Indicator, Btn = Btn, Icon = Icon}
	end

	Btn.MouseButton1Click:Connect(Activate)
	
	-- Chọn tab đầu tiên
	if not CurrentTab then Activate() end

	return Page
end

-- ================= ADD SECTION =================
-- [NEW] AddSection Function
function Windy:AddSection(Page, text)
	local SectionFrame = Instance.new("Frame", Page)
	SectionFrame.Size = UDim2.new(1,-5,0,25)
	SectionFrame.BackgroundTransparency = 1
	
	local Label = Instance.new("TextLabel", SectionFrame)
	Label.Size = UDim2.new(1,0,1,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.SectionText
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Kẻ dòng nhỏ dưới section (Option)
	local Line = Instance.new("Frame", SectionFrame)
	Line.Size = UDim2.new(1,0,0,1)
	Line.Position = UDim2.new(0,0,1,-2)
	Line.BackgroundColor3 = Theme.Main
	Line.BorderSizePixel = 0
	
	return SectionFrame
end

-- ================= BUTTON =================
function Windy:AddButton(Page,text,callback)
	local BtnFrame = Instance.new("Frame", Page)
	BtnFrame.Size = UDim2.new(1,-5,0,38)
	BtnFrame.BackgroundColor3 = Theme.Section
	Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0,6)
	
	local Btn = Instance.new("TextButton", BtnFrame)
	Btn.Size = UDim2.new(1,0,1,0)
	Btn.BackgroundTransparency = 1
	Btn.Text = text
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamSemibold
	Btn.TextSize = 13
	
	Btn.MouseButton1Click:Connect(function()
		TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50,50,55)}):Play()
		task.wait(0.1)
		TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Section}):Play()
		callback()
	end)
end

-- ================= TOGGLE =================
function Windy:AddToggle(Page,text,default,callback)
	local state = Config.Toggles[text]
	if state == nil then state = default end

	local Frame = Instance.new("Frame", Page)
	Frame.Size = UDim2.new(1,-5,0,38)
	Frame.BackgroundColor3 = Theme.Section
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1,-60,1,0)
	Label.Position = UDim2.new(0,12,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local ToggleBtn = Instance.new("TextButton", Frame)
	ToggleBtn.Size = UDim2.new(0,42,0,22)
	ToggleBtn.Position = UDim2.new(1,-52,0.5,-11)
	ToggleBtn.Text = ""
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,65)
	Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

	local Circle = Instance.new("Frame", ToggleBtn)
	Circle.Size = UDim2.new(0,18,0,18)
	Circle.Position = UDim2.new(0,2,0.5,-9)
	Circle.BackgroundColor3 = Color3.fromRGB(200,200,200)
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)

	local function Refresh()
		if state then
			TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Main}):Play()
			TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1,-20,0.5,-9)}):Play()
		else
			TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,60,65)}):Play()
			TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0,2,0.5,-9)}):Play()
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

-- ================= GUI TOGGLE =================
local GUI_VISIBLE = true

local function ToggleGUI(state)
	GUI_VISIBLE = state
	if GUI_VISIBLE then
		Main.Visible = true
		TweenService:Create(Main,TweenInfo.new(0.3),{BackgroundTransparency = 0}):Play()
		for _,v in pairs(Main:GetDescendants()) do
			if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("ImageLabel") then
				-- v.TextTransparency = 0 (Simplified)
			end
		end
	else
		-- Hide animation
		Main.Visible = false 
	end
end

-- Floating Button
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0,40,0,40) -- Hình tròn
FloatBtn.Position = UDim2.new(0,20,0.5,-20)
FloatBtn.BackgroundColor3 = Theme.Main
FloatBtn.Text = ""
FloatBtn.ZIndex = 999
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1,0)
-- Icon Windy
local FIcon = Instance.new("ImageLabel", FloatBtn)
FIcon.Size = UDim2.new(0,24,0,24)
FIcon.Position = UDim2.new(0.5,-12,0.5,-12)
FIcon.BackgroundTransparency = 1
FIcon.Image = "rbxassetid://3926305904" -- Settings Icon
FIcon.ImageRectOffset = Vector2.new(324, 124)
FIcon.ImageRectSize = Vector2.new(36, 36)

FloatBtn.MouseButton1Click:Connect(function()
	ToggleGUI(not Main.Visible)
end)

local ToggleKey = Enum.KeyCode[Config.Keybind] or Enum.KeyCode.RightControl
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == ToggleKey then
		ToggleGUI(not Main.Visible)
	end
end)

return Windy
