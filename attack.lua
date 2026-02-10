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

--====================================================
-- CONFIG
--====================================================
local Config = {
    Bring = true,
    MaxMobs = 4,              -- 🔥 GOM TỐI ĐA 4 CON
    BringDistance = 350,
    AttackDistance = 70,
    AttackCooldown = 0.0001,
    AutoClickEnabled = true,
    CircleRadius = 6          -- bán kính xếp tròn
}

--====================================================
-- GLOBAL
--====================================================
local PosMon = nil

pcall(function()
    sethiddenproperty(Player, "SimulationRadius", math.huge)
end)

--====================================================
-- FAST ATTACK CLASS
--====================================================
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    return setmetatable({
        ComboDebounce = 0,
        M1Combo = 0
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
-- LẤY TÊN QUÁI THEO QUEST
--====================================================
function FastAttack:GetQuestMobName()
    local gui = Player.PlayerGui:FindFirstChild("Main")
    if not gui then return nil end

    local quest = gui:FindFirstChild("Quest")
    if not quest then return nil end

    local title = quest:FindFirstChild("QuestTitle")
    if title and title.Text then
        -- Ví dụ: "Defeat 8 Bandits (0/8)"
        local name = title.Text:match("Defeat%s+(.+)%s+%(")
        return name
    end
    return nil
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
-- BRING MOB (MAX 4 - GOM TRÒN - CÙNG QUEST)
--====================================================
function FastAttack:BringEnemy()
    if not Config.Bring or not PosMon then return end

    local QuestMob = self:GetQuestMobName()
    if not QuestMob then return end

    local selected = {}

    -- chọn tối đa 4 quái cùng quest
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if #selected >= Config.MaxMobs then break end

        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 and mob.Name:find(QuestMob) then
            if (hrp.Position - PosMon).Magnitude <= Config.BringDistance then
                table.insert(selected, mob)
            end
        end
    end

    -- xếp vòng tròn
    for i, mob in ipairs(selected) do
        local hum = mob.Humanoid
        local hrp = mob.HumanoidRootPart

        for _, part in ipairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Massless = true
            end
        end

        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.AutoRotate = false

        local angle = (math.pi * 2 / #selected) * (i - 1)
        local offset = Vector3.new(
            math.cos(angle) * Config.CircleRadius,
            0,
            math.sin(angle) * Config.CircleRadius
        )

        local groundY = hrp.Position.Y
        local targetPos = Vector3.new(
            PosMon.X + offset.X,
            groundY,
            PosMon.Z + offset.Z
        )

        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos), 0.35)
    end
end

--====================================================
-- GET HITS (CHỈ 4 CON)
--====================================================
function FastAttack:GetBladeHits(Character, Distance)
    local Hits = {}
    Distance = Distance or Config.AttackDistance
    local Pos = Character:GetPivot().Position
    local QuestMob = self:GetQuestMobName()

    if not QuestMob then return Hits end

    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if #Hits >= Config.MaxMobs then break end

        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 and mob.Name:find(QuestMob) then
            if (hrp.Position - Pos).Magnitude <= Distance then
                table.insert(Hits, {mob, hrp})
            end
        end
    end

    return Hits
end

--====================================================
-- FAST ATTACK AOE (4 CON)
--====================================================
function FastAttack:UseNormalClick(Character)
    local Hits = self:GetBladeHits(Character)
    if #Hits == 0 then return end

    RegisterAttack:FireServer(Config.AttackCooldown)

    for _, hit in ipairs(Hits) do
        RegisterHit:FireServer(hit[2], Hits)
    end
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled then return end

    local char = Player.Character
    if not char or not self:IsAlive(char) then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tip = tool.ToolTip
    if not table.find({"Melee","Sword","Blox Fruit"}, tip) then return end

    self:UseNormalClick(char)
end

--====================================================
-- START
--====================================================
local AttackInstance = FastAttack.new()

RunService.Heartbeat:Connect(function()
    AttackInstance:BringEnemy()
    AttackInstance:Attack()
end)

return FastAttack
