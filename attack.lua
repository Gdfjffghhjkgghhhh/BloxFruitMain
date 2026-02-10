--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--====================================================
-- REMOTES
--====================================================
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")

--====================================================
-- CONFIG
--====================================================
local Config = {
    Bring = true,
    BringDistance = 200,
    AttackDistance = 70,
    AttackCooldown = 0.001,
    ComboResetTime = 0.03,
    AutoClickEnabled = true,
    MaxTargets = 15,
    BringSpeed = 0.5,
    TeleportMode = false, -- CHẾ ĐỘ TELEPORT THAY VÌ KÉO
    KeepMobsBelow = true, -- LUÔN GIỮ MOB DƯỚI CHÂN
    HeightDifference = 0, -- MOB THẤP HƠN PLAYER BAO NHIÊU STUD
    RotationRadius = 10, -- BÁN KÍNH VÒNG TRÒN XUNG QUANH PLAYER
    SnapToGround = true -- TỰ ĐỘNG SNAP XUỐNG MẶT ĐẤT
}

--====================================================
-- GLOBAL
--====================================================
local PosMon = nil
local LastGroundCheck = 0
local GroundY = nil

pcall(function()
    sethiddenproperty(Player, "SimulationRadius", math.huge)
    sethiddenproperty(Player, "MaxSimulationRadius", math.huge)
end)

--====================================================
-- FAST ATTACK CLASS
--====================================================
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    return setmetatable({
        ComboDebounce = 0,
        M1Combo = 0,
        LastShoot = 0,
        MobPositions = {},
        RotationAngle = 0
    }, FastAttack)
end

--====================================================
-- UTILS
--====================================================
function FastAttack:IsAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

function FastAttack:GetGroundHeight(position)
    -- Dùng raycast để tìm độ cao mặt đất
    local rayOrigin = Vector3.new(position.X, position.Y + 100, position.Z)
    local rayDirection = Vector3.new(0, -200, 0)
    local ray = Ray.new(rayOrigin, rayDirection)
    
    local ignoreList = {Player.Character}
    local hit, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        return hitPosition.Y + 2 -- Thêm 2 stud để mob đứng trên mặt đất
    end
    
    return position.Y
end

function FastAttack:SnapToGroundPosition(position)
    if not Config.SnapToGround then return position end
    
    local groundY = self:GetGroundHeight(position)
    return Vector3.new(position.X, groundY, position.Z)
end

--====================================================
-- UPDATE POSMON
--====================================================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        PosMon = char.HumanoidRootPart.Position
        
        -- Update ground height mỗi 0.5 giây
        if tick() - LastGroundCheck > 0.5 then
            GroundY = FastAttack:GetGroundHeight(PosMon)
            LastGroundCheck = tick()
        end
    end
end)

