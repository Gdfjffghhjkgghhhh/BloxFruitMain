--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

--// LOCALS
local Player = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

--// REMOTES
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

--// CONFIGURATION
local Config = {
    Enabled = true,
    AttackDistance = 60,
    AttackCooldown = 0.12,    -- Tốc độ chém (0.1 - 0.15 là mượt nhất)
    NoAnimation = true,       -- XÓA HOÀN TOÀN ANIMATION ĐÁNH
    UltraLowLag = true,       -- GIẢM LAG TỐI ĐA
}

--// CLASS: FAST ATTACK
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        LastCleanTime = 0,
    }, FastAttack)

    -- [Tối ưu] Tắt bóng đổ và hiệu ứng ánh sáng để tăng FPS
    if Config.UltraLowLag then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then v.Enabled = false end
        end
    end

    -- [Tối ưu] Xóa hiệu ứng ngay khi chúng vừa xuất hiện
    Workspace.ChildAdded:Connect(function(child)
        if Config.UltraLowLag and (child.Name == "HitEffect" or child.Name == "DamageCounter" or child:IsA("Explosion")) then
            RunService.RenderStepped:Wait() -- Chờ 1 frame rồi xóa
            child:Destroy()
        end
    end)

    return self
end

-- Hàm dừng Animation (Quan trọng)
function FastAttack:StopAttackAnim()
    if not Config.NoAnimation then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            -- Dừng các animation có tên liên quan đến tấn công
            if track.Name:lower():find("attack") or track.Name:lower():find("slash") or track.Name:lower():find("swing") then
                track:Stop(0) -- Dừng ngay lập tức với 0s fade
            end
        end
    end
end

function FastAttack:GetTargets()
    local char = Player.Character
    if not char then return {} end
    local pos = char:GetPivot().Position
    local targets = {}
    local parts = {}

    local folders = {Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Characters")}
    for _, folder in pairs(folders) do
        if folder then
            for _, enemy in pairs(folder:GetChildren()) do
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                local hum = enemy:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 and (pos - hrp.Position).Magnitude <= Config.AttackDistance then
                    table.insert(targets, {enemy, hrp})
                    table.insert(parts, hrp)
                end
            end
        end
    end
    return targets, parts
end

function FastAttack:Attack()
    local char = Player.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool or (tool.ToolTip ~= "Melee" and tool.ToolTip ~= "Sword") then return end

    local targets, parts = self:GetTargets()
    if #targets == 0 then return end

    -- Gửi lệnh đánh trực tiếp tới Server (Bỏ qua VirtualInputManager nếu có thể)
    RegisterAttack:FireServer(Config.AttackCooldown)
    
    for _, data in ipairs(targets) do
        RegisterHit:FireServer(data[2], parts)
    end

    -- Xóa animation ngay lập tức sau khi gửi lệnh đánh
    self:StopAttackAnim()
end

function FastAttack:Update()
    if not Config.Enabled then return end
    
    if tick() - self.Debounce >= Config.AttackCooldown then
        self.Debounce = tick()
        self:Attack()
    end
end

--// INITIALIZE
local MyAttack = FastAttack.new()
RunService.Heartbeat:Connect(function()
    MyAttack:Update()
end)

print("Fast Attack: NO-ANIMATION + FIX LAG LOADED SUCCESS")
