--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Wait for modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

--// OPTIMIZED CONFIG - GIẢM LAG NHƯNG VẪN NHANH
local Config = {
    Enabled = true,
    AttackDistance = 80,
    GunDistance = 200,
    AttackMobs = true,
    AttackPlayers = true,
    
    -- Tối ưu: 100-150 hits/sec thay vì 200 (giảm lag đáng kể)
    HitsPerSecond = 120,
    SpamMultiplier = 3,  -- Giảm từ 5 xuống 3 (giảm spam overhead)
    
    -- Cache timing
    TargetUpdateInterval = 0.1,  -- Update targets mỗi 0.1s thay vì mỗi frame
    LastTargetUpdate = 0,
}

--// SPEED SYSTEM
local SpeedAttack = {
    HitCount = 0,
    StartTime = tick(),
    CachedTargets = {},  -- Cache targets
    CachedGunTargets = {},
    
    -- Function cache
    ShootFunc = nil,
    HitFunc = nil,
    CombatFlags = nil,
}

--// INIT FUNCTIONS
local function InitFunctions()
    pcall(function()
        SpeedAttack.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
    end)
    
    pcall(function()
        local CombatController = ReplicatedStorage.Controllers.CombatController
        if CombatController then
            SpeedAttack.ShootFunc = getupvalue(require(CombatController).Attack, 9)
        end
    end)
    
    pcall(function()
        local LocalScript = Player.PlayerScripts:FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            local env = getsenv(LocalScript)
            if env and env._G and env._G.SendHitsToServer then
                SpeedAttack.HitFunc = env._G.SendHitsToServer
            end
        end
    end)
end

