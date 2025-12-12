--// Services

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Workspace = game:GetService("Workspace")

local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()

-- Cập nhật Character khi respawn

Player.CharacterAdded:Connect(function(newChar)

    Character = newChar

end)

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Net = Modules:WaitForChild("Net")

-- Safe Remote Retrieval (Tránh lỗi nếu game update tên remote)

local function GetRemote(path)

    local obj = Net

    for _, name in ipairs(string.split(path, "/")) do

        obj = obj:FindFirstChild(name)

        if not obj then return nil end

    end

    return obj

end

local RegisterAttack = GetRemote("RE/RegisterAttack")

local RegisterHit = GetRemote("RE/RegisterHit")

local ShootGunEvent = GetRemote("RE/ShootGunEvent")

local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

--// Config (Super Fast / Bypass Mode)

local Config = {

    AttackDistance = 60,            -- Khoảng cách an toàn để không bị lỗi hitbox

    AttackMobs = true,

    AttackPlayers = true,

    AttackDelay = 0,01                -- 0 = Max Speed (No yield)

    AnimCancel = true,              -- Bật hủy hoạt ảnh để đánh nhanh hơn

    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand", "HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso"},

    AutoClickEnabled = true

}

--// FastAttack Class

local FastAttack = {}

FastAttack.__index = FastAttack

