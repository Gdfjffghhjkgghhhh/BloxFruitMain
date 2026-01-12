--// WINDY UI V3 FULL
--// Stable + Scroll + Search + Section + Icon

local Windy = {}

-- SERVICES
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- REMOVE OLD
pcall(function()
	CoreGui:FindFirstChild("WindyUI_V3"):Destroy()
end)

-- THEME
local Theme = {
	BG = Color3.fromRGB(25,25,30),
	Sidebar = Color3.fromRGB(20,20,25),
	Section = Color3.fromRGB(35,35,40),
	Text = Color3.fromRGB(240,240,240),
	SubText = Color3.fromRGB(150,150,150),
	Main = Color3.fromRGB(45,120,255)
}

-- CONFIG
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

-- GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "WindyUI_V3"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,620,0,420)
Main.Position = UDim2.new(0.5,-310,0.5,-210)
Main.BackgroundColor3 = Theme.BG
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

-- DRAG
do
	local drag, startPos, startInput
	Main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			startInput = i.Position
			startPos = Main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag = false end
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

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,170,1,0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1,-20,0,40)
Title.Position = UDim2.new(0,10,0,10)
Title.BackgroundTransparency = 1
Title.Text = "WINDY HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

-- SEARCH TAB
local TabSearch = Instance.new("TextBox", Sidebar)
TabSearch.Size = UDim2.new(1,-20,0,30)
TabSearch.Position = UDim2.new(0,10,0,55)
TabSearch.PlaceholderText = "Search tab..."
TabSearch.Text = ""
TabSearch.BackgroundColor3 = Theme.Section
TabSearch.TextColor3 = Theme.Text
TabSearch.ClearTextOnFocus = false
Instance.new("UICorner", TabSearch).CornerRadius = UDim.new(0,6)

-- TAB LIST
local TabButtons = Instance.new("ScrollingFrame", Sidebar)
TabButtons.Position = UDim2.new(0,0,0,95)
TabButtons.Size = UDim2.new(1,0,1,-95)
TabButtons.BackgroundTransparency = 1
TabButtons.ScrollBarThickness = 4
TabButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y

local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.Padding = UDim.new(0,6)

-- CONTENT
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,185,0,15)
Content.Size = UDim2.new(1,-195,1,-30)
Content.BackgroundTransparency = 1

local CurrentTab

-- SEARCH LOGIC TAB
TabSearch:GetPropertyChangedSignal("Text"):Connect(function()
	for _,btn in ipairs(TabButtons:GetChildren()) do
		if btn:IsA("TextButton") then
			local lbl = btn:FindFirstChild("Label")
			if lbl then
				btn.Visible = TabSearch.Text == "" or lbl.Text:lower():find(TabSearch.Text:lower())
			end
		end
	end
end)

-- CREATE TAB
function Windy:CreateTab(name, icon)
	local Btn = Instance.new("TextButton", TabButtons)
	Btn.Size = UDim2.new(1,0,0,36)
	Btn.Text = ""
	Btn.BackgroundTransparency = 1

	if icon then
		local Icon = Instance.new("ImageLabel", Btn)
		Icon.Size = UDim2.new(0,18,0,18)
		Icon.Position = UDim2.new(0,12,0.5,-9)
		Icon.BackgroundTransparency = 1
		Icon.Image = icon
	end

	local Label = Instance.new("TextLabel", Btn)
	Label.Name = "Label"
	Label.Size = UDim2.new(1,-45,1,0)
	Label.Position = UDim2.new(0,icon and 40 or 15,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 14
	Label.TextColor3 = Theme.SubText
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Page = Instance.new("ScrollingFrame", Content)
	Page.Size = UDim2.new(1,0,1,0)
	Page.ScrollBarThickness = 4
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0,10)

	local function Activate()
		if CurrentTab then
			CurrentTab.Page.Visible = false
			CurrentTab.Label.TextColor3 = Theme.SubText
		end
		Page.Visible = true
		Label.TextColor3 = Theme.Text
		CurrentTab = {Page = Page, Label = Label}
	end

	Btn.MouseButton1Click:Connect(Activate)
	if not CurrentTab then Activate() end

	return Page
end

-- ADD SECTION
function Windy:AddSection(Page, title)
	local Holder = Instance.new("Frame", Page)
	Holder.Size = UDim2.new(1,-10,0,32)
	Holder.AutomaticSize = Enum.AutomaticSize.Y
	Holder.BackgroundTransparency = 1

	local Header = Instance.new("TextButton", Holder)
	Header.Size = UDim2.new(1,0,0,32)
	Header.Text = "▼ "..title
	Header.BackgroundTransparency = 1
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 13
	Header.TextColor3 = Theme.SubText
	Header.TextXAlignment = Enum.TextXAlignment.Left

	local Container = Instance.new("Frame", Holder)
	Container.Position = UDim2.new(0,0,0,32)
	Container.Size = UDim2.new(1,0,0,0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	Container.BackgroundTransparency = 1

	local Layout = Instance.new("UIListLayout", Container)
	Layout.Padding = UDim.new(0,8)

	local open = true
	Header.MouseButton1Click:Connect(function()
		open = not open
		Container.Visible = open
		Header.Text = (open and "▼ " or "▶ ")..title
	end)

	return Container
end

-- ADD BUTTON
function Windy:AddButton(Page, text, callback)
	local Btn = Instance.new("TextButton", Page)
	Btn.Size = UDim2.new(1,-10,0,40)
	Btn.BackgroundColor3 = Theme.Section
	Btn.Text = text
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamSemibold
	Btn.TextSize = 14
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
	Btn.MouseButton1Click:Connect(callback)
end

-- ADD TOGGLE
function Windy:AddToggle(Page, text, default, callback)
	local state = Config.Toggles[text]
	if state == nil then state = default end

	local Frame = Instance.new("Frame", Page)
	Frame.Size = UDim2.new(1,-10,0,40)
	Frame.BackgroundColor3 = Theme.Section
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1,-70,1,0)
	Label.Position = UDim2.new(0,15,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Toggle = Instance.new("TextButton", Frame)
	Toggle.Size = UDim2.new(0,40,0,20)
	Toggle.Position = UDim2.new(1,-55,0.5,-10)
	Toggle.Text = ""
	Toggle.BackgroundColor3 = Color3.fromRGB(60,60,65)
	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)

	local Circle = Instance.new("Frame", Toggle)
	Circle.Size = UDim2.new(0,16,0,16)
	Circle.Position = UDim2.new(0,2,0.5,-8)
	Circle.BackgroundColor3 = Color3.fromRGB(200,200,200)
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)

	local function Refresh()
		Toggle.BackgroundColor3 = state and Theme.Main or Color3.fromRGB(60,60,65)
		Circle.Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
		Config.Toggles[text] = state
		SaveConfig()
		callback(state)
	end

	Refresh()
	Toggle.MouseButton1Click:Connect(function()
		state = not state
		Refresh()
	end)
end

-- FLOATING BUTTON
local GUI_VISIBLE = true
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0,70,0,32)
FloatBtn.Position = UDim2.new(0,20,0.5,-16)
FloatBtn.BackgroundColor3 = Theme.Main
FloatBtn.Text = "ON"
FloatBtn.TextColor3 = Color3.new(1,1,1)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 14
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1,0)

FloatBtn.MouseButton1Click:Connect(function()
	GUI_VISIBLE = not GUI_VISIBLE
	Main.Visible = GUI_VISIBLE
	FloatBtn.Text = GUI_VISIBLE and "ON" or "OFF"
end)

return Windy
