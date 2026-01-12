--// WindyUI v2.5 FULL
--// Stable Hub Library

local Windy = {}

-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Prevent duplicate
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
local Config = {
	Toggles = {},
	Dropdowns = {},
	Sliders = {},
	Keybind = "RightControl"
}

-- Load config
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

-- ================= SCREEN GUI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WindyUI_V2"
ScreenGui.Parent = CoreGui
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
	local dragging, startPos, startInput
	Main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInput = i.Position
			startPos = Main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
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

-- Tabs
local TabButtons = Instance.new("Frame", Sidebar)
TabButtons.Position = UDim2.new(0,0,0,60)
TabButtons.Size = UDim2.new(1,0,1,-60)
TabButtons.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.Padding = UDim.new(0,6)

-- ================= CONTENT =================
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,170,0,15)
Content.Size = UDim2.new(1,-180,1,-30)
Content.BackgroundTransparency = 1

local CurrentTab

-- ================= NOTIFY =================
local NotifyHolder = Instance.new("Frame", ScreenGui)
NotifyHolder.Size = UDim2.new(0,300,1,0)
NotifyHolder.Position = UDim2.new(1,-310,0,10)
NotifyHolder.BackgroundTransparency = 1

local function Notify(text)
	local Frame = Instance.new("Frame", NotifyHolder)
	Frame.Size = UDim2.new(1,0,0,40)
	Frame.BackgroundColor3 = Theme.Section
	Frame.BackgroundTransparency = 0.1
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1,-20,1,0)
	Label.Position = UDim2.new(0,10,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left

	Frame.Position = UDim2.new(1,0,0,0)
	TweenService:Create(Frame,TweenInfo.new(0.3),{
		Position = UDim2.new(0,0,0,0)
	}):Play()

	task.delay(2,function()
		TweenService:Create(Frame,TweenInfo.new(0.3),{
			Position = UDim2.new(1,0,0,0),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		Frame:Destroy()
	end)
end

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

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0,10)

	Page.ChildAdded:Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 15)
	end)

	local function Activate()
		if CurrentTab then
			CurrentTab.Page.Visible = false
			CurrentTab.Label.TextColor3 = Theme.SubText
		end
		Page.Visible = true
		Label.TextColor3 = Theme.Text
		CurrentTab = {Page=Page,Label=Label}
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
	Btn.LayoutOrder = #Page:GetChildren()
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

	Btn.MouseButton1Click:Connect(function()
		callback()
		Notify(text)
	end)
end

-- ================= TOGGLE =================
function Windy:AddToggle(Page,text,default,callback)
	local state = Config.Toggles[text]
	if state == nil then state = default end

	local Frame = Instance.new("Frame", Page)
	Frame.Size = UDim2.new(1,-10,0,40)
	Frame.BackgroundColor3 = Theme.Section
	Frame.LayoutOrder = #Page:GetChildren()
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

-- ================= KEYBIND GUI =================
local GUI_ENABLED = true
local ToggleKey = Enum.KeyCode[Config.Keybind] or Enum.KeyCode.RightControl

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == ToggleKey then
		GUI_ENABLED = not GUI_ENABLED
		ScreenGui.Enabled = GUI_ENABLED
		Notify(GUI_ENABLED and "GUI Enabled" or "GUI Hidden")
	end
end)

-- ================= MINI BUTTON =================
local Mini = Instance.new("TextButton", ScreenGui)
Mini.Size = UDim2.new(0,40,0,40)
Mini.Position = UDim2.new(0,20,0.5,-20)
Mini.Text = "W"
Mini.Visible = false
Mini.BackgroundColor3 = Theme.Main
Mini.TextColor3 = Color3.new(1,1,1)
Mini.Font = Enum.Font.GothamBold
Mini.TextSize = 18
Instance.new("UICorner", Mini).CornerRadius = UDim.new(1,0)

Mini.MouseButton1Click:Connect(function()
	ScreenGui.Enabled = true
	Mini.Visible = false
end)

ScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	Mini.Visible = not ScreenGui.Enabled
end)

return Windy
