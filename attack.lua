--// ════════════════════════════════════════════
--//   SERVICES
--// ════════════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local Workspace  = game:GetService("Workspace")
local VIM        = game:GetService("VirtualInputManager")

local Player  = Players.LocalPlayer
local Enemies = Workspace:WaitForChild("Enemies")

--// ════════════════════════════════════════════
--//   REMOTES
--// ════════════════════════════════════════════
local Net            = require(RS.Modules.Net)
local RegisterHit    = Net:RemoteEvent("RegisterHit", true)
local RegisterAttack = RS.Modules.Net["RE/RegisterAttack"]

--// ════════════════════════════════════════════
--//   CONFIG
--// ════════════════════════════════════════════
local CFG = {
    MobRange      = 65,
    PlayerRange   = 65,
    GunRange      = 150,
    MaxTargets    = 20,
    -- ↓ KEY: số lần fire mỗi Heartbeat
    HitsPerFrame  = 20,   -- tăng = đánh nhanh hơn (melee/sword/fruit)
    AttackMobs    = true,
    AttackPlayers = true,
}

local MOB_SQ = CFG.MobRange    * CFG.MobRange
local PLR_SQ = CFG.PlayerRange * CFG.PlayerRange
local GUN_SQ = CFG.GunRange    * CFG.GunRange

--// ════════════════════════════════════════════
--//   REUSE TABLES (zero GC)
--// ════════════════════════════════════════════
local allHits      = table.create(CFG.MaxTargets)
local playerHits   = table.create(16)
local combinedHits = table.create(CFG.MaxTargets)

--// ════════════════════════════════════════════
--//   ALIVE CHECK
--// ════════════════════════════════════════════
local function alive(model)
    local h = model and model:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

