--// DUAL SPAM SCRIPT (Melee + Fruit M1)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

print(">>> DUAL SPAM LOADED: Melee + Fruit M1 <<<")

--// CẤU HÌNH
local Config = {
    Range = 80,          -- Tầm đánh (Nên để xa để farm Boss)
    Speed = 0,     -- Tốc độ loop (Càng nhỏ càng nhanh)
    M1Counter = 1,       -- Biến đếm combo fruit
}

--// HÀM TÌM QUÁI (Tối ưu hóa)
local function GetTarget()
    local Char = Player.Character
    if not Char then return nil end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Target = nil
    local MinDist = Config.Range

    -- Ưu tiên Boss/Quái trong thư mục Enemies
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

--// HÀM TẤN CÔNG KÉP
local function Attack()
    local Char = Player.Character
    if not Char then return end
    
    local Equipped = Char:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    -- Chỉ chạy khi cầm Melee, Sword hoặc Blox Fruit
    if not table.find({"Melee", "Blox Fruit", "Sword"}, Equipped.ToolTip) then return end

    local TargetPart = GetTarget()
    if not TargetPart then return end
    
    --[[ PHẦN 1: MELEE DAMAGE (Gửi gói tin đánh tay) ]]
    -- Luôn gửi cái này dù đang cầm Fruit để lấy thêm dmg từ chỉ số Melee
    task.spawn(function()
        -- Fake Animation đánh
        RegisterAttack:FireServer(0) 
        -- Gửi Hit Damage
        RegisterHit:FireServer(TargetPart, {{TargetPart.Parent, TargetPart}})
    end)

    --[[ PHẦN 2: FRUIT DAMAGE (Gửi gói tin M1) ]]
    -- Chỉ hoạt động nếu đang cầm Fruit
    if Equipped.ToolTip == "Blox Fruit" then
        task.spawn(function()
            -- Tính hướng bắn chính xác vào quái
            local MyPos = Char.HumanoidRootPart.Position
            local TargetPos = TargetPart.Position
            local Direction = (TargetPos - MyPos).Unit
            
            -- Tăng biến combo ảo
            Config.M1Counter = Config.M1Counter + 1
            if Config.M1Counter > 5 then Config.M1Counter = 1 end

            -- Cách 1: Gửi Remote trực tiếp (Nhanh nhất)
            if Equipped:FindFirstChild("LeftClickRemote") then
                Equipped.LeftClickRemote:FireServer(Direction, Config.M1Counter)
            end
            
            -- Cách 2: Kích hoạt Click ảo (Để kích hoạt hitbox ẩn của một số Fruit)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

--// VÒNG LẶP HỦY DIỆT (Heartbeat Loop)
local AttackLoop
AttackLoop = RunService.Heartbeat:Connect(function()
    pcall(function()
        Attack()
    end)
end)

-- Thông báo
game.StarterGui:SetCore("SendNotification", {
    Title = "Dual Attack ON",
    Text = "Đang spam Melee + Fruit!",
    Duration = 5
})
