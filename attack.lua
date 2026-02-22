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

--// ULTRA SPEED CONFIG - 300+ HITS/SECOND
local Config = {
    Enabled = true,
    AttackDistance = 80,
    GunDistance = 200,
    AttackMobs = true,
    AttackPlayers = true,
    
    -- TỐC ĐỘ CỰC NHANH
    HitsPerSecond = 300,
    SpamMultiplier = 8,  -- Tăng từ 5 lên 8
    FastClick = true,    -- Bật click nhanh
}

--// SPEED SYSTEM
local SpeedAttack = {
    HitCount = 0,
    StartTime = tick(),
    Targets = {},
    LastAttack = 0,
    
    -- Function cache
    ShootFunc = nil,
    HitFunc = nil,
    CombatFlags = nil,
    FruitRemote = nil,
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

--// GET ALL TARGETS INSTANTLY (Optimized)
local function GetAllTargets()
    if not Character or not Character.PrimaryPart then return {} end
    
    local Pos = Character.PrimaryPart.Position
    local AllTargets = {}
    local DistSq = Config.AttackDistance * Config.AttackDistance
    
    -- Get Mobs (optimized)
    if Config.AttackMobs then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            local humanoid = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local delta = hrp.Position - Pos
                if delta.X*delta.X + delta.Y*delta.Y + delta.Z*delta.Z <= DistSq then
                    table.insert(AllTargets, {enemy, hrp})
                end
            end
        end
    end
    
    -- Get Players (optimized)
    if Config.AttackPlayers then
        for _, enemy in pairs(Workspace.Characters:GetChildren()) do
            if enemy ~= Character then
                local humanoid = enemy:FindFirstChild("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and hrp then
                    local delta = hrp.Position - Pos
                    if delta.X*delta.X + delta.Y*delta.Y + delta.Z*delta.Z <= DistSq then
                        table.insert(AllTargets, {enemy, hrp})
                    end
                end
            end
        end
    end
    
    return AllTargets
end

--// GET GUN TARGETS (Optimized)
local function GetGunTargets()
    if not Character or not Character.PrimaryPart then return {} end
    
    local Pos = Character.PrimaryPart.Position
    local Targets = {}
    local DistSq = Config.GunDistance * Config.GunDistance
    
    if Config.AttackMobs then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            local humanoid = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local delta = hrp.Position - Pos
                if delta.X*delta.X + delta.Y*delta.Y + delta.Z*delta.Z <= DistSq then
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
                    local delta = hrp.Position - Pos
                    if delta.X*delta.X + delta.Y*delta.Y + delta.Z*delta.Z <= DistSq then
                        table.insert(Targets, hrp)
                    end
                end
            end
        end
    end
    
    return Targets
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

--// SPAM MELEE ATTACKS - ULTRA FAST
local function SpamMeleeAttacks()
    if not CanAttack() then return end
    
    local Targets = GetAllTargets()
    if #Targets == 0 then return end
    
    -- SPAM NHIỀU HƠN
    for spam = 1, Config.SpamMultiplier do
        task.spawn(function()
            pcall(function()
                RegisterAttack:FireServer(0)
                
                if SpeedAttack.CombatFlags and SpeedAttack.HitFunc then
                    SpeedAttack.HitFunc(Targets[1][2], Targets)
                else
                    RegisterHit:FireServer(Targets[1][2], Targets)
                end
                
                -- Gửi thêm 1 lần nữa để tăng tốc
                RegisterHit:FireServer(Targets[1][2], Targets)
                
                SpeedAttack.HitCount = SpeedAttack.HitCount + 1
            end)
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

--// SPAM GUN SHOOTS
local function SpamGunShoots()
    if not CanAttack() then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool or Tool.ToolTip ~= "Gun" then return end
    
    local Targets = GetGunTargets()
    if #Targets == 0 then return end
    
    -- SPAM NHIỀU HƠN
    for spam = 1, Config.SpamMultiplier do
        for _, target in ipairs(Targets) do
            task.spawn(function()
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
            end)
        end
    end
end

--// SPAM FRUIT M1 (FIXED - Cải thiện)
local function SpamFruitM1()
    if not CanAttack() then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool or Tool.ToolTip ~= "Blox Fruit" then return end
    
    local Targets = GetAllTargets()
    if #Targets == 0 then return end
    
    -- TÌM REMOTE PHÙ HỢP
    local Remote = Tool:FindFirstChild("LeftClickRemote") or 
                   Tool:FindFirstChild("RemoteEvent") or
                   Tool:FindFirstChild("MouseButton1ClickEvent")
    
    if not Remote then return end
    
    local TargetPos = Targets[1][2].Position
    local MyPos = Character.PrimaryPart.Position
    local Direction = (TargetPos - MyPos).Unit
    
    -- SPAM FRUIT ATTACKS - NHIỀU PHƯƠNG THỨC
    for spam = 1, Config.SpamMultiplier do
        task.spawn(function()
            pcall(function()
                -- Phương thức 1: LeftClickRemote với Direction
                if Remote.Name == "LeftClickRemote" then
                    Remote:FireServer(Direction, spam)
                    Remote:FireServer(Direction)
                    
                -- Phương thức 2: RemoteEvent
                elseif Remote.Name == "RemoteEvent" then
                    Remote:FireServer("TAP", TargetPos)
                    Remote:FireServer("MouseButton1Click", TargetPos)
                    
                -- Phương thức 3: MouseButton1Click
                else
                    Remote:FireServer(TargetPos)
                    Remote:FireServer(Direction)
                end
                
                -- Thử gửi thêm với RegisterAttack
                RegisterAttack:FireServer(0)
                
                SpeedAttack.HitCount = SpeedAttack.HitCount + 1
            end)
        end)
        
        -- Thêm delay nhỏ giữa các lần spam để tránh rate limit
        if spam % 3 == 0 then
            task.wait()
        end
    end
end

--// MAIN ATTACK LOOP (Optimized)
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
        print(string.format("⚡ Hits/Sec: %d | Total: %d | Elapsed: %.1fs", hps, SpeedAttack.HitCount, elapsed))
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

--// ULTRA SPEED LOOPS - TĂNG CƯỜNG
-- Loop 1: RenderStepped (60+ times/sec)
RunService.RenderStepped:Connect(function()
    MainAttack()
end)

-- Loop 2: Heartbeat (60+ times/sec)  
RunService.Heartbeat:Connect(function()
    MainAttack()
end)

-- Loop 3: Stepped (Physics step)
RunService.Stepped:Connect(function()
    MainAttack()
end)

-- Loop 4: ULTRA FAST SPAM LOOP
task.spawn(function()
    while task.wait() do
        MainAttack()
        MainAttack()
        MainAttack()  -- Triple call thay vì double
    end
end)

-- Loop 5: BACKUP SPAM (tăng cường)
task.spawn(function()
    while task.wait() do
        for i = 1, 5 do  -- Tăng từ 3 lên 5
            task.spawn(MainAttack)
        end
    end
end)

-- Loop 6: HYPER SPAM (MỚI)
task.spawn(function()
    while task.wait() do
        for i = 1, 3 do
            task.defer(MainAttack)
        end
    end
end)

return SpeedAttack
