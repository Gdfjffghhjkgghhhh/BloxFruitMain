loadstring(game:HttpGet("https://raw.githubusercontent.com/Gdfjffghhjkgghhhh/WbmxHubNew/refs/heads/main/UnBanFastAttack.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

-- CONFIG
local AttackDistance = 200
local HitMultiplier = 3

local function Alive(entity)
    local hum = entity:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function GetTargets()
    local targets = {}

    local char = Player.Character
    if not char then return targets end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end

    local pos = root.Position

    -- MOBS
    for _,v in ipairs(Workspace.Enemies:GetChildren()) do
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if hrp and Alive(v) then
            if (hrp.Position - pos).Magnitude <= AttackDistance then
                table.insert(targets,{v,hrp})
            end
        end
    end

    -- PLAYERS
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and Alive(plr.Character) then
                if (hrp.Position - pos).Magnitude <= AttackDistance then
                    table.insert(targets,{plr.Character,hrp})
                end
            end
        end
    end

    return targets
end

local function UltraAttack()
    local char = Player.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local targets = GetTargets()
    if #targets == 0 then return end

    -- REGISTER ATTACK
    pcall(function()
        RegisterAttack:FireServer(0)
    end)

    -- SPAM HITS
    for i = 1, HitMultiplier do
        for _,target in ipairs(targets) do
            pcall(function()
                RegisterHit:FireServer(target[2],targets)
            end)
        end
    end
end

-- LOOP ULTRA FAST
task.spawn(function()
    while true do
        UltraAttack()
        task.wait(0)
    end
end)
