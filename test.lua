--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// LOCALS
local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

--// REMOTES
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

--// BYPASS HIT SERVER
local HitBypass = {
    AttackQueue = {},
    LastAttackTime = 0,
    MaxQueueSize = 50,
    BypassEnabled = true,
    
    -- Multiple remote methods
    AttackRemotes = {
        RegisterAttack,
        RegisterHit,
        Net:FindFirstChild("RE/CombatHit") or RegisterHit,
        Net:FindFirstChild("RE/Damage") or RegisterHit
    },
    
    -- Random hit data patterns
    HitPatterns = {
        {"Normal", "Critical", "Combo"},
        {"Head", "Torso", "Limbs"},
        {1, 2, 3, 4, 5},
        {"Front", "Back", "Side"}
    }
}

-- Tìm tất cả remote có thể hit
function HitBypass:FindAllHitRemotes()
    local remotes = {}
    
    -- Tìm trong Net
    for _, remote in pairs(Net:GetChildren()) do
        if remote:IsA("RemoteEvent") and (remote.Name:find("Hit") or remote.Name:find("Damage") or remote.Name:find("Attack") or remote.Name:find("Combat")) then
            table.insert(remotes, remote)
        end
    end
    
    -- Tìm trong ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:find("Hit") or obj.Name:find("Damage")) then
            table.insert(remotes, obj)
        end
    end
    
    return remotes
end

-- Tạo hit data ngẫu nhiên để bypass
function HitBypass:GenerateRandomHitData(target)
    local randomData = {
        target = target,
        damage = math.random(10, 100),
        hitType = HitBypass.HitPatterns[1][math.random(1, 3)],
        bodyPart = HitBypass.HitPatterns[2][math.random(1, 3)],
        combo = HitBypass.HitPatterns[3][math.random(1, 5)],
        direction = HitBypass.HitPatterns[4][math.random(1, 3)],
        timestamp = tick(),
        validator = math.random(1000000, 9999999)
    }
    return randomData
end

-- Queue attack để bypass rate limit
function HitBypass:QueueAttack(target, hitData)
    if #self.AttackQueue < self.MaxQueueSize then
        table.insert(self.AttackQueue, {
            target = target,
            data = hitData or self:GenerateRandomHitData(target),
            time = tick()
        })
    end
end

