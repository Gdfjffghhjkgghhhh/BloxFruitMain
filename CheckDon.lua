
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local CFG = {
    TitleLeft = "📌 Note",
    TitleMid  = "📊 Status",
    TitleRight= "⚙ Setting",

    MainTextPrefix = "Tên : ",
    BottomText = "GHI DON VAO DAY",

    MaskName = true,
    KeepChars = 4,        
    MaskChar = "*",
    MinStars = 5,         

    Size = UDim2.fromOffset(720, 220),
    Position = UDim2.new(0.5, 0, 0.08, 0), -- giữa trên

    CornerRadius = 15,    -- bo góc ít
    BorderThickness = 3,  -- viền trắng mỏng
    BorderColor = Color3.fromRGB(255,255,255),

    InnerColor = Color3.fromRGB(0,255,255), -- xanh ngọc
    InnerTransparency = 0.78,                 -- mờ nhẹ
    OuterColor = Color3.fromRGB(255,255,255),  -- nền tối phía ngoài
    OuterTransparency = 0.15,

    TextColor = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold,
}

local function maskName(name)
    if not CFG.MaskName then return name end
    name = tostring(name or "")
    if #name <= CFG.KeepChars then
        return name .. string.rep(CFG.MaskChar, CFG.MinStars)
    end
    local keep = string.sub(name, 1, CFG.KeepChars)
    local stars = math.max(CFG.MinStars, #name - CFG.KeepChars)
    return keep .. string.rep(CFG.MaskChar, stars)
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        obj:Destroy()
    end
end

safeDestroy(CoreGui:FindFirstChild("NeonNameCard_UI"))

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonNameCard_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Outer = Instance.new("Frame")
Outer.Name = "Outer"
Outer.AnchorPoint = Vector2.new(0.5, 0)
Outer.Position = CFG.Position
Outer.Size = CFG.Size
Outer.BackgroundColor3 = CFG.OuterColor
Outer.BackgroundTransparency = CFG.OuterTransparency
Outer.Parent = ScreenGui

local OuterCorner = Instance.new("UICorner")
OuterCorner.CornerRadius = UDim.new(0, CFG.CornerRadius)
OuterCorner.Parent = Outer

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = CFG.BorderThickness
Stroke.Color = CFG.BorderColor
Stroke.Transparency = 0
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Outer

local Inner = Instance.new("Frame")
Inner.Name = "Inner"
Inner.Size = UDim2.new(1, -10, 1, -10)
Inner.Position = UDim2.fromOffset(5, 5)
Inner.BackgroundColor3 = CFG.InnerColor
Inner.BackgroundTransparency = CFG.InnerTransparency
Inner.Parent = Outer

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, CFG.CornerRadius - 2)
InnerCorner.Parent = Inner

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, -20, 0, 44)
TopBar.Position = UDim2.fromOffset(10, 6)
TopBar.Parent = Inner

local function makeTopLabel(text, posX)
    local L = Instance.new("TextLabel")
    L.BackgroundTransparency = 1
    L.Size = UDim2.new(0.33, 0, 1, 0)
    L.Position = UDim2.new(posX, 0, 0, 0)
    L.Font = CFG.Font
    L.TextSize = 26
    L.TextColor3 = CFG.TextColor
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Text = text
    L.Parent = TopBar
    return L
end

local LNote   = makeTopLabel(CFG.TitleLeft, 0.00)
local LStatus = makeTopLabel(CFG.TitleMid,  0.34)
local LSetting= makeTopLabel(CFG.TitleRight,0.67)

local NameRow = Instance.new("Frame")
NameRow.Name = "NameRow"
NameRow.BackgroundTransparency = 1
NameRow.Size = UDim2.new(1, -20, 0, 90)
NameRow.Position = UDim2.fromOffset(10, 56)
NameRow.Parent = Inner

local Icon = Instance.new("TextLabel")
Icon.BackgroundTransparency = 1
Icon.Size = UDim2.fromOffset(70, 70)
Icon.Position = UDim2.fromOffset(0, 10)
Icon.Font = Enum.Font.GothamBlack
Icon.TextSize = 56
Icon.TextColor3 = CFG.TextColor
Icon.Text = "👤"
Icon.Parent = NameRow

