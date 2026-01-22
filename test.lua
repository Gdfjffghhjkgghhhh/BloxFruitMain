--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// LOCALS
local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

--// REMOTES
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")

--// CONFIG TỰ ĐỘNG
local Config = {
    Enabled = true,  -- LUÔN BẬT
    AttackDistance = 150,  -- Tầm xa
    AttackSpeed = 0.001,   -- Cực nhanh
    AutoStart = true,      -- Tự động chạy
    DebugMode = false      -- Hiển thị log
}

--// AUTO ATTACK SYSTEM
local AutoAttack = {
    IsAttacking = false,
    LastAttackTime = 0,
    CurrentWeapon = nil,
    TargetCache = {},
    AttackCount = 0,
    
    -- Các remotes phát hiện tự động
    FoundRemotes = {},
    
    -- Danh sách weapon types
    WeaponTypes = {
        Melee = {"Melee", "Sword", "Katana", "Blade"},
        Gun = {"Gun", "Rifle", "Pistol", "Shotgun"},
        Fruit = {"Blox Fruit", "Devil Fruit", "Fruit"}
    }
}

-- TỰ ĐỘNG KHỞI ĐỘNG
function AutoAttack:AutoInitialize()
    print("🤖 AUTO ATTACK SYSTEM INITIALIZING...")
    
    -- Tìm tất cả remote có thể dùng
    self:ScanForRemotes()
    
    -- Tự động bắt đầu tấn công
    self:StartAutoAttack()
    
    -- Auto equip detection
    self:SetupWeaponDetection()
    
    print("✅ AUTO ATTACK READY - ALWAYS ON")
end

-- Quét remotes tự động
function AutoAttack:ScanForRemotes()
    local found = {}
    
    -- Quét trong Net
    for _, remote in pairs(Net:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            table.insert(found, remote)
            if Config.DebugMode then
                print("📡 Found remote: " .. remote.Name)
            end
        end
    end
    
    -- Quét toàn bộ game cho combat remotes
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:find("Hit") or obj.Name:find("Attack") or obj.Name:find("Damage")) then
            table.insert(found, obj)
        end
    end
    
    self.FoundRemotes = found
    return found
end

-- Tự động phát hiện vũ khí
function AutoAttack:DetectWeaponType(tool)
    if not tool then return nil end
    
    local name = tool.Name:lower()
    local toolTip = tool.ToolTip or ""
    
    for weaponType, keywords in pairs(self.WeaponTypes) do
        for _, keyword in ipairs(keywords) do
            if name:find(keyword:lower()) or toolTip:find(keyword) then
                return weaponType
            end
        end
    end
    
    return "Unknown"
end

-- Quét mục tiêu tự động
function AutoAttack:AutoScanTargets()
    local character = Player.Character
    if not character then return {} end
    
    local charPos = character:GetPivot().Position
    local targets = {}
    local count = 0
    
    -- QUÉT TẤT CẢ MODEL CÓ THỂ TẤN CÔNG
    for _, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model ~= character then
            local humanoid = model:FindFirstChild("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local dist = (charPos - hrp.Position).Magnitude
                if dist <= Config.AttackDistance then
                    count = count + 1
                    targets[count] = {
                        Model = model,
                        HRP = hrp,
                        Humanoid = humanoid,
                        Distance = dist
                    }
                    
                    if count >= 20 then break end -- Giới hạn
                end
            end
        end
    end
    
    self.TargetCache = targets
    return targets
end

-- TẤN CÔNG MELEE TỰ ĐỘNG
function AutoAttack:AutoMeleeAttack()
    local targets = self:AutoScanTargets()
    if #targets == 0 then return end
    
    local now = tick()
    if now - self.LastAttackTime < Config.AttackSpeed then return end
    self.LastAttackTime = now
    
    -- Gửi attack event
    pcall(function()
        RegisterAttack:FireServer(Config.AttackSpeed)
    end)
    
    -- TẤN CÔNG TẤT CẢ MỤC TIÊU
    for _, target in ipairs(targets) do
        local hrp = target.HRP
        
        -- Gửi qua nhiều remote khác nhau
        for _, remote in ipairs(self.FoundRemotes) do
            pcall(function()
                remote:FireServer(hrp, {hrp})
                remote:FireServer(hrp, {hrp}, "AutoHit")
            end)
        end
        
        -- Gửi hit chính
        pcall(function()
            RegisterHit:FireServer(hrp, {hrp})
        end)
        
        self.AttackCount = self.AttackCount + 1
    end
end

-- TẤN CÔNG GUN TỰ ĐỘNG
function AutoAttack:AutoGunAttack()
    local targets = self:AutoScanTargets()
    if #targets == 0 then return end
    
    local now = tick()
    if now - self.LastAttackTime < 0.05 then return end
    self.LastAttackTime = now
    
    -- BẮN TẤT CẢ MỤC TIÊU
    for _, target in ipairs(targets) do
        pcall(function()
            ShootGunEvent:FireServer(target.HRP.Position)
            -- Bắn thêm lần nữa
            ShootGunEvent:FireServer(target.HRP.Position + Vector3.new(0, 2, 0))
        end)
        
        self.AttackCount = self.AttackCount + 1
    end
end

-- TẤN CÔNG FRUIT TỰ ĐỘNG
function AutoAttack:AutoFruitAttack()
    local character = Player.Character
    if not character then return end
    
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped or not equipped:FindFirstChild("LeftClickRemote") then return end
    
    local targets = self:AutoScanTargets()
    if #targets == 0 then return end
    
    local now = tick()
    if now - self.LastAttackTime < 0.1 then return end
    self.LastAttackTime = now
    
    -- Tấn công target gần nhất
    local closest = targets[1]
    if closest then
        local charPos = character:GetPivot().Position
        local direction = (closest.HRP.Position - charPos).Unit
        
        pcall(function()
            equipped.LeftClickRemote:FireServer(direction, 1)
            -- Gửi thêm
            equipped.LeftClickRemote:FireServer(direction, 2)
        end)
        
        self.AttackCount = self.AttackCount + 1
    end
end

-- HÀM CHÍNH TỰ ĐỘNG
function AutoAttack:AutoAttackLoop()
    if not Config.Enabled then return end
    
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Tự động tìm vũ khí
    local equipped = character:FindFirstChildOfClass("Tool")
    if not equipped then
        -- Tự động equip vũ khí đầu tiên trong backpack
        self:AutoEquipWeapon()
        return
    end
    
    -- Phát hiện loại vũ khí và tấn công
    local weaponType = self:DetectWeaponType(equipped)
    
    if weaponType == "Melee" then
        self:AutoMeleeAttack()
    elseif weaponType == "Gun" then
        self:AutoGunAttack()
    elseif weaponType == "Fruit" then
        self:AutoFruitAttack()
    else
        -- Thử tất cả các phương pháp
        self:AutoMeleeAttack()
        self:AutoGunAttack()
    end
end

-- TỰ ĐỘNG EQUIP VŨ KHÍ
function AutoAttack:AutoEquipWeapon()
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return end
    
    -- Tìm vũ khí đầu tiên
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function()
                Player.Character.Humanoid:EquipTool(tool)
                self.CurrentWeapon = tool
                if Config.DebugMode then
                    print("🔫 Auto-equipped: " .. tool.Name)
                end
            end)
            break
        end
    end
