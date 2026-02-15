--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- Tìm các remote event linh hoạt
local function findRemote(name)
    local paths = {
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net"),
        ReplicatedStorage:FindFirstChild("Network"),
        ReplicatedStorage
    }
    for _, container in ipairs(paths) do
        if container then
            local remote = container:FindFirstChild(name) or container:FindFirstChild("RE/"..name) or container:FindFirstChild(name:gsub("RE/", ""))
            if remote then return remote end
        end
    end
    return nil
end

local RegisterAttack = findRemote("RegisterAttack")
local RegisterHit = findRemote("RegisterHit")
local ShootGunEvent = findRemote("ShootGunEvent")
local GunValidator = findRemote("Validator2") or findRemote("GunValidator")

-- Config
local Config = {
    AttackDistance = 65,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.18,
    ComboResetTime = 0.03,
    AutoClickEnabled = true,
    GunRange = 120,
    DragonstormRange = 350,
    AimbotEnabled = true,
    UseMouseClickForGuns = true,  -- nếu true, sẽ ưu tiên click chuột thay vì remote (ổn định hơn)
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
    }, FastAttack)

    -- Không cố lấy upvalue nữa, vì dễ lỗi
    return self
end

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character)
    local stun = Character:FindFirstChild("Stun")
    local busy = Character:FindFirstChild("Busy")
    if stun and stun.Value > 0 then return false end
    if busy and busy.Value then return false end
    return true
end

-- Lấy danh sách kẻ địch trong phạm vi
function FastAttack:GetTargets(Character, Distance)
    local position = Character:GetPivot().Position
    local targets = {}
    Distance = Distance or Config.AttackDistance

    local function scan(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            if obj ~= Character and self:IsEntityAlive(obj) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                if root and (position - root.Position).Magnitude <= Distance then
                    table.insert(targets, {obj, root})
                end
            end
        end
    end

    if Config.AttackMobs then scan(Workspace:FindFirstChild("Enemies")) end
    if Config.AttackPlayers then scan(Workspace:FindFirstChild("Characters")) end

    return targets
end

function FastAttack:GetClosestTarget(Character, Distance)
    local targets = self:GetTargets(Character, Distance)
    local closest, minDist = nil, math.huge
    local charPos = Character:GetPivot().Position
    for _, t in ipairs(targets) do
        local dist = (charPos - t[2].Position).Magnitude
        if dist < minDist then
            minDist = dist
            closest = t[2]
        end
    end
    return closest
end

function FastAttack:GetCombo()
    local now = tick()
    if now - self.ComboDebounce <= Config.ComboResetTime then
        self.M1Combo = self.M1Combo + 1
    else
        self.M1Combo = 1
    end
    self.ComboDebounce = now
    return self.M1Combo
end

-- Bắn súng bằng click chuột (ổn định hơn remote)
function FastAttack:ShootWithMouse()
    local mouse = Player:GetMouse()
    if mouse then
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
    end
end

-- Bắn súng bằng remote (nếu có)
function FastAttack:ShootWithRemote(targetPos, equipped)
    if not targetPos then return false end
    local success = false
    local shootType = equipped and equipped.Name == "Dragonstorm" and "Overheat" or "Normal"

    -- Xử lý overheat Dragonstorm
    if equipped and equipped.Name == "Dragonstorm" then
        local oh = self.Overheat.Dragonstorm
        if oh.Shooting and oh.TotalOverheat >= oh.MaxOverheat then
            return false  -- quá tải, không bắn
        end
    end

    -- Thử bắn bằng remote
    if ShootGunEvent then
        pcall(function()
            ShootGunEvent:FireServer(targetPos)
            success = true
        end)
    end

    -- Nếu có remote đặc biệt cho TAP (Skull Guitar)
    if not success and equipped and equipped:FindFirstChild("RemoteEvent") then
        pcall(function()
            equipped.RemoteEvent:FireServer("TAP", targetPos)
            success = true
        end)
    end

    -- Gửi validator nếu có
    if GunValidator and success then
        pcall(function()
            GunValidator:FireServer(0, 0)  -- gửi giá trị mặc định, không cần upvalue
        end)
    end

    -- Cập nhật overheat Dragonstorm
    if equipped and equipped.Name == "Dragonstorm" and success then
        local oh = self.Overheat.Dragonstorm
        oh.Shooting = true
        oh.TotalOverheat = oh.TotalOverheat + 1
        task.delay(2, function()
            oh.Shooting = false
            oh.TotalOverheat = 0
        end)
    end

    return success
end

-- Tấn công bằng súng (aimbot)
function FastAttack:AttackWithGun(equipped)
    if not equipped then return end

    -- Xác định khoảng cách theo loại súng
    local range = (equipped.Name == "Dragonstorm" and Config.DragonstormRange) or Config.GunRange
    local targetRoot = self:GetClosestTarget(Player.Character, range)
    if not targetRoot then return end

    -- Chống spam
    if tick() - self.ShootDebounce < 0.1 then return end
    self.ShootDebounce = tick()

    if Config.UseMouseClickForGuns then
        -- Dùng click chuột (aimbot tự động xoay camera? Không, nhưng game sẽ tự nhắm nếu đang nhìn hướng đó)
        -- Để đảm bảo, ta có thể xoay camera về phía mục tiêu (tùy chọn)
        self:ShootWithMouse()
    else
        -- Dùng remote
        self:ShootWithRemote(targetRoot.Position, equipped)
    end
end

-- Tấn công cận chiến (kiếm, melee, trái ác quỷ)
function FastAttack:AttackMelee(character, equipped, toolTip)
    local targets = self:GetTargets(character)
    if #targets == 0 then return end

    local combo = self:GetCombo()

    if toolTip == "Blox Fruit" and equipped and equipped:FindFirstChild("LeftClickRemote") then
        -- Trái ác quỷ M1
        local dir = (targets[1][2].Position - character:GetPivot().Position).Unit
        pcall(function()
            equipped.LeftClickRemote:FireServer(dir, combo)
        end)
    else
        -- Kiếm / melee
        if RegisterAttack then
            pcall(function()
                RegisterAttack:FireServer(0.1)  -- cooldown nhẹ
            end)
        end
        for _, t in ipairs(targets) do
            if RegisterHit then
                pcall(function()
                    RegisterHit:FireServer(t[2], targets)  -- gửi toàn bộ targets để game xử lý multi-hit
                end)
            end
        end
    end
end

-- Vòng lặp chính
function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local character = Player.Character
    if not character then return end
    if not self:IsEntityAlive(character) then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    if not self:CheckStun(character) then return end

    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped then return end

    local toolTip = equipped.ToolTip
    if not toolTip then return end

    if toolTip == "Gun" then
        self:AttackWithGun(equipped)
    elseif table.find({"Melee", "Sword", "Blox Fruit"}, toolTip) then
        self:AttackMelee(character, equipped, toolTip)
    end
end

-- Khởi chạy
local AttackInstance = FastAttack.new()
table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(function()
    local success, err = pcall(function()
        AttackInstance:Attack()
    end)
    if not success then
        warn("FastAttack error:", err)  -- in lỗi ra console để biết nguyên nhân
    end
    task.wait(0.01)  -- giảm tải
end))

return FastAttack
