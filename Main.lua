local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--------------------------------------------------------------------------------
-- // CẤU HÌNH GIAO DIỆN //
--------------------------------------------------------------------------------
local Window = Fluent:CreateWindow({
    Title = "Gemini Script | Blox Fruits Bone",
    SubTitle = "Super Fast Attack + Bring",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl 
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farming", Icon = "sword" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--------------------------------------------------------------------------------
-- // 1. TÍCH HỢP SUPER FAST ATTACK (CODE CỦA BẠN) //
--------------------------------------------------------------------------------
-- Biến cấu hình Fast Attack toàn cục để UI điều khiển
getgenv().FastAttackConfig = {
    AttackDistance = 65,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0.0001,
    ComboResetTime = 0.0001,
    MaxCombo = math.huge,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = false -- Mặc định tắt, sẽ bật khi Auto Farm bật
}

spawn(function()
    --// Services
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
            Overheat = {Dragonstorm = {MaxOverheat = 3, Cooldown = 0, TotalOverheat = 0, Distance = 350, Shooting = false}},
            ShootsPerTarget = {["Dual Flintlock"] = 2},
            SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
        }, FastAttack)

        pcall(function()
            self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
            self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
            local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
            if LocalScript and getsenv then
                self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
            end
        end)

        return self
    end

    function FastAttack:IsEntityAlive(entity)
        local humanoid = entity and entity:FindFirstChild("Humanoid")
        return humanoid and humanoid.Health > 0
    end

    function FastAttack:CheckStun(Character, Humanoid, ToolTip)
        local Stun = Character:FindFirstChild("Stun")
        local Busy = Character:FindFirstChild("Busy")
        if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
            return false
        elseif Stun and Stun.Value > 0 or Busy and Busy.Value then
            return false
        end
        return true
    end

    function FastAttack:GetBladeHits(Character, Distance)
        local Position = Character:GetPivot().Position
        local BladeHits = {}
        Distance = Distance or getgenv().FastAttackConfig.AttackDistance

        local function ProcessTargets(Folder)
            for _, Enemy in ipairs(Folder:GetChildren()) do
                if Enemy ~= Character and self:IsEntityAlive(Enemy) then
                    local BasePart = Enemy:FindFirstChild("HumanoidRootPart")
                    if BasePart and (Position - BasePart.Position).Magnitude <= Distance then
                        table.insert(BladeHits, {Enemy, BasePart})
                        if not self.EnemyRootPart then
                            self.EnemyRootPart = BasePart
                        end
                    end
                end
            end
        end

        if getgenv().FastAttackConfig.AttackMobs then ProcessTargets(Workspace.Enemies) end
        if getgenv().FastAttackConfig.AttackPlayers then ProcessTargets(Workspace.Characters) end

        return BladeHits
    end

    function FastAttack:GetCombo()
        local Combo = (tick() - self.ComboDebounce) <= getgenv().FastAttackConfig.ComboResetTime and self.M1Combo or 0
        Combo = Combo + 1
        self.ComboDebounce = tick()
        self.M1Combo = Combo
        return Combo
    end

    function FastAttack:ShootInTarget(TargetPosition)
        local Character = Player.Character
        if not self:IsEntityAlive(Character) then return end

        local Equipped = Character:FindFirstChildOfClass("Tool")
        if not Equipped or Equipped.ToolTip ~= "Gun" then return end

        local Cooldown = 0.0001
        if (tick() - self.ShootDebounce) < Cooldown then return end

        local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
        if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
            Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
            GunValidator:FireServer(self:GetValidator2())

            if ShootType == "TAP" then
                Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
            else
                ShootGunEvent:FireServer(TargetPosition)
            end
            self.ShootDebounce = tick()
        else
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.0001)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            self.ShootDebounce = tick()
        end
    end

    function FastAttack:GetValidator2()
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
    end

    function FastAttack:UseNormalClick(Character, Humanoid, Cooldown)
        local BladeHits = self:GetBladeHits(Character)
        for _, Hit in ipairs(BladeHits) do
            local TargetRoot = Hit[2]
            RegisterAttack:FireServer(Cooldown)
            if self.CombatFlags and self.HitFunction then
                self.HitFunction(TargetRoot, BladeHits)
            else
                RegisterHit:FireServer(TargetRoot, BladeHits)
            end
        end
    end

    function FastAttack:UseFruitM1(Character, Equipped, Combo)
        local Targets = self:GetBladeHits(Character)
        if not Targets[1] then return end

        local Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
        Equipped.LeftClickRemote:FireServer(Direction, Combo)
    end

    function FastAttack:Attack()
        if not getgenv().FastAttackConfig.AutoClickEnabled then return end
        local Character = Player.Character
        if not Character or not self:IsEntityAlive(Character) then return end

        local Humanoid = Character.Humanoid
        local Equipped = Character:FindFirstChildOfClass("Tool")
        if not Equipped then return end

        local ToolTip = Equipped.ToolTip
        if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
        if not self:CheckStun(Character, Humanoid, ToolTip) then return end

        local Combo = self:GetCombo()
        self.Debounce = tick()

        if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
            self:UseFruitM1(Character, Equipped, Combo)
        elseif ToolTip == "Gun" then
            local Targets = self:GetBladeHits(Character, 120)
            for _, t in ipairs(Targets) do
                self:ShootInTarget(t[2].Position)
            end
        else
            self:UseNormalClick(Character, Humanoid, 0.0001)
        end
    end

    -- Khởi chạy Fast Attack Loop
    local AttackInstance = FastAttack.new()
    RunService.Heartbeat:Connect(function()
        AttackInstance:Attack()
    end)
