--// ══════════════════════════════════════════════════
--//   ULTRA SPEED ATTACK — MAXIMUM THROUGHPUT
--// ══════════════════════════════════════════════════

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local Workspace  = game:GetService("Workspace")
local VIM        = game:GetService("VirtualInputManager")

local Player  = Players.LocalPlayer
local Enemies = Workspace:WaitForChild("Enemies")

--// ── REMOTES (cached 1 lần duy nhất) ──────────────
local Net            = require(RS.Modules.Net)
local RegisterHit    = Net:RemoteEvent("RegisterHit", true)
local RegisterAttack = RS.Modules.Net["RE/RegisterAttack"]
local ShootGun       = RS.Modules.Net["RE/ShootGunEvent"]
local Validator2     = RS:WaitForChild("Remotes"):WaitForChild("Validator2")

--// ── CONFIG ────────────────────────────────────────
local CFG = {
    MobRange    = 65,
    PlayerRange = 65,
    GunRange    = 150,
    MaxTargets  = 30,
    -- Số coroutine song song bắn mỗi frame
    -- Heartbeat ~60fps × Threads = tổng fire/giây
    Threads     = 8,
}

-- Pre-square ranges
local MOB_SQ = CFG.MobRange    ^ 2
local PLR_SQ = CFG.PlayerRange ^ 2
local GUN_SQ = CFG.GunRange    ^ 2

--// ── REUSE TABLES (zero alloc) ────────────────────
local mobBuf  = table.create(CFG.MaxTargets)
local plrBuf  = table.create(16)
local allBuf  = table.create(CFG.MaxTargets)

--// ── COROUTINE POOL (reuse, không tạo mới) ────────
local pool = {}
for i = 1, 64 do
    pool[i] = coroutine.create(function(fn, ...)
        while true do
            fn(...)
            fn, ... = coroutine.yield()
        end
    end)
end
local poolIdx = 0

