

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Enemies = Workspace:WaitForChild("Enemies")

--// REMOTES
local Net = require(RS.Modules.Net)
local RegisterHit = Net:RemoteEvent("RegisterHit", true)
local RegisterAttack = RS.Modules.Net["RE/RegisterAttack"]

--// CONFIG (đã chỉnh tối ưu nhất)
local CFG = {
    MobRange = 65,
    PlayerRange = 65,
    GunRange = 150,
    MaxTargets = 25,
    HitsPerFrame = 5,        -- 5 là con số vàng (nhanh mà không delay)
    AttackMobs = true,
    AttackPlayers = true,
}

local MOB_SQ = CFG.MobRange * CFG.MobRange
local PLR_SQ = CFG.PlayerRange * CFG.PlayerRange
local GUN_SQ = CFG.GunRange * CFG.GunRange

--// REUSE TABLES
local allHits = table.create(CFG.MaxTargets)
local playerHits = table.create(20)
local combinedHits = table.create(CFG.MaxTargets)

local function alive(model)
    local h = model and model:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

--// GetAllBladeHits (tối ưu nhất)
local function GetAllBladeHits(pos)
    table.clear(combinedHits)
    local pos = pos

    -- Mobs
    if CFG.AttackMobs then
        for _, e in ipairs(Enemies:GetChildren()) do
            if #combinedHits >= CFG.MaxTargets then break end
            if alive(e) then
                local r = e:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = r.Position - pos
                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= MOB_SQ then
                        combinedHits[#combinedHits+1] = {e, r}
                    end
                end
            end
        end
    end

    -- Players
    if CFG.AttackPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if #combinedHits >= CFG.MaxTargets then break end
            if plr ~= Player and plr.Character and alive(plr.Character) then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = r.Position - pos
                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= PLR_SQ then
                        combinedHits[#combinedHits+1] = {plr.Character, r}
                    end
                end
            end
        end
    end
    return combinedHits
end

--// CLASS
local FA = {}
FA.__index = FA

function FA.new()
    local self = setmetatable({
        combo = 0,
        HitFn = nil,
    }, FA)

    pcall(function()
        self.HitFn = getsenv(Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript"))._G.SendHitsToServer
    end)
    return self
end

function FA:GetCombo()
    self.combo = (self.combo % 100) + 1
    return self.combo
end

function FA:FireHit(targetRoot, targetList)
    pcall(function()
        if self.HitFn then
            self.HitFn(targetRoot, targetList)
        else
            RegisterHit:FireServer(targetRoot, targetList)
        end
    end)
end

--// NORMAL ATTACK (đã fix delay)
function FA:UseNormalClick(pos)
    local targets = GetAllBladeHits(pos)
    if #targets == 0 then return end

    for _ = 1, CFG.HitsPerFrame do
        pcall(function() RegisterAttack:FireServer(0) end)   -- chỉ 1 lần RegisterAttack mỗi hit cycle
        for i = 1, #targets do
            self:FireHit(targets[i][2], targets)
        end
    end
end

--// Fruit M1
function FA:UseFruitM1(pos, tool, combo)
    local targets = GetAllBladeHits(pos)
    if #targets == 0 then return end
    local dir = (targets[1][2].Position - pos).Unit
    pcall(function() tool.LeftClickRemote:FireServer(dir, combo) end)
end

--// Gun
function FA:ShootTarget(tool, targetPos)
    local st = ({
        ["Skull Guitar"] = "TAP",
        ["Bazooka"] = "Position",
        ["Cannon"] = "Position",
        ["Dragonstorm"] = "Overheat",
    })[tool.Name] or "Normal"

    local shots = ({["Dual Flintlock"] = 2})[tool.Name] or 1

    for _ = 1, shots do
        pcall(function()
            if st == "Position" then
                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                RS:WaitForChild("Remotes").Validator2:FireServer(math.floor(os.clock() * 1337) % 16777216)
                RS.Modules.Net["RE/ShootGunEvent"]:FireServer(targetPos)
            elseif st == "TAP" and tool:FindFirstChild("RemoteEvent") then
                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                tool.RemoteEvent:FireServer("TAP", targetPos)
            else
                VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                VIM:SendMouseButtonEvent(0,0,0,false,game,1)
            end
        end)
    end
end

--// MAIN
function FA:Attack()
    local char = Player.Character
    if not char or not alive(char) then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not root or not tool then return end

    local tip = tool.ToolTip
    if not (tip == "Melee" or tip == "Blox Fruit" or tip == "Sword" or tip == "Gun") then return end

    -- Bypass stun
    pcall(function()
        for _, v in {"Stun","Busy","NoAttack","Attacking"} do
            local obj = char:FindFirstChild(v)
            if obj then
                if typeof(obj.Value) == "number" then obj.Value = 0
                else obj.Value = false end
            end
        end
    end)

    local pos = root.Position
    local combo = self:GetCombo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(pos, tool, combo)
    elseif tip == "Gun" then
        local targets = GetAllBladeHits(pos)
        for i = 1, #targets do
            self:ShootTarget(tool, targets[i][2].Position)
        end
    else
        self:UseNormalClick(pos)
    end
end

local inst = FA.new()
inst.Connection = RunService.Heartbeat:Connect(function()
    inst:Attack()
end)

return FA
