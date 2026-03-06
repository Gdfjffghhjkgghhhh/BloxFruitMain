
--// ════════════════════════════════════════════

--// FAST ATTACK ULTRA EXTREME (2026 Optimized)

--// Đánh cực nhanh hơn bản cũ rất nhiều (double spam + 2 connection + Extreme Mode)

--// ════════════════════════════════════════════

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

--// CONFIG - ĐÃ ĐẨY MAX TỐC ĐỘ

local CFG = {

    MobRange = 65,

    PlayerRange = 65,

    GunRange = 150,

    MaxTargets = 25,           -- tăng để đánh nhiều mục tiêu hơn

    HitsPerFrame = 6,          -- TĂNG MẠNH từ 3 → 8 (có thể chỉnh 6-12)

    AttackMobs = true,

    AttackPlayers = true,

    ExtremeMode = true,        -- BẬT = cực mạnh (spam RegisterAttack gấp đôi)

}

local MOB_SQ = CFG.MobRange * CFG.MobRange

local PLR_SQ = CFG.PlayerRange * CFG.PlayerRange

local GUN_SQ = CFG.GunRange * CFG.GunRange

--// REUSE TABLES (tối ưu tối đa)

local allHits = table.create(CFG.MaxTargets)

local playerHits = table.create(20)

local combinedHits = table.create(CFG.MaxTargets)

--// ALIVE CHECK

local function alive(model)

    local h = model and model:FindFirstChildOfClass("Humanoid")

    return h and h.Health > 0

end

--// GetAllBladeHits (đã inline + tối ưu thứ tự)

local function GetAllBladeHits(pos, mobSq, plrSq)

    table.clear(combinedHits)

    local mSq = mobSq or MOB_SQ

    local pSq = plrSq or PLR_SQ

    -- Mobs trước (nhanh hơn)

    if CFG.AttackMobs then

        table.clear(allHits)

        for _, e in ipairs(Enemies:GetChildren()) do

            if #combinedHits >= CFG.MaxTargets then break end

            if alive(e) then

                local r = e:FindFirstChild("HumanoidRootPart")

                if r then

                    local d = r.Position - pos

                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= mSq then

                        combinedHits[#combinedHits+1] = {e, r}

                    end

                end

            end

        end

    end

    -- Players sau

    if CFG.AttackPlayers then

        table.clear(playerHits)

        for _, plr in ipairs(Players:GetPlayers()) do

            if #combinedHits >= CFG.MaxTargets then break end

            if plr ~= Player and plr.Character and alive(plr.Character) then

                local r = plr.Character:FindFirstChild("HumanoidRootPart")

                if r then

                    local d = r.Position - pos

                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= pSq then

                        combinedHits[#combinedHits+1] = {plr.Character, r}

                    end

                end

            end

        end

    end

    return combinedHits

end

--// FAST ATTACK CLASS

local FA = {}

FA.__index = FA

function FA.new()

    local self = setmetatable({

        combo = 0,

        Connections = {},

        HitFn = nil,

        SpecialShoot = {

            ["Skull Guitar"] = "TAP",

            ["Bazooka"] = "Position",

            ["Cannon"] = "Position",

            ["Dragonstorm"] = "Overheat",

        },

        ShootsPerTarget = { ["Dual Flintlock"] = 2 },

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

--// USE NORMAL CLICK - ULTRA SPAM

function FA:UseNormalClick(pos)

    local targets = GetAllBladeHits(pos)

    if #targets == 0 then return end

    if CFG.ExtremeMode then

        -- Cách cực mạnh: spam RegisterAttack trước rồi mới hit (tăng combo điên cuồng)

        for _ = 1, CFG.HitsPerFrame * 2 do

            pcall(function() RegisterAttack:FireServer(0) end)

        end

        for _ = 1, CFG.HitsPerFrame do

            for i = 1, #targets do

                self:FireHit(targets[i][2], targets)

            end

        end

    else

        -- Cách an toàn hơn

        for _ = 1, CFG.HitsPerFrame do

            pcall(function() RegisterAttack:FireServer(0) end)

            for i = 1, #targets do

                self:FireHit(targets[i][2], targets)

            end

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

--// Gun Shoot

function FA:ShootTarget(tool, targetPos)

    local st = self.SpecialShoot[tool.Name] or "Normal"

    local shots = self.ShootsPerTarget[tool.Name] or 1

    for _ = 1, shots do

        pcall(function()

            if st == "Position" then

                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)

                local Validator = RS:WaitForChild("Remotes"):WaitForChild("Validator2")

                Validator:FireServer(math.floor(os.clock() * 1337) % 16777216)

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

--// MAIN ATTACK

function FA:Attack()

    local char = Player.Character

    if not char or not alive(char) then return end

    local root = char:FindFirstChild("HumanoidRootPart")

    local tool = char:FindFirstChildOfClass("Tool")

    if not root or not tool then return end

    local tip = tool.ToolTip

    if not (tip == "Melee" or tip == "Blox Fruit" or tip == "Sword" or tip == "Gun") then return end

    -- Bypass stun/busy cực mạnh

    pcall(function()

        for _, name in {"Stun", "Busy", "NoAttack", "Attacking"} do

            local obj = char:FindFirstChild(name)

            if obj then

                if typeof(obj.Value) == "number" then obj.Value = 0

                elseif typeof(obj.Value) == "boolean" then obj.Value = false end

            end

        end

    end)

    local pos = root.Position

    local combo = self:GetCombo()

    if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then

        self:UseFruitM1(pos, tool, combo)

    elseif tip == "Gun" then

        local targets = GetAllBladeHits(pos, GUN_SQ, GUN_SQ)

        for i = 1, #targets do

            self:ShootTarget(tool, targets[i][2].Position)

        end

    else

        self:UseNormalClick(pos)

    end

end

local inst = FA.new()
table.insert(inst.Connections, RunService.RenderStepped:Connect(function()
    inst:Attack()
end))
table.insert(inst.Connections, RunService.Heartbeat:Connect(function()

    inst:Attack()

end))

print("✅ FAST ATTACK ULTRA EXTREME LOADED! (đánh cực nhanh hơn bản cũ rất nhiều)")

return FA
