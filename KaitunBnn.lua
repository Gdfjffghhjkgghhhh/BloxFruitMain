--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

--// Blox Fruits Specific Modules (Trái tim của Fast Attack)
local CombatFramework, CameraShaker
local success, err = pcall(function()
    local PlayerScripts = Player:WaitForChild("PlayerScripts")
    CombatFramework = require(PlayerScripts:WaitForChild("CombatFramework"))
    CameraShaker = require(ReplicatedStorage.Util.CameraShaker)
end)

if not success then
    warn("Không tìm thấy Module Blox Fruits, script có thể không hoạt động tối đa: " .. err)
end

--// Config
local Config = {
    Distance = 60,          -- Khoảng cách tối đa để bắt đầu đánh
    AttackMobs = true,      -- Chỉ tập trung đánh quái
    AttackPlayers = false,  -- Tắt đánh người để tối ưu cho Farm
}

--// Variables
local CurrentTarget = nil

-- Cập nhật Character khi respawn
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

--// Core Fast Attack
local FastAttack = {}

function FastAttack:IsAlive(model)
    if not model then return false end
    local hum = model:FindFirstChild("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    return hum and root and hum.Health > 0
end

-- Tối ưu tìm mục tiêu (Dùng caching để đỡ lag)
function FastAttack:GetTarget()
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    -- Nếu mục tiêu cũ còn sống và ở gần, giữ nguyên mục tiêu (Đỡ phải tìm lại)
    if CurrentTarget and self:IsAlive(CurrentTarget) then
        local Dist = (CurrentTarget.HumanoidRootPart.Position - MyRoot.Position).Magnitude
        if Dist < Config.Distance then
            return CurrentTarget
        end
    end

    local Nearest = nil
    local MinDist = Config.Distance

    -- Chỉ quét thư mục Enemies để tối ưu tốc độ farm
    local EnemiesFolder = Workspace:FindFirstChild("Enemies")
    if EnemiesFolder then
        for _, v in pairs(EnemiesFolder:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local Dist = (v.HumanoidRootPart.Position - MyRoot.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Nearest = v
                end
            end
        end
    end
    
    CurrentTarget = Nearest
    return Nearest
end

--// Logic Tấn Công Siêu Nhanh (CombatFramework Hook)
function FastAttack:Attack(Target)
    if not CombatFramework then return end -- Fallback nếu không load được module
    
    local Root = Target:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    -- 1. Hook vào Controller của game để chỉnh Cooldown
    local activeController = CombatFramework.activeController
    
    if activeController and activeController.equipped then
        -- Ép hồi chiêu về 0
        activeController.timeToNextAttack = 0
        activeController.hitboxMagnitude = 60 -- Tăng tầm đánh ảo
        
        -- Gọi hàm tấn công của game
        activeController:attack()
        
        -- 2. Tắt rung màn hình để đỡ chóng mặt và tăng FPS
        if CameraShaker then
            CameraShaker:Stop()
        end
    end

    -- 3. Spam Remote BladeHit (Bổ trợ sát thương)
    -- Logic này gửi tín hiệu trúng đòn trực tiếp tới server
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool and Tool:FindFirstChild("RemoteEvent") then
        task.spawn(function()
            pcall(function()
                -- Giả lập hit
                ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(Tool.Name))
                ReplicatedStorage.RigControllerEvent:FireServer("hit", {Target.HumanoidRootPart}, {
                    ["start"] = Character.HumanoidRootPart.Position,
                    ["t"] = 0.05, -- Thời gian hit cực nhanh
                    ["p"] = Target.HumanoidRootPart.Position
                }, Tool.Name)
            end)
        end)
    end
end

--// Main Loops
local AC = FastAttack

-- Loop 1: Tấn công tốc độ cao (Dùng Stepped để đồng bộ Physics)
RunService.Stepped:Connect(function()
    local Target = AC:GetTarget()
    if Target then
        AC:Attack(Target)
        
        -- Tự động quay mặt về phía quái (Giúp skill định hướng trúng)
        if Character:FindFirstChild("HumanoidRootPart") and Target:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CFrame.new(
                Character.HumanoidRootPart.Position, 
                Vector3.new(Target.HumanoidRootPart.Position.X, Character.HumanoidRootPart.Position.Y, Target.HumanoidRootPart.Position.Z)
            )
        end
    end
end)

-- Loop 2: Xóa hiệu ứng Stun liên tục
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Character:FindFirstChild("Stun") then Character.Stun.Value = 0 end
        if Character:FindFirstChild("Busy") then Character.Busy.Value = false end
        -- Xóa body velocity lạ để tránh bị đẩy lùi khi đánh quái
        for _, v in pairs(Character.HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end)
end)

print("Fast Attack Optimized for Mobs - Loaded")
