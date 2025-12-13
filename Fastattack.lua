--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Modules & Remotes
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

print("--- HYBRID ATTACK LOADED ---")

-- Config
local Config = {
    Distance = 60,
    Cooldown = 0.05, -- Không để quá thấp tránh lag remote
}

--// FastAttack Class
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        LastAttack = 0,
        M1Counter = 1,
    }, FastAttack)
    return self
end

function FastAttack:GetTarget()
    local Character = Player.Character
    if not Character then return nil end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Closest = nil
    local MinDist = Config.Distance

    -- Ưu tiên tìm trong folder Enemies (Quái) trước
    local Enems = Workspace:FindFirstChild("Enemies")
    if Enems then
        for _, v in pairs(Enems:GetChildren()) do
            local Hum = v:FindFirstChild("Humanoid")
            local HRP = v:FindFirstChild("HumanoidRootPart")
            if Hum and HRP and Hum.Health > 0 then
                local Dist = (HRP.Position - Root.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Closest = HRP
                end
            end
        end
    end
    
    -- Nếu không có quái thì tìm người chơi (Characters)
    if not Closest then
        local Chars = Workspace:FindFirstChild("Characters")
        if Chars then
            for _, v in pairs(Chars:GetChildren()) do
                if v ~= Character then
                     local Hum = v:FindFirstChild("Humanoid")
                     local HRP = v:FindFirstChild("HumanoidRootPart")
                     if Hum and HRP and Hum.Health > 0 then
                        local Dist = (HRP.Position - Root.Position).Magnitude
                        if Dist < MinDist then
                            MinDist = Dist
                            Closest = HRP
                        end
                     end
                end
            end
        end
    end

    return Closest
end

function FastAttack:Attack()
    local Character = Player.Character
    if not Character then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    -- Chỉ chạy nếu cầm Melee, Sword hoặc Blox Fruit
    if not table.find({"Melee", "Blox Fruit", "Sword"}, Equipped.ToolTip) then return end

    local TargetPart = self:GetTarget()
    if not TargetPart then return end

    -- 1. XỬ LÝ MELEE (ĐÁNH THƯỜNG) - LUÔN CHẠY
    -- Gửi hit damage trực tiếp
    RegisterAttack:FireServer(Config.Cooldown)
    RegisterHit:FireServer(TargetPart, {{TargetPart.Parent, TargetPart}})
    
    -- 2. XỬ LÝ FRUIT M1 (NẾU CẦM TRÁI ÁC QUỶ)
    if Equipped.ToolTip == "Blox Fruit" then
        -- Cách 1: Gửi Remote thủ công (Nhanh nhất)
        if Equipped:FindFirstChild("LeftClickRemote") then
            local Direction = (TargetPart.Position - Character.HumanoidRootPart.Position).Unit
            self.M1Counter = self.M1Counter + 1
            if self.M1Counter > 5 then self.M1Counter = 1 end
            
            -- Bắn Remote
            Equipped.LeftClickRemote:FireServer(Direction, self.M1Counter)
        end

        -- Cách 2: Giả lập Click chuột (Dự phòng nếu Remote bị chặn)
        -- Chỉ click chuột ảo nếu đang nhắm vào mục tiêu để tránh đánh lung tung
        task.spawn(function()
             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
             task.wait()
             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

-- Main Loop
local AttackSystem = FastAttack.new()
RunService.Heartbeat:Connect(function()
    if (tick() - AttackSystem.LastAttack) > Config.Cooldown then
        AttackSystem:Attack()
        AttackSystem.LastAttack = tick()
    end
end)