-- Xử lý queue với tốc độ cao
function HitBypass:ProcessQueue()
    if not self.BypassEnabled or #self.AttackQueue == 0 then return end
    
    local now = tick()
    local processed = 0
    
    -- Process multiple hits per frame
    for i = 1, math.min(10, #self.AttackQueue) do
        local attack = self.AttackQueue[i]
        if attack then
            self:SendBypassHit(attack.target, attack.data)
            self.AttackQueue[i] = nil
            processed = processed + 1
        end
    end
    
    -- Clean array
    if processed > 0 then
        local newQueue = {}
        for _, attack in pairs(self.AttackQueue) do
            if attack then table.insert(newQueue, attack) end
        end
        self.AttackQueue = newQueue
    end
end

-- Gửi hit với multiple methods
function HitBypass:SendBypassHit(target, hitData)
    if not target then return end
    
    -- Gửi qua tất cả remotes
    for _, remote in pairs(self.AttackRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                -- Thử nhiều format khác nhau
                remote:FireServer(target, {target})
                remote:FireServer(target, hitData)
                remote:FireServer({target = target, damage = hitData.damage})
                remote:FireServer(target, target.Position, hitData.hitType)
            end
        end)
    end
    
    -- Gửi trực tiếp với hook
    pcall(function()
        -- Hook vào network để bypass
        HitBypass:DirectNetworkSend(target, hitData)
    end)
end

-- Direct network send (advanced bypass)
function HitBypass:DirectNetworkSend(target, data)
    -- Tạo fake validator để bypass
    local fakeValidator = {
        __type = "Validator",
        value = math.random(100000, 999999),
        time = tick(),
        signature = tostring(math.random()):sub(3, 10)
    }
    
    -- Gửi với nhiều protocol khác nhau
    for i = 1, 3 do
        pcall(function()
            -- Method 1: Standard
            RegisterHit:FireServer(target, {target})
            
            -- Method 2: With validator
            RegisterHit:FireServer(target, {target}, fakeValidator)
            
            -- Method 3: Multiple targets
            RegisterHit:FireServer({target}, {{target}})
            
            -- Method 4: Position based
            RegisterHit:FireServer(target.Position, target)
        end)
    end
end

--// MAIN ATTACK SYSTEM
local UltraAttack = {
    Config = {
        Enabled = true,
        AttackDistance = 100,
        AttackSpeed = 0.0001, -- Rất nhanh
        MultiHit = true,
        MaxTargets = 15,
        BypassMode = "Aggressive" -- Aggressive, Stealth, Normal
    },
    
    Targets = {},
    LastScan = 0,
    ScanCooldown = 0.05
}

-- Quét targets nhanh
function UltraAttack:ScanTargets()
    local now = tick()
    if now - self.LastScan < self.ScanCooldown then return self.Targets end
    
    self.Targets = {}
    local char = Player.Character
    if not char then return {} end
    
    local charPos = char:GetPivot().Position
    local count = 0
    
    -- Quét workspace
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model ~= char then
            local humanoid = model:FindFirstChild("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local dist = (charPos - hrp.Position).Magnitude
                if dist <= self.Config.AttackDistance then
                    count = count + 1
                    self.Targets[count] = {model, hrp, humanoid}
                    
                    if count >= self.Config.MaxTargets then break end
                end
            end
        end
    end
    
    self.LastScan = now
    return self.Targets
end

-- Tấn công với bypass
function UltraAttack:ExecuteBypassAttack()
    if not self.Config.Enabled then return end
    
    local targets = self:ScanTargets()
    if #targets == 0 then return end
    
    -- Gửi attack event
    pcall(function()
        RegisterAttack:FireServer(self.Config.AttackSpeed)
    end)
    
    -- Gửi hits với bypass
    for _, targetData in pairs(targets) do
        local hrp = targetData[2]
        
        if self.Config.BypassMode == "Aggressive" then
            -- Gửi nhiều hits cùng lúc
            for i = 1, 5 do
                HitBypass:QueueAttack(hrp)
            end
        else
            HitBypass:QueueAttack(hrp)
        end
    end
    
    -- Xử lý queue ngay lập tức
    HitBypass:ProcessQueue()
end

--// INITIALIZE BYPASS
HitBypass.AttackRemotes = HitBypass:FindAllHitRemotes()
print("🔍 Found " .. #HitBypass.AttackRemotes .. " hit remotes")

--// MAIN LOOP
RunService.Heartbeat:Connect(function(dt)
    UltraAttack:ExecuteBypassAttack()
end)

--// BIND KEYS
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        UltraAttack.Config.Enabled = not UltraAttack.Config.Enabled
        print("⚡ Attack: " .. (UltraAttack.Config.Enabled and "ON" or "OFF"))
        
    elseif input.KeyCode == Enum.KeyCode.G then
        -- Tăng tốc độ
        UltraAttack.Config.AttackSpeed = math.max(0.00001, UltraAttack.Config.AttackSpeed / 2)
        print("🚀 Speed: " .. UltraAttack.Config.AttackSpeed .. "s")
        
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Giảm tốc độ (tăng cooldown)
        UltraAttack.Config.AttackSpeed = UltraAttack.Config.AttackSpeed * 2
        print("🐢 Speed: " .. UltraAttack.Config.AttackSpeed .. "s")
        
    elseif input.KeyCode == Enum.KeyCode.J then
        -- Thay đổi bypass mode
        local modes = {"Normal", "Stealth", "Aggressive"}
        local current = UltraAttack.Config.BypassMode
        local nextIndex = (table.find(modes, current) or 1) % 3 + 1
        UltraAttack.Config.BypassMode = modes[nextIndex]
        print("🛡️ Bypass Mode: " .. UltraAttack.Config.BypassMode)
        
    elseif input.KeyCode == Enum.KeyCode.K then
        -- Force attack (bypass all)
        print("💥 FORCE ATTACKING...")
        for i = 1, 20 do
            UltraAttack:ExecuteBypassAttack()
            task.wait(0.001)
        end
    end
end)

--// ANTI-AFK
local VirtualInputManager = game:GetService("VirtualInputManager")
task.spawn(function()
    while task.wait(30) do
        pcall(function()
            -- Di chuyển nhẹ để không bị AFK
            VirtualInputManager:SendMouseMoveEvent(10, 10)
            VirtualInputManager:SendMouseMoveEvent(-10, -10)
        end)
    end
end)

print([[
╔══════════════════════════════════════════╗
║     🚀 HIT SERVER BYPASS LOADED 🚀      ║
║                                          ║
║  FEATURES:                              ║
║  • Bypass Server Rate Limit             ║
║  • Multi-Remote Spamming                ║
║  • Queue-Based Attack System            ║
║  • Random Hit Data Generation           ║
║  • Anti-AFK Protection                  ║
║                                          ║
║  CONTROLS:                              ║
║  • F - Toggle Attack                    ║
║  • G - Increase Speed (x2)              ║
║  • H - Decrease Speed (/2)              ║
║  • J - Change Bypass Mode               ║
║  • K - Force Attack (20x burst)         ║
║                                          ║
║  Current Speed: ]] .. string.format("%.5f", UltraAttack.Config.AttackSpeed) .. [[s     ║
║  Bypass Mode: ]] .. UltraAttack.Config.BypassMode .. [[              ║
╚══════════════════════════════════════════╝]])
