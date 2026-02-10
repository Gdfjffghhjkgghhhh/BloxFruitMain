--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--====================================================
-- REMOTES
--====================================================
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")

--====================================================
-- CONFIG
--====================================================
local Config = {
    Bring = true,
    BringDistance = 350,
    AttackDistance = 70,
    AttackCooldown = 0.0001,
    ComboResetTime = 0.03,
    AutoClickEnabled = true,
    MaxTargets = 15 -- giới hạn số mob đánh (chống kick)
}

--====================================================
-- GLOBAL
--====================================================
local PosMon = nil

pcall(function()
    sethiddenproperty(Player, "SimulationRadius", math.huge)
end)

--====================================================
-- FAST ATTACK CLASS
--====================================================
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    return setmetatable({
        ComboDebounce = 0,
        M1Combo = 0
    }, FastAttack)
end

--====================================================
-- UTILS
--====================================================
function FastAttack:IsAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

--====================================================
-- UPDATE POSMON
--====================================================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        PosMon = char.HumanoidRootPart.Position
    end
end)

--====================================================
-- BRING MOB (AOE)
--====================================================
function FastAttack:BringEnemy()
    if not Config.Bring or not PosMon then return end

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then
            if (hrp.Position - PosMon).Magnitude <= Config.BringDistance then

                for _, part in ipairs(mob:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = true
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                    end
                end

                hum.WalkSpeed = 0
                hum.JumpPower = 0
                hum.PlatformStand = true

                hrp.CFrame = hrp.CFrame:Lerp(
                    CFrame.new(PosMon + Vector3.new(0,2,0)),
                    0.35
                )
            end
        end
    end
end

--====================================================
-- GET ALL MOBS IN RANGE (AOE)
--====================================================
function FastAttack:GetBladeHits(Character, Distance)
    local Hits = {}
    Distance = Distance or Config.AttackDistance
    local Pos = Character:GetPivot().Position

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if #Hits >= Config.MaxTargets then break end

        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then
            if (hrp.Position - Pos).Magnitude <= Distance then
                table.insert(Hits, {mob, hrp})
            end
        end
    end

    return Hits
end

function FastAttack:GetCombo()
    local combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    combo += 1
    self.M1Combo = combo
    self.ComboDebounce = tick()
    return combo
end

--====================================================
-- ATTACK AOE
--====================================================
function FastAttack:UseNormalClick(Character)
    local Hits = self:GetBladeHits(Character)
    if #Hits == 0 then return end

    RegisterAttack:FireServer(Config.AttackCooldown)

    for _, hit in ipairs(Hits) do
        RegisterHit:FireServer(hit[2], Hits)
    end
end

function FastAttack:ShootInTarget(pos)
    if tick() - (self.LastShoot or 0) < 0.0001 then return end
    ShootGunEvent:FireServer(pos)
    self.LastShoot = tick()
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local char = Player.Character
    if not char or not self:IsAlive(char) then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tip = tool.ToolTip
    if not table.find({"Melee","Sword","Gun","Blox Fruit"}, tip) then return end

    self:GetCombo()

    if tip == "Gun" then
        local Targets = self:GetBladeHits(char, 120)
        for _, t in ipairs(Targets) do
            self:ShootInTarget(t[2].Position)
        end
    else
        self:UseNormalClick(char)
    end
end

--====================================================
-- START
--====================================================
local AttackInstance = FastAttack.new()

RunService.Heartbeat:Connect(function()
    AttackInstance:BringEnemy()
    AttackInstance:Attack()
end)

return FastAttack
