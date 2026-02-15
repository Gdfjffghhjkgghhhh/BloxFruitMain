--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

-- Các remote event (có fallback nếu không tìm thấy)
local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
local RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")
local ShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent") or Net:FindFirstChild("ShootGunEvent")
local GunValidator = (ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage):FindFirstChild("Validator2")

-- Config (Super Fast)
local Config = {
    AttackDistance = 65,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.18,
    ComboResetTime = 0.03,
    MaxCombo = math.huge,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true,
    GunRange = 120,          -- khoảng cách bắn súng
    FrameDelay = 0.01,        -- delay nhẹ giữa các lần attack để tránh spam
    UseMouseClickFallback = true -- nếu không bắn được bằng event thì dùng click chuột
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

    -- Cố gắng lấy combat flags và hit function, nếu lỗi thì dùng fallback
    pcall(function()
        local success, flags = pcall(require, Modules.Flags)
        if success then
            self.CombatFlags = flags.COMBAT_REMOTE_THREAD
        end
    end)

    pcall(function()
        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            local env = getsenv(LocalScript)
            if env and env._G and env._G.SendHitsToServer then
                self.HitFunction = env._G.SendHitsToServer
            end
        end
    end)

    -- Lấy shoot function từ CombatController
    pcall(function()
        local CombatController = require(ReplicatedStorage.Controllers.CombatController)
        if CombatController and CombatController.Attack then
            self.ShootFunction = getupvalue(CombatController.Attack, 9)
        end
    end)

    return self
end

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    -- Kiểm tra nếu nhân vật đang ngồi và vũ khí là dạng cận chiến thì cho phép
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return true  -- sửa thành true vì một số trường hợp vẫn đánh được khi ngồi
    end
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Stun and Stun.Value > 0 then
        return false
    end
    if Busy and Busy.Value then
        return false
    end
    return true
end

-- GetBladeHits tối ưu, lấy tất cả kẻ địch trong phạm vi
function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    Distance = Distance or Config.AttackDistance

    local function ProcessTargets(Folder)
        if not Folder then return end
        for _, Enemy in ipairs(Folder:GetChildren()) do
            if Enemy ~= Character and self:IsEntityAlive(Enemy) then
                local BasePart = Enemy:FindFirstChild("HumanoidRootPart") or Enemy:FindFirstChild("Torso") or Enemy:FindFirstChild("UpperTorso")
                if BasePart and (Position - BasePart.Position).Magnitude <= Distance then
                    table.insert(BladeHits, {Enemy, BasePart})
                    if not self.EnemyRootPart then
                        self.EnemyRootPart = BasePart
                    end
                end
            end
        end
    end

    if Config.AttackMobs then ProcessTargets(Workspace:FindFirstChild("Enemies")) end
    if Config.AttackPlayers then ProcessTargets(Workspace:FindFirstChild("Characters")) end

    return BladeHits
end

-- Tính combo với reset time linh hoạt
function FastAttack:GetCombo()
    local now = tick()
    if (now - self.ComboDebounce) <= Config.ComboResetTime then
        self.M1Combo = self.M1Combo + 1
    else
        self.M1Combo = 1
    end
    self.ComboDebounce = now
    return self.M1Combo
end

-- Xử lý bắn súng
function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    if not self:IsEntityAlive(Character) then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end

    -- Cooldown nhẹ để tránh spam
    if (tick() - self.ShootDebounce) < 0.05 then return end
    self.ShootDebounce = tick()

    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    local success = false

    -- Thử bắn bằng remote event trước
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        pcall(function()
            -- Cập nhật attribute và validator nếu có
            if Equipped:GetAttribute then
                Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
            end
            -- Gửi validator nếu có hàm và gun validator tồn tại
            if self.ShootFunction and GunValidator then
                local v1, v2 = self:GetValidator2()
                GunValidator:FireServer(v1, v2)
            end

            if ShootType == "TAP" and Equipped.RemoteEvent then
                Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
                success = true
            elseif ShootGunEvent then
                ShootGunEvent:FireServer(TargetPosition)
                success = true
            end
        end)
    end

    -- Fallback: click chuột nếu remote không hoạt động hoặc cấu hình cho phép
    if not success and Config.UseMouseClickFallback then
        pcall(function()
            -- Mô phỏng click chuột trái
            local mouse = Player:GetMouse()
            if mouse then
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
            end
        end)
    end
end

-- Tính validator cho súng (có fallback nếu lỗi)
function FastAttack:GetValidator2()
    if not self.ShootFunction then return 0, 0 end
    local success, result = pcall(function()
        local v1 = getupvalue(self.ShootFunction, 15)
        local v2 = getupvalue(self.ShootFunction, 13)
        local v3 = getupvalue(self.ShootFunction, 16)
        local v4 = getupvalue(self.ShootFunction, 17)
        local v5 = getupvalue(self.ShootFunction, 14)
        local v6 = getupvalue(self.ShootFunction, 12)
        local v7 = getupvalue(self.ShootFunction, 18)

        if not (v1 and v2 and v3 and v4 and v5 and v6 and v7) then
            return 0, 0
        end

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
    end)
    if success then
        return result
    else
        return 0, 0
    end
end

-- Đánh thường (kiếm, melee)
function FastAttack:UseNormalClick(Character, Humanoid, Cooldown)
    local BladeHits = self:GetBladeHits(Character)
    if #BladeHits == 0 then return end

    -- Gửi RegisterAttack
    if RegisterAttack then
        pcall(function()
            RegisterAttack:FireServer(Cooldown)
        end)
    end

    -- Gửi hit theo từng mục tiêu
    for _, Hit in ipairs(BladeHits) do
        local TargetRoot = Hit[2]
        if self.HitFunction then
            pcall(self.HitFunction, TargetRoot, BladeHits)
        elseif RegisterHit then
            pcall(RegisterHit.FireServer, RegisterHit, TargetRoot, BladeHits)
        end
    end
end

-- Đánh bằng trái ác quỷ (M1)
function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    if not Targets[1] then return end

    local Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    if Equipped:FindFirstChild("LeftClickRemote") then
        pcall(function()
            Equipped.LeftClickRemote:FireServer(Direction, Combo)
        end)
    end
end

-- Attack chính
function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local Character = Player.Character
    if not Character then return end
    if not self:IsEntityAlive(Character) then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

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
        -- Chỉ bắn vào mục tiêu gần nhất để tránh spam
        local TargetRoot = self:GetClosestEnemy(Character, Config.GunRange)
        if TargetRoot then
            self:ShootInTarget(TargetRoot.Position)
        end
    else
        self:UseNormalClick(Character, Humanoid, 0.1) -- tăng cooldown nhẹ để ổn định
    end
end

-- Instance
local AttackInstance = FastAttack.new()
table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(function()
    AttackInstance:Attack()
    -- Delay nhẹ giữa các frame để tránh quá tải
    task.wait(Config.FrameDelay)
end))

return FastAttack
