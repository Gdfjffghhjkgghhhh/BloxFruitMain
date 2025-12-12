--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

--// CẤU HÌNH TỐI ƯU (OPTIMIZED CONFIG)
local Config = {
    HitsPerFrame = 2,    -- GIẢM XUỐNG: 2-3 hit/frame là đủ nhanh (quá cao server sẽ chặn)
    Range = 50,          -- Phạm vi an toàn
    AutoClick = true,
}

--// Fast Attack Core
local FastAttack = {}

function FastAttack:GetTarget()
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    local Nearest = nil
    local MinDist = Config.Range

    local Enemies = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
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

-- Hàm đánh gây damage thực
function FastAttack:Attack(Target)
    if not Target then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then return end

    -- 1. Xóa Animation (Client side visual)
    local Hum = Character:FindFirstChild("Humanoid")
    if Hum then
        local Tracks = Hum:GetPlayingAnimationTracks()
        for _, t in pairs(Tracks) do
            t:Stop()
        end
    end

    -- 2. Spam Click (Kích hoạt tool)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- 3. QUAN TRỌNG: Giả lập kiếm chạm vào quái (Fake Handle Touch)
    -- Đây là phần quan trọng nhất để gây damage cho các tool thường
    local Handle = Tool:FindFirstChild("Handle")
    local TargetRoot = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Torso")
    
    if Handle and TargetRoot then
        -- firetouchinterest là hàm của Executor, giả lập việc va chạm vật lý
        pcall(function()
            firetouchinterest(Handle, TargetRoot, 0) -- Bắt đầu chạm
            firetouchinterest(Handle, TargetRoot, 1) -- Kết thúc chạm
        end)
    end

    -- 4. Kích hoạt Remote (Nếu game dùng Remote thay vì Touch)
    -- Thử gửi Humanoid của quái vào Remote (Fix lỗi thiếu Argument)
    if Tool:FindFirstChild("RemoteEvent") then
        task.spawn(function()
            pcall(function() 
                -- Gửi kèm Target Humanoid (cách hoạt động phổ biến)
                Tool.RemoteEvent:FireServer(Target.Humanoid) 
            end)
        end)
    end
    
    -- Blox Fruits specific (Nếu là Blox Fruits thì dùng module này)
    if game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent") then
         task.spawn(function()
            pcall(function()
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange", tostring(Tool.Name))
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", {
                    [1] = Target.HumanoidRootPart,
                    [2] = {
                        ["p"] = Target.HumanoidRootPart.Position,
                        ["pid"] = 1
                    },
                    [3] = 0.1 -- Hit time
                })
            end)
        end)
    end
end

--// LOGIC LOOP
RunService.Heartbeat:Connect(function()
    if not Config.AutoClick then return end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then return end 

    local Target = FastAttack:GetTarget()
    if Target then
        -- Teleport Hitbox (CFrame để dính vào quái giúp server nhận hit dễ hơn)
        if Character:FindFirstChild("HumanoidRootPart") and Target:FindFirstChild("HumanoidRootPart") then
            -- Giữ khoảng cách 3-5 stud để tránh bị kick do noclip
            Character.HumanoidRootPart.CFrame = CFrame.new(Target.HumanoidRootPart.Position + Target.HumanoidRootPart.CFrame.LookVector * 2, Target.HumanoidRootPart.Position)
        end

        for i = 1, Config.HitsPerFrame do
            FastAttack:Attack(Target)
        end
    end
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ FIXED SCRIPT";
    Text = "Added TouchInterest & Argument logic";
    Duration = 3;
})
