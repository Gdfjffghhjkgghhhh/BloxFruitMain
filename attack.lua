local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local Workspace  = game:GetService("Workspace")
local VIM        = game:GetService("VirtualInputManager")

local Player  = Players.LocalPlayer
local Enemies = Workspace:WaitForChild("Enemies")

local Net            = require(RS.Modules.Net)
local RegisterHit    = Net:RemoteEvent("RegisterHit", true)
local RegisterAttack = RS.Modules.Net["RE/RegisterAttack"]
local ShootGun       = RS.Modules.Net["RE/ShootGunEvent"]
local Validator2     = RS:WaitForChild("Remotes"):WaitForChild("Validator2")

local CFG = {
    MobRange    = 65,
    PlayerRange = 65,
    GunRange    = 150,
    MaxTargets  = 20,
    HitRepeat   = 4, -- fire song song, tăng thoải mái không lag
}

local MOB_SQ = CFG.MobRange    ^ 2
local PLR_SQ = CFG.PlayerRange ^ 2

local allBuf = table.create(CFG.MaxTargets)
local _char, _hum, _root, _tool, _pos

local function refreshCache()
    _char = Player.Character
    if not _char then _hum = nil; _root = nil; _tool = nil; _pos = nil; return end
    _hum  = _char:FindFirstChildOfClass("Humanoid")
    _root = _char:FindFirstChild("HumanoidRootPart")
    _tool = _char:FindFirstChildOfClass("Tool")
    _pos  = _root and _root.Position
end

local STUNS = {"Stun","Busy","NoAttack","Attacking"}
local function bypassStun()
    for i = 1, #STUNS do
        local obj = _char:FindFirstChild(STUNS[i])
        if obj then
            local v = obj.Value
            if type(v) == "number"  and v ~= 0   then rawset(obj, "Value", 0)     end
            if type(v) == "boolean" and v == true then rawset(obj, "Value", false) end
        end
    end
end

local function GetAll()
    table.clear(allBuf)
    local pos = _pos
    if not pos then return allBuf end

    local ec = Enemies:GetChildren()
    for i = 1, #ec do
        if #allBuf >= CFG.MaxTargets then break end
        local e = ec[i]
        local hum = e:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local r = e:FindFirstChild("HumanoidRootPart")
            if r then
                local d = r.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= MOB_SQ then
                    allBuf[#allBuf+1] = {e, r}
                end
            end
        end
    end

    local all = Players:GetPlayers()
    for i = 1, #all do
        if #allBuf >= CFG.MaxTargets then break end
        local p = all[i]
        if p ~= Player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = r.Position - pos
                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= PLR_SQ then
                        allBuf[#allBuf+1] = {p.Character, r}
                    end
                end
            end
        end
    end

    return allBuf
end

local FA = {}
FA.__index = FA

function FA.new()
    local self = setmetatable({
        combo  = 0,
        HitFn  = nil,
        SpecialShoot = {
            ["Skull Guitar"] = "TAP",
            ["Bazooka"]      = "Position",
            ["Cannon"]       = "Position",
            ["Dragonstorm"]  = "Overheat",
        },
        MultiShoot = {["Dual Flintlock"] = 2},
    }, FA)

    pcall(function()
        local ls = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if ls and getsenv then
            self.HitFn = getsenv(ls)._G.SendHitsToServer
        end
    end)

    return self
end

function FA:UseNormalClick()
    local targets = GetAll()
    local n = #targets
    if n == 0 then return end

    RegisterAttack:FireServer(0)

    local hitFn = self.HitFn
    for i = 1, n do
        local root = targets[i][2]
        for _ = 1, CFG.HitRepeat do
            task.spawn(function()
                if hitFn then
                    hitFn(root, targets)
                else
                    RegisterHit:FireServer(root, targets)
                end
            end)
        end
    end
end

function FA:UseFruitM1()
    local targets = GetAll()
    if #targets == 0 then return end
    local dir  = (targets[1][2].Position - _pos).Unit
    local lclr = _tool.LeftClickRemote
    local combo = self.combo
    for _ = 1, CFG.HitRepeat do
        task.spawn(function()
            lclr:FireServer(dir, combo)
        end)
    end
end

function FA:ShootTarget(targetPos)
    local tool  = _tool
    local st    = self.SpecialShoot[tool.Name] or "Normal"
    local shots = self.MultiShoot[tool.Name] or 1

    for _ = 1, shots do
        task.spawn(function()
            if st == "Position" then
                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                Validator2:FireServer(math.floor(os.clock() * 1337) % 16777216)
                ShootGun:FireServer(targetPos)
            elseif st == "TAP" then
                local re = tool:FindFirstChild("RemoteEvent")
                if re then
                    tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                    re:FireServer("TAP", targetPos)
                end
            else
                VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                VIM:SendMouseButtonEvent(0,0,0,false,game,1)
            end
        end)
    end
end

function FA:Attack()
    refreshCache()
    if not _char or not _hum or _hum.Health <= 0 then return end
    if not _root or not _tool then return end

    local tip = _tool.ToolTip
    if tip ~= "Melee" and tip ~= "Blox Fruit"
    and tip ~= "Sword" and tip ~= "Gun" then return end

    bypassStun()
    self.combo = (self.combo % 100) + 1

    if tip == "Blox Fruit" and _tool:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1()
    elseif tip == "Gun" then
        local targets = GetAll()
        for i = 1, #targets do
            self:ShootTarget(targets[i][2].Position)
        end
    else
        self:UseNormalClick()
    end
end

local function AutoEquipMelee()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local backpack = Player:WaitForChild("Backpack")

    local current = char:FindFirstChildOfClass("Tool")
    if current and current.ToolTip == "Melee" then return end

    local melee = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Melee" then
            melee = tool
            break
        end
    end

    if not melee then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Melee" then
                melee = tool
                break
            end
        end
    end

    if melee then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(melee) end
    end
end

local inst = FA.new()

pcall(AutoEquipMelee)

RunService.Heartbeat:Connect(function()
    pcall(function() inst:Attack() end)
end)

return FA
