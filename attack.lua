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

--// Cấu hình siêu tốc (có thể chỉnh)
local Config = {
    AttackDistance = 70,          -- tăng lên 70
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.01,        -- cực nhanh
    ComboResetTime = 0.15,        -- giữ combo 0.15s để tăng dame
    MaxCombo = math.huge,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true,
    GunRange = 150,               -- bắn súng xa hơn
    CacheUpdateInterval = 0.2,    -- refresh enemy list 5 lần/giây
    MaxTargetsPerTick = 2,        -- chỉ attack 2 mục tiêu gần nhất mỗi lần (tránh lag)
}

--// FastAttack Class (v2 - 10/10)
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        LastAttackTime = 0,
        ComboStartTime = 0,
        CurrentCombo = 0,
        ShootDebounce = 0,
        EnemyCache = {Mobs = {}, Players = {}},
        CacheTime = 0,
        OverheatData = {Dragonstorm = {value = 0, max = 3, lastShot = 0, cooldown = 1.5}},
        Connections = {},
    }, FastAttack)

    -- Lấy các hàm cần thiết (bảo vệ bằng pcall)
    pcall(function()
        local CombatFlags = require(Modules.Flags)
        self.CombatFlags = CombatFlags.COMBAT_REMOTE_THREAD
        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
        end
        self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
    end)

    return self
end

-- Kiểm tra entity còn sống
function FastAttack:IsAlive(character)
    local humanoid = character and character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Kiểm tra stun/busy
function FastAttack:CanAct(character, humanoid, toolTip)
    if humanoid.Sit and (toolTip == "Sword" or toolTip == "Melee" or toolTip == "Blox Fruit") then
        return false
    end
    local stun = character:FindFirstChild("Stun")
    local busy = character:FindFirstChild("Busy")
    if (stun and stun.Value > 0) or (busy and busy.Value) then
        return false
    end
    return true
end

-- Cập nhật cache enemy (chạy định kỳ)
function FastAttack:UpdateEnemyCache()
    local now = tick()
    if now - self.CacheTime < Config.CacheUpdateInterval then return end
    self.CacheTime = now
    self.EnemyCache.Mobs = {}
    self.EnemyCache.Players = {}

    local charPos = Player.Character and Player.Character:GetPivot().Position or Vector3.zero

    if Config.AttackMobs then
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            if enemy ~= Player.Character and self:IsAlive(enemy) then
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (charPos - hrp.Position).Magnitude
                    table.insert(self.EnemyCache.Mobs, {enemy, hrp, dist})
                end
            end
        end
        table.sort(self.EnemyCache.Mobs, function(a,b) return a[3] < b[3] end)
    end

    if Config.AttackPlayers then
        for _, enemy in ipairs(Workspace.Characters:GetChildren()) do
            if enemy ~= Player.Character and self:IsAlive(enemy) then
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (charPos - hrp.Position).Magnitude
                    table.insert(self.EnemyCache.Players, {enemy, hrp, dist})
                end
            end
        end
        table.sort(self.EnemyCache.Players, function(a,b) return a[3] < b[3] end)
    end
end

