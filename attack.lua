
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

local Config = {
    AttackDistance = 95,
    AttackMobs = true,
    AttackPlayers = true,
    AutoClickEnabled = true,      
    MeleeMultiplier = 4,         
    ComboResetTime = 0.001
}

-- FAKE VALIDATOR
local ValidatorCounter = 0
local ValidatorSeed = math.floor(tick() * 1337) % 16777215
local function GetFakeValidator2()
    ValidatorCounter = ValidatorCounter + 1
    local hash = math.floor((ValidatorSeed + ValidatorCounter * 0xDEADBEEF) % 16777215)
    return hash, ValidatorCounter
end

local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        Connections = {},
        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
    }, FastAttack)

    pcall(function()
        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
        local CombatController = require(ReplicatedStorage.Controllers.CombatController)
        self.ShootFunction = getupvalue(CombatController.Attack, 9)
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then
            self.HitFunction = getsenv(ls)._G.SendHitsToServer
        end
    end)
    return self
end

function FastAttack:IsEntityAlive(entity)
    local h = entity and entity:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then return false end
    if Stun and Stun.Value > 0 or Busy and Busy.Value then return false end
    return true
end

function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    Distance = Distance or Config.AttackDistance
    local function Process(Folder)
        for _, e in ipairs(Folder:GetChildren()) do
            if e ~= Character and self:IsEntityAlive(e) then
                local root = e:FindFirstChild("HumanoidRootPart")
                if root and (Position - root.Position).Magnitude <= Distance then
                    table.insert(BladeHits, {e, root})
                end
            end
        end
    end
    if Config.AttackMobs then Process(Workspace.Enemies) end
    if Config.AttackPlayers then Process(Workspace.Characters) end
    return BladeHits
end

function FastAttack:GetCombo()
    local c = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    c = c + 1
    self.ComboDebounce = tick()
    self.M1Combo = c
    return c
end

function FastAttack:ShootInTarget(TargetPosition)
    local char = Player.Character
    if not self:IsEntityAlive(char) then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.ToolTip ~= "Gun" then return end

    local cd = 0.0001
    if (tick() - self.ShootDebounce) < cd then return end

    local st = self.SpecialShoots[tool.Name] or "Normal"
    if st == "Position" or (st == "TAP" and tool:FindFirstChild("RemoteEvent")) then
        tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(GetFakeValidator2())
        if st == "TAP" then
            tool.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
        self.ShootDebounce = tick()
    else
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
        task.wait(0.0001)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
        self.ShootDebounce = tick()
    end
end

function FastAttack:UseNormalClick(Character)
    local BladeHits = self:GetBladeHits(Character)
    if #BladeHits == 0 then return end

    pcall(function() RegisterAttack:FireServer(0.0001) end)

    for _, Hit in ipairs(BladeHits) do
        pcall(function()
            if self.CombatFlags and self.HitFunction then
                self.HitFunction(Hit[2], BladeHits)
            else
                RegisterHit:FireServer(Hit[2], BladeHits)
            end
        end)
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    if not Targets[1] then return end
    local dir = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    Equipped.LeftClickRemote:FireServer(dir, Combo)
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local char = Player.Character
    if not char or not self:IsEntityAlive(char) then return end

    local hum = char.Humanoid
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tip = tool.ToolTip
    if not table.find({"Melee","Blox Fruit","Sword","Gun"}, tip) then return end
    if not self:CheckStun(char, hum, tip) then return end

    local combo = self:GetCombo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(char, tool, combo)
    elseif tip == "Gun" then
        local t = self:GetBladeHits(char, 120)
        for _, tar in ipairs(t) do
            self:ShootInTarget(tar[2].Position)
        end
    else
        for i = 1, Config.MeleeMultiplier do
            self:UseNormalClick(char)
        end
    end
end

local AttackInstance = FastAttack.new()

table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(function()
    AttackInstance:Attack()
end))

print("✅ FAST ATTACK NO GUI LOADED - Melee đang đánh (" .. Config.MeleeMultiplier .. "x)")
print("   Để tắt: đổi AutoClickEnabled = false trong Config")
