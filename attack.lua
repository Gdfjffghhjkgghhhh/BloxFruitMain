
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local RS                  = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")
local VIM                 = game:GetService("VirtualInputManager")

local Player              = Players.LocalPlayer
local Modules             = RS:WaitForChild("Modules")
local Net                 = Modules:WaitForChild("Net")
local RegisterAttack      = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit         = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent       = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator        = RS:WaitForChild("Remotes"):WaitForChild("Validator2")
local Enemies             = Workspace.Enemies
local CharFolder          = Workspace:FindFirstChild("Characters") or Workspace

--// ════════════════════════════════════════════
--//              CONFIG
--// ════════════════════════════════════════════
local CFG = {
    MobRange      = 65,
    PlayerRange   = 65,
    GunRange      = 150,
    MaxTargets    = 20,   -- tăng tối đa target 1 frame
    HitsPerFrame  = 3,    -- số lần fire hit mỗi target / frame
    AttackMobs    = true,
    AttackPlayers = true,
}
-- Pre-compute range² — tránh sqrt mọi lúc
local MOB_SQ = CFG.MobRange    * CFG.MobRange
local PLR_SQ = CFG.PlayerRange * CFG.PlayerRange
local GUN_SQ = CFG.GunRange    * CFG.GunRange

--// ════════════════════════════════════════════
--//         REUSABLE TABLES (no GC)
--// ════════════════════════════════════════════
local hits       = table.create(CFG.MaxTargets)
local mobList    = table.create(64)
local plrList    = table.create(32)

--// ════════════════════════════════════════════
--//         FAST ATTACK CLASS
--// ════════════════════════════════════════════
local FA   = {}
FA.__index = FA

--// ─── Constructor ───────────────────────────
function FA.new()
    local self = setmetatable({
        combo        = 0,
        comboTick    = 0,
        shootTick    = 0,
        enemyRoot    = nil,
        Connections  = {},
        SpecialShoot = {
            ["Skull Guitar"] = "TAP",
            ["Bazooka"]      = "Position",
            ["Cannon"]       = "Position",
            ["Dragonstorm"]  = "Overheat",
        },
        ShootsPerTarget = { ["Dual Flintlock"] = 2 },
        -- upvalue cache
        ShootFn      = nil,
        HitFn        = nil,
        CombatFlags  = nil,
    }, FA)

    pcall(function()
        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
        self.ShootFn     = getupvalue(require(RS.Controllers.CombatController).Attack, 9)
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then self.HitFn = getsenv(ls)._G.SendHitsToServer end
    end)

    return self
end

--// ─── Alive check (inlined, no pcall) ────────
local function alive(e)
    local h = rawget(e, "Humanoid") or e:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

--// ─── Validator (real upvalue method) ────────
function FA:Validator2()
    if not self.ShootFn then
        -- fallback hash khi không có upvalue
        local seed = math.floor(os.clock() * 1337) % 16777216
        return seed, 1
    end
    local v1=getupvalue(self.ShootFn,15) local v2=getupvalue(self.ShootFn,13)
    local v3=getupvalue(self.ShootFn,16) local v4=getupvalue(self.ShootFn,17)
    local v5=getupvalue(self.ShootFn,14) local v6=getupvalue(self.ShootFn,12)
    local v7=getupvalue(self.ShootFn,18)
    local v8  = v6*v2
    local v9  = (v5*v2 + v6*v1) % v3
    v9 = (v9*v3 + v8) % v4
    v5 = math.floor(v9/v3)
    v6 = v9 - v5*v3
    v7 = v7+1
    setupvalue(self.ShootFn,15,v1) setupvalue(self.ShootFn,13,v2)
    setupvalue(self.ShootFn,16,v3) setupvalue(self.ShootFn,17,v4)
    setupvalue(self.ShootFn,14,v5) setupvalue(self.ShootFn,12,v6)
    setupvalue(self.ShootFn,18,v7)
    return math.floor(v9/v4*16777215), v7
end

--// ─── Combo (no reset limit) ──────────────────
function FA:Combo()
    self.combo     = self.combo + 1
    self.comboTick = tick()
    return self.combo
end

