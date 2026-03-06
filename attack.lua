loadstring(game:HttpGet("https://raw.githubusercontent.com/Gdfjffghhjkgghhhh/WbmxHubNew/refs/heads/main/UnBanFastAttack.lua"))()
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
    AttackDistance    = 95,
    PlayerDistance    = 60,   -- range riêng cho player
    AttackMobs        = true,
    AttackPlayers     = true,
    AutoClickEnabled  = true,
    MeleeMultiplier   = 3,
    ComboResetTime    = 0.001,
    MaxMobHits        = 10,   -- giới hạn số mob hit 1 lần
    MaxPlayerHits     = 5,    -- giới hạn số player hit 1 lần
}

-- ══════════════════════════════════════════
--           FAKE VALIDATOR
-- ══════════════════════════════════════════
local ValidatorCounter = 0
local ValidatorSeed = math.floor(os.clock() * 1337) % 16777216

local function GetFakeValidator2()
    ValidatorCounter += 1
    return (ValidatorSeed + ValidatorCounter * 1103515245) % 16777216
end

-- ══════════════════════════════════════════
--           FAST ATTACK CLASS
-- ══════════════════════════════════════════
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo       = 0,
        Connections   = {},
        SpecialShoots = {
            ["Skull Guitar"] = "TAP",
            ["Bazooka"]      = "Position",
            ["Cannon"]       = "Position",
            ["Dragonstorm"]  = "Overheat",
        }
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

-- ══════════════════════════════════════════
--           UTILITY
-- ══════════════════════════════════════════
function FastAttack:IsEntityAlive(entity)
    local h = entity and entity:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then return false end
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Stun and Stun.Value > 0 then return false end
    if Busy and Busy.Value then return false end
    return true
end

function FastAttack:GetCombo()
    local c = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    c = c + 1
    self.ComboDebounce = tick()
    self.M1Combo = c
    return c
end

-- ══════════════════════════════════════════
--   GetBladeHits() — CHỈ MOB (Enemies)
-- ══════════════════════════════════════════
function FastAttack:GetBladeHits(Character, Distance)
    local pos   = Character:GetPivot().Position
    local dist  = Distance or Config.AttackDistance
    local hits  = {}

    for _, e in ipairs(Workspace.Enemies:GetChildren()) do
        if #hits >= Config.MaxMobHits then break end
        if e ~= Character and self:IsEntityAlive(e) then
            local root = e:FindFirstChild("HumanoidRootPart")
            if root and (pos - root.Position).Magnitude <= dist then
                table.insert(hits, {e, root})
            end
        end
    end

    return hits
end

-- ══════════════════════════════════════════
--   GetPlayerHit() — CHỈ PLAYERS
-- ══════════════════════════════════════════
function FastAttack:GetPlayerHit(Character, Distance)
    local pos  = Character:GetPivot().Position
    local dist = Distance or Config.PlayerDistance
    local hits = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if #hits >= Config.MaxPlayerHits then break end
        if plr ~= Player and plr.Character then
            local char = plr.Character
            if char ~= Character and self:IsEntityAlive(char) then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and (pos - root.Position).Magnitude <= dist then
                    table.insert(hits, {char, root})
                end
            end
        end
    end

    return hits
end

-- ══════════════════════════════════════════
--   GetAllBladeHits() — MOB + PLAYERS gộp
-- ══════════════════════════════════════════
function FastAttack:GetAllBladeHits(Character, Distance)
    local pos   = Character:GetPivot().Position
    local dist  = Distance or Config.AttackDistance
    local hits  = {}

    -- Mobs
    if Config.AttackMobs then
        for _, e in ipairs(Workspace.Enemies:GetChildren()) do
            if e ~= Character and self:IsEntityAlive(e) then
                local root = e:FindFirstChild("HumanoidRootPart")
                if root and (pos - root.Position).Magnitude <= dist then
                    table.insert(hits, {e, root})
                end
            end
        end
    end

    -- Players
    if Config.AttackPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character then
                local char = plr.Character
                if char ~= Character and self:IsEntityAlive(char) then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root and (pos - root.Position).Magnitude <= dist then
                        table.insert(hits, {char, root})
                    end
                end
            end
        end
    end

    return hits
end

-- ══════════════════════════════════════════
--           SHOOT IN TARGET
-- ══════════════════════════════════════════
function FastAttack:ShootInTarget(TargetPosition)
    local char = Player.Character
    if not self:IsEntityAlive(char) then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.ToolTip ~= "Gun" then return end
    if (tick() - self.ShootDebounce) < 0.0001 then return end

    local st = self.SpecialShoots[tool.Name] or "Normal"

    if st == "Position" or (st == "TAP" and tool:FindFirstChild("RemoteEvent")) then
        tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(GetFakeValidator2())
        if st == "TAP" then
            tool.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
    else
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
        task.wait(0.0001)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
    end

    self.ShootDebounce = tick()
end

-- ══════════════════════════════════════════
--           ATTACK METHODS
-- ══════════════════════════════════════════
function FastAttack:UseNormalClick(Character)
    -- Lấy cả mob lẫn player
    local BladeHits = self:GetAllBladeHits(Character)
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
    local Targets = self:GetAllBladeHits(Character)
    if not Targets[1] then return end
    local dir = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    Equipped.LeftClickRemote:FireServer(dir, Combo)
end

-- ══════════════════════════════════════════
--           MAIN ATTACK LOOP
-- ══════════════════════════════════════════
function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local char = Player.Character
    if not char or not self:IsEntityAlive(char) then return end

    local hum  = char.Humanoid
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tip = tool.ToolTip
    if not table.find({"Melee","Blox Fruit","Sword","Gun"}, tip) then return end
    if not self:CheckStun(char, hum, tip) then return end

    local combo = self:GetCombo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(char, tool, combo)

    elseif tip == "Gun" then
        -- Bắn vào cả mob lẫn player
        local allTargets = self:GetAllBladeHits(char, 120)
        for _, tar in ipairs(allTargets) do
            self:ShootInTarget(tar[2].Position)
        end

    else
        -- Melee / Sword: đánh MeleeMultiplier lần
        for i = 1, Config.MeleeMultiplier do
            self:UseNormalClick(char)
        end
    end
end

local AttackInstance = FastAttack.new()

table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(function()
    AttackInstance:Attack()
end))
