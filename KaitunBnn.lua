--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser") -- Dùng cái này click chuẩn hơn
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

--// Config
local Config = {
    Distance = 50,          -- Khoảng cách đánh
    AttackSpeed = 0,        -- 0 là nhanh nhất (tùy máy)
    BypassStun = true       -- Xóa choáng
}

--// Variables
local Active = true

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

--// Fast Attack Logic
local function GetNearestEnemy()
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    local Nearest = nil
    local MinDist = Config.Distance

    -- Chỉ tìm trong thư mục Enemies (Quái)
    local Enemies = Workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, v in pairs(Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
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

-- Hàm tấn công (Sử dụng VirtualUser + Animation Cancel)
local function Attack(Target)
    if not Target then return end
    
    -- 1. Trang bị vũ khí (Melee/Sword)
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then
        -- Tự tìm tool trong ba lô nếu chưa cầm
        local BackpackTool = Player.Backpack:FindFirstChildOfClass("Tool")
        if BackpackTool then
            Character.Humanoid:EquipTool(BackpackTool)
            Tool = BackpackTool
        end
    end

    if Tool then
        -- 2. Click chuột ảo (Cách an toàn nhất để server nhận dmg)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(900, 600)) -- Click vào giữa màn hình
        end)
        
        -- 3. Kích hoạt Tool thủ công (Dự phòng)
        pcall(function()
            Tool:Activate()
        end)
        
        -- 4. Animation Cancel (Bí thuật đánh nhanh)
        -- Ngắt hoạt ảnh ngay lập tức để đánh đòn tiếp theo
        local Hum = Character:FindFirstChild("Humanoid")
        if Hum then
            for _, track in pairs(Hum:GetPlayingAnimationTracks()) do
                -- Chỉ ngắt hoạt ảnh tấn công
                if track.Priority == Enum.AnimationPriority.Action or track.Name == "Tool" then
                    track:Stop()
                end
            end
        end
    end
end

--// Main Loop
task.spawn(function()
    while task.wait(Config.AttackSpeed) do -- Loop siêu nhanh
        if Active then
            pcall(function()
                local Target = GetNearestEnemy()
                if Target then
                    -- Tự quay mặt vào quái
                    if Character:FindFirstChild("HumanoidRootPart") then
                        Character.HumanoidRootPart.CFrame = CFrame.new(
                            Character.HumanoidRootPart.Position, 
                            Vector3.new(Target.HumanoidRootPart.Position.X, Character.HumanoidRootPart.Position.Y, Target.HumanoidRootPart.Position.Z)
                        )
                    end
                    
                    Attack(Target)
                end
            end)
        end
    end
end)

--// Anti Stun Loop (Chống choáng khi quái đánh lại)
RunService.Heartbeat:Connect(function()
    if Config.BypassStun and Character then
        pcall(function()
            if Character:FindFirstChild("Stun") then Character.Stun.Value = 0 end
            if Character:FindFirstChild("Busy") then Character.Busy.Value = false end
        end)
    end
end)

print("Fast Attack (Universal Version) - Loaded")
