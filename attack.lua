--// Services
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

-- Config (Super Fast / God Mode)
local Config = {
    AttackDistance = 70,       -- Tăng nhẹ khoảng cách để bắt mục tiêu sớm hơn
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0,        -- 0 delay
    ComboResetTime = 0,        -- Reset combo ngay lập tức
    MaxCombo = math.huge,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true,
    FruitBurst = 3             -- Số lần gửi tín hiệu Fruit M1 trong 1 khung hình (Tăng tốc độ Fruit)
}

--// FastAttack Class
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        EnemyRootPart = nil,
        Connections = {},
        Overheat = {Dragonstorm = {MaxOverheat = 3, Cooldown = 0, TotalOverheat = 0, Distance = 350, Shooting = false}},
        ShootsPerTarget = {["Dual Flintlock"] = 2},
        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
    }, FastAttack)

    pcall(function()
        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
        self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
        end
    end)

    return self
end

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    
    -- Bỏ qua check stun nếu muốn đánh bất chấp (rủi ro kick nhưng nhanh hơn)
    -- Nếu muốn an toàn thì giữ nguyên logic cũ bên dưới:
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    elseif Stun and Stun.Value > 0 or Busy and Busy.Value then
        return false
    end
    return true
end

function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    Distance = Distance or Config.AttackDistance

    local function ProcessTargets(Folder)
        for _, Enemy in ipairs(Folder:GetChildren()) do
            if Enemy ~= Character and self:IsEntityAlive(Enemy) then
                local BasePart = Enemy:FindFirstChild("HumanoidRootPart")
                if BasePart and (Position - BasePart.Position).Magnitude <= Distance then
                    table.insert(BladeHits, {Enemy, BasePart})
                    if not self.EnemyRootPart then
                        self.EnemyRootPart = BasePart
                    end
                end
            end
        end
    end

    if Config.AttackMobs then ProcessTargets(Workspace.Enemies) end
    if Config.AttackPlayers then ProcessTargets(Workspace.Characters) end

    return BladeHits
end

-- Hàm lấy mục tiêu gần nhất tối ưu cho Fruit M1
function FastAttack:GetClosestTargetForFruit(Character)
    local Position = Character:GetPivot().Position
    local ClosestPart = nil
    local MinDist = Config.AttackDistance

    local function Check(Folder)
        for _, v in pairs(Folder:GetChildren()) do
            if v ~= Character and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local Root = v:FindFirstChild("HumanoidRootPart")
                if Root then
                    local Dist = (Root.Position - Position).Magnitude
                    if Dist < MinDist then
                        MinDist = Dist
                        ClosestPart = Root
                    end
                end
            end
        end
    end
    
    if Config.AttackMobs then Check(Workspace.Enemies) end
    if Config.AttackPlayers then Check(Workspace.Characters) end
    
    return ClosestPart
end

function FastAttack:GetCombo()
    local Combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    Combo = Combo + 1
    self.ComboDebounce = tick()
    self.M1Combo = Combo
    return Combo
end

function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    if not self:IsEntityAlive(Character) then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end

    -- Spam Gun cực nhanh (No cooldown)
    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(self:GetValidator2())

        if ShootType == "TAP" then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
    else
        -- Virtual Click spam
        task.spawn(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

function FastAttack:GetValidator2()
    local v1 = getupvalue(self.ShootFunction, 15)
    local v2 = getupvalue(self.ShootFunction, 13)
    local v3 = getupvalue(self.ShootFunction, 16)
    local v4 = getupvalue(self.ShootFunction, 17)
    local v5 = getupvalue(self.ShootFunction, 14)
    local v6 = getupvalue(self.ShootFunction, 12)
    local v7 = getupvalue(self.ShootFunction, 18)

    local v8 = v6 * v2
    local v9 = (v5 * v2 + v6 * v1) % v3
    v9 = (v9 * v3 + v8) % v4
    v5 = math.floor(v9 / v3)
    v6 = v9 - v5 * v3
    v7 = v7 + 1

    setupvalue(self.ShootFunction, 15, v1)
    setupvalue(self.ShootFunction, 13, v2)
    setupvalue(self.ShootFunction, 16, v3)
    setupvalue(self.ShootFunction, 17, v4)
    setupvalue(self.ShootFunction, 14, v5)
    setupvalue(self.ShootFunction, 12, v6)
    setupvalue(self.ShootFunction, 18, v7)

    return math.floor(v9 / v4 * 16777215), v7
end

function FastAttack:UseNormalClick(Character, Humanoid)
    local BladeHits = self:GetBladeHits(Character)
    -- Dùng spawn để không bị wait
    task.spawn(function()
        for _, Hit in ipairs(BladeHits) do
            local TargetRoot = Hit[2]
            RegisterAttack:FireServer(Config.AttackCooldown)
            if self.CombatFlags and self.HitFunction then
                self.HitFunction(TargetRoot, BladeHits)
            else
                RegisterHit:FireServer(TargetRoot, BladeHits)
            end
        end
    end)
end

--// NÂNG CẤP: Fruit M1 Super Fast
function FastAttack:UseFruitM1(Character, Equipped, Combo)
    -- Dùng hàm tìm mục tiêu riêng để nhanh hơn, không load cả list
    local TargetRoot = self:GetClosestTargetForFruit(Character)
    if not TargetRoot then return end

    local Direction = (TargetRoot.Position - Character:GetPivot().Position).Unit
    
    -- Sử dụng task.spawn để spam tín hiệu (Burst Mode)
    task.spawn(function()
        for i = 1, Config.FruitBurst do
            if Equipped.Parent == Character then
                Equipped.LeftClickRemote:FireServer(Direction, Combo)
            end
        end
    end)
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end

    local Humanoid = Character.Humanoid
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end

    local Combo = self:GetCombo()
    
    -- Logic chia luồng để tối ưu tốc độ
    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        local Targets = self:GetBladeHits(Character, 120)
        for _, t in ipairs(Targets) do
            self:ShootInTarget(t[2].Position)
        end
    else
        self:UseNormalClick(Character, Humanoid)
    end
end

-- Instance
local AttackInstance = FastAttack.new()

-- Chạy vòng lặp tấn công
-- Sử dụng task.spawn wrap vòng lặp để đảm bảo ưu tiên luồng
task.spawn(function()
    while true do
        local success, err = pcall(function()
            AttackInstance:Attack()
        end)
        if not success then warn("Attack Error:", err) end
        
        -- Tốc độ loop siêu nhanh (nhanh hơn Heartbeat nếu máy mạnh)
        task.wait() 
    end
end)

return FastAttack
