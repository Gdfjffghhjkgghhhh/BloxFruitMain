local Windy = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Gdfjffghhjkgghhhh/BloxFruitMain/refs/heads/main/guinew.lua"
))()

local Status = Windy:CreateTab("Status Server")
local SettingTab = Windy:CreateTab("Setting Farm")
local MainTab = Windy:CreateTab("Main Farming")
local Items = Windy:CreateTab("Update Items")
local MiscFarming = Windy:CreateTab("Misc Farming")
local Travel = Windy:CreateTab("Travel")
local Fruit = Windy:CreateTab("Raid and Fruit")
local Race = Windy:CreateTab("Race V4")
local Seaevent = Windy:CreateTab("Sea Event")
local Dojo = Windy:CreateTab("Prehistoric and Dojo")
local Shop = Windy:CreateTab("Shop")
local Pvp = Windy:CreateTab("Pvp")
local MiscTab = Windy:CreateTab("Misc")

Windy:AddSection(SettingTab, "Cài đặt vũ khí")

Windy:AddDropdown(SettingTab, "Select Weapon", {"Mele", "Swords", "Gun", "Fruit"}, "Mele", function(Value)
    _G.SelectWeapon = Value
end)
spawn(function()
  while wait(Sec) do
    pcall(function()
      if _G.ChooseWP == "Melee" then
        for _,v in pairs(plr.Backpack:GetChildren()) do
	      if v.ToolTip == "Melee" then
		    if plr.Backpack:FindFirstChild(tostring(v.Name)) then
	          _G.SelectWeapon = v.Name              
            end
          end
        end
   	  elseif _G.ChooseWP == "Sword" then     
	    for _,v in pairs(plr.Backpack:GetChildren()) do
	      if v.ToolTip == "Sword" then
		    if plr.Backpack:FindFirstChild(tostring(v.Name)) then
		      _G.SelectWeapon = v.Name              
            end
          end
        end
      elseif _G.ChooseWP == "Gun" then     
	     for _,v in pairs(plr.Backpack:GetChildren()) do
	       if v.ToolTip == "Gun" then
		    if plr.Backpack:FindFirstChild(tostring(v.Name)) then
		      _G.SelectWeapon = v.Name              
            end
          end
        end
      elseif _G.ChooseWP == "Blox Fruit" then     
	    for _,v in pairs(plr.Backpack:GetChildren()) do
	      if v.ToolTip == "Blox Fruit" then
		    if plr.Backpack:FindFirstChild(tostring(v.Name)) then
		      _G.SelectWeapon = v.Name		                    
            end
          end
        end        
      end
    end)
  end
end)
WindyUI:AddToggle(SettingTab, "Bring Mob", false, function(state)
     _B = state
end)
BringEnemy = function()
    if not _B or not PosMon then return end
    
    pcall(function()
        sethiddenproperty(plr, "SimulationRadius", math.huge)
    end)

    task.defer(function()
        for _, v in ipairs(workspace.Enemies:GetChildren()) do
            local hum = v:FindFirstChild("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
            
            if hum and hrp and hum.Health > 0 then
                local dist = (hrp.Position - PosMon).Magnitude
                if dist <= 300 and isnetworkowner(hrp) then
                    
                    -- Apply anti-ghost measures
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
                    
                    -- Smooth teleport without dropping to ground
                    for i = 1, 3 do
                        if isnetworkowner(hrp) then
                            hrp.CFrame = CFrame.new(PosMon + Vector3.new(0, 5, 0))
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
WindyUI:AddSection(MainTab, "Haunted Castle")

WindyUI:AddToggle(MainTab, "Auto Farm Bones", false, function(state)
    _G.AutoFarm_Bone = state
    -- Bật thêm cái này để tự nhận quest nếu bạn muốn
    _G.AcceptQuestC = state 
end)

--// 1. ĐỊNH NGHĨA CÁC HÀM CƠ BẢN (Để code farm không bị lỗi)
local function _tp(cframe)
    pcall(function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end)
end

local function GetConnectionEnemies(targetList)
    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
        for _, targetName in pairs(targetList) do
            if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                return v
            end
        end
    end
    -- Nếu không thấy trong Workspace, tìm trong ReplicatedStorage (tùy game) hoặc chờ spawn
    return nil
end

-- Giả lập hàm Attack nếu bạn chưa có script attack riêng
local Attack = {}
Attack.Kill = function(target, state)
    if state and target then
        -- Gọi hàm chọn vũ khí (đã viết ở câu trước)
        if EquipWeapon then EquipWeapon() end
        -- Click đánh
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
    end
end

--// 2. LOGIC FARM BONE CỦA BẠN (Đã tối ưu)
if not _G.MobIndex then _G.MobIndex = 1 end

task.spawn(function()
    local function RemoveAntiGravity(root)
        if root and root:FindFirstChild("AntiGravity") then
            root.AntiGravity:Destroy()
        end
    end

    while task.wait() do 
        if _G.AutoFarm_Bone then
            pcall(function()        
                local player = game.Players.LocalPlayer
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local questUI = player.PlayerGui.Main.Quest
                
                local BonesTable = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
                
                if not root then return end
                local CurrentTargetName = BonesTable[_G.MobIndex]
                local bone = GetConnectionEnemies({CurrentTargetName})
                
                -- /// LOGIC NHẬN QUEST ///
                if _G.AcceptQuestC and not questUI.Visible then
                     local questPos = CFrame.new(-9516.99316, 172.017181, 6078.46533)
                     RemoveAntiGravity(root)
                     
                     if (questPos.Position - root.Position).Magnitude > 50 then
                          _tp(questPos)
                          return 
                     else
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

                if bone and bone:FindFirstChild("Humanoid") and bone:FindFirstChild("HumanoidRootPart") and bone.Humanoid.Health > 0 then
                    repeat 
                        task.wait() 
                        if _G.AutoFarm_Bone and bone and bone.Parent and bone.Humanoid.Health > 0 then
                            local enemyRoot = bone:FindFirstChild("HumanoidRootPart")
                            
                            if enemyRoot then
                                local dist = (root.Position - enemyRoot.Position).Magnitude
                                if dist < 350 then
                                    -- Bay trên đầu quái
                                    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                                    
                                    if not root:FindFirstChild("AntiGravity") then
                                        local bv = Instance.new("BodyVelocity")
                                        bv.Name = "AntiGravity"
                                        bv.Parent = root
                                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        bv.Velocity = Vector3.new(0, 0, 0)
                                    end
                                    Attack.Kill(bone, _G.AutoFarm_Bone) 
                                else
                                    RemoveAntiGravity(root)
                                    _tp(enemyRoot.CFrame * CFrame.new(0, 25, 0))
                                end
                            end
                        else
                            break 
                        end
                    until not _G.AutoFarm_Bone or bone.Humanoid.Health <= 0 or not bone.Parent or (questUI.Visible == false and _G.AcceptQuestC)
                    
                    RemoveAntiGravity(root)
                else
                    RemoveAntiGravity(root)
                    _G.MobIndex = _G.MobIndex + 1
                    if _G.MobIndex > #BonesTable then _G.MobIndex = 1 end
                    task.wait(0.5)
                end
            end)
        else
            local player = game.Players.LocalPlayer
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then RemoveAntiGravity(root) end
        end
    end
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gdfjffghhjkgghhhh/BloxFruitMain/refs/heads/main/attack.lua"))