--====================================================
-- BRING MOB - FIXED VERSION (KHÔNG BAY LÊN TRỜI)
--====================================================
function FastAttack:BringEnemy()
    if not Config.Bring or not PosMon then return end

    local char = Player.Character
    if not char then return end
    
    local playerHrp = char:FindFirstChild("HumanoidRootPart")
    if not playerHrp then return end

    -- Tăng góc xoay cho vòng tròn
    self.RotationAngle = self.RotationAngle + 0.05
    
    -- Lấy danh sách mob
    local mobs = Workspace.Enemies:GetChildren()
    local count = 0
    
    for i, mob in ipairs(mobs) do
        if count >= Config.MaxTargets then break end
        
        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then
            local distance = (hrp.Position - PosMon).Magnitude
            
            if distance <= Config.BringDistance then
                count = count + 1
                
                -- KHÔNG disable collision - GIỮ MOB ĐỨNG VỮNG
                for _, part in ipairs(mob:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true -- GIỮ COLLISION
                        part.Massless = false  -- GIỮ KHỐI LƯỢNG
                    end
                end

                hum.JumpPower = 0
                hum.PlatformStand = false
                
                -- Tính toán vị trí mục tiêu
                local targetPos
                
                if Config.KeepMobsBelow then
                    -- Mob luôn ở DƯỚI chân player
                    targetPos = Vector3.new(
                        playerHrp.Position.X,
                        (GroundY or playerHrp.Position.Y) - Config.HeightDifference,
                        playerHrp.Position.Z
                    )
                else
                    -- Giữ mob ở độ cao mặt đất
                    targetPos = Vector3.new(
                        playerHrp.Position.X,
                        self:GetGroundHeight(playerHrp.Position) + 1,
                        playerHrp.Position.Z
                    )
                end
                
                -- Phân bố mob theo vòng tròn
                local angle = self.RotationAngle + (i * (math.pi * 2 / math.min(#mobs, Config.MaxTargets)))
                local radius = Config.RotationRadius + (i % 3) * 2 -- Thêm variation
                
                targetPos = Vector3.new(
                    targetPos.X + math.cos(angle) * radius,
                    targetPos.Y,
                    targetPos.Z + math.sin(angle) * radius
                )
                
                -- Snap xuống mặt đất
                if Config.SnapToGround then
                    targetPos = self:SnapToGroundPosition(targetPos)
                end
                
                if Config.TeleportMode then
                    -- TELEPORT TRỰC TIẾP - KHÔNG DÙNG LERP
                    hrp.CFrame = CFrame.new(targetPos)
                else
                    -- Di chuyển từ từ NHƯNG LUÔN GIỮ Ở MẶT ĐẤT
                    local currentPos = hrp.Position
                    local newPos = Vector3.new(
                        targetPos.X,
                        math.max(targetPos.Y, self:GetGroundHeight(targetPos)), -- KHÔNG BAO GIỜ Ở TRÊN MẶT ĐẤT
                        targetPos.Z
                    )
                    
                    local distanceToMove = (newPos - currentPos).Magnitude
                    if distanceToMove > 5 then
                        hrp.Velocity = (newPos - currentPos).Unit * Config.BringSpeed * 50
                    else
                        hrp.Velocity = Vector3.zero
                        hrp.CFrame = CFrame.new(newPos)
                    end
                end
                
                -- Đảm bảo mob không bay lên
                hrp.AssemblyLinearVelocity = Vector3.new(0, -10, 0) -- Lực hút xuống
                
                -- Reset state của humanoid
                hum:ChangeState(Enum.HumanoidStateType.Running)
                
                -- Lưu vị trí mob
                self.MobPositions[mob] = targetPos
            end
        end
    end
end

--====================================================
-- GET ALL MOBS IN RANGE (AOE)
--====================================================
function FastAttack:GetBladeHits(Character, Distance)
    local Hits = {}
    Distance = Distance or Config.AttackDistance
    local Pos = Character:GetPivot().Position

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if #Hits >= Config.MaxTargets then break end

        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then
            if (hrp.Position - Pos).Magnitude <= Distance then
                table.insert(Hits, {mob, hrp})
            end
        end
    end

    return Hits
end

function FastAttack:GetCombo()
    local combo = (tick() - self.ComboDebounce) <= Config.ComboResetTime and self.M1Combo or 0
    combo = combo + 1
    self.M1Combo = combo
    self.ComboDebounce = tick()
    return combo
end

--====================================================
-- ATTACK AOE
--====================================================
function FastAttack:UseNormalClick(Character)
    local Hits = self:GetBladeHits(Character)
    if #Hits == 0 then return end

    RegisterAttack:FireServer(Config.AttackCooldown)

    for _, hit in ipairs(Hits) do
        RegisterHit:FireServer(hit[2], Hits)
    end
end

function FastAttack:ShootInTarget(pos)
    if tick() - (self.LastShoot or 0) < 0.0001 then return end
    ShootGunEvent:FireServer(pos)
    self.LastShoot = tick()
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local char = Player.Character
    if not char or not self:IsAlive(char) then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tip = tool.ToolTip
    if not table.find({"Melee","Sword","Gun","Blox Fruit"}, tip) then return end

    self:GetCombo()

    if tip == "Gun" then
        local Targets = self:GetBladeHits(char, 120)
        for _, t in ipairs(Targets) do
            self:ShootInTarget(t[2].Position)
        end
    else
        self:UseNormalClick(char)
    end
end

--====================================================
-- GROUND STABILIZER (GIỮ MOB TRÊN MẶT ĐẤT)
--====================================================
function FastAttack:GroundStabilizer()
    if not PosMon then return end
    
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Kiểm tra nếu mob đang ở quá cao
            local groundHeight = self:GetGroundHeight(hrp.Position)
            if hrp.Position.Y > groundHeight + 5 then
                -- Kéo mob xuống mặt đất
                hrp.CFrame = CFrame.new(
                    hrp.Position.X,
                    groundHeight + 2,
                    hrp.Position.Z
                )
                hrp.Velocity = Vector3.new(hrp.Velocity.X, -50, hrp.Velocity.Z)
            end
        end
    end
end

--====================================================
-- START
--====================================================
local AttackInstance = FastAttack.new()

-- Main loop
RunService.Heartbeat:Connect(function()
    AttackInstance:BringEnemy()
    AttackInstance:Attack()
    AttackInstance:GroundStabilizer() -- THÊM STABILIZER
end)

-- Anti-AFK
local VirtualInputManager = game:GetService("VirtualInputManager")
local lastInput = tick()

RunService.Heartbeat:Connect(function()
    if tick() - lastInput > 20 then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
        lastInput = tick()
    end
end)

-- Debug info
spawn(function()
    while task.wait(1) do
        if PosMon and GroundY then
            print(string.format("Player Y: %.1f | Ground Y: %.1f | Difference: %.1f", 
                PosMon.Y, GroundY, PosMon.Y - GroundY))
        end
    end
end)

return FastAttack
