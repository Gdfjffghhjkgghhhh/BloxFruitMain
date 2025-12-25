--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = Workspace.CurrentCamera

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

--// Config (Tối ưu hóa)
local Config = {
    AttackDistance = 60,       -- Khoảng cách vừa đủ để không bị lỗi
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.05,     -- Tăng nhẹ delay để giảm lag CPU (Vẫn rất nhanh)
    GunSpamSpeed = 0.01,       -- Tốc độ spam súng
    AutoClickEnabled = false
}

--// FastAttack Class
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        GunDebounce = 0,
        M1Combo = 0,
        CurrentTarget = nil,       -- Cache mục tiêu hiện tại
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

-- Hàm tìm mục tiêu tối ưu (Chỉ tìm khi cần thiết)
function FastAttack:GetBestTarget(Character)
    -- Nếu mục tiêu cũ vẫn còn sống và ở gần -> Dùng tiếp (Không quét lại -> Giảm Lag)
    if self.CurrentTarget and self.CurrentTarget.Parent and self:IsEntityAlive(self.CurrentTarget.Parent) then
        local Dist = (Character:GetPivot().Position - self.CurrentTarget.Position).Magnitude
        if Dist <= Config.AttackDistance then
            return self.CurrentTarget
        end
    end

    -- Nếu không có mục tiêu, bắt đầu quét mới
    self.CurrentTarget = nil
    local Closest, MinDist = nil, Config.AttackDistance
    local MyPos = Character:GetPivot().Position

    local function CheckFolder(Folder)
        for _, v in ipairs(Folder:GetChildren()) do
            if v ~= Character and self:IsEntityAlive(v) then
                local Root = v:FindFirstChild("HumanoidRootPart")
                if Root then
                    local Dist = (MyPos - Root.Position).Magnitude
                    if Dist < MinDist then
                        MinDist = Dist
                        Closest = Root
                    end
                end
            end
        end
    end

    if Config.AttackMobs then CheckFolder(Workspace.Enemies) end
    if Config.AttackPlayers then CheckFolder(Workspace.Characters) end

    self.CurrentTarget = Closest -- Lưu lại mục tiêu mới
    return Closest
end

-- Lấy danh sách hit cho Melee (Đánh lan)
function FastAttack:GetBladeHits(Character)
    local BladeHits = {}
    local MyPos = Character:GetPivot().Position
    
    -- Chỉ quét xung quanh mục tiêu chính để giảm lag
    local MainTarget = self:GetBestTarget(Character)
    if not MainTarget then return {} end

    -- Thêm mục tiêu chính vào trước
    table.insert(BladeHits, {MainTarget.Parent, MainTarget})

    -- Quét nhẹ các con lân cận (nếu muốn đánh lan)
    -- Bỏ qua bước này nếu máy quá yếu
    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
        if v ~= MainTarget.Parent and self:IsEntityAlive(v) then
             local Root = v:FindFirstChild("HumanoidRootPart")
             if Root and (Root.Position - MyPos).Magnitude < Config.AttackDistance then
                 table.insert(BladeHits, {v, Root})
             end
        end
    end
    
    return BladeHits
end

function FastAttack:GetCombo()
    self.M1Combo = self.M1Combo + 1
    return self.M1Combo
end

--// LOGIC SÚNG MỚI (Hỗ trợ click Mob)
function FastAttack:ShootGun(Character, Equipped)
    if (tick() - self.GunDebounce) < Config.GunSpamSpeed then return end
    self.GunDebounce = tick()

    local TargetRoot = self:GetBestTarget(Character)
    if not TargetRoot then return end

    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"

    -- Logic 1: Dùng Remote (Cho súng xịn)
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(self:GetValidator2())
        
        if ShootType == "TAP" then
            Equipped.RemoteEvent:FireServer("TAP", TargetRoot.Position)
        else
            ShootGunEvent:FireServer(TargetRoot.Position)
        end
    else
        -- Logic 2: Click chuột ảo (Cho súng thường/Mob)
        -- Tự động aim camera vào quái để click trúng
        local Pos, OnScreen = Camera:WorldToViewportPoint(TargetRoot.Position)
        
        if OnScreen then
            VirtualInputManager:SendMouseButtonEvent(Pos.X, Pos.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(Pos.X, Pos.Y, 0, false, game, 1)
        else
            -- Nếu quái không ở trong màn hình, bắn đại (vẫn trúng nhờ hitbox game)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end
end

function FastAttack:GetValidator2()
    -- Giữ nguyên logic bypass
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

function FastAttack:UseNormalClick(Character)
    local BladeHits = self:GetBladeHits(Character)
    if #BladeHits > 0 then
        RegisterAttack:FireServer(Config.AttackCooldown)
        if self.CombatFlags and self.HitFunction then
            self.HitFunction(BladeHits[1][2], BladeHits)
        else
            RegisterHit:FireServer(BladeHits[1][2], BladeHits)
        end
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local TargetRoot = self:GetBestTarget(Character)
    if not TargetRoot then return end

    local Direction = (TargetRoot.Position - Character:GetPivot().Position).Unit
    Equipped.LeftClickRemote:FireServer(Direction, Combo)
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    -- Bypass Stun đơn giản
    local Humanoid = Character.Humanoid
    if Humanoid.Sit then return end -- Chỉ check ngồi để tránh lỗi script, bỏ check stun

    local Combo = self:GetCombo()

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        self:ShootGun(Character, Equipped)
    elseif table.find({"Melee", "Sword"}, ToolTip) then
        self:UseNormalClick(Character)
    end
end

-- Instance & Loop
local AttackInstance = FastAttack.new()

-- Dùng Loop task.spawn + wait thay vì Heartbeat để kiểm soát tốc độ & giảm lag CPU
task.spawn(function()
    while true do
        local success, err = pcall(function()
            AttackInstance:Attack()
        end)
        if not success then warn(err) end
        
        -- Nếu dùng Gun thì delay ít hơn, Melee thì delay theo config
        -- Điều chỉnh delay ở đây giúp máy yếu không bị crash
        task.wait(Config.AttackCooldown) 
    end
end)

return FastAttack