--// ════════════════════════════════════════════
--//   GetBladeHits  — CHỈ MOB
--// ════════════════════════════════════════════
function FA:GetBladeHits(pos, rangeSq)
    table.clear(hits)
    rangeSq = rangeSq or MOB_SQ
    local enemyChildren = Enemies:GetChildren()

    for i = 1, #enemyChildren do
        if #hits >= CFG.MaxTargets then break end
        local e = enemyChildren[i]
        local r = e:FindFirstChild("HumanoidRootPart")
        if r and alive(e) then
            local d = r.Position - pos
            if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= rangeSq then
                hits[#hits+1] = {e, r}
            end
        end
    end

    return hits
end

--// ════════════════════════════════════════════
--//   GetPlayerHit  — CHỈ PLAYER
--// ════════════════════════════════════════════
function FA:GetPlayerHit(pos, rangeSq)
    table.clear(plrList)
    rangeSq = rangeSq or PLR_SQ
    local all = Players:GetPlayers()

    for i = 1, #all do
        if #plrList >= CFG.MaxTargets then break end
        local p = all[i]
        if p ~= Player and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r and alive(p.Character) then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= rangeSq then
                    plrList[#plrList+1] = {p.Character, r}
                end
            end
        end
    end

    return plrList
end

--// ════════════════════════════════════════════
--//   GetAllBladeHits  — MOB + PLAYER gộp
--// ════════════════════════════════════════════
function FA:GetAllBladeHits(pos, mobSq, plrSq)
    table.clear(mobList)
    mobSq = mobSq or MOB_SQ
    plrSq = plrSq or PLR_SQ

    -- Mobs
    if CFG.AttackMobs then
        local ec = Enemies:GetChildren()
        for i = 1, #ec do
            if #mobList >= CFG.MaxTargets then break end
            local e = ec[i]
            local r = e:FindFirstChild("HumanoidRootPart")
            if r and alive(e) then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= mobSq then
                    mobList[#mobList+1] = {e, r}
                end
            end
        end
    end

    -- Players
    if CFG.AttackPlayers then
        local all = Players:GetPlayers()
        for i = 1, #all do
            if #mobList >= CFG.MaxTargets then break end
            local p = all[i]
            if p ~= Player and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r and alive(p.Character) then
                    local d = r.Position - pos
                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= plrSq then
                        mobList[#mobList+1] = {p.Character, r}
                    end
                end
            end
        end
    end

    return mobList
end

--// ════════════════════════════════════════════
--//   UseNormalClick — fire N lần / target
--// ════════════════════════════════════════════
function FA:UseNormalClick(pos)
    local allHits = self:GetAllBladeHits(pos)
    if #allHits == 0 then return end

    for rep = 1, CFG.HitsPerFrame do   -- fire nhiều lần liên tiếp
        RegisterAttack:FireServer(0)
        for i = 1, #allHits do
            local root = allHits[i][2]
            pcall(function()
                if self.HitFn then
                    self.HitFn(root, allHits)
                else
                    RegisterHit:FireServer(root, allHits)
                end
            end)
        end
    end
end

--// ════════════════════════════════════════════
--//   FruitM1 — nhắm vào gần nhất
--// ════════════════════════════════════════════
function FA:UseFruitM1(charPos, tool, combo)
    local targets = self:GetAllBladeHits(charPos)
    if #targets == 0 then return end
    local dir = (targets[1][2].Position - charPos).Unit
    pcall(function() tool.LeftClickRemote:FireServer(dir, combo) end)
end

--// ════════════════════════════════════════════
--//   ShootInTarget — gun không delay
--// ════════════════════════════════════════════
function FA:ShootInTarget(pos, targetPos)
    local char = Player.Character
    if not alive(char) then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.ToolTip ~= "Gun" then return end

    local st = self.SpecialShoot[tool.Name] or "Normal"
    local shots = self.ShootsPerTarget[tool.Name] or 1

    for _ = 1, shots do
        pcall(function()
            if st == "Position" then
                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                GunValidator:FireServer(self:Validator2())
                ShootGunEvent:FireServer(targetPos)

            elseif st == "TAP" and tool:FindFirstChild("RemoteEvent") then
                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                GunValidator:FireServer(self:Validator2())
                tool.RemoteEvent:FireServer("TAP", targetPos)

            else
                -- Normal gun: virtual click
                VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                VIM:SendMouseButtonEvent(0,0,0,false,game,1)
            end
        end)
    end

    self.shootTick = tick()
end

--// ════════════════════════════════════════════
--//   MAIN ATTACK (called every Heartbeat)
--// ════════════════════════════════════════════
function FA:Attack()
    local char = Player.Character
    if not char then return end
    if not alive(char) then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not root or not tool then return end

    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Blox Fruit" and tip ~= "Sword" and tip ~= "Gun" then return end

    -- Bypass stun/busy mỗi frame
    pcall(function()
        local stun = char:FindFirstChild("Stun")
        local busy = char:FindFirstChild("Busy")
        if stun then stun.Value = 0 end
        if busy then busy.Value = false end
    end)

    local pos   = root.Position
    local combo = self:Combo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(pos, tool, combo)

    elseif tip == "Gun" then
        local targets = self:GetAllBladeHits(pos, GUN_SQ, GUN_SQ)
        for i = 1, #targets do
            self:ShootInTarget(pos, targets[i][2].Position)
        end

    else
        -- Melee / Sword: fire HitsPerFrame lần
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
