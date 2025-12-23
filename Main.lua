
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Icon = Instance.new("ImageLabel")
local UICorner = Instance.new("UICorner")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "BlueX_MiniUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.1, 0.1)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0, 20, 0.1, -6)
MainFrame.Size = UDim2.new(0, 50, 0, 50)

Icon.Name = "Icon"
Icon.Parent = MainFrame
Icon.AnchorPoint = Vector2.new(0.5, 0.5)
Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
Icon.Size = UDim2.new(0, 40, 0, 40)
Icon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
Icon.BackgroundTransparency = 1
Icon.Image = "http://www.roblox.com/asset/?id=78936816738382"

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainFrame

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ""

-- Hiệu ứng nút bấm
local isToggled = false
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local SizeBig = UDim2.new(0, 40, 0, 40)
local SizeSmall = UDim2.new(0, 30, 0, 30)

local fadeOut = TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 0.25})
local fadeIn = TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 0})

local isFrameVisible = false

ToggleButton.MouseButton1Down:Connect(function()
    if isToggled then
        TweenService:Create(Icon, tweenInfo, {Size = SizeBig}):Play()
    else
        TweenService:Create(Icon, tweenInfo, {Size = SizeSmall}):Play()
    end
    isToggled = not isToggled

    if isFrameVisible then
        fadeIn:Play()
    else
        fadeOut:Play()
    end
    isFrameVisible = not isFrameVisible
    VirtualInputManager:SendKeyEvent(true, "LeftControl", false, game)
end)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Neon X Hub",
    SubTitle = "Brainrot Evolution",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "" }),
    Upgrade = Window:AddTab({ Title = "Upgrade", Icon = "" }),
    Use = Window:AddTab({ Title = "Use & Claim", Icon = "" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "" })
}

Window:SelectTab(1)

-- // TAB MAIN // --
Tabs.Main:AddParagraph({ Title = "Equip", Content = "-----" })

local TimeEquidBest = 10
Tabs.Main:AddSlider("TimeEquid", {
    Title = "Time Equip Best",
    Default = 10,
    Min = 1,
    Max = 180,
    Rounding = 0,
    Callback = function(Value)
        TimeEquidBest = Value
    end
})

local AutoEquipBrainrot = false
Tabs.Main:AddToggle("EBrainrot", {
    Title = "Auto Equip Best Brainrot",
    Default = false,
    Callback = function(Value)
        AutoEquipBrainrot = Value
    end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoEquipBrainrot then
            pcall(function()
                ReplicatedStorage.Packages.Knit.Services.MonsterService.RF.EquipBest:InvokeServer()
                task.wait(TimeEquidBest)
            end)
        end
    end
end)

local AutoEquipPet = false
Tabs.Main:AddToggle("EPet", {
    Title = "Auto Equip Best Pet",
    Default = false,
    Callback = function(Value)
        AutoEquipPet = Value
    end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoEquipPet then
            pcall(function()
                ReplicatedStorage.Packages.Knit.Services.PetsService.RF.EquipBest:InvokeServer()
                task.wait(TimeEquidBest)
            end)
        end
    end
end)

Tabs.Main:AddParagraph({ Title = "Farm", Content = "-----" })

local MobList = {}
local MobSeen = {}
local SelectMobDropdown = nil

local function RefreshMobs()
    MobList = {}
    MobSeen = {}
    
    -- Sửa lại vòng lặp lấy mobs từ workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
            local mobName = tostring(obj.Name)
            if mobName ~= "" and not MobSeen[mobName] then
                table.insert(MobList, mobName)
                MobSeen[mobName] = true
            end
        end
    end
    
    if SelectMobDropdown then
        pcall(function()
            SelectMobDropdown:SetValues(MobList)
        end)
    end
end

local SelectedMobName = ""
SelectMobDropdown = Tabs.Main:AddDropdown("Selectmob", {
    Title = "Select Mob",
    Values = {},
    Multi = false,
    Callback = function(Value)
        SelectedMobName = Value
    end
})

RefreshMobs() -- Chạy lần đầu

Tabs.Main:AddButton({
    Title = "Refresh Mob",
    Callback = function()
        RefreshMobs()
    end
})

local IsAutoFarm = false
Tabs.Main:AddToggle("AMob", {
    Title = "Auto Farm Mob Select",
    Default = false,
    Callback = function(Value)
        IsAutoFarm = Value
        if Value then
            task.spawn(function()
                while IsAutoFarm do
                    pcall(function()
                        TeleportToSelectedMob()
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end
})

function TeleportToSelectedMob()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == SelectedMobName and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
            local targetPos = obj.HumanoidRootPart.Position
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 7, 0))
            end
            break
        end
    end
end

-- Auto Click (Auto Attack Button in Game HUD)
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                -- Tìm nút Auto Attack trong HUD
                local hud = playerGui:FindFirstChild("HUD", true)
                if hud then
                    local autoBtn = hud:FindFirstChild("Buttons", true) and hud.Buttons:FindFirstChild("AutoAttackButton", true)
                    local onOffLabel = autoBtn and autoBtn:FindFirstChild("Frame", true) and autoBtn.Frame:FindFirstChild("On_Off", true) and autoBtn.Frame.On_Off:FindFirstChild("On_Off")
                    
                    if onOffLabel and onOffLabel:IsA("TextLabel") then
                        if IsAutoFarm and onOffLabel.Text == "OFF" then
                            ReplicatedStorage.Packages.Knit.Services.SettingsService.RF.UpdateSetting:InvokeServer("Auto Attack")
                        elseif not IsAutoFarm and onOffLabel.Text == "ON" then
                            ReplicatedStorage.Packages.Knit.Services.SettingsService.RF.UpdateSetting:InvokeServer("Auto Attack")
                        end
                    end
                end
            end
        end)
    end
end)

