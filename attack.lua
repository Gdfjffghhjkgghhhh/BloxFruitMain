--// Services
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

-- Safe pcall wrapper
local function safeGet(f) local ok, v = pcall(f); return ok and v or nil end

-- Config
local Config = {
    AttackDistance = 65,
    GunDistance = 120,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.018,
    ComboResetTime = 0,
    AutoClickEnabled = true,
}

--// FastAttack Class
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        Connections = {},
    }, FastAttack)

    -- Optional advanced hooks (chỉ load nếu acc có)
    self.CombatFlags = safeGet(function()
        return require(Modules:FindFirstChild("Flags") or {}) and
               require(Modules.Flags).COMBAT_REMOTE_THREAD
    end)

    self.HitFunction = safeGet(function()
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then
            return getsenv(ls)._G and getsenv(ls)._G.SendHitsToServer
        end
    end)

    -- GunValidator optional
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    self.GunValidator = remotes and remotes:FindFirstChild("Validator2")

    -- ShootFunction optional (cho GetValidator2)
    self.ShootFunction = safeGet(function()
        local cc = ReplicatedStorage.Controllers and
                   ReplicatedStorage.Controllers:FindFirstChild("CombatController")
        if cc and getupvalue then
            return getupvalue(require(cc).Attack, 9)
        end
    end)

    self.SpecialShoots = {
        ["Skull Guitar"] = "TAP",
        ["Bazooka"] = "Position",
        ["Cannon"] = "Position",
        ["Dragonstorm"] = "Overheat",
    }

    return self
end

function FastAttack:IsEntityAlive(entity)
    if not entity then return false end
    local hum = entity:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    end
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Stun and Stun.Value > 0 then return false end
    if Busy and Busy.Value then return false end
    return true
end

function FastAttack:GetBladeHits(Character, Distance)
    Distance = Distance or Config.AttackDistance
    local pos = Character:GetPivot().Position
    local hits = {}

    local function scan(folder)
        if not folder then return end
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy ~= Character and self:IsEntityAlive(enemy) then
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if root and (pos - root.Position).Magnitude <= Distance then
                    table.insert(hits, {enemy, root})
                end
            end
        end
    end

    if Config.AttackMobs then scan(Workspace:FindFirstChild("Enemies")) end
    if Config.AttackPlayers then scan(Workspace:FindFirstChild("Characters")) end

    return hits
end

function FastAttack:GetCombo()
    local now = tick()
    local combo = (now - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    combo = combo + 1
    self.ComboDebounce = now
    self.M1Combo = combo
    return combo
end

-- Validator2 — chỉ chạy nếu ShootFunction tồn tại
function FastAttack:GetValidator2()
    if not self.ShootFunction or not getupvalue or not setupvalue then return nil, nil end
    local ok, v1  = pcall(getupvalue, self.ShootFunction, 15)
    local _,  v2  = pcall(getupvalue, self.ShootFunction, 13)
    local _,  v3  = pcall(getupvalue, self.ShootFunction, 16)
    local _,  v4  = pcall(getupvalue, self.ShootFunction, 17)
    local _,  v5  = pcall(getupvalue, self.ShootFunction, 14)
    local _,  v6  = pcall(getupvalue, self.ShootFunction, 12)
    local _,  v7  = pcall(getupvalue, self.ShootFunction, 18)
    if not ok then return nil, nil end

    local v8 = v6 * v2
    local v9 = (v5 * v2 + v6 * v1) % v3
    v9 = (v9 * v3 + v8) % v4
    v5 = math.floor(v9 / v3)
    v6 = v9 - v5 * v3
    v7 = v7 + 1

    pcall(setupvalue, self.ShootFunction, 15, v1)
    pcall(setupvalue, self.ShootFunction, 13, v2)
    pcall(setupvalue, self.ShootFunction, 16, v3)
    pcall(setupvalue, self.ShootFunction, 17, v4)
    pcall(setupvalue, self.ShootFunction, 14, v5)
    pcall(setupvalue, self.ShootFunction, 12, v6)
    pcall(setupvalue, self.ShootFunction, 18, v7)

    return math.floor(v9 / v4 * 16777215), v7
end

function FastAttack:ShootInTarget(targetPos)
    local Character = Player.Character
    if not self:IsEntityAlive(Character) then return end
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end

    if (tick() - self.ShootDebounce) < 0.05 then return end
    self.ShootDebounce = tick()

    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"

    if ShootType == "TAP" then
        local re = Equipped:FindFirstChild("RemoteEvent")
        if re then
            Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
            if self.GunValidator then
                local a, b = self:GetValidator2()
                if a then self.GunValidator:FireServer(a, b) end
            end
            re:FireServer("TAP", targetPos)
        end
    elseif ShootType == "Position" then
        if self.GunValidator then
            local a, b = self:GetValidator2()
            if a then self.GunValidator:FireServer(a, b) end
        end
        ShootGunEvent:FireServer(targetPos)
    else
        -- Normal gun: dùng VirtualInput click
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.delay(0.03, function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

function FastAttack:UseNormalClick(Character, Humanoid)
    local hits = self:GetBladeHits(Character)
    if not hits[1] then return end

    RegisterAttack:FireServer(0.18)

    if self.CombatFlags and self.HitFunction then
        -- advanced path nếu acc có hook
        for _, hit in ipairs(hits) do
            pcall(self.HitFunction, hit[2], hits)
        end
    else
        -- fallback universal: FireServer mỗi target
        for _, hit in ipairs(hits) do
            RegisterHit:FireServer(hit[2], hits)
        end
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local targets = self:GetBladeHits(Character)
    if not targets[1] then return end
    local dir = (targets[1][2].Position - Character:GetPivot().Position).Unit
    local re = Equipped:FindFirstChild("LeftClickRemote")
    if re then re:FireServer(dir, Combo) end
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end

    -- Cooldown attack
    if (tick() - self.Debounce) < Config.AttackCooldown then return end
    self.Debounce = tick()

    local Combo = self:GetCombo()

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        local targets = self:GetBladeHits(Character, Config.GunDistance)
        for _, t in ipairs(targets) do
            self:ShootInTarget(t[2].Position)
        end
    else
        self:UseNormalClick(Character, Humanoid)
    end
end

-- Start
local instance = FastAttack.new()
table.insert(instance.Connections, RunService.Heartbeat:Connect(function()
    instance:Attack()
end))

return FastAttack
