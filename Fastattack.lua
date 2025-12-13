--// DUAL PACKET FORCE - FIX FRUIT M1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

print("--- HYBRID FIX LOADED ---")

--// CẤU HÌNH
local Config = {
    Distance = 60,
    SpamSpeed = true -- Max tốc độ
}

local function GetTarget()
    local Char = Player.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local Root = Char.HumanoidRootPart
    local Target = nil
    local MinDist = Config.Distance

    -- Quét kẻ địch
    local Enemies = Workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, v in pairs(Enemies:GetChildren()) do
            local H = v:FindFirstChild("Humanoid")
            local R = v:FindFirstChild("HumanoidRootPart")
            if H and R and H.Health > 0 then
                local Dist = (R.Position - Root.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Target = R
                end
            end
        end
    end
    return Target
end

local function Attack()
    local Char = Player.Character
    if not Char then return end
    
    local Equipped = Char:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local TargetRoot = GetTarget()
    if not TargetRoot then return end

    --// PHẦN 1: MELEE DAMAGE (LUÔN GỬI)
    -- Gửi gói tin này để gây damage tay (kể cả khi cầm Fruit)
    task.spawn(function()
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(TargetRoot, {{TargetRoot.Parent, TargetRoot}})
    end)

    --// PHẦN 2: FRUIT M1 (XỬ LÝ KỸ HƠN)
    if Equipped.ToolTip == "Blox Fruit" then
        -- Tìm Remote bắn M1
        local Remote = Equipped:FindFirstChild("LeftClickRemote")
        if Remote then
            task.spawn(function()
                -- TÍNH TOÁN HƯỚNG BẮN (Vector3)
                -- Đây là phần quan trọng nhất để Fruit M1 trúng đích
                local MyPos = Char.HumanoidRootPart.Position
                local EnemyPos = TargetRoot.Position
                local Direction = (EnemyPos - MyPos).Unit -- Vector hướng thẳng vào quái
                
                -- Gửi lệnh bắn (Spam 2 lần cho chắc)
                Remote:FireServer(Direction, 1) 
            end)
        else
            -- Debug: Nếu không tìm thấy Remote (Một số trái revamp đổi tên)
            -- Thử dùng chuột ảo làm phương án dự phòng
             local VirtualInputManager = game:GetService("VirtualInputManager")
             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end
end

--// CHẠY VÒNG LẶP
local Loop
Loop = RunService.Heartbeat:Connect(function()
    pcall(function()
        Attack()
    end)
end)
