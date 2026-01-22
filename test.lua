--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// LOCALS
local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

--// REMOTES
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")

--// CONFIGURATION SIÊU NHANH
local Config = {
    Enabled = true,
    AttackDistance = 100,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.001,   -- SIÊU NHANH
    
    -- Tấn công đa mục tiêu
    MultiHit = true,
    MaxTargets = 20,
    
    -- Tối ưu
    FastScan = true,
    NoAnimation = true
}

--// TẤN CÔNG SIÊU TỐC
local SuperFastAttack = {
    Debounce = 0,
    TargetsCache = {},
    HitFunction = nil,
    
    -- Cache folders
    EnemiesFolder = Workspace:WaitForChild("Enemies"),
    CharactersFolder = Workspace:WaitForChild("Characters")
}

-- Tìm hàm hit server nhanh
task.spawn(function()
    pcall(function()
        -- Thử tìm hàm hit từ CombatController
        local success, combat = pcall(require, ReplicatedStorage.Controllers.CombatController)
        if success and combat then
            -- Tìm tất cả hàm có thể hit
            for name, func in pairs(combat) do
                if type(func) == "function" and (name:find("Hit") or name:find("Damage") or name:find("Attack")) then
                    SuperFastAttack.HitFunction = func
                    break
                end
            end
        end
        
        -- Thử tìm từ LocalScript
        local playerScripts = Player:WaitForChild("PlayerScripts")
        for _, script in ipairs(playerScripts:GetChildren()) do
            if script:IsA("LocalScript") and getsenv then
                local success, env = pcall(getsenv, script)
                if success and env then
                    for k, v in pairs(env) do
                        if type(v) == "function" and (k:find("Hit") or k:find("Damage") or k:find("Attack")) then
                            SuperFastAttack.HitFunction = v
                            break
                        end
                    end
                end
            end
        end
    end)
end)

