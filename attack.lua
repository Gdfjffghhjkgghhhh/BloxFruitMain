--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

--// MODULES & REMOTES
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")

--====================================================
-- CONFIG
--====================================================
local Config = {
    Bring = true,                 -- bật / tắt gom
    BringDistance = 300,
    AttackDistance = 65,
    AttackCooldown = 0.0001,
    ComboResetTime = 0.03,
    AutoClickEnabled = true
}

--====================================================
-- GLOBAL VAR
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
    local self = setmetatable({
        ComboDebounce = 0,
        M1Combo = 0,
        LockedTarget = nil
    }, FastAttack)

    pcall(function()
        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
        self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
        local LS = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LS and getsenv then
            self.HitFunction = getsenv(LS)._G.SendHitsToServer
        end
    end)

    return self
end

--====================================================
-- UTILS
--====================================================
function FastAttack:IsAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

--====================================================
-- UPDATE POSMON (VỊ TRÍ GOM)
--====================================================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        PosMon = char.HumanoidRootPart.Position
    end
end)

--====================================================
-- BRING MOB (GẮN TRONG FAST)
--====================================================
function FastAttack:BringEnemy()
    if not Config.Bring or not PosMon then return end

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 and isnetworkowner(hrp) then
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
-- LOCK 1 MOB GẦN POSMON NHẤT
--====================================================
function FastAttack:GetLockedTarget(Distance)
    if not PosMon then return nil end
    Distance = Distance or Config.AttackDistance

    local Closest, MinDist = nil, math.huge
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local d = (hrp.Position - PosMon).Magnitude
            if d <= Distance and d < MinDist then
                MinDist = d
                Closest = hrp
            end
        end
    end

    self.LockedTarget = Closest
    return Closest
end

function FastAttack:GetBladeHits()
    local Target = self:GetLockedTarget()
    if not Target then return {} end
    return { {Target.Parent, Target} }
end

function FastAttack:GetCombo()
    local combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    combo += 1
    self.M1Combo = combo
    self.ComboDebounce = tick()
    return combo
end

--====================================================
-- ATTACK
--====================================================
function FastAttack:UseNormalClick(Character)
    local Hits = self:GetBladeHits()
    if not Hits[1] then return end

    local TargetRoot = Hits[1][2]
    RegisterAttack:FireServer(Config.AttackCooldown)

    if self.CombatFlags and self.HitFunction then
        self.HitFunction(TargetRoot, Hits)
    else
        RegisterHit:FireServer(TargetRoot, Hits)
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
        local Target = self:GetLockedTarget(120)
        if Target then
            self:ShootInTarget(Target.Position)
        end
    else
        self:UseNormalClick(char)
    end
end

--====================================================
-- START LOOP
--====================================================
local AttackInstance = FastAttack.new()

RunService.Heartbeat:Connect(function()
    AttackInstance:BringEnemy()
    AttackInstance:Attack()
end)

return FastAttack
