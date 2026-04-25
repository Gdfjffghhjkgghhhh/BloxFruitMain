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

local CombatUtil = nil
pcall(function() CombatUtil = require(Modules.CombatUtil) end)
local FX = nil
pcall(function() FX = require(Modules.FX) end)

local Config = {
    AttackDistance  = 65,
    AttackMobs      = true,
    AttackPlayers   = true,
    ComboResetTime  = 0,
    MaxCombo        = math.huge,
    AutoClickEnabled = true,
    HitRepeat       = 3, -- fire hit N lần mỗi frame
}

local function bypassCooldowns()
    local realTick = tick
    getgenv().tick = function() return realTick() + 9999 end

    pcall(function()
        local CC = require(ReplicatedStorage.Controllers.CombatController)
        for i = 1, 50 do
            local ok, _, val = pcall(getupvalue, CC.Attack, i)
            if ok and type(val) == "number" and val > 0 and val < 2 then
                pcall(setupvalue, CC.Attack, i, 0)
            end
        end
    end)

    pcall(function() setthreadidentity(8) end)

    pcall(function()
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(999)
                end
            end
        end
        local animate = char:FindFirstChild("Animate")
        if animate and getsenv then
            local env = getsenv(animate)
            if env and env.setAnimationSpeed then
                env.setAnimationSpeed(999)
            end
        end
    end)
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    bypassCooldowns()
end)
bypassCooldowns()

local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo       = 0,
        EnemyRootPart = nil,
        Connections   = {},
        HitFn         = nil,
        CombatFlags   = nil,
        ShootFunction = nil,
        Overheat      = {Dragonstorm = {MaxOverheat=3,Cooldown=0,TotalOverheat=0,Distance=350,Shooting=false}},
        ShootsPerTarget = {["Dual Flintlock"]=2},
        SpecialShoots = {["Skull Guitar"]="TAP",["Bazooka"]="Position",["Cannon"]="Position",["Dragonstorm"]="Overheat"},
    }, FastAttack)

    pcall(function()
        self.CombatFlags  = require(Modules.Flags).COMBAT_REMOTE_THREAD
        self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then self.HitFn = getsenv(ls)._G.SendHitsToServer end
    end)

    pcall(function()
        if self.ShootFunction then
            for i = 1, 30 do
                local ok, _, val = pcall(getupvalue, self.ShootFunction, i)
                if ok and type(val) == "number" and val > 0 and val < 2 then
                    pcall(setupvalue, self.ShootFunction, i, 0)
                end
            end
        end
    end)

    return self
end

function FastAttack:IsEntityAlive(e)
    local h = e and e:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

-- bypass stun inline, không loop qua ipairs
function FastAttack:BypassStun(char)
    local names = {"Stun","Busy","NoAttack","Attacking"}
    for i = 1, 4 do
        local obj = char:FindFirstChild(names[i])
        if obj then
            local v = obj.Value
            if type(v) == "number"  and v ~= 0   then rawset(obj, "Value", 0)     end
            if type(v) == "boolean" and v == true then rawset(obj, "Value", false) end
        end
    end
end