--// ════════════════════════════════════════════
--//   HIT DETECTION
--// ════════════════════════════════════════════
local function GetBladeHits(pos, rangeSq)
    table.clear(allHits)
    rangeSq = rangeSq or MOB_SQ
    local ec = Enemies:GetChildren()
    for i = 1, #ec do
        if #allHits >= CFG.MaxTargets then break end
        local e = ec[i]
        if alive(e) then
            local r = e:FindFirstChild("HumanoidRootPart")
            if r then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= rangeSq then
                    allHits[#allHits+1] = {e, r}
                end
            end
        end
    end
    return allHits
end

local function GetPlayerHit(pos, rangeSq)
    table.clear(playerHits)
    rangeSq = rangeSq or PLR_SQ
    local all = Players:GetPlayers()
    for i = 1, #all do
        if #playerHits >= CFG.MaxTargets then break end
        local plr = all[i]
        if plr ~= Player and plr.Character and alive(plr.Character) then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= rangeSq then
                    playerHits[#playerHits+1] = {plr.Character, r}
                end
            end
        end
    end
    return playerHits
end

local function GetAllBladeHits(pos, mobSq, plrSq)
    table.clear(combinedHits)
    if CFG.AttackMobs then
        local m = GetBladeHits(pos, mobSq or MOB_SQ)
        for i = 1, #m do combinedHits[#combinedHits+1] = m[i] end
    end
    if CFG.AttackPlayers then
        local p = GetPlayerHit(pos, plrSq or PLR_SQ)
        for i = 1, #p do
            if #combinedHits >= CFG.MaxTargets then break end
            combinedHits[#combinedHits+1] = p[i]
        end
    end
    return combinedHits
end

--// ════════════════════════════════════════════
--//   FA CLASS
--// ════════════════════════════════════════════
local FA = {}
FA.__index = FA

function FA.new()
    local self = setmetatable({
        combo       = 0,
        comboTick   = 0,
        Connections = {},
        HitFn       = nil,
        ShootFn     = nil,
        CombatFlags = nil,
        SpecialShoot = {
            ["Skull Guitar"] = "TAP",
            ["Bazooka"]      = "Position",
            ["Cannon"]       = "Position",
            ["Dragonstorm"]  = "Overheat",
        },
        ShootsPerTarget = {["Dual Flintlock"] = 2},
    }, FA)

    pcall(function()
        self.CombatFlags = require(RS.Modules.Flags).COMBAT_REMOTE_THREAD
        self.ShootFn     = getupvalue(require(RS.Controllers.CombatController).Attack, 9)
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then self.HitFn = getsenv(ls)._G.SendHitsToServer end
    end)

    return self
end

function FA:GetCombo()
    self.combo     = self.combo + 1
    self.comboTick = tick()
    return self.combo
end

--// ─── FireHit: spawn song song mỗi target ──
function FA:FireHit(targetRoot, targetList)
    pcall(function()
        if self.HitFn then
            self.HitFn(targetRoot, targetList)
        else
            RegisterHit:FireServer(targetRoot, targetList)
        end
    end)
end

--// ════════════════════════════════════════════
--//   UseNormalClick — SIÊU NHANH
--//   Mỗi Heartbeat:
--//   • HitsPerFrame lần RegisterAttack
--//   • Mỗi lần → tất cả target đều bị hit
--//   • Dùng task.spawn để không block
--// ════════════════════════════════════════════
function FA:UseNormalClick(pos)
    local targets = GetAllBladeHits(pos)
    local n = #targets
    if n == 0 then return end

    -- Spawn song song HitsPerFrame đợt fire
    for wave = 1, CFG.HitsPerFrame do
        task.spawn(function()
            pcall(function() RegisterAttack:FireServer(0) end)
            for i = 1, n do
                self:FireHit(targets[i][2], targets)
            end
        end)
    end
end

--// ─── FruitM1 — spawn song song ─────────────
function FA:UseFruitM1(pos, tool, combo)
    local targets = GetAllBladeHits(pos)
    if #targets == 0 then return end
    local dir = (targets[1][2].Position - pos).Unit

    -- Fire nhiều lần liên tiếp như melee
    for _ = 1, CFG.HitsPerFrame do
        task.spawn(function()
            pcall(function() tool.LeftClickRemote:FireServer(dir, combo) end)
        end)
    end
end

--// ─── Gun shoot ────────────────────────────
local ShootGun  = RS.Modules.Net["RE/ShootGunEvent"]
local Validator = RS:WaitForChild("Remotes"):WaitForChild("Validator2")

function FA:ShootTarget(tool, targetPos)
    local st    = self.SpecialShoot[tool.Name] or "Normal"
    local shots = self.ShootsPerTarget[tool.Name] or 1
    for _ = 1, shots do
        task.spawn(function()
            pcall(function()
                if st == "Position" then
                    tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                    Validator:FireServer(math.floor(os.clock() * 1337) % 16777216)
                    ShootGun:FireServer(targetPos)
                elseif st == "TAP" and tool:FindFirstChild("RemoteEvent") then
                    tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                    tool.RemoteEvent:FireServer("TAP", targetPos)
                else
                    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                    VIM:SendMouseButtonEvent(0,0,0,false,game,1)
                end
            end)
        end)
    end
end

--// ════════════════════════════════════════════
--//   MAIN ATTACK
--// ════════════════════════════════════════════
function FA:Attack()
    local char = Player.Character
    if not char or not alive(char) then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not root or not tool then return end

    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Blox Fruit" and tip ~= "Sword" and tip ~= "Gun" then return end

    -- Bypass stun/busy
    pcall(function()
        local stun = char:FindFirstChild("Stun")
        local busy = char:FindFirstChild("Busy")
        if stun and stun.Value > 0  then stun.Value = 0     end
        if busy and busy.Value      then busy.Value = false  end
    end)

    local pos   = root.Position
    local combo = self:GetCombo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(pos, tool, combo)

    elseif tip == "Gun" then
        local targets = GetAllBladeHits(pos, GUN_SQ, GUN_SQ)
        for i = 1, #targets do
            self:ShootTarget(tool, targets[i][2].Position)
        end

    else
        self:UseNormalClick(pos)
    end
end

--// ════════════════════════════════════════════
--//   START
--// ════════════════════════════════════════════
local inst = FA.new()
table.insert(inst.Connections, RunService.Heartbeat:Connect(function()
    inst:Attack()
end))

return FA