local NameLabel = Instance.new("TextLabel")
NameLabel.Name = "NameLabel"
NameLabel.BackgroundTransparency = 1
NameLabel.Size = UDim2.new(1, -80, 1, 0)
NameLabel.Position = UDim2.fromOffset(80, 0)
NameLabel.Font = CFG.Font
NameLabel.TextSize = 54
NameLabel.TextColor3 = CFG.TextColor
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.TextYAlignment = Enum.TextYAlignment.Center
NameLabel.Text = CFG.MainTextPrefix .. maskName(LP.Name)
NameLabel.Parent = NameRow

local Bottom = Instance.new("TextLabel")
Bottom.Name = "Bottom"
Bottom.BackgroundTransparency = 1
Bottom.Size = UDim2.new(1, -20, 0, 60)
Bottom.Position = UDim2.new(0, 10, 1, -64)
Bottom.Font = CFG.Font
Bottom.TextSize = 44
Bottom.TextColor3 = CFG.TextColor
Bottom.TextXAlignment = Enum.TextXAlignment.Center
Bottom.Text = CFG.BottomText
Bottom.Parent = Inner

--animation gui
Outer.Visible = true
Outer.Size = UDim2.fromOffset(CFG.Size.X.Offset, 0)
Outer.BackgroundTransparency = 1
Inner.BackgroundTransparency = 1
Stroke.Transparency = 1
TopBar.Position = UDim2.fromOffset(10, 16)
NameRow.Position = UDim2.fromOffset(10, 74)
Bottom.Position = UDim2.new(0, 10, 1, -54)

TweenService:Create(Outer, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = CFG.Size,
    BackgroundTransparency = CFG.OuterTransparency
}):Play()

TweenService:Create(Inner, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    BackgroundTransparency = CFG.InnerTransparency
}):Play()

TweenService:Create(Stroke, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Transparency = 0
}):Play()

TweenService:Create(TopBar, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.fromOffset(10, 6)
}):Play()

TweenService:Create(NameRow, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.fromOffset(10, 56)
}):Play()

TweenService:Create(Bottom, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0, 10, 1, -64)
}):Play()

local function refreshName()
    NameLabel.Text = CFG.MainTextPrefix .. maskName(LP.Name)
end

LP:GetPropertyChangedSignal("Name"):Connect(refreshName)
refreshName()
--api gui
getgenv().NeonNameCardAPI = {
    SetPrefix = function(prefix)
        CFG.MainTextPrefix = tostring(prefix or "Tên : ")
        refreshName()
    end,

    SetBottomText = function(text)
        CFG.BottomText = tostring(text or "")
        Bottom.Text = CFG.BottomText
    end,

    SetTopTitles = function(left, mid, right)
        if left ~= nil then CFG.TitleLeft = tostring(left) LNote.Text = CFG.TitleLeft end
        if mid  ~= nil then CFG.TitleMid  = tostring(mid)  LStatus.Text = CFG.TitleMid end
        if right~= nil then CFG.TitleRight= tostring(right)LSetting.Text = CFG.TitleRight end
    end,

    SetMask = function(enabled, keepChars, minStars)
        CFG.MaskName = (enabled == true)
        if keepChars then CFG.KeepChars = math.max(0, tonumber(keepChars) or CFG.KeepChars) end
        if minStars then CFG.MinStars = math.max(0, tonumber(minStars) or CFG.MinStars) end
        refreshName()
    end,

    SetTheme = function(innerColor, innerTransparency, borderColor)
        if innerColor then
            CFG.InnerColor = innerColor
            Inner.BackgroundColor3 = innerColor
        end
        if innerTransparency ~= nil then
            CFG.InnerTransparency = math.clamp(tonumber(innerTransparency) or CFG.InnerTransparency, 0, 1)
            Inner.BackgroundTransparency = CFG.InnerTransparency
        end
        if borderColor then
            CFG.BorderColor = borderColor
            Stroke.Color = borderColor
        end
    end,

    Destroy = function()
        safeDestroy(ScreenGui)
        if getgenv().NeonNameCardAPI then
            getgenv().NeonNameCardAPI = nil
        end
    end
}
