--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

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
    AttackCooldown = 0.05,    -- TỐC ĐỘ RẤT NHANH
    AutoClickEnabled = false,
    
    -- Cấu hình tối ưu hiệu ứng
    RemoveEffects = true,
    RemoveParticles = true,    -- Tắt particle
    RemoveTrails = true,       -- Tắt trail
    RemoveSounds = false,      -- Giữ âm thanh để biết đang đánh
    LightMode = true,          -- Chế độ nhẹ
    
    -- Tối ưu hiệu suất
    MaxTargets = 10,           -- Giới hạn số mục tiêu
    CleanupInterval = 5,       -- Giây giữa mỗi lần dọn dẹp
    FastScan = true            -- Quét nhanh
}

--// CLASS: FAST ATTACK
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        ComboDebounce = 0,
        LastCleanTime = 0,
        LastScanTime = 0,
        CachedTargets = {},
        
        -- Cache các đối tượng thường dùng
        EnemiesFolder = Workspace:FindFirstChild("Enemies"),
        CharactersFolder = Workspace:FindFirstChild("Characters"),
        
        SpecialShoots = {
            ["Skull Guitar"] = "TAP", 
            ["Bazooka"] = "Position", 
            ["Cannon"] = "Position"
        }
    }, FastAttack)

    -- Tải các hàm cần thiết một lần
    task.spawn(function()
        pcall(function()
            local CombatController = require(ReplicatedStorage.Controllers.CombatController)
            if CombatController and CombatController.Attack then
                self.ShootFunction = getupvalue(CombatController.Attack, 9)
            end
        end)
        
        -- Tìm hàm hit hiệu quả hơn
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

    -- Xử lý hiệu ứng một cách tối ưu
    if Config.RemoveEffects then
        Workspace.DescendantAdded:Connect(function(descendant)
            if not Config.Enabled then return end
            
            -- Xử lý nhanh không cần task.wait
            if Config.RemoveParticles and descendant:IsA("ParticleEmitter") then
                descendant.Enabled = false
            elseif Config.RemoveTrails and descendant:IsA("Trail") then
                descendant.Enabled = false
            elseif descendant:IsA("Explosion") then
                descendant.BlastPressure = 0
                descendant.BlastRadius = 0
            elseif descendant.Name == "DamageCounter" and Config.RemoveEffects then
                descendant:Destroy()
            end
        end)
    end

    return self
end

function FastAttack:IsEntityAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

function FastAttack:QuickGetTargets(Character, Distance)
    local currentTime = tick()
    
    -- Cache kết quả scan trong 0.1 giây để tăng hiệu suất
    if currentTime - self.LastScanTime < 0.1 and #self.CachedTargets > 0 then
        return self.CachedTargets, self.CachedTargets
    end
    
    self.LastScanTime = currentTime
    local Position = Character:GetPivot().Position
    local TargetList = {} 
    local HitPartList = {}
    local count = 0
    
    Distance = Distance or Config.AttackDistance
    
    -- Hàm quét nhanh
    local function QuickScanFolder(Folder)
        if not Folder then return end
        for i = 1, #Folder:GetChildren() do
            if count >= Config.MaxTargets then break end
            local Enemy = Folder:GetChildren()[i]
            if Enemy ~= Character then
                local HRP = Enemy:FindFirstChild("HumanoidRootPart")
                if HRP then
                    local distance = (Position - HRP.Position).Magnitude
                    if distance <= Distance and self:IsEntityAlive(Enemy) then
                        count = count + 1
                        TargetList[count] = {Enemy, HRP}
                        HitPartList[count] = HRP
                    end
                end
            end
        end
    end

    -- Quét theo cấu hình
    if Config.AttackMobs then
        QuickScanFolder(self.EnemiesFolder or Workspace:FindFirstChild("Enemies"))
    end
    if Config.AttackPlayers and count < Config.MaxTargets then
        QuickScanFolder(self.CharactersFolder or Workspace:FindFirstChild("Characters"))
    end
    
    -- Cache kết quả
    self.CachedTargets = TargetList
    return TargetList, HitPartList
end

-- Hàm dọn dẹp tối ưu
function FastAttack:OptimizedCleanup()
    if not Config.RemoveEffects then return end
    if tick() - self.LastCleanTime < Config.CleanupInterval then return end
    self.LastCleanTime = tick()
    
    -- Chỉ dọn khi có nhiều hiệu ứng
    local descendantCount = #Workspace:GetDescendants()
    if descendantCount < 500 then return end -- Không dọn nếu ít hiệu ứng
    
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") and Config.RemoveParticles then
            v.Enabled = false
        elseif v:IsA("Trail") and Config.RemoveTrails then
            v.Enabled = false
        elseif v.Name == "DamageCounter" then
            v:Destroy()
        elseif v:IsA("Beam") then
            v.Enabled = false
        end
    end
end

-- Melee attack tối ưu
function FastAttack:FastMeleeAttack(Character)
    local Targets = self:QuickGetTargets(Character)
    if #Targets == 0 then return end
    
    -- Gửi input nhanh hơn
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.spawn(function()
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
    
    -- Fire server với delay nhỏ
    RegisterAttack:FireServer(Config.AttackCooldown)
    
    -- Gửi hit tới tất cả mục tiêu
    for _, Data in ipairs(Targets) do
        local EnemyRoot = Data[2]
        if self.HitFunction then
            pcall(self.HitFunction, EnemyRoot, {Data})
        else
            RegisterHit:FireServer(EnemyRoot, {EnemyRoot})
        end
    end
end

-- Gun attack tối ưu
function FastAttack:FastGunAttack(Character)
    local Targets = self:QuickGetTargets(Character, 100)
    for _, t in ipairs(Targets) do
        self:ShootInTarget(t[2].Position)
    end
end

-- Fruit attack tối ưu
function FastAttack:FastFruitAttack(Character, Equipped)
    local Targets = self:QuickGetTargets(Character)
    if Targets[1] then
        local direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
        Equipped.LeftClickRemote:FireServer(direction, 1)
    end
end

function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end
    
    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        -- Bắn đặc biệt
        if ShootType == "TAP" then 
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else 
            ShootGunEvent:FireServer(TargetPosition) 
        end
    else
        -- Bắn thường với input nhanh
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.spawn(function()
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

-- Hàm update chính tối ưu
function FastAttack:OptimizedUpdate()
    if not Config.Enabled then return end
    
    -- Dọn dẹp định kỳ
    if Config.LightMode then
        self:OptimizedCleanup()
    end
    
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    local currentTime = tick()
    
    -- Melee/Sword attack rất nhanh
    if ToolTip == "Melee" or ToolTip == "Sword" then
        if currentTime - self.Debounce >= Config.AttackCooldown then
            self.Debounce = currentTime
            self:FastMeleeAttack(Character)
        end
    
    -- Gun attack
    elseif ToolTip == "Gun" then
        if currentTime - self.ShootDebounce >= 0.05 then  -- Tăng tốc bắn súng
            self.ShootDebounce = currentTime
            self:FastGunAttack(Character)
        end
    
    -- Fruit attack
    elseif ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        if currentTime - self.ComboDebounce >= 0.05 then  -- Tăng tốc trái ác quỷ
            self.ComboDebounce = currentTime
            self:FastFruitAttack(Character, Equipped)
        end
    end
end

--// INITIALIZE
local MyAttack = FastAttack.new()

-- Sử dụng RenderStepped để cập nhật nhanh hơn
RunService.RenderStepped:Connect(function(deltaTime)
    MyAttack:OptimizedUpdate()
end)

print("⚡ Fast Attack v2: Tối ưu hóa - Tốc độ cực nhanh + Giảm lag tối đa")
print("⚙️ Cấu hình: Cooldown = " .. Config.AttackCooldown .. "s | Light Mode = " .. tostring(Config.LightMode))
