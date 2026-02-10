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

-- Config (Super Fast)
local Config = {
    AttackDistance = 65,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.18,        -- giảm nhỏ hơn để attack cực nhanh
    ComboResetTime = 0.03,        -- combo reset tức thì
    MaxCombo = math.huge,           -- combo vô hạn
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true,
    BringMonEnabled = true,        -- Thêm option bring mob
    BringDistance = 300,           -- Khoảng cách bring mob
    BringHeight = 5                -- Độ cao khi bring mob
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
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    elseif Stun and Stun.Value > 0 or Busy and Busy.Value then
        return false
    end
    return true
end

-- GetBladeHits tối ưu, chọn HumanoidRootPart luôn
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

function FastAttack:GetClosestEnemy(Character, Distance)
    local BladeHits = self:GetBladeHits(Character, Distance)
    local Closest, MinDistance = nil, math.huge

    for _, Hit in ipairs(BladeHits) do
        local Magnitude = (Character:GetPivot().Position - Hit[2].Position).Magnitude
        if Magnitude < MinDistance then
            MinDistance = Magnitude
            Closest = Hit[2]
        end
    end
    return Closest
end

function FastAttack:GetCombo()
    local Combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    Combo = Combo + 1
    self.ComboDebounce = tick()
    self.M1Combo = Combo
    return Combo
end

-- Shoot tối ưu, gần như liên tục
function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    if not self:IsEntityAlive(Character) then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end

    local Cooldown = 0.0001  -- bỏ cooldown gun, nhanh hơn
    if (tick() - self.ShootDebounce) < Cooldown then return end

    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(self:GetValidator2())

        if ShootType == "TAP" then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
        self.ShootDebounce = tick()
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.0001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        self.ShootDebounce = tick()
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

-- UseNormalClick: loop qua tất cả target để không bỏ ai
function FastAttack:UseNormalClick(Character, Humanoid, Cooldown)
    local BladeHits = self:GetBladeHits(Character)
    for _, Hit in ipairs(BladeHits) do
        local TargetRoot = Hit[2]
        RegisterAttack:FireServer(Cooldown)
        if self.CombatFlags and self.HitFunction then
            self.HitFunction(TargetRoot, BladeHits)
        else
            RegisterHit:FireServer(TargetRoot, BladeHits)
        end
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    if not Targets[1] then return end

    local Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    Equipped.LeftClickRemote:FireServer(Direction, Combo)
end

-- Hàm BringEnemy tích hợp
function FastAttack:BringEnemy()
    if not Config.BringMonEnabled then return end
    
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end
    
    local PosMon = Character:GetPivot().Position
    
    pcall(function()
        sethiddenproperty(Player, "SimulationRadius", math.huge)
    end)

    for _, v in ipairs(workspace.Enemies:GetChildren()) do
        local hum = v:FindFirstChild("Humanoid")
        local hrp = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
        
        if hum and hrp and hum.Health > 0 then
            local dist = (hrp.Position - PosMon).Magnitude
            if dist <= Config.BringDistance and isnetworkowner(hrp) then
                
                -- Apply anti-ghost measures
                for _, part in ipairs(v:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Anchored = false
                        part.Massless = true
                    end
                end
                
                hum.WalkSpeed, hum.JumpPower = 0, 0
                hum.PlatformStand = true
                
                local anim = hum:FindFirstChildOfClass("Animator")
                if anim then anim.Parent = nil end
                
                -- Smooth teleport without dropping to ground
                for i = 1, 3 do
                    if isnetworkowner(hrp) then
                        hrp.CFrame = CFrame.new(PosMon + Vector3.new(0, Config.BringHeight, 0))
                        task.wait(0.05)
                    else
                        break
                    end
                end
            end
        end
    end
end

-- Attack Super Fast, loop qua tất cả target nếu là Gun
function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end

    -- Bring enemy trước khi tấn công
    if Config.BringMonEnabled then
        self:BringEnemy()
    end

    local Humanoid = Character.Humanoid
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end

    local Combo = self:GetCombo()
    self.Debounce = tick()

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        local Targets = self:GetBladeHits(Character, 120)
        for _, t in ipairs(Targets) do
            self:ShootInTarget(t[2].Position)
        end
    else
        self:UseNormalClick(Character, Humanoid, 0.0001)
    end
end

-- Instance
local AttackInstance = FastAttack.new()
table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(function()
    AttackInstance:Attack()
end))

return FastAttack
