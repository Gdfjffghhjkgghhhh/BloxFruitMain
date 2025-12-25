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

-- Config (INSANE MODE)
local Config = {
    AttackDistance = 80,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0,
    ComboResetTime = 0,
    MaxCombo = math.huge,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true,
    FruitBurst = 20,           -- Tăng lên 20 lần spam mỗi nhịp (Cực nhanh)
    ThreadCount = 3            -- Số luồng chạy song song (Tăng tốc độ xử lý)
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

-- Tắt check stun để đánh xuyên hiệu ứng (Nhanh hơn nhưng dễ lỗi animation)
function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    return true 
end

function FastAttack:GetClosestTargetForFruit(Character)
    local Position = Character:GetPivot().Position
    local ClosestPart = nil
    local MinDist = Config.AttackDistance

    -- Quét nhanh mob
    if Config.AttackMobs then
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local Root = v:FindFirstChild("HumanoidRootPart")
                if Root and (Root.Position - Position).Magnitude < MinDist then
                    MinDist = (Root.Position - Position).Magnitude
                    ClosestPart = Root
                end
            end
        end
    end
    -- Quét nhanh player
    if Config.AttackPlayers then
        for _, v in pairs(Workspace.Characters:GetChildren()) do
            if v ~= Character and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local Root = v:FindFirstChild("HumanoidRootPart")
                if Root and (Root.Position - Position).Magnitude < MinDist then
                    MinDist = (Root.Position - Position).Magnitude
                    ClosestPart = Root
                end
            end
        end
    end
    
    return ClosestPart
end

function FastAttack:GetCombo()
    local Combo = self.M1Combo
    self.M1Combo = self.M1Combo + 1
    return Combo
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
    local BladeHits = {} 
    -- Logic get targets tối giản cho Melee/Sword để giảm lag khi spam
    local P = Character:GetPivot().Position
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
         if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - P).Magnitude < Config.AttackDistance then
             table.insert(BladeHits, {v, v.HumanoidRootPart})
         end
    end

    if #BladeHits > 0 then
        RegisterAttack:FireServer(Config.AttackCooldown)
        if self.CombatFlags and self.HitFunction then
            self.HitFunction(BladeHits[1][2], BladeHits)
        else
            RegisterHit:FireServer(BladeHits[1][2], BladeHits)
        end
    end
end

--// INSANE FRUIT SPAM
function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local TargetRoot = self:GetClosestTargetForFruit(Character)
    if not TargetRoot then return end

    local Direction = (TargetRoot.Position - Character:GetPivot().Position).Unit
    
    -- Spam thẳng không qua task.spawn để ép thực thi ngay lập tức
    for i = 1, Config.FruitBurst do
        Equipped.LeftClickRemote:FireServer(Direction, Combo)
    end
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("Humanoid") then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    local Combo = self:GetCombo()
    
    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Melee" or ToolTip == "Sword" then
        self:UseNormalClick(Character, Character.Humanoid)
    end
end

-- Instance
local AttackInstance = FastAttack.new()

--// MULTI-THREAD EXECUTION (Chạy 3 luồng cùng lúc)

-- Luồng 1: RenderStepped (Siêu nhanh, theo FPS)
RunService.RenderStepped:Connect(function()
    pcall(function() AttackInstance:Attack() end)
end)

-- Luồng 2: Heartbeat (Theo Physics engine)
RunService.Heartbeat:Connect(function()
    pcall(function() AttackInstance:Attack() end)
end)

-- Luồng 3: Vòng lặp Spam cưỡng bức
task.spawn(function()
    while true do
        pcall(function() AttackInstance:Attack() end)
        task.wait() -- Không delay, chạy hết công suất CPU cho phép
    end
end)

return FastAttack