-- Hàm quét MỤC TIÊU SIÊU NHANH (dùng vector operations)
function ScanTargetsUltraFast(characterPos)
    local targets = {}
    local charCount = 0
    
    -- QUÉT ENEMIES
    if Config.AttackMobs and SuperFastAttack.EnemiesFolder then
        local enemies = SuperFastAttack.EnemiesFolder:GetChildren()
        for i = 1, math.min(#enemies, Config.MaxTargets) do
            local enemy = enemies[i]
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (characterPos - hrp.Position).Magnitude
                if dist <= Config.AttackDistance then
                    charCount = charCount + 1
                    targets[charCount] = {enemy, hrp}
                end
            end
        end
    end
    
    -- QUÉT PLAYERS
    if Config.AttackPlayers and charCount < Config.MaxTargets and SuperFastAttack.CharactersFolder then
        local chars = SuperFastAttack.CharactersFolder:GetChildren()
        for i = 1, math.min(#chars, Config.MaxTargets - charCount) do
            local char = chars[i]
            if char ~= Player.Character then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (characterPos - hrp.Position).Magnitude
                    if dist <= Config.AttackDistance then
                        charCount = charCount + 1
                        targets[charCount] = {char, hrp}
                    end
                end
            end
        end
    end
    
    return targets
end

-- TẤN CÔNG MELEE SIÊU TỐC
function UltraFastMeleeAttack()
    if not Config.Enabled then return end
    
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped then return end
    
    local toolTip = equipped.ToolTip
    if not (toolTip == "Melee" or toolTip == "Sword") then return end
    
    -- Kiểm tra cooldown
    local now = tick()
    if now - SuperFastAttack.Debounce < Config.AttackCooldown then return end
    SuperFastAttack.Debounce = now
    
    -- Lấy vị trí
    local charPos = character:GetPivot().Position
    
    -- QUÉT và TẤN CÔNG CÙNG LÚC
    local targets = ScanTargetsUltraFast(charPos)
    if #targets == 0 then return end
    
    -- GỬI ATTACK EVENT
    RegisterAttack:FireServer(Config.AttackCooldown)
    
    -- GỬI HIT TỚI TẤT CẢ MỤC TIÊU CÙNG LÚC
    for i = 1, #targets do
        local targetData = targets[i]
        local enemyRoot = targetData[2]
        
        -- Thử dùng HitFunction trước
        if SuperFastAttack.HitFunction then
            pcall(SuperFastAttack.HitFunction, enemyRoot, {targetData})
        else
            -- Dùng remote mặc định
            pcall(function()
                RegisterHit:FireServer(enemyRoot, {enemyRoot})
            end)
        end
        
        -- Gửi thêm hit thứ 2 để chắc chắn (tăng damage)
        task.spawn(function()
            pcall(function()
                RegisterHit:FireServer(enemyRoot, {enemyRoot})
            end)
        end)
    end
end

-- TẤN CÔNG GUN SIÊU TỐC
function UltraFastGunAttack()
    local character = Player.Character
    if not character then return end
    
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped or equipped.ToolTip ~= "Gun" then return end
    
    -- Lấy vị trí
    local charPos = character:GetPivot().Position
    local targets = ScanTargetsUltraFast(charPos)
    
    -- BẮN TẤT CẢ MỤC TIÊU CÙNG LÚC
    for i = 1, #targets do
        local targetPos = targets[i][2].Position
        pcall(function()
            ShootGunEvent:FireServer(targetPos)
            -- Bắn thêm lần nữa
            ShootGunEvent:FireServer(targetPos)
        end)
    end
end

-- TẤN CÔNG FRUIT SIÊU TỐC
function UltraFastFruitAttack()
    local character = Player.Character
    if not character then return end
    
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped or equipped.ToolTip ~= "Blox Fruit" then return end
    if not equipped:FindFirstChild("LeftClickRemote") then return end
    
    local charPos = character:GetPivot().Position
    local targets = ScanTargetsUltraFast(charPos)
    
    if #targets > 0 then
        local targetPos = targets[1][2].Position
        local direction = (targetPos - charPos).Unit
        
        -- GỬI NHIỀU LẦN ĐỂ TĂNG DAMAGE
        pcall(function()
            for i = 1, 3 do
                equipped.LeftClickRemote:FireServer(direction, 1)
                task.wait(0.01)
            end
        end)
    end
end

-- MAIN LOOP SIÊU NHANH
local connection
connection = RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped then return end
    
    local toolTip = equipped.ToolTip
    
    -- PHÂN LOẠI VÀ TẤN CÔNG
    if toolTip == "Melee" or toolTip == "Sword" then
        UltraFastMeleeAttack()
    elseif toolTip == "Gun" then
        UltraFastGunAttack()
    elseif toolTip == "Blox Fruit" then
        UltraFastFruitAttack()
    end
end)

-- THÊM BIND KEY ĐỂ BẬT/TẮT NHANH
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        Config.Enabled = not Config.Enabled
        print("⚡ Super Fast Attack: " .. (Config.Enabled and "ENABLED" or "DISABLED"))
    elseif input.KeyCode == Enum.KeyCode.G then
        Config.AttackDistance = Config.AttackDistance + 10
        print("📏 Attack Distance: " .. Config.AttackDistance)
    elseif input.KeyCode == Enum.KeyCode.H then
        Config.AttackDistance = math.max(20, Config.AttackDistance - 10)
        print("📏 Attack Distance: " .. Config.AttackDistance)
    end
end)

print([[
╔══════════════════════════════════════════╗
║   🚀 SUPER FAST ATTACK LOADED 🚀        ║
║                                          ║
║  Features:                              ║
║  • Ultra Fast Melee (0.001s cooldown)   ║
║  • Multi-target hitting                 ║
║  • No animations (direct hits)          ║
║  • Auto-detect weapon type              ║
║                                          ║
║  Controls:                              ║
║  • F - Toggle On/Off                    ║
║  • G - Increase range                   ║
║  • H - Decrease range                   ║
║                                          ║
║  Current Config:                        ║
║  • Cooldown: ]] .. Config.AttackCooldown .. [[s         ║
║  • Range: ]] .. Config.AttackDistance .. [[ studs        ║
╚══════════════════════════════════════════╝]])