function FastAttack:GetBladeHits(char, dist)
    local pos  = char:GetPivot().Position
    local hits = {}
    dist = dist or Config.AttackDistance
    local distSq = dist * dist

    local function scan(folder)
        local children = folder:GetChildren()
        for i = 1, #children do
            local e = children[i]
            if e ~= char then
                local hum = e:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local hrp = e:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = hrp.Position - pos
                        if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= distSq then
                            hits[#hits+1] = {e, hrp}
                            if not self.EnemyRootPart then self.EnemyRootPart = hrp end
                        end
                    end
                end
            end
        end
    end

    if Config.AttackMobs    then scan(Workspace.Enemies)    end
    if Config.AttackPlayers then scan(Workspace.Characters) end
    return hits
end

function FastAttack:GetCombo()
    local combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    combo = combo + 1
    self.ComboDebounce = tick()
    self.M1Combo = combo
    return combo
end

function FastAttack:ApplyVisuals(char, hits, wname)
    for i = 1, #hits do
        local mob, part = hits[i][1], hits[i][2]
        pcall(function()
            if CombatUtil then CombatUtil:ApplyDamageHighlight(mob, char, wname, part) end
        end)
        pcall(function()
            if FX then FX:Get("HitEffect", part.CFrame) end
        end)
        if not CombatUtil then
            pcall(function()
                local h = Instance.new("SelectionBox")
                h.Adornee = mob
                h.Color3 = Color3.fromRGB(255,0,0)
                h.LineThickness = 0.05
                h.SurfaceTransparency = 0.7
                h.Parent = game:GetService("CoreGui")
                game:GetService("Debris"):AddItem(h, 0.08)
            end)
        end
    end
end

function FastAttack:UseNormalClick(char, hits)
    if #hits == 0 then return end

    local hitFn = self.HitFn
    local flags = self.CombatFlags

    -- setthreadidentity 1 lần trước toàn bộ loop
    pcall(function() setthreadidentity(8) end)

    -- fire RegisterAttack 1 lần trước
    RegisterAttack:FireServer(0)

    -- fire hit N lần lên tất cả targets, dùng index loop nhanh hơn pairs
    for rep = 1, Config.HitRepeat do
        for i = 1, #hits do
            local root = hits[i][2]
            if flags and hitFn then
                hitFn(root, hits)
            else
                RegisterHit:FireServer(root, hits)
            end
        end
    end

    pcall(function() setthreadidentity(2) end)

    -- visual sau
    local tool = char:FindFirstChildOfClass("Tool")
    local wname = tool and tool.Name or ""
    pcall(function()
        if CombatUtil then wname = CombatUtil:GetWeaponName(tool) end
    end)
    self:ApplyVisuals(char, hits, wname)
end

function FastAttack:UseFruitM1(char, tool, combo)
    local hits = self:GetBladeHits(char)
    if #hits == 0 then return end
    local lclr = tool:FindFirstChild("LeftClickRemote")
    if not lclr then return end

    local myPos = char:GetPivot().Position
    pcall(function() setthreadidentity(8) end)

    -- fire lên từng target riêng với direction chính xác
    for i = 1, #hits do
        local targetPos = hits[i][2].Position
        local dir = (targetPos - myPos)
        if dir.Magnitude > 0 then
            dir = dir.Unit
        else
            dir = char:GetPivot().LookVector
        end
        -- fire mỗi target N lần với combo tăng dần
        for rep = 1, Config.HitRepeat do
            local c = combo + rep - 1
            lclr:FireServer(dir, c)
        end
    end

    -- reset combo để tránh bị reject
    self.M1Combo = 0
    self.ComboDebounce = 0

    pcall(function() setthreadidentity(2) end)
    self:ApplyVisuals(char, hits, tool.Name)
end

function FastAttack:ShootInTarget(pos)
    local char = Player.Character
    if not self:IsEntityAlive(char) then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.ToolTip ~= "Gun" then return end
    if (tick() - self.ShootDebounce) < 0.0001 then return end

    local st = self.SpecialShoots[tool.Name] or "Normal"
    if st == "Position" or (st == "TAP" and tool:FindFirstChild("RemoteEvent")) then
        tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(self:GetValidator2())
        if st == "TAP" then
            tool.RemoteEvent:FireServer("TAP", pos)
        else
            ShootGunEvent:FireServer(pos)
        end
    else
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
    end
    self.ShootDebounce = tick()
end

function FastAttack:GetValidator2()
    local v1=getupvalue(self.ShootFunction,15)
    local v2=getupvalue(self.ShootFunction,13)
    local v3=getupvalue(self.ShootFunction,16)
    local v4=getupvalue(self.ShootFunction,17)
    local v5=getupvalue(self.ShootFunction,14)
    local v6=getupvalue(self.ShootFunction,12)
    local v7=getupvalue(self.ShootFunction,18)
    local v8=v6*v2
    local v9=(v5*v2+v6*v1)%v3
    v9=(v9*v3+v8)%v4
    v5=math.floor(v9/v3)
    v6=v9-v5*v3
    v7=v7+1
    setupvalue(self.ShootFunction,15,v1)
    setupvalue(self.ShootFunction,13,v2)
    setupvalue(self.ShootFunction,16,v3)
    setupvalue(self.ShootFunction,17,v4)
    setupvalue(self.ShootFunction,14,v5)
    setupvalue(self.ShootFunction,12,v6)
    setupvalue(self.ShootFunction,18,v7)
    return math.floor(v9/v4*16777215),v7
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local char = Player.Character
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Blox Fruit" and tip ~= "Sword" and tip ~= "Gun" then return end
    if hum.Sit and tip ~= "Gun" then return end

    self:BypassStun(char)

    local combo = self:GetCombo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(char, tool, combo)
    elseif tip == "Gun" then
        local hits = self:GetBladeHits(char, 120)
        for i = 1, #hits do self:ShootInTarget(hits[i][2].Position) end
    else
        local hits = self:GetBladeHits(char)
        self:UseNormalClick(char, hits)
    end
end

local inst = FastAttack.new()
table.insert(inst.Connections, RunService.Heartbeat:Connect(function()
    inst:Attack()
end))

return FastAttack