function FastAttack.new()

    local self = setmetatable({

        Debounce = 0,

        ShootDebounce = 0,

        M1Combo = 0,

        ComboDebounce = 0,

        EnemyRootPart = nil,

        Connections = {},

        ShootsPerTarget = {["Dual Flintlock"] = 2},

        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}

    }, FastAttack)

    -- Lấy function Hits (Bypass Anti-cheat cơ bản nếu có)

    task.spawn(function()

        pcall(function()

            self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD

            self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)

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

    local humanoid = entity:FindFirstChild("Humanoid")

    local root = entity:FindFirstChild("HumanoidRootPart")

    return humanoid and root and humanoid.Health > 0

end

-- Hàm hủy hoạt ảnh (Key để đánh nhanh)

function FastAttack:StopAnimation(Char)

    if not Config.AnimCancel then return end

    local Hum = Char:FindFirstChild("Humanoid")

    if Hum then

        local Tracks = Hum:GetPlayingAnimationTracks()

        for _, Track in pairs(Tracks) do

            -- Chỉ dừng các animation tấn công để không bị lỗi di chuyển

            if Track.Priority == Enum.AnimationPriority.Action or Track.Priority == Enum.AnimationPriority.Action2 then

                Track:Stop()

            end

        end

    end

end

function FastAttack:GetBladeHits(MyChar, Distance)

    local Position = MyChar:GetPivot().Position

    local BladeHits = {}

    Distance = Distance or Config.AttackDistance

    -- Tối ưu hóa việc tìm target bằng cách dùng OverlapParams (Nhanh hơn loop thông thường)

    -- Tuy nhiên để giữ logic cũ của bạn hoạt động ổn định, ta sẽ tối ưu loop:

    

    local function ScanFolder(Folder)

        local Children = Folder:GetChildren()

        for i = 1, #Children do

            local Enemy = Children[i]

            if Enemy ~= MyChar and self:IsEntityAlive(Enemy) then

                local Root = Enemy.HumanoidRootPart

                if (Root.Position - Position).Magnitude <= Distance then

                    table.insert(BladeHits, {Enemy, Root})

                    -- Break sớm nếu chỉ cần 1 target để giảm lag (tùy chọn)

                    -- if #BladeHits >= 2 then break end 

                end

            end

        end

    end

    if Config.AttackMobs then ScanFolder(Workspace.Enemies) end

    if Config.AttackPlayers then ScanFolder(Workspace.Characters) end

    return BladeHits

end

function FastAttack:GetCombo()

    -- Luôn giữ combo ở mức cao để sát thương ổn định (nếu game tính dmg theo combo)

    if (tick() - self.ComboDebounce) > 0.2 then

        self.M1Combo = 0

    end

    self.M1Combo = self.M1Combo + 1

    self.ComboDebounce = tick()

    return math.min(self.M1Combo, 5) -- Giới hạn số ảo để tránh lỗi server

end

-- Validator cho súng (Giữ nguyên logic của bạn vì nó phụ thuộc vào game version)

function FastAttack:GetValidator2()

    if not self.ShootFunction then return 0, 0 end

    -- Wrap pcall để tránh crash script nếu game update

    local s, result, v7 = pcall(function()

        local v1 = getupvalue(self.ShootFunction, 15)

        local v2 = getupvalue(self.ShootFunction, 13)

        local v3 = getupvalue(self.ShootFunction, 16)

        local v4 = getupvalue(self.ShootFunction, 17)

        local v5 = getupvalue(self.ShootFunction, 14)

        local v6 = getupvalue(self.ShootFunction, 12)

        local v7 = getupvalue(self.ShootFunction, 18)

        local v8 = v6 * v2

        local v9 = (v5 * v2 + v6 * v1) % v3

        v9 = (v9 * v3 + v8) % v4

        v5 = math.floor(v9 / v3)

        v6 = v9 - v5 * v3

        v7 = v7 + 1

        setupvalue(self.ShootFunction, 15, v1)

        setupvalue(self.ShootFunction, 13, v2)

        setupvalue(self.ShootFunction, 16, v3)

        setupvalue(self.ShootFunction, 17, v4)

        setupvalue(self.ShootFunction, 14, v5)

        setupvalue(self.ShootFunction, 12, v6)

        setupvalue(self.ShootFunction, 18, v7)

        return math.floor(v9 / v4 * 16777215), v7

    end)

    if s then return result, v7 else return 0, 0 end

end

function FastAttack:Attack()

    if not Config.AutoClickEnabled then return end

    

    local MyChar = Player.Character

    if not MyChar or not MyChar:FindFirstChild("HumanoidRootPart") then return end

    

    local Equipped = MyChar:FindFirstChildOfClass("Tool")

    if not Equipped then return end

    local ToolTip = Equipped.ToolTip

    

    -- Kiểm tra Tool hợp lệ

    if not ToolTip or not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end

    -- Logic Gun (Súng)

    if ToolTip == "Gun" then

        local Targets = self:GetBladeHits(MyChar, 100)

        for _, t in ipairs(Targets) do

            local EnemyRoot = t[2]

            

            -- Spam FireServer

            task.spawn(function()

                local val, v7 = self:GetValidator2()

                if GunValidator then GunValidator:FireServer(val, v7) end

                

                if ShootGunEvent then

                    ShootGunEvent:FireServer(EnemyRoot.Position)

                elseif Equipped:FindFirstChild("RemoteEvent") then

                    Equipped.RemoteEvent:FireServer("TAP", EnemyRoot.Position)

                else

                    -- Fallback nếu không tìm thấy remote đúng

                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)

                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

                end

            end)

        end

        return -- Kết thúc Gun logic

    end

    -- Logic Melee/Sword/Fruit (Cận chiến)

    -- 1. Register Attack (Click ảo)

    if RegisterAttack then

        pcall(function() RegisterAttack:FireServer(Config.AttackDelay) end)

    end

    

    -- 2. Register Hit (Gây dmg)

    local BladeHits = self:GetBladeHits(MyChar, Config.AttackDistance)

    if #BladeHits > 0 then

        if self.HitFunction then

            -- Dùng HitFunction native của game (Bypass tốt hơn)

            pcall(function() self.HitFunction(BladeHits[1][2], BladeHits) end)

        elseif RegisterHit then

            -- Fallback dùng Remote thường

            for _, HitData in ipairs(BladeHits) do

                pcall(function() RegisterHit:FireServer(HitData[2], {HitData}) end)

            end

        end

        

        -- Hủy hoạt ảnh ngay sau khi đánh trúng để reset đòn

        self:StopAnimation(MyChar)

    end

    

    -- Blox Fruit Skill Click (Left Click)

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then

        local Target = BladeHits[1]

        if Target then

            local Direction = (Target[2].Position - MyChar.HumanoidRootPart.Position).Unit

            pcall(function() 

                Equipped.LeftClickRemote:FireServer(Direction, self:GetCombo()) 

            end)

        end

    end

end

--// Execution Logic (Siêu nhanh)

local AttackInstance = FastAttack.new()

-- Sử dụng 2 luồng: Heartbeat (ổn định) + Loop Task (Spam cực nhanh)

-- Luồng 1: Ổn định theo khung hình

table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(function()

    AttackInstance:Attack()

end))

-- Luồng 2: Spam (Bypass delay)

task.spawn(function()

    while task.wait() do -- wait() thấp nhất có thể

        if Config.AutoClickEnabled then

            AttackInstance:Attack()

        end

    end

end)

return FastAttack

