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

-- Cache thư mục để tránh tốn CPU tìm kiếm mỗi frame
local EnemiesFolder = Workspace:WaitForChild("Enemies")
local CharactersFolder = Workspace:WaitForChild("Characters")

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
    HitRepeat       = 3, 
    TickRate        = 0.05 
}

local STUN_STATES = {"Stun", "Busy", "NoAttack", "Attacking"}

local function bypassCooldowns()
    local realTick = tick
    getgenv().tick = function() return realTick() + 9999 end

    task.spawn(function()
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
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
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
        LastScanTick  = 0,
        CachedHits    = {}
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

function FastAttack:BypassStun(char)
    -- TỐI ƯU: Sử dụng table tĩnh đã định nghĩa ở trên
    for i = 1, #STUN_STATES do
        local obj = char:FindFirstChild(STUN_STATES[i])
        if obj then
            local v = obj.Value
            if type(v) == "number"  and v ~= 0   then obj.Value = 0 end
            if type(v) == "boolean" and v == true then obj.Value = false end
        end
    end
end

function FastAttack:GetBladeHits(char, dist)
    -- TỐI ƯU: Cache kết quả quét trong 0.1s để giảm tải CPU thay vì quét liên tục mỗi frame
    if tick() - self.LastScanTick < 0.1 then
        return self.CachedHits
    end

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
                        -- Math tối ưu để tính khoảng cách thay vì Magnitude (tốn ít CPU hơn)
                        local dx = hrp.Position.X - pos.X
                        local dy = hrp.Position.Y - pos.Y
                        local dz = hrp.Position.Z - pos.Z
                        
                        if (dx*dx + dy*dy + dz*dz) <= distSq then
                            hits[#hits+1] = {e, hrp}
                            if not self.EnemyRootPart then self.EnemyRootPart = hrp end
                        end
                    end
                end
            end
        end
    end

    if Config.AttackMobs    then scan(EnemiesFolder)    end
    if Config.AttackPlayers then scan(CharactersFolder) end
    
    self.CachedHits = hits
    self.LastScanTick = tick()
    
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
    -- Giữ nguyên visuals vì nó không ảnh hưởng quá lớn tới logic
    for i = 1, #hits do
        local mob, part = hits[i][1], hits[i][2]
        task.spawn(function() -- Bọc trong spawn để tránh bị chặn luồng chính
            pcall(function()
                if CombatUtil then CombatUtil:ApplyDamageHighlight(mob, char, wname, part) end
            end)
            pcall(function()
                if FX then FX:Get("HitEffect", part.CFrame) end
            end)
        end)
    end
end

function FastAttack:UseNormalClick(char, hits)
    if #hits == 0 then return end

    local hitFn = self.HitFn
    local flags = self.CombatFlags

    pcall(function() setthreadidentity(8) end)
    RegisterAttack:FireServer(0)

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

    for i = 1, #hits do
        local targetPos = hits[i][2].Position
        local dx = targetPos.X - myPos.X
        local dy = targetPos.Y - myPos.Y
        local dz = targetPos.Z - myPos.Z
        local dir = Vector3.new(dx, dy, dz)
        
        if dir.Magnitude > 0 then
            dir = dir.Unit
        else
            dir = char:GetPivot().LookVector
        end

        for rep = 1, Config.HitRepeat do
            local c = combo + rep - 1
            lclr:FireServer(dir, c)
        end
    end

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
    if (tick() - self.ShootDebounce) < 0.1 then return end -- Thêm cooldown nhẹ để không bị lag súng

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
local lastTick = 0

-- TỐI ƯU VÒNG LẶP: Thay vì chạy max ping (60+ FPS), giới hạn tick rate để phần cứng thở được
table.insert(inst.Connections, RunService.Heartbeat:Connect(function()
    local currentTick = tick()
    if currentTick - lastTick >= Config.TickRate then
        inst:Attack()
        lastTick = currentTick
    end
end))

return FastAttack
