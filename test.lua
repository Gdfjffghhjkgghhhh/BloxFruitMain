--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

--// PLAYER
local Player = Players.LocalPlayer

--// REMOTES (Blox Fruits)
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

--// CONFIG
local Config = {
    Enabled = false,
    AttackDistance = 60,
    AttackCooldown = 0.18,
}

----------------------------------------------------------------
--// AUTO ATTACK CORE (CÓ DAMAGE)
----------------------------------------------------------------
local AutoAttack = {
    LastAttack = 0
}

function AutoAttack:GetTargets()
    local char = Player.Character
    if not char then return {} end
    local pos = char:GetPivot().Position
    local list = {}

    local function scan(folder)
        for _, v in ipairs(folder:GetChildren()) do
            local hum = v:FindFirstChild("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if (pos - hrp.Position).Magnitude <= Config.AttackDistance then
                    table.insert(list, hrp)
                end
            end
        end
    end

    if Workspace:FindFirstChild("Enemies") then
        scan(Workspace.Enemies)
    end
    if Workspace:FindFirstChild("Characters") then
        scan(Workspace.Characters)
    end

    return list
end

function AutoAttack:StopAttackAnim(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Animation and track.Animation.AnimationId:lower():find("attack") then
            track:Stop(0)
            track:Destroy()
        end
    end
end

function AutoAttack:Attack()
    if not Config.Enabled then return end

    local char = Player.Character
    if not char or not char:FindFirstChild("Humanoid") then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.ToolTip ~= "Melee" then return end

    if tick() - self.LastAttack < Config.AttackCooldown then return end
    self.LastAttack = tick()

    local targets = self:GetTargets()
    if #targets == 0 then return end

    -- Click bắt buộc
    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)

    self:StopAttackAnim(char)

    RegisterAttack:FireServer(Config.AttackCooldown)
    for _, hrp in ipairs(targets) do
        RegisterHit:FireServer(hrp, targets)
    end
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        AutoAttack:Attack()
    end)
end)

----------------------------------------------------------------
--// GUI (NHẸ – KHÔNG RÁC)
----------------------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoAttackGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220,140)
frame.Position = UDim2.fromScale(0.05,0.4)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "AUTO ATTACK"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0,10,0,50)
toggle.Size = UDim2.new(1,-20,0,40)
toggle.Text = "FAST ATTACK : OFF"
toggle.Font = Enum.Font.Gotham
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", toggle)

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = "FAST ATTACK : " .. (Config.Enabled and "ON" or "OFF")
end)

print("✅ GUI Auto Attack Loaded")