local function poolSpawn(fn, ...)
    poolIdx = (poolIdx % #pool) + 1
    local co = pool[poolIdx]
    if coroutine.status(co) == "suspended" then
        coroutine.resume(co, fn, ...)
    else
        -- fallback nếu co đang chạy
        task.spawn(fn, ...)
    end
end

--// ── ALIVE (inline, no method call overhead) ──────
local find = game.FindFirstChildOfClass
local function alive(m)
    local h = find(m, m, "Humanoid")
    return h and h.Health > 0
end

--// ── HIT DETECTION ────────────────────────────────
local function GetMobHits(pos)
    table.clear(mobBuf)
    local ec = Enemies:GetChildren()
    local n  = #ec
    for i = 1, n do
        if #mobBuf >= CFG.MaxTargets then break end
        local e = ec[i]
        local h = e:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then
            local r = e:FindFirstChild("HumanoidRootPart")
            if r then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= MOB_SQ then
                    mobBuf[#mobBuf+1] = {e, r}
                end
            end
        end
    end
    return mobBuf
end

local function GetPlrHits(pos)
    table.clear(plrBuf)
    local all = Players:GetPlayers()
    local n   = #all
    for i = 1, n do
        if #plrBuf >= CFG.MaxTargets then break end
        local p = all[i]
        if p ~= Player then
            local c = p.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r then
                        local d = r.Position - pos
                        if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= PLR_SQ then
                            plrBuf[#plrBuf+1] = {c, r}
                        end
                    end
                end
            end
        end
    end
    return plrBuf
end

local function GetAll(pos)
    table.clear(allBuf)
    local m = GetMobHits(pos)
    local p = GetPlrHits(pos)
    for i = 1, #m do allBuf[#allBuf+1] = m[i] end
    for i = 1, #p do
        if #allBuf >= CFG.MaxTargets then break end
        allBuf[#allBuf+1] = p[i]
    end
    return allBuf
end

--// ── FA CLASS ──────────────────────────────────────
local FA = {}
FA.__index = FA

function FA.new()
    local self = setmetatable({
        combo   = 0,
        HitFn   = nil,
        SpecialShoot = {
            ["Skull Guitar"] = "TAP",
            ["Bazooka"]      = "Position",
            ["Cannon"]       = "Position",
            ["Dragonstorm"]  = "Overheat",
        },
        MultiShoot = {["Dual Flintlock"] = 2},
    }, FA)

    pcall(function()
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then
            self.HitFn = getsenv(ls)._G.SendHitsToServer
        end
    end)
    return self
end

--// ── FIRE HIT (hot path, pcall wrap mỏng) ─────────
function FA:FH(root, list)
    if self.HitFn then
        self.HitFn(root, list)
    else
        RegisterHit:FireServer(root, list)
    end
end

--// ── WAVE: 1 đợt RegisterAttack + tất cả hits ─────
function FA:Wave(targets, n)
    RegisterAttack:FireServer(0)
    for i = 1, n do
        pcall(self.FH, self, targets[i][2], targets)
    end
end

--// ════════════════════════════════════════════
--//   NORMAL / SWORD — ULTRA FIRE
--//   Threads coroutine song song, mỗi cái 1 wave
--// ════════════════════════════════════════════
function FA:UseNormalClick(pos)
    local targets = GetAll(pos)
    local n = #targets
    if n == 0 then return end

    -- Spawn Threads wave song song qua coroutine pool
    for t = 1, CFG.Threads do
        poolSpawn(function()
            pcall(function()
                self:Wave(targets, n)
            end)
        end)
    end
end

--// ── FRUIT M1 — fire Threads lần ──────────────────
function FA:UseFruitM1(pos, tool, combo)
    local targets = GetAll(pos)
    if #targets == 0 then return end
    local dir = (targets[1][2].Position - pos).Unit

    for t = 1, CFG.Threads do
        poolSpawn(function()
            pcall(function()
                tool.LeftClickRemote:FireServer(dir, combo)
            end)
        end)
    end
end

--// ── GUN ──────────────────────────────────────────
function FA:ShootTarget(tool, targetPos)
    local st    = self.SpecialShoot[tool.Name] or "Normal"
    local shots = self.MultiShoot[tool.Name] or 1

    for _ = 1, shots do
        poolSpawn(function()
            pcall(function()
                if st == "Position" then
                    tool:SetAttribute("LocalTotalShots",
                        (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                    Validator2:FireServer(math.floor(os.clock() * 1337) % 16777216)
                    ShootGun:FireServer(targetPos)
                elseif st == "TAP" then
                    local re = tool:FindFirstChild("RemoteEvent")
                    if re then
                        tool:SetAttribute("LocalTotalShots",
                            (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                        re:FireServer("TAP", targetPos)
                    end
                else
                    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                    VIM:SendMouseButtonEvent(0,0,0,false,game,1)
                end
            end)
        end)
    end
end

--// ── BYPASS STUN (pre-cached refs) ────────────────
local stunNames = {"Stun","Busy","NoAttack","Attacking"}
function FA:BypassStun(char)
    for i = 1, #stunNames do
        local obj = char:FindFirstChild(stunNames[i])
        if obj then
            local v = obj.Value
            if type(v) == "number" then
                if v ~= 0 then obj.Value = 0 end
            elseif v then
                obj.Value = false
            end
        end
    end
end

--// ── MAIN ATTACK ───────────────────────────────────
function FA:Attack()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not root or not tool then return end

    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Blox Fruit"
       and tip ~= "Sword" and tip ~= "Gun" then return end

    self:BypassStun(char)

    local pos   = root.Position
    self.combo  = (self.combo % 100) + 1

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(pos, tool, self.combo)
    elseif tip == "Gun" then
        local targets = GetAll(pos)
        for i = 1, #targets do
            self:ShootTarget(tool, targets[i][2].Position)
        end
    else
        self:UseNormalClick(pos)
    end
end


local inst = FA.new()

-- Connection 1
RunService.Heartbeat:Connect(function()
    pcall(function() inst:Attack() end)
end)

-- Connection 2 — song song với connection 1
RunService.Heartbeat:Connect(function()
    pcall(function() inst:Attack() end)
end)

print("⚡ ULTRA SPEED ATTACK LOADED")
return FA