-- // TAB SHOP (EGG) // --
Tabs.Shop:AddParagraph({ Title = "Egg", Content = "-----" })

local SelectedEgg = ""
Tabs.Shop:AddDropdown("Egg", {
    Title = "Select Egg",
    Values = {
        "Adventure Egg", "Alien Egg", "Anicent Egg", "Cactus Egg", "Coral Egg", "Corn Egg",
        "Flower Egg", "Golem Egg", "Ice Egg", "Kraken Egg", "Lab Egg", "Leviathan Egg",
        "Marsh Egg", "Mecha Egg", "Monster Egg", "Reindeer Egg", "Scorpio Egg", "Snow Egg",
        "Solider Egg", "Train Egg", "Void Egg", "Voidrassic Egg", "Xenon Egg"
    },
    Multi = false,
    Callback = function(Value)
        SelectedEgg = Value
    end
})

local TimeBuyEgg = 2
Tabs.Shop:AddSlider("TimeBE", {
    Title = "Time Buy Egg",
    Default = 2,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        TimeBuyEgg = Value
    end
})

local AutoBuyEgg = false
Tabs.Shop:AddToggle("OpenEgg", {
    Title = "Auto Buy Egg Select",
    Default = false,
    Callback = function(Value)
        AutoBuyEgg = Value
    end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoBuyEgg and SelectedEgg ~= "" then
            pcall(function()
                local args = { SelectedEgg, 1, false, {} }
                ReplicatedStorage.Packages.Knit.Services.EggService.RF.OpenEgg:InvokeServer(unpack(args))
                task.wait(TimeBuyEgg)
            end)
        end
    end
end)

-- // TAB UPGRADE // --
Tabs.Upgrade:AddParagraph({ Title = "Upgrade", Content = "-----" })

local function BuyUpgrade(upgradeName)
    ReplicatedStorage.Packages.Knit.Services.WorldUpgradesService.RF.BuyUpgrade:InvokeServer(upgradeName)
end

Tabs.Upgrade:AddButton({ Title = "Upgrade Pet 1", Callback = function() BuyUpgrade("PetUpgrade1") end })
Tabs.Upgrade:AddButton({ Title = "Upgrade Pet 2", Callback = function() BuyUpgrade("PetUpgrade2") end })
Tabs.Upgrade:AddButton({ Title = "Upgrade Exp 1", Callback = function() BuyUpgrade("ExpUpgrade1") end })
Tabs.Upgrade:AddButton({ Title = "Upgrade Exp 2", Callback = function() BuyUpgrade("ExpUpgrade2") end })
Tabs.Upgrade:AddButton({ Title = "Upgrade Speed 1", Callback = function() BuyUpgrade("SpeedUpgrades1") end })
Tabs.Upgrade:AddButton({ Title = "Upgrade Relic 1", Callback = function() BuyUpgrade("RelicUpgrade1") end })
Tabs.Upgrade:AddButton({ Title = "Upgrade Damage 1", Callback = function() BuyUpgrade("DamageUpgrade1") end })

-- // TAB USE POTION & CLAIM // --
Tabs.Use:AddParagraph({ Title = "Use Potion", Content = "-----" })

local TimePotion = 2
Tabs.Use:AddSlider("TimeUse", {
    Title = "Time Use Potion",
    Default = 2,
    Min = 1,
    Max = 60,
    Rounding = 0,
    Callback = function(Value)
        TimePotion = Value
    end
})

local AutoUseExp = false
Tabs.Use:AddToggle("Exp", {
    Title = "Auto Use Exp Potion",
    Default = false,
    Callback = function(Value) AutoUseExp = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoUseExp then
            pcall(function()
                ReplicatedStorage.Packages.Knit.Services.ItemsService.RF.UseItem:InvokeServer("Exp Potion", "1")
                task.wait(TimePotion)
            end)
        end
    end
end)

local AutoUseWins = false
Tabs.Use:AddToggle("Win", {
    Title = "Auto Use Wins Potion",
    Default = false,
    Callback = function(Value) AutoUseWins = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoUseWins then
            pcall(function()
                ReplicatedStorage.Packages.Knit.Services.ItemsService.RF.UseItem:InvokeServer("Wins Potion", "1")
                task.wait(TimePotion)
            end)
        end
    end
end)

local AutoUseLuck = false
Tabs.Use:AddToggle("Luck", {
    Title = "Auto Use Luck Potion",
    Default = false,
    Callback = function(Value) AutoUseLuck = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoUseLuck then
            pcall(function()
                ReplicatedStorage.Packages.Knit.Services.ItemsService.RF.UseItem:InvokeServer("Luck Potion", "1")
                task.wait(TimePotion)
            end)
        end
    end
end)

Tabs.Use:AddParagraph({ Title = "Claim", Content = "-----" })

local TimeClaim = 2
Tabs.Use:AddSlider("TimeClaim", {
    Title = "Time Claim",
    Default = 2,
    Min = 1,
    Max = 60,
    Rounding = 0,
    Callback = function(Value) TimeClaim = Value end
})

local AutoClaimDaily = false
Tabs.Use:AddToggle("Daily", {
    Title = "Auto Claim Daily",
    Default = false,
    Callback = function(Value) AutoClaimDaily = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoClaimDaily then
            pcall(function()
                for i = 1, 7 do
                    ReplicatedStorage.Packages.Knit.Services.DailyService.RF.CollectDailyReward:InvokeServer(i)
                    task.wait(TimeClaim)
                end
            end)
        end
    end
end)

local AutoClaimGift = false
Tabs.Use:AddToggle("Gift", {
    Title = "Auto Claim Gift",
    Default = false,
    Callback = function(Value) AutoClaimGift = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoClaimGift then
            pcall(function()
                for i = 1, 7 do
                    ReplicatedStorage.Packages.Knit.Services.GiftService.RF.CollectGift:InvokeServer(i)
                    task.wait(TimeClaim)
                end
            end)
        end
    end
end)

local AutoClaimPassFree = false
Tabs.Use:AddToggle("PassF", {
    Title = "Auto Claim Pass Free",
    Default = false,
    Callback = function(Value) AutoClaimPassFree = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoClaimPassFree then
            pcall(function()
                for i = 1, 15 do
                    ReplicatedStorage.Packages.Knit.Services.SeasonPassService.RF.ClaimPass:InvokeServer("Free", i)
                    task.wait(TimeClaim)
                end
            end)
        end
    end
end)

local AutoClaimPassPremium = false
Tabs.Use:AddToggle("PassP", {
    Title = "Auto Claim Pass Premium",
    Default = false,
    Callback = function(Value) AutoClaimPassPremium = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoClaimPassPremium then
            pcall(function()
                for i = 1, 15 do
                    ReplicatedStorage.Packages.Knit.Services.SeasonPassService.RF.ClaimPass:InvokeServer("Paid", i)
                    task.wait(TimeClaim)
                end
            end)
        end
    end
end)

-- // TAB MISC // --
Tabs.Misc:AddParagraph({ Title = "Misc", Content = "-----" })

Tabs.Misc:AddToggle("AFK", {
    Title = "Anti AFK",
    Default = true,
    Callback = function(Value)
        if Value then
            local vu59 = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                VirtualUser:ClickButton2(Vector2.new())
                -- Sửa logic click chuột để tránh lỗi
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

local WalkSpeedValue = 50
Tabs.Misc:AddSlider("Speed", {
    Title = "Speed",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        WalkSpeedValue = Value
    end
})

local EnableWalkSpeed = false
Tabs.Misc:AddToggle("Walk", {
    Title = "Walk Speed",
    Default = false,
    Callback = function(Value)
        EnableWalkSpeed = Value
    end
})

local function UpdateWalkSpeed()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = EnableWalkSpeed and WalkSpeedValue or 16
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if EnableWalkSpeed then
        UpdateWalkSpeed()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if EnableWalkSpeed then
                UpdateWalkSpeed()
            end
        end)
    end
end)
