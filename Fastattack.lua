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
    MeleeName = "Godhuman",   -- Điền đúng tên Melee của bạn (Vd: Godhuman, Sanguine Art)
    SwitchDelay = 0.1,        -- Tốc độ đổi (Đừng để thấp quá kẻo lag)
    Range = 60
}

print("--- WEAPON SWAPPER LOADED ---")

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

local function FindFruit()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")
    
    -- Kiểm tra xem đang cầm Fruit chưa
    if CharTool and CharTool.ToolTip == "Blox Fruit" then
        return CharTool
    end
    
    -- Tìm trong Balo
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then
            return v
        end
    end
    return nil
end

local function FindMelee()
    local Backpack = Player.Backpack
    -- Tìm trong Balo hoặc trên tay
    local MeleeTool = Character:FindFirstChild(Config.MeleeName) or Backpack:FindFirstChild(Config.MeleeName)
    return MeleeTool
end

local LastAttack = 0

RunService.Heartbeat:Connect(function()
    if tick() - LastAttack < Config.SwitchDelay then return end
    
    local Target = GetTarget()
    if not Target then return end
    
    local Fruit = FindFruit()
    local Melee = FindMelee()
    
    if Fruit and Melee then
        LastAttack = tick()
        
        -- 1. Cầm Fruit ra
        Humanoid:EquipTool(Fruit)
        
        -- 2. Bắn Fruit (Dùng Remote hoặc Click ảo)
        if Fruit:FindFirstChild("LeftClickRemote") then
            local Dir = (Target.Position - Character.HumanoidRootPart.Position).Unit
            Fruit.LeftClickRemote:FireServer(Dir, 1)
        else
            -- Dự phòng click ảo
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        end
        
        -- 3. Cầm lại Melee ngay lập tức
        Humanoid:EquipTool(Melee)
        
        -- 4. Kích hoạt đánh thường cho Melee (Nếu cần)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
    end
end)
