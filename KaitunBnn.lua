--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Cập nhật Character khi chết
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

--// Config
local Config = {
    Distance = 55,          -- Khoảng cách đánh
    ClickSpeed = 0,         -- Tốc độ click (0 = Max)
    AutoClick = true,       -- Bật/Tắt
    AttackPlayers = true,   -- Đánh người chơi
    AttackMobs = true,      -- Đánh quái
    BypassStun = true,      -- Cố gắng xóa Stun
}

--// Core Fast Attack
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({}, FastAttack)
    self.Running = false
    self.Target = nil
    return self
end

-- Hàm kiểm tra mục tiêu sống
function FastAttack:IsAlive(model)
    if not model then return false end
    local hum = model:FindFirstChild("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    return hum and root and hum.Health > 0
end

-- Tìm mục tiêu gần nhất
function FastAttack:GetTarget()
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end
    
    local Nearest = nil
    local MinDist = Config.Distance

    local function CheckFolder(Folder)
        if not Folder then return end
        for _, v in pairs(Folder:GetChildren()) do
            if v ~= Character and self:IsAlive(v) then
                local EnemyRoot = v.HumanoidRootPart
                local Dist = (EnemyRoot.Position - MyRoot.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Nearest = v
                end
            end
        end
    end

    if Config.AttackMobs then CheckFolder(Workspace:FindFirstChild("Enemies")) end
    if Config.AttackPlayers then CheckFolder(Workspace:FindFirstChild("Characters")) end
    
    return Nearest
end

-- Hàm tấn công chính
function FastAttack:Attack(Target)
    if not Target then return end
    
    local Root = Target:FindFirstChild("HumanoidRootPart")
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    
    if not Root or not MyRoot then return end

    -- 1. Virtual Input (Giả lập click chuột - An toàn nhất)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

    -- 2. Xử lý Remote Blox Fruit (Nếu có)
    -- Tìm tool đang cầm
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool and Tool:FindFirstChild("RemoteEvent") then
        -- Thử spam remote đánh thường (thường dùng cho Gun/Melee)
        pcall(function()
            Tool.RemoteEvent:FireServer()
        end)
    end
    
    -- 3. Cố gắng trigger Blade Hit (Dành cho Melee/Sword)
    -- Đoạn này dùng logic đơn giản để tránh lỗi update
    local Combat = ReplicatedStorage:FindFirstChild("Modules") 
        and ReplicatedStorage.Modules:FindFirstChild("Net")
    
    if Combat then
        -- Cố gắng tìm remote RegisterHit một cách an toàn
        local attemptHit = Combat:FindFirstChild("RE/RegisterHit") or Combat:FindFirstChild("RegisterHit")
        if attemptHit then
             pcall(function()
                attemptHit:FireServer(Root, { {Target, Root} })
             end)
        end
    end
    
    -- Hủy hoạt ảnh đánh để spam nhanh hơn
    local Hum = Character:FindFirstChild("Humanoid")
    if Hum then
        for _, track in pairs(Hum:GetPlayingAnimationTracks()) do
            -- Chỉ dừng animation hành động
            if track.Priority == Enum.AnimationPriority.Action then
                track:Stop()
            end
        end
    end
end

--// Main Loop
local AC = FastAttack.new()

-- Luồng chạy siêu nhanh
task.spawn(function()
    while task.wait(Config.ClickSpeed) do
        if Config.AutoClick then
            local Target = AC:GetTarget()
            if Target then
                AC:Attack(Target)
            end
        end
    end
end)

-- Luồng Heartbeat để giữ kết nối ổn định
RunService.Heartbeat:Connect(function()
    if Config.AutoClick and Config.BypassStun then
        -- Xóa stun đơn giản nếu bị dính
        if Character:FindFirstChild("Stun") then
            Character.Stun.Value = 0
        end
        if Character:FindFirstChild("Busy") then
            Character.Busy.Value = false
        end
    end
end)

print("Fast Attack Loaded - Universal Mode")
return AC
