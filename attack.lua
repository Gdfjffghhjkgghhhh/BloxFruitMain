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
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

--// CONFIG
local Config = {
    AttackDistance = 65,
    AttackCooldown = 0.0001,
    ComboResetTime = 0.03,
    AutoClickEnabled = true
}

--// FAST ATTACK CLASS
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
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

--// UTILS
function FastAttack:IsAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

--// LOCK MOB GẦN POSMON NHẤT
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

--// CHỈ TRẢ VỀ 1 TARGET
function FastAttack:GetBladeHits(Character, Distance)
    local Target = self:GetLockedTarget(Distance)
    if not Target then return {} end
    return {
        {Target.Parent, Target}
    }
end

function FastAttack:GetCombo()
    local combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    combo += 1
    self.M1Combo = combo
    self.ComboDebounce = tick()
    return combo
end

--// GUN SHOOT
function FastAttack:ShootInTarget(pos)
    if tick() - (self.LastShoot or 0) < 0.0001 then return end
    ShootGunEvent:FireServer(pos)
    self.LastShoot = tick()
end

--// NORMAL ATTACK (MELEE / SWORD)
function FastAttack:UseNormalClick(Character)
    local Hits = self:GetBladeHits(Character)
    if not Hits[1] then return end

    local TargetRoot = Hits[1][2]
    RegisterAttack:FireServer(Config.AttackCooldown)

    if self.CombatFlags and self.HitFunction then
        self.HitFunction(TargetRoot, Hits)
    else
        RegisterHit:FireServer(TargetRoot, Hits)
    end
end

--// MAIN ATTACK LOOP
function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local Char = Player.Character
    if not Char or not self:IsAlive(Char) then return end

    local Tool = Char:FindFirstChildOfClass("Tool")
    if not Tool then return end

    local Tip = Tool.ToolTip
    if not table.find({"Melee","Sword","Gun","Blox Fruit"}, Tip) then return end

    self:GetCombo()

    if Tip == "Gun" then
        local Target = self:GetLockedTarget(120)
        if Target then
            self:ShootInTarget(Target.Position)
        end
    else
        self:UseNormalClick(Char)
    end
end

--// START
local AttackInstance = FastAttack.new()
RunService.Heartbeat:Connect(function()
    AttackInstance:Attack()
end)

return FastAttack