end)

--------------------------------------------------------------------------------
-- // 2. BIẾN & DỊCH VỤ CHÍNH //
--------------------------------------------------------------------------------
_G.AutoFarm_Bone = false
_G.BringMob = false
_G.AcceptQuestC = false
_G.TweenSpeed = 300
_G.MobIndex = 1

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer 

--------------------------------------------------------------------------------
-- // 3. CHỨC NĂNG BRING MOB //
--------------------------------------------------------------------------------
getgenv().BringEnemy = function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        getgenv().PosMon = plr.Character.HumanoidRootPart.Position
    end

    if not _G.BringMob or not getgenv().PosMon then return end
    
    pcall(function()
        sethiddenproperty(plr, "SimulationRadius", math.huge)
    end)

    task.defer(function()
        for _, v in ipairs(workspace.Enemies:GetChildren()) do
            local hum = v:FindFirstChild("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
            
            if hum and hrp and hum.Health > 0 then
                local dist = (hrp.Position - getgenv().PosMon).Magnitude
                if dist <= 350 and isnetworkowner(hrp) then
                    for _, part in ipairs(v:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Anchored = false
                            part.Massless = true
                        end
                    end
                    
                    hum.WalkSpeed, hum.JumpPower = 0, 0
                    hum.PlatformStand = true
                    
                    local anim = hum:FindFirstChildOfClass("Animator")
                    if anim then anim.Parent = nil end
                    
                    for i = 1, 3 do
                        if isnetworkowner(hrp) then
                            hrp.CFrame = CFrame.new(getgenv().PosMon)
                            task.wait(0.05)
                        else
                            break
                        end
                    end
                end
            end
        end
    end)
end

spawn(function()
    while task.wait() do
        if _G.BringMob then
             getgenv()._B = true
             BringEnemy()
        else
             getgenv()._B = false
        end
    end
end)

--------------------------------------------------------------------------------
-- // 4. HÀM HỖ TRỢ & TWEEN //
--------------------------------------------------------------------------------

function GetConnectionEnemies(nameTable)
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        for _, name in pairs(nameTable) do
            if enemy.Name == name and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                return enemy
            end
        end
    end
    return nil
end

spawn(function()
    RunService.Stepped:Connect(function()
        if _G.AutoFarm_Bone then
            pcall(function()
                local char = plr.Character
                if char then
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end
    end)
end)

local currentTween = nil
function _tp(targetCFrame)
    local Character = plr.Character
    if not Character then return end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    if typeof(targetCFrame) == "Vector3" then targetCFrame = CFrame.new(targetCFrame) end

    local Distance = (Root.Position - targetCFrame.Position).Magnitude
    if Distance < 5 then Root.CFrame = targetCFrame; return end

    if currentTween then currentTween:Cancel() end

    local Time = Distance / _G.TweenSpeed
    local TweenInfoData = TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    
    currentTween = TweenService:Create(Root, TweenInfoData, {CFrame = targetCFrame})
    currentTween:Play()
    
    if Distance > 50 then
        local stuckCheck = 0
        repeat 
            task.wait(0.1)
            stuckCheck = stuckCheck + 1
            if not plr.Character or not _G.AutoFarm_Bone then currentTween:Cancel(); break end
            if (plr.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude < 10 then break end
        until stuckCheck > 100
    end
end

--------------------------------------------------------------------------------
-- // 5. UI ELEMENTS //
--------------------------------------------------------------------------------

local Options = Fluent.Options

local ToggleFarm = Tabs.Main:AddToggle("AutoFarmBone", {Title = "Auto Farm Bone (Siêu Tốc)", Default = false })
ToggleFarm:OnChanged(function()
    _G.AutoFarm_Bone = Options.AutoFarmBone.Value
    -- Tự động bật Fast Attack khi bật Auto Farm
    getgenv().FastAttackConfig.AutoClickEnabled = Options.AutoFarmBone.Value 
end)

local ToggleBring = Tabs.Main:AddToggle("AutoBring", {Title = "Bring Mob (Gom quái)", Default = false })
ToggleBring:OnChanged(function()
    _G.BringMob = Options.AutoBring.Value
end)

local ToggleQuest = Tabs.Main:AddToggle("AutoQuest", {Title = "Auto Accept Quest", Default = true })
ToggleQuest:OnChanged(function()
    _G.AcceptQuestC = Options.AutoQuest.Value
end)

local SliderSpeed = Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Tween Speed",
    Description = "Tốc độ bay",
    Default = 300,
    Min = 100,
    Max = 600,
    Rounding = 0,
    Callback = function(Value)
        _G.TweenSpeed = Value
    end
})

--------------------------------------------------------------------------------
-- // 6. LOGIC FARMING CHÍNH //
--------------------------------------------------------------------------------

spawn(function()
    while task.wait() do 
        if _G.AutoFarm_Bone then
            pcall(function()        
                local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                local questUI = plr.PlayerGui.Main.Quest
                local BonesTable = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
                
                if not root then return end
                
                -- Nhận Quest
                if _G.AcceptQuestC and not questUI.Visible then
                      local questPos = CFrame.new(-9516.99316, 172.017181, 6078.46533)
                      if (questPos.Position - root.Position).Magnitude > 20 then
                           _tp(questPos)
                           return
                      else
                           root.CFrame = questPos
                           task.wait(0.2)
                           local randomQuest = math.random(1, 4)
                           local questData = {
                             [1] = {"StartQuest", "HauntedQuest2", 2},
                             [2] = {"StartQuest", "HauntedQuest2", 1},
                             [3] = {"StartQuest", "HauntedQuest1", 1},
                             [4] = {"StartQuest", "HauntedQuest1", 2}
                           }                    
                           game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(questData[randomQuest]))
                           task.wait(0.5)
                      end
                end

                -- Tìm quái để bay tới
                local CurrentTargetName = BonesTable[_G.MobIndex]
                local bone = GetConnectionEnemies({CurrentTargetName})

                if bone and bone:FindFirstChild("Humanoid") and bone.Humanoid.Health > 0 and bone:FindFirstChild("HumanoidRootPart") then
                    repeat 
                        task.wait()
                        if bone and bone.Parent and bone:FindFirstChild("HumanoidRootPart") and bone.Humanoid.Health > 0 then
                            local targetPos = bone.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
                            local dist = (root.Position - targetPos.Position).Magnitude
                            
                            -- Logic bay
                            if dist > 10 then
                                _tp(targetPos)
                            else
                                root.CFrame = targetPos -- Khóa vị trí
                            end
                            
                            -- LƯU Ý: Không cần gọi hàm Attack() ở đây nữa
                            -- Vì Fast Attack đã chạy ngầm bằng Heartbeat ở phần 1 rồi
                            
                            -- Tự trang bị vũ khí (Melee) nếu chưa cầm
                            local Equipped = plr.Character:FindFirstChildOfClass("Tool")
                            if not Equipped then
                                for _, v in pairs(plr.Backpack:GetChildren()) do
                                    if v.ToolTip == "Melee" then
                                        plr.Character.Humanoid:EquipTool(v)
                                        break
                                    end
                                end
                            end

                        else
                            break
                        end
                    until not _G.AutoFarm_Bone or bone.Humanoid.Health <= 0 or not bone.Parent or (_G.AcceptQuestC and not questUI.Visible)
                else
                    _G.MobIndex = _G.MobIndex + 1
                    if _G.MobIndex > #BonesTable then _G.MobIndex = 1 end
                    task.wait(0.2)
                end
            end)
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({
    Title = "Gemini Script",
    Content = "Đã kích hoạt Super Fast Attack + Auto Farm!",
    Duration = 5
})
