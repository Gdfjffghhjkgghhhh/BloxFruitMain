--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Tự động cập nhật nhân vật khi chết
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

--// CẤU HÌNH (CONFIG)
local Config = {
    AttackDistance = 60,      -- Phạm vi đánh (Nên để dưới 60 để tránh lỗi)
    SpeedMultiplier = 5,      -- Số lần click trong 1 khung hình (Càng cao càng nhanh, nhưng dễ lag máy. Tầm 5-10 là ổn)
    AutoClick = true,         -- Bật/Tắt
    NoAnimation = true,       -- Xóa animation để đánh nhanh hơn
}

--// Fast Attack Core
local FastAttack = {}

function FastAttack:GetTarget()
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    local Nearest = nil
    local MinDist = Config.AttackDistance

    -- Ưu tiên tìm trong thư mục Enemies trước (nhẹ hơn quét cả workspace)
    local Enemies = Workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, v in pairs(Enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
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

function FastAttack:StopAnims()
    if not Config.NoAnimation then return end
    local Hum = Character:FindFirstChild("Humanoid")
    if not Hum then return end
    
    local Tracks = Hum:GetPlayingAnimationTracks()
    for _, Track in pairs(Tracks) do
        -- Chỉ xóa animation tấn công (Action) để không bị lỗi di chuyển
        if Track.Priority == Enum.AnimationPriority.Action or 
           Track.Priority == Enum.AnimationPriority.Action2 or 
           Track.Priority == Enum.AnimationPriority.Action3 or
           string.find(string.lower(Track.Name), "attack") then
            
            Track:Stop() 
            Track:AdjustSpeed(0) -- Đóng băng animation ngay lập tức
        end
    end
end

function FastAttack:Attack(Target)
    if not Target then return end
    local Root = Target:FindFirstChild("HumanoidRootPart")
    
    -- 1. Click Ảo (An toàn nhất)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- 2. Spam Remote (Cố gắng tìm remote nếu có)
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool then
        -- Kích hoạt remote đánh thường nếu tool có hỗ trợ
        if Tool:FindFirstChild("RemoteEvent") then
            pcall(function() Tool.RemoteEvent:FireServer() end)
        end
    end

    -- 3. Xóa Animation ngay sau khi ra đòn
    self:StopAnims()
end

--// VÒNG LẶP SIÊU TỐC (RenderStepped)
local RunLogic = RunService.RenderStepped:Connect(function()
    if not Config.AutoClick then return end
    
    -- Kiểm tra tool
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then return end -- Không cầm tool thì không đánh

    local Target = FastAttack:GetTarget()
    
    if Target then
        -- Dịch chuyển nhẹ về phía mục tiêu để hitbox chuẩn hơn (tùy chọn)
        -- Character.HumanoidRootPart.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, Target.HumanoidRootPart.Position)

        -- SPAM LOOP: Chạy nhiều lần trong 1 frame
        for i = 1, Config.SpeedMultiplier do
            FastAttack:Attack(Target)
        end
    end
end)

-- Anti-Stun Loop (Chạy song song)
task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoClick then
            pcall(function()
                if Character:FindFirstChild("Stun") then Character.Stun.Value = 0 end
                if Character:FindFirstChild("Busy") then Character.Busy.Value = false end
            end)
        end
    end
end)

-- Giao diện thông báo nhỏ
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "⚡ SUPER FAST ATTACK ⚡";
    Text = "Mode: No Animation | Speed: " .. Config.SpeedMultiplier .. "x";
    Duration = 5;
})
