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
    BringDistance = 350,
    AttackDistance = 70,
    AttackCooldown = 0.0001,
    ComboResetTime = 0.03,
    AutoClickEnabled = true,
    MaxTargets = 5,
    KeepMobsOnGround = true,
    MobHeightOffset = -5,
    BringSpeed = 1 -- Tốc độ kéo mob (0.1-1.0)
}

--====================================================
-- GLOBAL
--====================================================
local PosMon = nil

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
        LastShoot = 0
    }, FastAttack)
end

--====================================================
-- UTILS
--====================================================
function FastAttack:IsAlive(model)
    local hum = model and model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

--====================================================
-- UPDATE POSMON
--====================================================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        PosMon = char.HumanoidRootPart.Position
    end
end)

--====================================================
-- BRING MOB (AOE) - FIXED VERSION
--====================================================
function FastAttack:BringEnemy()
    if not Config.Bring or not PosMon then return end

    local char = Player.Character
    if not char then return end
    
    local playerHrp = char:FindFirstChild("HumanoidRootPart")
    if not playerHrp then return end

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then
            local distance = (hrp.Position - PosMon).Magnitude
            
            if distance <= Config.BringDistance then
                -- Disable physics để mob không bay lên
                for _, part in ipairs(mob:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = true
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                    end
                end

                hum.JumpPower = 0
                
                -- Tính toán vị trí target
                local targetPos
                if Config.KeepMobsOnGround then
                    -- Giữ mob dưới chân player với offset
                    targetPos = Vector3.new(
                        playerHrp.Position.X,
                        playerHrp.Position.Y + Config.MobHeightOffset,
                        playerHrp.Position.Z
                    )
                    
                    -- Đảm bảo mob không xuống quá thấp (giữ trên mặt đất)
                    local ray = Ray.new(Vector3.new(targetPos.X, targetPos.Y + 50, targetPos.Z), Vector3.new(0, -100, 0))
                    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {char, mob})
                    
                    if hit then
                        -- Nếu mob xuống quá thấp, đưa lên trên mặt đất 2 stud
                        targetPos = Vector3.new(targetPos.X, math.max(position.Y + 2, targetPos.Y), targetPos.Z)
                    end
                else
                    -- Giữ mob ở độ cao hiện tại
                    targetPos = Vector3.new(
                        playerHrp.Position.X,
                        hrp.Position.Y,
                        playerHrp.Position.Z
                    )
                end
                
                -- Tạo một vòng tròn xung quanh player để mob không dồn vào 1 điểm
                local angle = tick() * 2 + (_ * 0.5)  -- Tạo chuyển động xoay
                local radius = math.min(distance * 0.1, 15)  -- Bán kính tối đa 15 stud
                
                targetPos = Vector3.new(
                    targetPos.X + math.cos(angle) * radius,
                    targetPos.Y,
                    targetPos.Z + math.sin(angle) * radius
                )
                
                -- Di chuyển mượt mà đến target position
                local currentPos = hrp.Position
                local direction = (targetPos - currentPos)
                local moveDistance = math.min(direction.Magnitude, Config.BringSpeed * 30)
                
                if moveDistance > 0.5 then
                    local newPos = currentPos + direction.Unit * moveDistance
                    hrp.CFrame = CFrame.new(newPos, newPos + playerHrp.CFrame.LookVector)
                end
                
                -- Reset mob về tư thế đứng
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
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
-- VISUAL EFFECT (TUỲ CHỌN)
--====================================================
function FastAttack:CreateVisualRing()
    if not Player.Character then return end
    
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Tạo một vòng tròn để hiển thị phạm vi kéo mob
    local ring = Instance.new("Part")
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = EnumMaterial.Neon
    ring.Color = Color3.fromRGB(255, 50, 50)
    ring.Transparency = 0.7
    ring.Size = Vector3.new(1, 0.2, 1)
    ring.Shape = Enum.PartType.Cylinder
    
    local mesh = Instance.new("SpecialMesh", ring)
    mesh.MeshType = Enum.MeshType.Cylinder
    mesh.Scale = Vector3.new(Config.BringDistance * 2, 0.1, Config.BringDistance * 2)
    
    ring.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(90), 0, 0)
    ring.Parent = Workspace
    
    game:GetService("Debris"):AddItem(ring, 0.1)
end

--====================================================
-- START
--====================================================
local AttackInstance = FastAttack.new()

-- Main loop
RunService.Heartbeat:Connect(function()
    AttackInstance:BringEnemy()
    AttackInstance:Attack()
    
    -- Hiển thị visual ring mỗi 0.5 giây (tuỳ chọn)
    if tick() % 0.5 < 0.016 then
        AttackInstance:CreateVisualRing()
    end
end)

-- Anti-AFK
local VirtualInputManager = game:GetService("VirtualInputManager")
local lastInput = tick()

RunService.Heartbeat:Connect(function()
    if tick() - lastInput > 20 then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
        lastInput = tick()
    end
end)

print("Fast Attack Script Loaded Successfully!")
print("Config:")
for key, value in pairs(Config) do
    print(string.format("  %s: %s", key, tostring(value)))
end

return FastAttack
