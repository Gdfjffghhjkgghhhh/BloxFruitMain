--[[ 
    FAST ATTACK BYPASS (STEALTH OPTIMIZED)
    - Bypass: Sử dụng hàm nội bộ của LocalScript để đánh.
    - Hiệu quả: Giảm thiểu rủi ro Kick "Unexpected Client Behavior".
    - Tốc độ: Ép xung dựa trên giới hạn xử lý của Server.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegAtk = Net:WaitForChild("RE/RegisterAttack")
local RegHit = Net:WaitForChild("RE/RegisterHit")

local Config = {
    Dist = 200,
    -- Điểm ngọt (Sweet Spot): Server thường nhận ~30-40 hit/s ổn định nhất.
    MaxBatch = 100, 
    BypassDetection = true
}

-- Tìm kiếm hàm đánh gốc của Game để Bypass
local InternalHitFunc = nil
pcall(function()
    for _, v in pairs(getnilcontents()) do -- Hoặc quét qua PlayerScripts
        if v:IsA("LocalScript") and v.Name == "CombatFramework" then
            local env = getsenv(v)
            if env and env.SendHit then
                InternalHitFunc = env.SendHit
            end
        end
    end
end)

local function GetAllTargets()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    
    local targets = {}
    -- Quét diện rộng cả Quái và Người để dồn dam
    for _, folderName in ipairs({"Enemies", "Characters"}) do
        local f = workspace:FindFirstChild(folderName)
        if f then
            for _, e in ipairs(f:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                    local eroot = e:FindFirstChild("HumanoidRootPart")
                    if eroot and (root.Position - eroot.Position).Magnitude <= Config.Dist then
                        table.insert(targets, {e, e:FindFirstChild("Head") or eroot})
                    end
                end
            end
        end
    end
    return targets
end

local function BypassAttack()
    local targets = GetAllTargets()
    if #targets == 0 then return end
    
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    
    -- Tự điều chỉnh tốc độ: Ping càng thấp, độ tin cậy càng cao -> Batch càng lớn
    local batchSize = math.clamp(math.floor(500 / (ping + 5)), 5, Config.MaxBatch)

    -- BYPASS LOGIC:
    -- Nếu tìm thấy hàm gốc, sử dụng nó (Cực kỳ an toàn)
    if InternalHitFunc and Config.BypassDetection then
        for i = 1, batchSize do
            InternalHitFunc(targets[1][1], targets)
        end
    else
        -- Nếu không, sử dụng phương pháp dồn nén gói tin (Fastest fallback)
        RegAtk:FireServer(0)
        for i = 1, batchSize do
            RegHit:FireServer(targets[1][2], targets)
        end
    end
end

-- Chạy bằng cơ chế Task Scheduler (Nhanh hơn Loop thường)
task.spawn(function()
    while true do
        local start = tick()
        pcall(BypassAttack)
        -- Tự động nghỉ dựa trên hiệu năng máy để không bị Drop FPS
        local waitTime = (tick() - start) > 0.01 and 0.01 or 0
        task.wait(waitTime)
    end
end)

print("🚀 BYPASS MODE: ACTIVATED (STEALTH)")
