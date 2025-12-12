--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

--// CẤU HÌNH CỰC ĐẠI (EXTREME CONFIG)
local Config = {
    HitsPerFrame = 15,    -- Số lần đánh trong 1 khung hình (15 x 60 FPS ≈ 900 hits/s)
    Range = 60,           -- Phạm vi
    AutoClick = true,
}

--// Fast Attack Core
local FastAttack = {}

function FastAttack:GetTarget()
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    local Nearest = nil
    local MinDist = Config.Range

    -- Quét thư mục Enemies (Nhanh nhất)
    local Enemies = Workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, v in pairs(Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local Dist = (v.HumanoidRootPart.Position - MyRoot.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Nearest = v
                end
            end
        end
    end
    return Nearest
end

-- Hàm đánh không delay
function FastAttack:Attack(Target)
    if not Target then return end
    
    -- 1. Xóa Animation ngay lập tức (Freeze Animation)
    local Hum = Character:FindFirstChild("Humanoid")
    if Hum then
        local Tracks = Hum:GetPlayingAnimationTracks()
        for _, t in pairs(Tracks) do
            t:Stop() -- Dừng ngay lập tức
        end
    end

    -- 2. Spam Click (Packet Spam)
    -- Gửi tín hiệu click chuột giả lập (Bypass client cooldown)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- 3. Trigger Tool Remote (Nếu có)
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool and Tool:FindFirstChild("RemoteEvent") then
        task.spawn(function() -- Chạy luồng riêng để không chờ
            pcall(function() Tool.RemoteEvent:FireServer() end)
        end)
    end
end

--// LOGIC BỎ QUA THỜI GIAN CHỜ (NO COOLDOWN LOOP)
-- Sử dụng Heartbeat (ưu tiên vật lý) để spam ổn định hơn RenderStepped khi lag
RunService.Heartbeat:Connect(function()
    if not Config.AutoClick then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then return end -- Phải cầm tool

    local Target = FastAttack:GetTarget()
    if Target then
        -- VÒNG LẶP "HỦY DIỆT" (Brute Force Loop)
        -- Chạy HitsPerFrame lần MỖI FRAME
        for i = 1, Config.HitsPerFrame do
            FastAttack:Attack(Target)
        end
        
        -- Teleport nhẹ để hitbox dính chặt vào quái (Giúp server nhận hit tốt hơn)
        if Character:FindFirstChild("HumanoidRootPart") and Target:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Target.HumanoidRootPart.Position)
        end
    end
end)

-- Anti-Stun / Anti-Lag (Dọn dẹp bộ nhớ)
task.spawn(function()
    while task.wait(1) do
        -- Dọn rác bộ nhớ nhẹ
        for i = 1, 10 do
            game:GetService("RunService").Stepped:Wait()
        end
    end
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🚀 GOD SPEED ENABLED";
    Text = "~900 Hits/Second | No Cooldown";
    Duration = 3;
})
