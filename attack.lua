local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local Workspace  = game:GetService("Workspace")
local VIM        = game:GetService("VirtualInputManager")

local Player  = Players.LocalPlayer
local Enemies = Workspace:WaitForChild("Enemies")

--// ── REMOTES ───────────────────────────────────────
local Net            = require(RS.Modules.Net)
local RegisterHit    = Net:RemoteEvent("RegisterHit", true)
local RegisterAttack = RS.Modules.Net["RE/RegisterAttack"]
local ShootGun       = RS.Modules.Net["RE/ShootGunEvent"]
local Validator2     = RS:WaitForChild("Remotes"):WaitForChild("Validator2")

--// ── CONFIG ────────────────────────────────────────
local CFG = {
    MobRange      = 65,
    PlayerRange   = 65,
    GunRange      = 150,
    MaxTargets    = 20,
    Threads       = 16,
    Cooldown      = 0.01,
}

local MOB_SQ = CFG.MobRange    ^ 2
local PLR_SQ = CFG.PlayerRange ^ 2
local GUN_SQ = CFG.GunRange    ^ 2

--// ── COROUTINE POOL ────────────────────────────────
local POOL_SIZE = 32
local pool      = table.create(POOL_SIZE)
local pidx      = 0

for i = 1, POOL_SIZE do
    -- FIX: khởi động đúng, yield ngay sau resume đầu tiên
    local co = coroutine.create(function(fn, a, b)
        while true do
            fn(a, b)
            fn, a, b = coroutine.yield()
        end
    end)
    pool[i] = co
end

local function go(fn, a, b)
    pidx = pidx % POOL_SIZE + 1
    local co = pool[pidx]
    local st = coroutine.status(co)
    if st == "suspended" then
        coroutine.resume(co, fn, a, b)
    else
        -- coroutine chưa chạy lần nào hoặc đang bận → task.spawn fallback
        task.spawn(fn, a, b)
    end
end

--// ── BUFFERS ───────────────────────────────────────
local allBuf = table.create(CFG.MaxTargets)

--// ── ALIVE FIX: dùng đúng : thay vì . ───────────
local function alive(m)
    if not m then return false end
    local h = m:FindFirstChildOfClass("Humanoid")  -- FIX: : không phải .
    return h ~= nil and h.Health > 0
end

--// ── HIT DETECTION ────────────────────────────────
local function GetAll(pos)
    table.clear(allBuf)

    -- Mobs
    local ec = Enemies:GetChildren()
    for i = 1, #ec do
        if #allBuf >= CFG.MaxTargets then break end
        local e = ec[i]
        -- FIX: kiểm tra trực tiếp, không qua alive() wrapper để tránh nil
        local hum = e:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local r = e:FindFirstChild("HumanoidRootPart")
            if r then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= MOB_SQ then
                    allBuf[#allBuf+1] = {e, r}
                end
            end
        end
    end

    -- Players
    local all = Players:GetPlayers()
    for i = 1, #all do
        if #allBuf >= CFG.MaxTargets then break end
        local p = all[i]
        if p ~= Player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = r.Position - pos
                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= PLR_SQ then
                        allBuf[#allBuf+1] = {p.Character, r}
                    end
                end
            end
        end
    end

    return allBuf
end

--// ── FA CLASS ──────────────────────────────────────
local FA = {}
FA.__index = FA

function FA.new()
    local self = setmetatable({
        combo    = 0,
        lastFire = 0,
        HitFn    = nil,
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

--// ── WAVE ─────────────────────────────────────────
function FA:Wave(targets, n)
    RegisterAttack:FireServer(0)
    local hitFn = self.HitFn
    for i = 1, n do
        local root = targets[i][2]
        pcall(function()
            if hitFn then
                hitFn(root, targets)
            else
                RegisterHit:FireServer(root, targets)
            end
        end)
    end
end

--// ── NORMAL / SWORD ────────────────────────────────
function FA:UseNormalClick(pos)
    local targets = GetAll(pos)
    local n = #targets
    if n == 0 then return end

    for _ = 1, CFG.Threads do
        go(function()
            pcall(function() self:Wave(targets, n) end)
        end)
    end
end

--// ── FRUIT M1 ──────────────────────────────────────
function FA:UseFruitM1(pos, tool, combo)
    local targets = GetAll(pos)
    if #targets == 0 then return end
    local dir  = (targets[1][2].Position - pos).Unit
    local lclr = tool.LeftClickRemote
    for _ = 1, CFG.Threads do
        go(function()
            pcall(function() lclr:FireServer(dir, combo) end)
        end)
    end
end

--// ── GUN ──────────────────────────────────────────
function FA:ShootTarget(tool, targetPos)
    local st    = self.SpecialShoot[tool.Name] or "Normal"
    local shots = self.MultiShoot[tool.Name] or 1
    for _ = 1, shots do
        go(function()
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

--// ── BYPASS STUN ───────────────────────────────────
local STUNS = {"Stun","Busy","NoAttack","Attacking"}
function FA:BypassStun(char)
    for i = 1, #STUNS do
        local obj = char:FindFirstChild(STUNS[i])
        if obj then
            local v = obj.Value
            if type(v) == "number" and v ~= 0 then
                obj.Value = 0
            elseif type(v) == "boolean" and v then
                obj.Value = false
            end
        end
    end
end

--// ── MAIN ATTACK ───────────────────────────────────
function FA:Attack()
    -- Throttle chống lag
    local now = tick()
    if now - self.lastFire < CFG.Cooldown then return end
    self.lastFire = now

    local char = Player.Character
    if not char then return end

    -- FIX: kiểm tra humanoid trực tiếp, không qua alive()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not root or not tool then return end

    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Blox Fruit"
    and tip ~= "Sword" and tip ~= "Gun" then return end

    self:BypassStun(char)

    local pos = root.Position
    self.combo = (self.combo % 100) + 1

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

--// ── START ─────────────────────────────────────────
local inst = FA.new()

RunService.Heartbeat:Connect(function()
    pcall(function() inst:Attack() end)
end)

return FA
