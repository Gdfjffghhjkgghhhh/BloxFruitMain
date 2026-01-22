--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

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
    AttackCooldown = 0.2,    -- Tốc độ đánh
    AutoClickEnabled = true,
    
    -- [MỚI] Cấu hình xóa hiệu ứng
    RemoveEffects = true,     -- Bật/Tắt xóa hiệu ứng
    RemoveDamageText = false,  -- Xóa số damage hiện lên
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
        SpecialShoots = {
            ["Skull Guitar"] = "TAP", 
            ["Bazooka"] = "Position", 
            ["Cannon"] = "Position"
        }
    }, FastAttack)

    task.spawn(function()
        pcall(function()
            self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
        end)
        pcall(function()
            local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
            if LocalScript and getsenv then
                self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
            end
        end)
    end)

    -- [MỚI] Tự động xóa hiệu ứng khi có Object mới sinh ra trong Workspace
    if Config.RemoveEffects then
        Workspace.ChildAdded:Connect(function(child)
            if not Config.Enabled then return end
            -- Xóa các part hiệu ứng rác thường gặp
            if child.Name == "HitEffect" or child.Name == "DamageCounter" or child.Name == "Explosion" then
                task.wait() -- Đợi 1 tick để chắc chắn nó load xong rồi xóa
                child:Destroy()
            end
        end)
    end

    return self
end

function FastAttack:IsEntityAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

function FastAttack:GetTargets(Character, Distance)
    local Position = Character:GetPivot().Position
    local TargetList = {} 
    local HitPartList = {}

    Distance = Distance or Config.AttackDistance

    local function ScanFolder(Folder)
        for _, Enemy in ipairs(Folder:GetChildren()) do
            if Enemy ~= Character and self:IsEntityAlive(Enemy) then
                local HRP = Enemy:FindFirstChild("HumanoidRootPart")
                if HRP and (Position - HRP.Position).Magnitude <= Distance then
                    table.insert(TargetList, {Enemy, HRP})
                    table.insert(HitPartList, HRP)
                end
            end
        end
    end

    if Config.AttackMobs and Workspace:FindFirstChild("Enemies") then
        ScanFolder(Workspace.Enemies)
    end
    if Config.AttackPlayers and Workspace:FindFirstChild("Characters") then
        ScanFolder(Workspace.Characters)
    end

    return TargetList, HitPartList
end

-- [MỚI] Hàm dọn dẹp hiệu ứng (Chạy định kỳ)
function FastAttack:CleanVisuals()
    if not Config.RemoveEffects then return end
    
    -- Chỉ quét mỗi 2 giây một lần để đỡ lag
    if tick() - self.LastCleanTime < 2 then return end
    self.LastCleanTime = tick()

    -- Tắt hiệu ứng Particle trong Workspace (Máu, tia lửa, bụi)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") then
            v.Enabled = false
        end
        -- Xóa chữ Damage nếu bật
        if Config.RemoveDamageText and v.Name == "DamageCounter" then
            v:Destroy()
        end
    end
end

function FastAttack:UseNormalClick(Character, Cooldown)
    local Targets, HitPartList = self:GetTargets(Character)
    if #Targets == 0 then return end

    -- Click ảo để kích hoạt animation (Bắt buộc để Melee hoạt động)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

    RegisterAttack:FireServer(Cooldown)

    for _, Data in ipairs(Targets) do
        local EnemyRoot = Data[2]
        if self.HitFunction then
            pcall(function() self.HitFunction(EnemyRoot, {Data}) end)
        else
            RegisterHit:FireServer(EnemyRoot, HitPartList)
        end
    end
end

function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end
    
    local function GetValidator()
        if not self.ShootFunction then return 0, 1 end
        local v1 = getupvalue(self.ShootFunction, 15); local v2 = getupvalue(self.ShootFunction, 13)
        local v3 = getupvalue(self.ShootFunction, 16); local v4 = getupvalue(self.ShootFunction, 17)
        local v5 = getupvalue(self.ShootFunction, 14); local v6 = getupvalue(self.ShootFunction, 12)
        local v7 = getupvalue(self.ShootFunction, 18)
        local v9 = ((v5 * v2 + v6 * v1) % v3 * v3 + v6 * v2) % v4
        setupvalue(self.ShootFunction, 18, v7 + 1)
        return math.floor(v9 / v4 * 16777215), v7 + 1
    end

    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator2")
        if Remote then Remote:FireServer(GetValidator()) end
        
        if ShootType == "TAP" then Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else ShootGunEvent:FireServer(TargetPosition) end
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

function FastAttack:Update()
    if not Config.Enabled then return end
    
    -- Chạy hàm dọn dẹp hiệu ứng
    self:CleanVisuals()
    
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    
    if ToolTip == "Melee" or ToolTip == "Sword" then
        if tick() - self.Debounce >= Config.AttackCooldown then
            self.Debounce = tick()
            self:UseNormalClick(Character, Config.AttackCooldown)
        end
    elseif ToolTip == "Gun" then
        if tick() - self.ShootDebounce >= 0.1 then
            self.ShootDebounce = tick()
            local Targets = self:GetTargets(Character, 100)
            for _, t in ipairs(Targets) do self:ShootInTarget(t[2].Position) end
        end
    elseif ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        if tick() - self.ComboDebounce >= 0.1 then
            self.ComboDebounce = tick()
            local Targets = self:GetTargets(Character)
            if Targets[1] then
                Equipped.LeftClickRemote:FireServer((Targets[1][2].Position - Character:GetPivot().Position).Unit, 1)
            end
        end
    end
end

--// INITIALIZE
local MyAttack = FastAttack.new()
RunService.Heartbeat:Connect(function()
    MyAttack:Update()
end)

print("Fast Attack: Fixed Melee + No Effects Loaded")
