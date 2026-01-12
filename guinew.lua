--// WindyUI v2.5 FINAL FIX
--// Stable Hub Library (No Bug)

local Windy = {}

-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Remove old
pcall(function()
	CoreGui:FindFirstChild("WindyUI_V2"):Destroy()
end)

-- ================= THEME =================
local Theme = {
	BG = Color3.fromRGB(25,25,30),
	Sidebar = Color3.fromRGB(20,20,25),
	Section = Color3.fromRGB(35,35,40),
	Text = Color3.fromRGB(240,240,240),
	SubText = Color3.fromRGB(150,150,150),
	Main = Color3.fromRGB(45,120,255)
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
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

-- Drag
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
Sidebar.Size = UDim2.new(0,160,1,0)
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

local TabButtons = Instance.new("Frame", Sidebar)
TabButtons.Position = UDim2.new(0,0,0,60)
TabButtons.Size = UDim2.new(1,0,1,-60)
TabButtons.BackgroundTransparency = 1
Instance.new("UIListLayout", TabButtons).Padding = UDim.new(0,6)

-- ================= CONTENT =================
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,170,0,15)
Content.Size = UDim2.new(1,-180,1,-30)
Content.BackgroundTransparency = 1

local CurrentTab

-- ================= TAB =================
function Windy:CreateTab(name)
	local Btn = Instance.new("TextButton", TabButtons)
	Btn.Size = UDim2.new(1,0,0,35)
	Btn.Text = ""
	Btn.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel", Btn)
	Label.Size = UDim2.new(1,-20,1,0)
	Label.Position = UDim2.new(0,15,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 14
	Label.TextColor3 = Theme.SubText
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Page = Instance.new("ScrollingFrame", Content)
	Page.Size = UDim2.new(1,0,1,0)
	Page.CanvasSize = UDim2.new(0,0,0,0)
	Page.ScrollBarThickness = 3
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

-- ================= BUTTON =================
function Windy:AddButton(Page,text,callback)
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

-- ================= TOGGLE =================
function Windy:AddToggle(Page,text,default,callback)
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
		if state then
			Toggle.BackgroundColor3 = Theme.Main
			Circle.Position = UDim2.new(1,-18,0.5,-8)
		else
			Toggle.BackgroundColor3 = Color3.fromRGB(60,60,65)
			Circle.Position = UDim2.new(0,2,0.5,-8)
		end
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

-- ================= GUI TOGGLE (FLOAT + KEYBIND) =================
local GUI_VISIBLE = true

local function ToggleGUI(state)
	GUI_VISIBLE = state
	if GUI_VISIBLE then
		Main.Visible = true
		Main.Size = UDim2.new(0,600,0,0)
		TweenService:Create(Main,TweenInfo.new(0.35),{
			Size = UDim2.new(0,600,0,400)
		}):Play()
	else
		TweenService:Create(Main,TweenInfo.new(0.3),{
			Size = UDim2.new(0,600,0,0)
		}):Play()
		task.delay(0.3,function()
			Main.Visible = false
		end)
	end
end

-- Floating Button
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0,70,0,32)
FloatBtn.Position = UDim2.new(0,20,0.5,-16)
FloatBtn.BackgroundColor3 = Theme.Main
FloatBtn.Text = "ON"
FloatBtn.TextColor3 = Color3.new(1,1,1)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 14
FloatBtn.ZIndex = 999
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1,0)

FloatBtn.MouseButton1Click:Connect(function()
	ToggleGUI(not GUI_VISIBLE)
	FloatBtn.Text = GUI_VISIBLE and "ON" or "OFF"
end)

-- Keybind
local ToggleKey = Enum.KeyCode[Config.Keybind] or Enum.KeyCode.RightControl
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == ToggleKey then
		ToggleGUI(not GUI_VISIBLE)
		FloatBtn.Text = GUI_VISIBLE and "ON" or "OFF"
	end
end)

return Windy
