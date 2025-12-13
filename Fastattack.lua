--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// CONFIG
local Config = {
    SwitchDelay = 0.5,        -- Tốc độ đổi (Nên để 0.15 để tránh bị kẹt vũ khí)
    Range = 60
}

print("--- AUTO WEAPON SWAPPER (ALL MELEE) LOADED ---")

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

-- Hàm tìm Blox Fruit (Trên tay hoặc trong Balo)
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

-- Hàm tìm BẤT KỲ Melee nào (Logic mới)
local function FindAnyMelee()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")

    -- 1. Kiểm tra trên tay trước
    if CharTool and CharTool.ToolTip == "Melee" then
        return CharTool
    end

    -- 2. Kiểm tra trong Balo
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Melee" then
            return v -- Lấy cái Melee đầu tiên tìm thấy
        end
    end
    return nil
end

local LastAttack = 0

-- Vòng lặp chính
RunService.Heartbeat:Connect(function()
    if tick() - LastAttack < Config.SwitchDelay then return end
    
    -- Cập nhật lại nhân vật nếu bị chết
    if not Character or not Character.Parent then
        Character = Player.Character
        Humanoid = Character:FindFirstChild("Humanoid")
        return
    end

    local Target = GetTarget()
    if not Target then return end
    
    local Fruit = FindFruit()
    local Melee = FindAnyMelee() -- Tự động tìm Melee
    
    if Fruit and Melee then
        LastAttack = tick()
        
        -- A. Cầm Fruit ra bắn skill
        Humanoid:EquipTool(Fruit)
        
        if Fruit:FindFirstChild("LeftClickRemote") then
            local Dir = (Target.Position - Character.HumanoidRootPart.Position).Unit
            -- Bắn 2 lần cho chắc ăn
            Fruit.LeftClickRemote:FireServer(Dir, 1)
        else
            -- Click ảo nếu không thấy remote
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        end
        
        -- B. Cầm Melee ra đánh thường
        Humanoid:EquipTool(Melee)
        
        -- Click đánh Melee
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
    end
end)
