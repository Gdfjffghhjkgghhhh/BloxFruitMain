--// INIT VAR
_G.AutoFarm_Bone = false
_G.AcceptQuestC = true
_G.MobIndex = 1

local BonesTable = {
    "Reborn Skeleton",
    "Living Zombie",
    "Demonic Soul",
    "Posessed Mummy"
}

--// GUI
local plr = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BoneFarmGUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0, 0)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Tween mở GUI
game:GetService("TweenService"):Create(
    main,
    TweenInfo.new(0.35, Enum.EasingStyle.Quart),
    {Size = UDim2.fromOffset(300, 220)}
):Play()

--// TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "💀 Auto Farm Bone"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

--// CREATE BUTTON FUNC
local function CreateButton(text, y)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.fromOffset(10, y)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    return btn
end

--// TOGGLE AUTO FARM
local farmBtn = CreateButton("Auto Farm Bone: OFF", 50)
farmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm_Bone = not _G.AutoFarm_Bone
    farmBtn.Text = "Auto Farm Bone: " .. (_G.AutoFarm_Bone and "ON" or "OFF")
end)

--// TOGGLE QUEST
local questBtn = CreateButton("Auto Quest: ON", 95)
questBtn.MouseButton1Click:Connect(function()
    _G.AcceptQuestC = not _G.AcceptQuestC
    questBtn.Text = "Auto Quest: " .. (_G.AcceptQuestC and "ON" or "OFF")
end)

--// DROPDOWN MOB
local mobBtn = CreateButton("Mob: "..BonesTable[_G.MobIndex], 140)
mobBtn.MouseButton1Click:Connect(function()
    _G.MobIndex += 1
    if _G.MobIndex > #BonesTable then
        _G.MobIndex = 1
    end
    mobBtn.Text = "Mob: "..BonesTable[_G.MobIndex]
end)

--// NOTE
local note = Instance.new("TextLabel", main)
note.Size = UDim2.new(1,0,0,30)
note.Position = UDim2.fromOffset(0,185)
note.BackgroundTransparency = 1
note.Text = "Drag GUI • Safe Tween"
note.TextColor3 = Color3.fromRGB(140,140,140)
note.Font = Enum.Font.Gotham
note.TextSize = 12
