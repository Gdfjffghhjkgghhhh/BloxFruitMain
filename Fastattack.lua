--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// CONFIG
local Config = {
    SwitchDelay = 0.15,
    Range = 60,
    NoAnim = true,       -- Xóa hoạt ảnh nhân vật (Múa tay)
    NoVFX = true,        -- Xóa hiệu ứng kỹ năng (Nổ, Sáng, Khói...)
    BoostFPS = true      -- Giảm đồ họa game xuống mức thấp nhất
}

print("--- AUTO SWAP + NO EFFECTS LOADED ---")

--// 1. HÀM XÓA ANIMATION (Múa may)
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

--// 2. HÀM XÓA HIỆU ỨNG KỸ NĂNG (VFX Cleaner)
if Config.NoVFX then
    -- Xóa hiệu ứng ngay khi nó được sinh ra
    Workspace.DescendantAdded:Connect(function(v)
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") then
            v:Destroy()
        end
    end)
    
    -- Quét sạch hiệu ứng hiện có
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") then
            v:Destroy()
        end
    end
end

--// 3. BOOST FPS (Làm nhẹ game)
if Config.BoostFPS then
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            end
        end
    end)
end

--// CÁC HÀM AUTO FARM (GIỮ NGUYÊN)
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
    if CharTool and CharTool.ToolTip == "Blox Fruit" then return CharTool end
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then return v end
    end
    return nil
end

local function FindAnyMelee()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")
    if CharTool and CharTool.ToolTip == "Melee" then return CharTool end
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Melee" then return v end
    end
    return nil
end

local LastAttack = 0

RunService.Heartbeat:Connect(function()
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
        
        -- A. Fruit
        Humanoid:EquipTool(Fruit)
        if Fruit:FindFirstChild("LeftClickRemote") then
            local Dir = (Target.Position - Character.HumanoidRootPart.Position).Unit
            Fruit.LeftClickRemote:FireServer(Dir, 1)
        else
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        end
        
        -- B. Melee
        Humanoid:EquipTool(Melee)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
    end
end)
