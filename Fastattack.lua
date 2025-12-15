--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// CONFIG
local Config = {
    SwitchDelay = 0.15,        -- Tốc độ đổi vũ khí
    Range = 60,                -- Tầm tìm quái
    NoAnim = true              -- Bật/Tắt xóa animation
}

print("--- AUTO WEAPON SWAPPER (NO CLICK) LOADED ---")

--// HÀM XÓA ANIMATION
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Config.NoAnim and Character and Character:FindFirstChild("Humanoid") then
            local Animator = Character.Humanoid:FindFirstChildOfClass("Animator")
            if Animator then
                for _, Track in pairs(Animator:GetPlayingAnimationTracks()) do
                    Track:Stop()
                end
            end
        end
    end)
end)

-- Hàm tìm quái
local function GetTarget()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end
    local Target = nil
    local MinDist = Config.Range

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

-- Hàm tìm Blox Fruit
local function FindFruit()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")
    
    if CharTool and CharTool.ToolTip == "Blox Fruit" then return CharTool end
    
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then
            return v
        end
    end
    return nil
end

-- Hàm tìm BẤT KỲ Melee nào
local function FindAnyMelee()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")

    if CharTool and CharTool.ToolTip == "Melee" then
        return CharTool
    end

    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Melee" then
            return v
        end
    end
    return nil
end

local LastAttack = 0

-- Vòng lặp chính
RunService.Heartbeat:Connect(function()
    -- Cập nhật nhân vật liên tục
    if not Character or not Character.Parent then
        Character = Player.Character
        Humanoid = Character:FindFirstChild("Humanoid")
        return
    end

    if tick() - LastAttack < Config.SwitchDelay then return end
    
    local Target = GetTarget()
    if not Target then return end
    
    local Fruit = FindFruit()
    local Melee = FindAnyMelee()
    
    if Fruit and Melee then
        LastAttack = tick()
        
        -- A. Cầm Fruit ra
        Humanoid:EquipTool(Fruit)
        
        -- Chỉ bắn nếu có Remote (Không dùng chuột ảo nữa)
        if Fruit:FindFirstChild("LeftClickRemote") then
            local Dir = (Target.Position - Character.HumanoidRootPart.Position).Unit
            Fruit.LeftClickRemote:FireServer(Dir, 1)
        end
        
        -- B. Cầm Melee ra
        Humanoid:EquipTool(Melee)
        
        -- Đã xóa phần VirtualInputManager (Click chuột) tại đây
        -- Melee sẽ chỉ được cầm trên tay, bạn cần tự click hoặc dùng script đánh khác
    end
end)
