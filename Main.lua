--// SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PlayerFruitGUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.25, 0.45)
main.Position = UDim2.fromScale(0.02, 0.25)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0.12,0)
title.Text = "🍎 PLAYER FRUIT SCANNER"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,100,100)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

--// SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0,0,0.13,0)
scroll.Size = UDim2.new(1,0,0.87,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 0.4
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

--// GET FRUIT
local function GetFruit(plr)
    local data = plr:FindFirstChild("Data")
    if data and data:FindFirstChild("DevilFruit") then
        return data.DevilFruit.Value ~= "" and data.DevilFruit.Value or "No Fruit"
    end
    return "Unknown"
end

--// REFRESH LIST
local function Refresh()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    for _,plr in pairs(Players:GetPlayers()) do
        local fruit = GetFruit(plr)

        local item = Instance.new("Frame", scroll)
        item.Size = UDim2.new(1,-10,0,45)
        item.BackgroundColor3 = Color3.fromRGB(35,35,35)
        item.BorderSizePixel = 0

        Instance.new("UICorner", item).CornerRadius = UDim.new(0,8)

        local txt = Instance.new("TextLabel", item)
        txt.Size = UDim2.new(1,-10,1,0)
        txt.Position = UDim2.new(0,5,0,0)
        txt.BackgroundTransparency = 1
        txt.TextXAlignment = Left
        txt.Text = "👤 "..plr.Name.." | 🍎 "..fruit
        txt.TextColor3 = Color3.fromRGB(230,230,230)
        txt.Font = Enum.Font.Gotham
        txt.TextScaled = true
    end

    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

--// AUTO UPDATE
Refresh()
Players.PlayerAdded:Connect(Refresh)
Players.PlayerRemoving:Connect(Refresh)

task.spawn(function()
    while task.wait(10) do
        Refresh()
    end
end)
