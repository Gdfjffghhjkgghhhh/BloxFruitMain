--// WindyUI v2
--// Stable Hub Library

local Windy = {}

-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Remove old
pcall(function()
	CoreGui:FindFirstChild("WindyUI_V2"):Destroy()
end)

-- Theme
local Theme = {
	BG = Color3.fromRGB(25,25,30),
	Sidebar = Color3.fromRGB(20,20,25),
	Section = Color3.fromRGB(35,35,40),
	Text = Color3.fromRGB(240,240,240),
	SubText = Color3.fromRGB(150,150,150),
	Main = Color3.fromRGB(45,120,255)
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WindyUI_V2"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main
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

-- Sidebar
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

-- Tab buttons
local TabButtons = Instance.new("Frame", Sidebar)
TabButtons.Position = UDim2.new(0,0,0,60)
TabButtons.Size = UDim2.new(1,0,1,-60)
TabButtons.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.Padding = UDim.new(0,6)

-- Content
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,170,0,15)
Content.Size = UDim2.new(1,-180,1,-30)
Content.BackgroundTransparency = 1

local Tabs = {}
local CurrentTab = nil

-- ================= TAB =================
function Windy:CreateTab(name)
	-- Button
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

	-- Page
	local Page = Instance.new("ScrollingFrame", Content)
	Page.Size = UDim2.new(1,0,1,0)
	Page.ScrollBarThickness = 3
	Page.CanvasSize = UDim2.new(0,0,0,0)
	Page.Visible = false
	Page.BackgroundTransparency = 1

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0,10)

	-- Force update canvas (KHÔNG BUG)
	local function UpdateCanvas()
		Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 15)
	end
	Page.ChildAdded:Connect(UpdateCanvas)

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

	if not CurrentTab then
		Activate()
	end

	table.insert(Tabs, Page)
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

	Btn.MouseButton1Click:Connect(callback)
end

-- ================= TOGGLE =================
function Windy:AddToggle(Page,text,default,callback)
	local state = default

	local Btn = Instance.new("Frame", Page)
	Btn.Size = UDim2.new(1,-10,0,40)
	Btn.BackgroundColor3 = Theme.Section
	Btn.LayoutOrder = #Page:GetChildren()
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

	local Label = Instance.new("TextLabel", Btn)
	Label.Size = UDim2.new(1,-70,1,0)
	Label.Position = UDim2.new(0,15,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Toggle = Instance.new("TextButton", Btn)
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
		callback(state)
	end
	Refresh()

	Toggle.MouseButton1Click:Connect(function()
		state = not state
		Refresh()
	end)
end
-- ================= TOGGLE GUI (KEYBIND) =================
local GUI_ENABLED = true
local TOGGLE_KEY = Enum.KeyCode.RightControl -- đổi Insert nếu muốn

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == TOGGLE_KEY then
		GUI_ENABLED = not GUI_ENABLED
		ScreenGui.Enabled = GUI_ENABLED
	end
end)

return Windy