--// OPTIMIZED TARGET GETTING - CHỈ UPDATE KHI CẦN
local function UpdateTargets()
    local now = tick()
    if now - Config.LastTargetUpdate < Config.TargetUpdateInterval then
        return  -- Dùng cache
    end
    
    Config.LastTargetUpdate = now
    
    if not Character or not Character.PrimaryPart then 
        SpeedAttack.CachedTargets = {}
        return 
    end
    
    local Pos = Character.PrimaryPart.Position
    local AllTargets = {}
    
    -- Get Mobs
    if Config.AttackMobs then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            local humanoid = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local distance = (Pos - hrp.Position).Magnitude
                if distance <= Config.AttackDistance then
                    table.insert(AllTargets, {enemy, hrp, distance})
                end
            end
        end
    end
    
    -- Get Players
    if Config.AttackPlayers then
        for _, enemy in pairs(Workspace.Characters:GetChildren()) do
            if enemy ~= Character then
                local humanoid = enemy:FindFirstChild("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and hrp then
                    local distance = (Pos - hrp.Position).Magnitude
                    if distance <= Config.AttackDistance then
                        table.insert(AllTargets, {enemy, hrp, distance})
                    end
                end
            end
        end
    end
    
    -- Sort by distance (gần nhất trước)
    table.sort(AllTargets, function(a, b) return a[3] < b[3] end)
    
    SpeedAttack.CachedTargets = AllTargets
end

--// UPDATE GUN TARGETS
local function UpdateGunTargets()
    local now = tick()
    if now - Config.LastTargetUpdate < Config.TargetUpdateInterval then
        return
    end
    
    if not Character or not Character.PrimaryPart then 
        SpeedAttack.CachedGunTargets = {}
        return 
    end
    
    local Pos = Character.PrimaryPart.Position
    local Targets = {}
    
    if Config.AttackMobs then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            local humanoid = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                if (Pos - hrp.Position).Magnitude <= Config.GunDistance then
                    table.insert(Targets, hrp)
                end
            end
        end
    end
    
    if Config.AttackPlayers then
        for _, enemy in pairs(Workspace.Characters:GetChildren()) do
            if enemy ~= Character then
                local humanoid = enemy:FindFirstChild("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and hrp then
                    if (Pos - hrp.Position).Magnitude <= Config.GunDistance then
                        table.insert(Targets, hrp)
                    end
                end
            end
        end
    end
    
    SpeedAttack.CachedGunTargets = Targets
end

--// CHECK IF CAN ATTACK
local function CanAttack()
    if not Character or not Character.PrimaryPart then return false end
    if not Humanoid or Humanoid.Health <= 0 then return false end
    
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    
    if Humanoid.Sit then return false end
    if Stun and Stun.Value > 0 then return false end
    if Busy and Busy.Value then return false end
    
    return true
end

--// OPTIMIZED MELEE ATTACKS
local function SpamMeleeAttacks()
    if not CanAttack() then return end
    
    UpdateTargets()  -- Update cache nếu cần
    
    if #SpeedAttack.CachedTargets == 0 then return end
    
    -- Chỉ spam số lượng vừa phải
    for spam = 1, Config.SpamMultiplier do
        pcall(function()
            RegisterAttack:FireServer(0)
            
            if SpeedAttack.CombatFlags and SpeedAttack.HitFunc then
                SpeedAttack.HitFunc(SpeedAttack.CachedTargets[1][2], SpeedAttack.CachedTargets)
            else
                RegisterHit:FireServer(SpeedAttack.CachedTargets[1][2], SpeedAttack.CachedTargets)
            end
            
            SpeedAttack.HitCount = SpeedAttack.HitCount + 1
        end)
    end
end

--// GET VALIDATOR FOR GUN
local function GetValidator()
    if not SpeedAttack.ShootFunc then return 0, 0 end
    
    local success, v1, v2 = pcall(function()
        local v1 = getupvalue(SpeedAttack.ShootFunc, 15)
        local v2 = getupvalue(SpeedAttack.ShootFunc, 13)
        local v3 = getupvalue(SpeedAttack.ShootFunc, 16)
        local v4 = getupvalue(SpeedAttack.ShootFunc, 17)
        local v5 = getupvalue(SpeedAttack.ShootFunc, 14)
        local v6 = getupvalue(SpeedAttack.ShootFunc, 12)
        local v7 = getupvalue(SpeedAttack.ShootFunc, 18)

        local v8 = v6 * v2
        local v9 = (v5 * v2 + v6 * v1) % v3
        v9 = (v9 * v3 + v8) % v4
        v5 = math.floor(v9 / v3)
        v6 = v9 - v5 * v3
        v7 = v7 + 1

        setupvalue(SpeedAttack.ShootFunc, 15, v1)
        setupvalue(SpeedAttack.ShootFunc, 13, v2)
        setupvalue(SpeedAttack.ShootFunc, 16, v3)
        setupvalue(SpeedAttack.ShootFunc, 17, v4)
        setupvalue(SpeedAttack.ShootFunc, 14, v5)
        setupvalue(SpeedAttack.ShootFunc, 12, v6)
        setupvalue(SpeedAttack.ShootFunc, 18, v7)

        return math.floor(v9 / v4 * 16777215), v7
    end)
    
    if success then return v1, v2 end
    return 0, 0
end

--// OPTIMIZED GUN SHOOTS
local function SpamGunShoots()
    if not CanAttack() then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool or Tool.ToolTip ~= "Gun" then return end
    
    UpdateGunTargets()
    
    if #SpeedAttack.CachedGunTargets == 0 then return end
    
    -- Giảm spam, tăng hiệu quả
    for spam = 1, math.min(Config.SpamMultiplier, 2) do
        for i = 1, math.min(#SpeedAttack.CachedGunTargets, 3) do  -- Chỉ shoot 3 targets gần nhất
            local target = SpeedAttack.CachedGunTargets[i]
            pcall(function()
                Tool:SetAttribute("LocalTotalShots", (Tool:GetAttribute("LocalTotalShots") or 0) + 1)
                GunValidator:FireServer(GetValidator())
                
                if Tool.Name == "Bazooka" or Tool.Name == "Cannon" then
                    ShootGunEvent:FireServer(target.Position)
                elseif Tool.Name == "Skull Guitar" and Tool:FindFirstChild("RemoteEvent") then
                    Tool.RemoteEvent:FireServer("TAP", target.Position)
                else
                    ShootGunEvent:FireServer(target.Position)
                end
                
                SpeedAttack.HitCount = SpeedAttack.HitCount + 1
            end)
        end
    end
end

--// OPTIMIZED FRUIT M1
local function SpamFruitM1()
    if not CanAttack() then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool or Tool.ToolTip ~= "Blox Fruit" then return end
    if not Tool:FindFirstChild("LeftClickRemote") then return end
    
    UpdateTargets()
    
    if #SpeedAttack.CachedTargets == 0 then return end
    
    local Direction = (SpeedAttack.CachedTargets[1][2].Position - Character.PrimaryPart.Position).Unit
    
    -- Spam vừa phải
    for spam = 1, Config.SpamMultiplier do
        pcall(function()
            Tool.LeftClickRemote:FireServer(Direction, spam)
            SpeedAttack.HitCount = SpeedAttack.HitCount + 1
        end)
    end
end

--// MAIN ATTACK LOOP
local function MainAttack()
    if not Config.Enabled then return end
    
    local Tool = Character and Character:FindFirstChildOfClass("Tool")
    if not Tool then return end
    
    local ToolTip = Tool.ToolTip
    
    if ToolTip == "Melee" or ToolTip == "Sword" then
        SpamMeleeAttacks()
    elseif ToolTip == "Gun" then
        SpamGunShoots()
    elseif ToolTip == "Blox Fruit" then
        SpamFruitM1()
    end
end

--// HIT COUNTER
task.spawn(function()
    while task.wait(1) do
        local elapsed = tick() - SpeedAttack.StartTime
        local hps = math.floor(SpeedAttack.HitCount / elapsed)
        print(string.format("⚡ Hits/Sec: %d | Total: %d | Lag: OPTIMIZED", hps, SpeedAttack.HitCount))
    end
end)

--// CHARACTER UPDATE
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    InitFunctions()
end)

--// INITIALIZE
InitFunctions()

--// OPTIMIZED LOOPS - CHỈ 2 LOOPS THAY VÌ 5
-- Loop 1: Heartbeat (Ổn định nhất, ít lag nhất)
local LastAttack = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - LastAttack >= (1 / Config.HitsPerSecond) then
        LastAttack = now
        MainAttack()
    end
end)

-- Loop 2: FAST LOOP nhưng có delay nhỏ để không spam quá
task.spawn(function()
    while task.wait(0.005) do  -- ~200 FPS, không quá nhanh
        MainAttack()
    end
end)

--// NOTIFY
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("⚡ OPTIMIZED FAST ATTACK")
print("⚡ Target: " .. Config.HitsPerSecond .. " HITS/SECOND")
print("⚡ Spam Multiplier: x" .. Config.SpamMultiplier)
print("⚡ Loops: 2 OPTIMIZED (GIẢM LAG)")
print("⚡ Cache: ENABLED")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

return SpeedAttack
