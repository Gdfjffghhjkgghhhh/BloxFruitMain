--// Configuration
_G.FastAttackRunning = true -- Đặt false để tắt script

local Config = {
    AttackDistance = 60,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0,      -- 0 là nhanh nhất có thể (theo tick của Heartbeat)
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true
}

--// Micro-Optimizations (Localize functions for speed)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

-- Cache math functions
local insert = table.insert
local find = table.find
local ipairs = ipairs
local tick = tick
local wait = task.wait
local V3 = Vector3.new

--// FastAttack Class
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        EnemyRootPart = nil,
        Connections = {},
        ShootsPerTarget = {["Dual Flintlock"] = 2},
        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
    }, FastAttack)

    task.spawn(function()
        pcall(function()
            self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
            self.ShootFunction = debug.getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
            local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
            if LocalScript and getsenv then
                self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
            end
        end)
    end)

    return self
end

function FastAttack:IsEntityAlive(entity)
    if not entity then return false end
    local hum = entity:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

-- Tối ưu hóa kiểm tra Stun
function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    -- Nếu đang ngồi và cầm vũ khí cận chiến -> Skip
    if Humanoid.Sit and (ToolTip ~= "Gun") then return false end
    
    -- Kiểm tra Stun/Busy trực tiếp giá trị (nhanh hơn FindFirstChild nhiều lần nếu gọi liên tục)
    -- Tuy nhiên để an toàn vẫn dùng FindFirstChild nhưng tối ưu logic
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")

    if (Stun and Stun.Value > 0) or (Busy and Busy.Value) then
        return false
    end
    return true
end

-- Tối ưu hóa tìm mục tiêu bằng Squared Magnitude (nhanh hơn Magnitude thường)
function FastAttack:GetBladeHits(Character, Distance)
    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return {} end
    
    local MyPos = MyRoot.Position
    local BladeHits = {}
    local DistSq = (Distance or Config.AttackDistance) ^ 2 -- Bình phương khoảng cách để so sánh

    local function ProcessFolder(Folder)
        local Children = Folder:GetChildren()
        for i = 1, #Children do
            local Enemy = Children[i]
            if Enemy ~= Character then
                local EnemyRoot = Enemy:FindFirstChild("HumanoidRootPart")
                local EnemyHum = Enemy:FindFirstChild("Humanoid")
                
                if EnemyRoot and EnemyHum and EnemyHum.Health > 0 then
                    if (EnemyRoot.Position - MyPos).Magnitude <= (Distance or Config.AttackDistance) then
                    -- Lưu ý: Roblox đã tối ưu .Magnitude, nhưng nếu muốn cực gắt có thể dùng phép tính vector tay
                    -- Ở đây giữ .Magnitude để đảm bảo chính xác Hitbox của game
                        insert(BladeHits, {Enemy, EnemyRoot})
                        self.EnemyRootPart = EnemyRoot
                    end
                end
            end
        end
    end

    if Config.AttackMobs then ProcessFolder(Workspace.Enemies) end
    if Config.AttackPlayers then ProcessFolder(Workspace.Characters) end

    return BladeHits
end

function FastAttack:GetCombo()
    -- Reset combo logic cực nhanh
    if (tick() - self.ComboDebounce) > 0.3 then -- Giới hạn thực tế của game để tránh bị anticheat reset
        self.M1Combo = 0 
    end
    self.M1Combo = self.M1Combo + 1
    self.ComboDebounce = tick()
    return self.M1Combo
end

-- Bypass Validator (Giữ nguyên logic nhưng thêm pcall để tránh crash)
function FastAttack:GetValidator2()
    local success, result = pcall(function()
        local v1 = debug.getupvalue(self.ShootFunction, 15)
        local v2 = debug.getupvalue(self.ShootFunction, 13)
        local v3 = debug.getupvalue(self.ShootFunction, 16)
        local v4 = debug.getupvalue(self.ShootFunction, 17)
        local v5 = debug.getupvalue(self.ShootFunction, 14)
        local v6 = debug.getupvalue(self.ShootFunction, 12)
        local v7 = debug.getupvalue(self.ShootFunction, 18)

        local v8 = v6 * v2
        local v9 = (v5 * v2 + v6 * v1) % v3
        v9 = (v9 * v3 + v8) % v4
        v5 = math.floor(v9 / v3)
        v6 = v9 - v5 * v3
        v7 = v7 + 1

        debug.setupvalue(self.ShootFunction, 15, v1)
        debug.setupvalue(self.ShootFunction, 13, v2)
        debug.setupvalue(self.ShootFunction, 16, v3)
        debug.setupvalue(self.ShootFunction, 17, v4)
        debug.setupvalue(self.ShootFunction, 14, v5)
        debug.setupvalue(self.ShootFunction, 12, v6)
        debug.setupvalue(self.ShootFunction, 18, v7)

        return math.floor(v9 / v4 * 16777215), v7
    end)
    
    if success then return result else return 0, 1 end
end

function FastAttack:ShootInTarget(TargetPosition, Equipped)
    -- Logic súng siêu nhanh
    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(self:GetValidator2())
        
        if ShootType == "TAP" then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
    else
        -- Giả lập click chuột ảo cực nhanh thay vì wait(0.0001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

function FastAttack:UseNormalClick(Character, BladeHits)
    -- Gửi gói tin tấn công
    RegisterAttack:FireServer(Config.AttackCooldown)
    
    -- RegisterHit cho tất cả mục tiêu trong danh sách
    for i = 1, #BladeHits do
        local TargetRoot = BladeHits[i][2]
        if TargetRoot then
             if self.CombatFlags and self.HitFunction then
                pcall(function() self.HitFunction(TargetRoot, BladeHits) end)
            else
                RegisterHit:FireServer(TargetRoot, BladeHits)
            end
        end
    end
end

--// Main Attack Loop
function FastAttack:Attack()
    if not Config.AutoClickEnabled or not _G.FastAttackRunning then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end

    local ToolTip = Equipped.ToolTip
    if not ToolTip or not find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end

    -- Xử lý theo loại vũ khí
    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        -- Blox Fruit M1
        local Targets = self:GetBladeHits(Character)
        if #Targets > 0 then
            local Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
            Equipped.LeftClickRemote:FireServer(Direction, self:GetCombo())
        end

    elseif ToolTip == "Gun" then
        -- Gun Spam
        local Targets = self:GetBladeHits(Character, 100) -- Tăng range cho súng
        for i = 1, #Targets do
            self:ShootInTarget(Targets[i][2].Position, Equipped)
        end

    else
        -- Melee / Sword
        local Targets = self:GetBladeHits(Character)
        if #Targets > 0 then
            self:UseNormalClick(Character, Targets)
        end
    end
end

--// Init
local AttackInstance = FastAttack.new()

-- Sử dụng Heartbeat nhưng có kiểm tra để tránh crash client
local HeartbeatConnection = RunService.Heartbeat:Connect(function()
    pcall(function()
        AttackInstance:Attack()
    end)
end)

table.insert(AttackInstance.Connections, HeartbeatConnection)

-- Hàm hủy script khi cần
_G.StopFastAttack = function()
    _G.FastAttackRunning = false
    if HeartbeatConnection then HeartbeatConnection:Disconnect() end
    print("Fast Attack Stopped")
end

return FastAttack