-- Lấy danh sách target gần nhất (tối đa MaxTargetsPerTick)
function FastAttack:GetNearestTargets(character, maxDist)
    self:UpdateEnemyCache()
    local targets = {}
    local maxTargets = Config.MaxTargetsPerTick

    for _, list in ipairs({self.EnemyCache.Mobs, self.EnemyCache.Players}) do
        for i = 1, math.min(#list, maxTargets - #targets) do
            if list[i][3] <= maxDist then
                table.insert(targets, list[i])
            end
        end
        if #targets >= maxTargets then break end
    end
    return targets
end

-- Xử lý combo (giữ combo thực tế)
function FastAttack:UpdateCombo()
    local now = tick()
    if now - self.ComboStartTime > Config.ComboResetTime then
        self.CurrentCombo = 0
    end
    self.CurrentCombo = self.CurrentCombo + 1
    self.ComboStartTime = now
    return self.CurrentCombo
end

-- Bắn súng thông minh (hỗ trợ các loại đặc biệt)
function FastAttack:Shoot(targetPos)
    local char = Player.Character
    if not char or not self:IsAlive(char) then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.ToolTip ~= "Gun" then return end

    local now = tick()
    if now - self.ShootDebounce < 0.008 then return end  -- cooldown bắn cực nhỏ

    local gunName = tool.Name
    -- Xử lý Dragonstorm overheat
    if gunName == "Dragonstorm" then
        local data = self.OverheatData.Dragonstorm
        if now - data.lastShot < data.cooldown then
            data.value = math.max(0, data.value - 1)
        end
        if data.value >= data.max then
            return  -- quá nhiệt, chờ nguội
        end
        data.value = data.value + 1
        data.lastShot = now
    end

    -- Gửi remote bắn phù hợp
    local success = pcall(function()
        if gunName == "Bazooka" or gunName == "Cannon" then
            ShootGunEvent:FireServer(targetPos)
        elseif gunName == "Skull Guitar" and tool:FindFirstChild("RemoteEvent") then
            tool.RemoteEvent:FireServer("TAP", targetPos)
        elseif gunName == "Dual Flintlock" then
            -- bắn 2 phát liên tiếp
            for _ = 1, 2 do
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                task.wait(0.001)
                VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                task.wait(0.001)
            end
        else
            -- Gun thường
            if self.ShootFunction then
                local v1, v2 = self:GetValidator2()
                GunValidator:FireServer(v1, v2)
            end
            ShootGunEvent:FireServer(targetPos)
        end
    end)
    if success then
        self.ShootDebounce = now
    end
end

-- Hàm validator cho gun (giữ nguyên logic cũ)
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

-- Tấn công cận chiến (M1)
function FastAttack:MeleeAttack(targetRoot)
    pcall(function()
        RegisterAttack:FireServer(0.0001)
        if self.CombatFlags and self.HitFunction then
            self.HitFunction(targetRoot, {})
        else
            RegisterHit:FireServer(targetRoot, {})
        end
    end)
end

-- Tấn công fruit
function FastAttack:FruitAttack(tool, targetPos, combo)
    pcall(function()
        local direction = (targetPos - Player.Character:GetPivot().Position).Unit
        tool.LeftClickRemote:FireServer(direction, combo)
    end)
end

-- Hàm chính tấn công (gọi mỗi frame)
function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local char = Player.Character
    if not char or not self:IsAlive(char) then return end

    local now = tick()
    if now - self.LastAttackTime < Config.AttackCooldown then return end

    local humanoid = char.Humanoid
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local toolTip = tool.ToolTip
    if not table.find({"Melee","Blox Fruit","Sword","Gun"}, toolTip) then return end
    if not self:CanAct(char, humanoid, toolTip) then return end

    -- Xác định khoảng cách tấn công dựa trên loại vũ khí
    local maxDist = (toolTip == "Gun") and Config.GunRange or Config.AttackDistance
    local targets = self:GetNearestTargets(char, maxDist)
    if #targets == 0 then return end

    self.LastAttackTime = now
    local combo = self:UpdateCombo()

    if toolTip == "Gun" then
        -- Bắn vào tất cả target (tối đa MaxTargetsPerTick)
        for _, t in ipairs(targets) do
            self:Shoot(t[2].Position)
        end
    elseif toolTip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        -- Fruit: tấn công target gần nhất
        local nearest = targets[1]
        self:FruitAttack(tool, nearest[2].Position, combo)
    else
        -- Melee / Sword: tấn công từng target
        for _, t in ipairs(targets) do
            self:MeleeAttack(t[2])
        end
    end
end

-- Khởi tạo và chạy (dùng RenderStepped để tốc độ tối đa)
local AttackInstance = FastAttack.new()
table.insert(AttackInstance.Connections, RunService.RenderStepped:Connect(function()
    AttackInstance:Attack()
end))

-- In thông báo
warn("✅ FastAttack v2 (10/10) đã kích hoạt - tốc độ tối đa!")
return FastAttack
