-- WindyUI Library
local Windy = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
	Background = Color3.fromRGB(25,25,30),
	Sidebar = Color3.fromRGB(20,20,25),
	Section = Color3.fromRGB(35,35,40),
	Text = Color3.fromRGB(240,240,240),
	TextDark = Color3.fromRGB(150,150,150),
	Gradient1 = Color3.fromRGB(45,120,255),
	Gradient2 = Color3.fromRGB(180,50,255)
}

pcall(function()
	CoreGui.WindyRemake:Destroy()
end)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "WindyRemake"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,600,0,400)
MainFrame.Position = UDim2.new(0.5,-300,0.5,-200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

-- Drag
do
	local dragging, startPos, startInput
	MainFrame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInput = i.Position
			startPos = MainFrame.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - startInput
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0,160,1,0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1,-30,0,30)
Title.Position = UDim2.new(0,15,0,15)
Title.BackgroundTransparency = 1
Title.Text = "WINDY HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UIGradient", Title).Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Theme.Gradient1),
	ColorSequenceKeypoint.new(1,Theme.Gradient2)
}

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Position = UDim2.new(0,0,0,60)
TabContainer.Size = UDim2.new(1,0,1,-60)
TabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0,5)

local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0,170,0,15)
Content.Size = UDim2.new(1,-180,1,-30)
Content.BackgroundTransparency = 1

local Tabs = {}

-- TAB
function Windy:CreateTab(name)
	local Btn = Instance.new("TextButton", TabContainer)
	Btn.Size = UDim2.new(1,0,0,35)
	Btn.Text = ""
	Btn.BackgroundTransparency = 1

	local Line = Instance.new("Frame", Btn)
	Line.Size = UDim2.new(0,3,0.6,0)
	Line.Position = UDim2.new(0,0,0.2,0)
	Line.BackgroundTransparency = 1
	Line.BackgroundColor3 = Theme.Gradient1

	local Label = Instance.new("TextLabel", Btn)
	Label.Size = UDim2.new(1,-20,1,0)
	Label.Position = UDim2.new(0,20,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 14
	Label.TextColor3 = Theme.TextDark
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Page = Instance.new("ScrollingFrame", Content)
	Page.Size = UDim2.new(1,0,1,0)
	Page.ScrollBarThickness = 3
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.CanvasSize = UDim2.new(0,0,0,0)

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0,10)

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
	end)

	local function Activate()
		for _,t in pairs(Tabs) do
			t.Page.Visible = false
			t.Line.BackgroundTransparency = 1
			t.Label.TextColor3 = Theme.TextDark
		end
		Page.Visible = true
		Line.BackgroundTransparency = 0
		Label.TextColor3 = Theme.Text
	end

	Btn.MouseButton1Click:Connect(Activate)

	table.insert(Tabs,{Page=Page,Line=Line,Label=Label})
	if #Tabs == 1 then Activate() end

	return Page
end

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

function Windy:AddToggle(Page,text,default,callback)
	local state = default
	local Btn = Instance.new("TextButton", Page)
	Btn.Size = UDim2.new(1,-10,0,40)
	Btn.BackgroundColor3 = Theme.Section
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.Gotham
	Btn.TextSize = 14
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

	local function Refresh()
		Btn.Text = text .. ": " .. tostring(state)
	end
	Refresh()

	Btn.MouseButton1Click:Connect(function()
		state = not state
		Refresh()
		callback(state)
	end)
end

return Windy
