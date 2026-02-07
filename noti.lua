--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--// REMOTES
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

--// CONFIG
local Config = {
    AutoClick = true,
    AttackDistance = 80,
    AttackCooldown = 0.05, -- rất nhanh
    FakeDamageCount = 4,  -- số dame mỗi hit
}

--// DAME ẢO UI
local function ShowDamage(pos, dmg)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.Position = pos
    part.Parent = Workspace

    local gui = Instance.new("BillboardGui", part)
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.AlwaysOnTop = true

    local txt = Instance.new("TextLabel", gui)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = "-" .. dmg
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBlack
    txt.TextStrokeTransparency = 0
    txt.TextColor3 = Color3.fromRGB(255, 80, 80)

    task.spawn(function()
        for i = 1, 20 do
            part.Position += Vector3.new(0, 0.08, 0)
            txt.TextTransparency += 0.05
            txt.TextStrokeTransparency += 0.05
            task.wait(0.02)
        end
        part:Destroy()
    end)
end

--// FAST ATTACK CLASS
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    return setmetatable({
        Debounce = 0
    }, FastAttack)
end

function FastAttack:GetTargets()
    local char = Player.Character
    if not char then return {} end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end

    local targets = {}

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            if (root.Position - hrp.Position).Magnitude <= Config.AttackDistance then
                table.insert(targets, hrp)
            end
        end
    end

    return targets
end

function FastAttack:Attack()
    if not Config.AutoClick then return end
    local char = Player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    if tick() - self.Debounce < Config.AttackCooldown then return end
    self.Debounce = tick()

    local targets = self:GetTargets()
    if not targets[1] then return end

    -- GỬI HIT THẬT (server)
    pcall(function()
        RegisterAttack:FireServer(Config.AttackCooldown)
        RegisterHit:FireServer(targets[1], {{targets[1]}})
    end)

    -- SPAM DAME ẢO (client)
    for i = 1, Config.FakeDamageCount do
        task.spawn(function()
            ShowDamage(
                targets[1].Position + Vector3.new(
                    math.random(-2,2),
                    math.random(1,3),
                    math.random(-2,2)
                ),
                math.random(5000, 12000)
            )
        end)
    end
end

--// START (RenderStepped = spam theo FPS)
local AttackInstance = FastAttack.new()
RunService.RenderStepped:Connect(function()
    AttackInstance:Attack()
end)

--// TOGGLE
game:GetService("UserInputService").InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightControl then
        Config.AutoClick = not Config.AutoClick
        warn("AutoClick:", Config.AutoClick)
    end
end)
