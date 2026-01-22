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

--// CONFIGURATION
local Config = {
    Enabled = true,
    AttackDistance = 60,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.002,    -- TỐC ĐỘ CỰC NHANH (không cần animation)
    
    -- Tối ưu hiệu suất
    MaxTargets = 10,
    FastMode = true           -- Chế độ không animation
}

--// CLASS: FAST ATTACK
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ShootDebounce = 0,
        ComboDebounce = 0,
        LastScanTime = 0,
        CachedTargets = {},
        
        -- Cache các folder
        EnemiesFolder = Workspace:FindFirstChild("Enemies"),
        CharactersFolder = Workspace:FindFirstChild("Characters"),
        
        SpecialShoots = {
            ["Skull Guitar"] = "TAP", 
            ["Bazooka"] = "Position", 
            ["Cannon"] = "Position"
        }
    }, FastAttack)

    -- Tải hit function
    task.spawn(function()
        pcall(function()
            local playerScripts = Player:WaitForChild("PlayerScripts")
            for _, script in ipairs(playerScripts:GetChildren()) do
                if script:IsA("LocalScript") and getsenv then
                    local env = getsenv(script)
                    if env and env._G and env._G.SendHitsToServer then
                        self.HitFunction = env._G.SendHitsToServer
                        break
                    end
                end
            end
        end)
    end)

    return self
end

function FastAttack:IsEntityAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

-- Quét mục tiêu tối ưu (không cache)
function FastAttack:GetTargetsDirect(Character, Distance)
    local Position = Character:GetPivot().Position
    local TargetList = {}
    local count = 0
    
    Distance = Distance or Config.AttackDistance
    
    -- Quét Enemies
    if Config.AttackMobs then
        local enemies = self.EnemiesFolder or Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, Enemy in ipairs(enemies:GetChildren()) do
                if count >= Config.MaxTargets then break end
                if Enemy ~= Character then
                    local HRP = Enemy:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        local dist = (Position - HRP.Position).Magnitude
                        if dist <= Distance and self:IsEntityAlive(Enemy) then
                            count = count + 1
                            TargetList[count] = {Enemy, HRP}
                        end
                    end
                end
            end
        end
    end
    
    -- Quét Players
    if Config.AttackPlayers and count < Config.MaxTargets then
        local chars = self.CharactersFolder or Workspace:FindFirstChild("Characters")
        if chars then
            for _, Enemy in ipairs(chars:GetChildren()) do
                if count >= Config.MaxTargets then break end
                if Enemy ~= Character then
                    local HRP = Enemy:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        local dist = (Position - HRP.Position).Magnitude
                        if dist <= Distance and self:IsEntityAlive(Enemy) then
                            count = count + 1
                            TargetList[count] = {Enemy, HRP}
                        end
                    end
                end
            end
        end
    end
    
    return TargetList
end

-- MELEE ATTACK DIRECT (không animation)
function FastAttack:DirectMeleeAttack(Character)
    local Targets = self:GetTargetsDirect(Character)
    if #Targets == 0 then return end
    
    -- Gửi attack trực tiếp (không click)
    RegisterAttack:FireServer(Config.AttackCooldown)
    
    -- Gửi hit trực tiếp tới tất cả targets
    for _, Data in ipairs(Targets) do
        local EnemyRoot = Data[2]
        if self.HitFunction then
            pcall(self.HitFunction, EnemyRoot, {Data})
        else
            RegisterHit:FireServer(EnemyRoot, {EnemyRoot})
        end
    end
end

-- GUN ATTACK DIRECT (không animation)
function FastAttack:DirectGunAttack(Character)
    local Targets = self:GetTargetsDirect(Character, 100)
    if #Targets == 0 then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end
    
    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        -- Bắn đặc biệt trực tiếp
        for _, t in ipairs(Targets) do
            if ShootType == "TAP" then 
                Equipped.RemoteEvent:FireServer("TAP", t[2].Position)
            else 
                ShootGunEvent:FireServer(t[2].Position) 
            end
        end
    else
        -- Bắn thường trực tiếp
        for _, t in ipairs(Targets) do
            ShootGunEvent:FireServer(t[2].Position)
        end
    end
end

-- FRUIT ATTACK DIRECT (không animation)
function FastAttack:DirectFruitAttack(Character)
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Blox Fruit" then return end
    if not Equipped:FindFirstChild("LeftClickRemote") then return end
    
    local Targets = self:GetTargetsDirect(Character)
    if #Targets == 0 then return end
    
    -- Gửi hit trực tiếp tới target đầu tiên
    local direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    Equipped.LeftClickRemote:FireServer(direction, 1)
end

-- UPDATE DIRECT (không animation)
function FastAttack:DirectUpdate()
    if not Config.Enabled then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    local currentTime = tick()
    
    -- MELEE/SWORD - ATTACK DIRECT
    if ToolTip == "Melee" or ToolTip == "Sword" then
        if currentTime - self.Debounce >= Config.AttackCooldown then
            self.Debounce = currentTime
            self:DirectMeleeAttack(Character)
        end
    
    -- GUN - ATTACK DIRECT
    elseif ToolTip == "Gun" then
        if currentTime - self.ShootDebounce >= 0.02 then
            self.ShootDebounce = currentTime
            self:DirectGunAttack(Character)
        end
    
    -- FRUIT - ATTACK DIRECT
    elseif ToolTip == "Blox Fruit" then
        if currentTime - self.ComboDebounce >= 0.02 then
            self.ComboDebounce = currentTime
            self:DirectFruitAttack(Character)
        end
    end
end

--// INITIALIZE
local MyAttack = FastAttack.new()

-- Chạy với tốc độ cao nhất
RunService.Heartbeat:Connect(function()
    MyAttack:DirectUpdate()
end)

print("⚡ DIRECT ATTACK: Đã xóa animation và auto click")
print("⚙️ Tấn công trực tiếp - Tốc độ: " .. Config.AttackCooldown .. "s")