end

-- Thiết lập phát hiện weapon
function AutoAttack:SetupWeaponDetection()
    local character = Player.Character or Player.CharacterAdded:Wait()
    
    -- Theo dõi khi thay đổi tool
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            self.CurrentWeapon = child
            if Config.DebugMode then
                print("🔄 Weapon changed to: " .. child.Name)
            end
        end
    end)
    
    Player.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                self.CurrentWeapon = child
            end
        end)
    end)
end

-- BẮT ĐẦU TẤN CÔNG TỰ ĐỘNG
function AutoAttack:StartAutoAttack()
    if self.IsAttacking then return end
    self.IsAttacking = true
    
    print("⚡ AUTO ATTACK STARTED - ATTACKING EVERYTHING")
    
    -- VÒNG LẶP TẤN CÔNG LIÊN TỤC
    local attackLoop
    attackLoop = RunService.Heartbeat:Connect(function()
        if Config.Enabled then
            pcall(function()
                self:AutoAttackLoop()
            end)
        end
    end)
    
    -- Auto stats display
    task.spawn(function()
        while task.wait(5) do
            if self.AttackCount > 0 then
                print(string.format("📊 Auto Stats: %d attacks | %d targets in range", 
                    self.AttackCount, #self.TargetCache))
            end
        end
    end)
end

-- TỰ ĐỘNG CHẠY KHI LOAD GAME
task.wait(2) -- Đợi game load
AutoAttack:AutoInitialize()

-- TỰ ĐỘNG KHI RESPAWN
Player.CharacterAdded:Connect(function()
    task.wait(1) -- Đợi character load
    AutoAttack:StartAutoAttack()
end)

-- TỰ ĐỘNG BẬT LẠI NẾU BỊ TẮT
task.spawn(function()
    while task.wait(1) do
        if not Config.Enabled then
            Config.Enabled = true -- Luôn bật lại
            print("🔁 Auto-reenabled attack system")
        end
    end
end)

-- ANTI-AFK TỰ ĐỘNG
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    while task.wait(60) do
        pcall(function()
            -- Di chuyển chuột để không bị AFK
            VirtualInputManager:SendMouseMoveEvent(5, 5)
            task.wait(0.1)
            VirtualInputManager:SendMouseMoveEvent(-5, -5)
        end)
    end
end)

-- AUTO TẤN CÔNG KHI CÓ ENEMY XUẤT HIỆN
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Enemies" or child.Name == "Characters" then
        task.wait(0.5) -- Đợi model load
        if Config.DebugMode then
            print("🎯 New enemy folder detected, attacking...")
        end
    elseif child:IsA("Model") and child:FindFirstChild("Humanoid") then
        -- Nếu có enemy mới xuất hiện, tấn công ngay
        task.wait(0.2)
        if Config.Enabled then
            AutoAttack:AutoAttackLoop()
        end
    end
end)

print([[
██████╗ ███████╗██████╗ ██╗   ██╗███████╗██████╗ ███████╗
██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗██╔════╝
██████╔╝█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝███████╗
██╔══██╗██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║
██████╔╝███████╗██████╔╝ ╚████╔╝ ███████╗██║  ██║███████║
╚═════╝ ╚══════╝╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝
                                                        
╔══════════════════════════════════════════════════════╗
║                🤖 AUTO ATTACK SYSTEM                 ║
║                Status: ALWAYS ACTIVE                 ║
║                                                      ║
║  Features:                                          ║
║  • Auto-detect weapons                             ║
║  • Auto-scan for enemies                           ║
║  • Auto-equip weapons                              ║
║  • Auto-attack on spawn                            ║
║  • Never turns off                                 ║
║  • Anti-AFK protection                             ║
║                                                      ║
║  Range: ]] .. Config.AttackDistance .. [[ studs               ║
║  Speed: ]] .. Config.AttackSpeed .. [[s/attack              ║
╚══════════════════════════════════════════════════════╝]])
