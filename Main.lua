
do
  ply = game.Players
  plr = ply.LocalPlayer
  Root = plr.Character.HumanoidRootPart
  replicated = game:GetService("ReplicatedStorage")
  Lv = game.Players.LocalPlayer.Data.Level.Value
  TeleportService = game:GetService("TeleportService")
  TW = game:GetService("TweenService")
  Lighting = game:GetService("Lighting")  
  Enemies = workspace.Enemies
  vim1 = game:GetService("VirtualInputManager")
  vim2 = game:GetService("VirtualUser")
  TeamSelf = plr.Team
  RunSer = game:GetService("RunService")
  Stats = game:GetService("Stats")  
  Energy = plr.Character.Energy.Value
  Boss = {}
  BringConnections = {}
  MaterialList = {}
  NPCList = {}  
  shouldTween = false
  SoulGuitar = false
  KenTest = true
  debug = false
  Brazier1 = false
  Brazier2 = false
  Brazier3 = false  
  Sec = 0.1
  ClickState = 0
  Num_self = 25
end

repeat local start = plr.PlayerGui:WaitForChild("Main"):WaitForChild("Loading") and game:IsLoaded() wait() until start
local Id = game.PlaceId

local World1 = Id == 2753915549 or Id == 85211729168715
local World2 = Id == 4442272183 or Id == 79091703265657
local World3 = Id == 7449423635 or Id == 100117331123089
Sea = World1 or World2 or World3 or plr:Kick("❌ Error : A[12]Blox Fruits ❌")
Marines = function() replicated.Remotes.CommF_:InvokeServer("SetTeam","Marines") end
Pirates = function() replicated.Remotes.CommF_:InvokeServer("SetTeam","Pirates") end
if World1 then Boss = {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard"}
elseif World2 then Boss = {"Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
elseif World3 then Boss = {"Tyrant of the Skies","Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Longma","Soul Reaper"}
end
if World1 then MaterialList = {"Leather + Scrap Metal", "Angel Wings", "Magma Ore", "Fish Tail"}
elseif World2 then MaterialList = {"Leather + Scrap Metal", "Radioactive Material", "Ectoplasm", "Mystic Droplet", "Magma Ore", "Vampire Fang"}
elseif World3 then MaterialList = {"Scrap Metal", "Demonic Wisp", "Conjured Cocoa", "Dragon Scale", "Gunpowder", "Fish Tail", "Mini Tusk"}
end
local DungeonTables = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}
local RenMon = {"Snow Lurker","Arctic Warrior","Hidden Key","Awakened Ice Admiral"}
local CursedTables = {["Mob"] = "Mythological Pirate",["Mob2"] = "Cursed Skeleton","Hell's Messenger",["Mob3"] = "Cursed Skeleton","Heaven's Guardian"}
local Past = {"Part","SpawnLocation","Terrain","WedgePart","MeshPart"}
local BartMon = {"Swan Pirate","Jeremy"}
local CitizenTable = {"Forest Pirate","Captain Elephant"}
local Human_v3_Mob = {"Fajita","Jeremy","Diamond"}
local AllBoats = {"Beast Hunter","Lantern","Guardian","Grand Brigade","Dinghy","Sloop","The Sentinel"}
local mastery1 = {"Cookie Crafter"}
local mastery2 = {"Reborn Skeleton"}
local PosMsList = {["Pirate Millionaire"] = CFrame.new(-712.8272705078125, 98.5770492553711, 5711.9541015625),["Pistol Billionaire"] = CFrame.new(-723.4331665039062, 147.42906188964844, 5931.9931640625),["Dragon Crew Warrior"] = CFrame.new(7021.50439453125, 55.76270294189453, -730.1290893554688),["Dragon Crew Archer"] = CFrame.new(6625, 378, 244),["Female Islander"] = CFrame.new(4692.7939453125, 797.9766845703125, 858.8480224609375),["Venomous Assailant"] = CFrame.new(4902, 670, 39), ["Marine Commodore"] = CFrame.new(2401, 123, -7589),["Marine Rear Admiral"] = CFrame.new(3588, 229, -7085),["Fishman Raider"] = CFrame.new(-10941, 332, -8760),["Fishman Captain"] = CFrame.new(-11035, 332, -9087),["Forest Pirate"] = CFrame.new(-13446, 413, -7760),["Mythological Pirate"] = CFrame.new(-13510, 584, -6987),["Jungle Pirate"] = CFrame.new(-11778, 426, -10592),["Musketeer Pirate"] = CFrame.new(-13282, 496, -9565),["Reborn Skeleton"] = CFrame.new(-8764, 142, 5963),["Living Zombie"] = CFrame.new(-10227, 421, 6161),["Demonic Soul"] = CFrame.new(-9579, 6, 6194),["Posessed Mummy"] = CFrame.new(-9579, 6, 6194),["Peanut Scout"] = CFrame.new(-1993, 187, -10103),["Peanut President"] = CFrame.new(-2215, 159, -10474),["Ice Cream Chef"] = CFrame.new(-877, 118, -11032),["Ice Cream Commander"] = CFrame.new(-877, 118, -11032),["Cookie Crafter"] = CFrame.new(-2021, 38, -12028),["Cake Guard"] = CFrame.new(-2024, 38, -12026),["Baking Staff"] = CFrame.new(-1932, 38, -12848),["Head Baker"] = CFrame.new(-1932, 38, -12848),["Cocoa Warrior"] = CFrame.new(95, 73, -12309),["Chocolate Bar Battler"] = CFrame.new(647, 42, -12401),["Sweet Thief"] = CFrame.new(116, 36, -12478),["Candy Rebel"] = CFrame.new(47, 61, -12889),["Ghost"] = CFrame.new(5251, 5, 1111)}
EquipWeapon = function(text)
  if not text then return end
  if plr.Backpack:FindFirstChild(text) then
	plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(text))
  end
end
weaponSc = function(weapon)
  for __in, v in pairs(plr.Backpack:GetChildren()) do
    if v:IsA("Tool") then
      if v.ToolTip == weapon then EquipWeapon(v.Name) end
    end
  end
end
hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Death),function() end)
hookfunction(require(game:GetService("ReplicatedStorage"):WaitForChild("GuideModule")).ChangeDisplayedNPC,function()end)
hookfunction(error, function()end)
hookfunction(warn, function()end)
local Rock = workspace:FindFirstChild("Rocks")
if Rock then Rock:Destroy()end
gay = (function()
  local lighting = game:GetService("Lighting")
  local lightingLayers = lighting:FindFirstChild("LightingLayers")
  if lightingLayers and game:GetService("Lighting") and game:GetService("Lighting") then
    local darkFog = lightingLayers:FindFirstChild("DarkFog")
    if darkFog then darkFog:Destroy() end
  end
  local Water = workspace._WorldOrigin["Foam;"]
  if Water and workspace._WorldOrigin["Foam;"] then Water:Destroy() end        
end)()
local Attack = {}
Attack.__index = Attack
Attack.Alive = function(model) if not model then return end local Humanoid = model:FindFirstChild("Humanoid") return Humanoid and Humanoid.Health > 0 end
Attack.Pos = function(model,dist) return (Root.Position - mode.Position).Magnitude <= dist end
Attack.Dist = function(model,dist) return (Root.Position - model:FindFirstChild("HumanoidRootPart").Position).Magnitude <= dist end
Attack.DistH = function(model,dist) return (Root.Position - model:FindFirstChild("HumanoidRootPart").Position).Magnitude > dist end
Attack.Kill = function(model,Succes)
  if model and Succes then
  if not model:GetAttribute("Locked") then model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
  PosMon = model:GetAttribute("Locked").Position
  BringEnemy()
  EquipWeapon(_G.SelectWeapon)
  local Equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
  local ToolTip = Equipped.ToolTip
  if ToolTip == "Blox Fruit" then _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,10,0) * CFrame.Angles(0,math.rad(90),0)) else _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,30,0) * CFrame.Angles(0,math.rad(180),0))end
  if RandomCFrame then wait(.5)_tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25)) wait(.5)_tp(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0)) wait(.5)_tp(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30 ,0)) wait(.5)_tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25)) wait(.5)_tp(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))end
  end
end
Attack.Kill2 = function(model,Succes)
  if model and Succes then
  if not model:GetAttribute("Locked") then model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
  PosMon = model:GetAttribute("Locked").Position
  BringEnemy()
  EquipWeapon(_G.SelectWeapon)
  local Equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
  local ToolTip = Equipped.ToolTip
  if ToolTip == "Blox Fruit" then _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,10,0) * CFrame.Angles(0,math.rad(90),0)) else _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,30,8) * CFrame.Angles(0,math.rad(180),0))end
  if RandomCFrame then wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30 ,0)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))end
  end
end
Attack.KillSea = function(model,Succes)
  if model and Succes then
  if not model:GetAttribute("Locked") then model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
  PosMon = model:GetAttribute("Locked").Position
  BringEnemy()
  EquipWeapon(_G.SelectWeapon)
  local Equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
  local ToolTip = Equipped.ToolTip
  if ToolTip == "Blox Fruit" then _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,10,0) * CFrame.Angles(0,math.rad(90),0)) else notween(model.HumanoidRootPart.CFrame * CFrame.new(0,50,8)) wait(.85)notween(model.HumanoidRootPart.CFrame * CFrame.new(0,400,0)) wait(1)end
  end
end
Attack.Sword = function(model,Succes)
  if model and Succes then
  if not model:GetAttribute("Locked") then model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
  PosMon = model:GetAttribute("Locked").Position
  BringEnemy()
  weaponSc("Sword")
  _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
  if RandomCFrame then wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30 ,0)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25)) wait(0.1)_tp(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))end
  end
end
Attack.Mas = function(model,Succes)
  if model and Succes then
  if not model:GetAttribute("Locked") then model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
  PosMon = model:GetAttribute("Locked").Position
  BringEnemy()
    if model.Humanoid.Health <= HealthM then
      _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,20,0))
      Useskills("Blox Fruit","Z")
      Useskills("Blox Fruit","X")
      Useskills("Blox Fruit","C")
    else
      weaponSc("Melee")
      _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
    end
  end
end
Attack.Masgun = function(model,Succes)
  if model and Succes then
  if not model:GetAttribute("Locked") then model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
  PosMon = model:GetAttribute("Locked").Position
  BringEnemy()
    if model.Humanoid.Health <= HealthM then
      _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,35,8))
      Useskills("Gun","Z")
      Useskills("Gun","X")
    else
      weaponSc("Melee")
      _tp(model.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
    end
  end
end
statsSetings = function(Num, value)
  if Num == "Melee" then
    if plr.Data.Points.Value ~= 0 then
      replicated.Remotes.CommF_:InvokeServer("AddPoint","Melee",value)
    end
  elseif Num == "Defense" then
    if plr.Data.Points.Value ~= 0 then
      replicated.Remotes.CommF_:InvokeServer("AddPoint","Defense",value)
    end
  elseif Num == "Sword" then
    if plr.Data.Points.Value ~= 0 then
      replicated.Remotes.CommF_:InvokeServer("AddPoint","Sword",value)
    end
  elseif Num == "Gun" then
    if plr.Data.Points.Value ~= 0 then
      replicated.Remotes.CommF_:InvokeServer("AddPoint","Gun",value)
    end
  elseif Num == "Devil" then
    if plr.Data.Points.Value ~= 0 then
      replicated.Remotes.CommF_:InvokeServer("AddPoint","Demon Fruit",value)
    end
  end
end

_B = _B or true
_R = _R or 300
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local frozenEnemies = {}  -- { enemy = {bodyPos, hrp, hum, targetPos} }
local monitorStarted = false

local function getEnemyHeight(enemy)
    local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
    if hrp and hrp:IsA("BasePart") then
        return hrp.Size.Y
    end
    return 5
end

local function getOffsetFromName(name)
    local hash = 0
    for i = 1, #name do
        hash = hash + name:byte(i)
    end
    local angle = (hash % 360) * math.pi / 180
    local radius = 3 + (hash % 5)
    return Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
end

local function attachBodyPosition(enemy, targetPos)
    local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
    if not hrp then return end

    local old = hrp:FindFirstChildOfClass("BodyPosition")
    if old then old:Destroy() end

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.D = 100
    bp.Position = targetPos
    bp.Parent = hrp
    return bp
end

-- vòng monitor chỉ chạy 1 lần (tránh mỗi lần BringEnemy gọi lại tạo thêm coroutine)
local function startFrozenMonitor()
    if monitorStarted then return end
    monitorStarted = true

    task.spawn(function()
        while true do
            task.wait(0.5)
            for enemy, data in pairs(frozenEnemies) do
                if (not enemy.Parent) or (not data.hum) or (data.hum.Health <= 0) then
                    if data.bodyPos and data.bodyPos.Parent then
                        data.bodyPos:Destroy()
                    end
                    frozenEnemies[enemy] = nil
                elseif data.hrp and isnetworkowner(data.hrp) then
                    if data.bodyPos and data.bodyPos.Parent then
                        data.bodyPos.Position = data.targetPos
                    else
                        -- nếu bị mất BodyPosition thì gắn lại
                        data.bodyPos = attachBodyPosition(enemy, data.targetPos)
                    end
                else
                    if data.bodyPos and data.bodyPos.Parent then
                        data.bodyPos:Destroy()
                    end
                    frozenEnemies[enemy] = nil
                end
            end
        end
    end)
end

BringEnemy = function()
    if not _B or not PosMon then return end

    pcall(function()
        sethiddenproperty(plr, "SimulationRadius", math.huge)
    end)

    local radius = tonumber(_R) or 300

    task.defer(function()
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end

        for _, v in ipairs(enemiesFolder:GetChildren()) do
            local hum = v:FindFirstChild("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart

            if hum and hrp and hum.Health > 0 then
                local dist = (hrp.Position - PosMon).Magnitude
                if dist <= radius and isnetworkowner(hrp) then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {v}

                    local rayOrigin = Vector3.new(PosMon.X, PosMon.Y + 10, PosMon.Z)
                    local rayDir = Vector3.new(0, -150, 0)
                    local rayResult = workspace:Raycast(rayOrigin, rayDir, raycastParams)

                    local targetY
                    if rayResult then
                        local groundY = rayResult.Position.Y
                        local enemyHeight = getEnemyHeight(v)
                        targetY = groundY + enemyHeight / 2
                    else
                        targetY = hrp.Position.Y
                    end

                    local baseTarget = Vector3.new(PosMon.X, targetY, PosMon.Z)
                    local offset = getOffsetFromName(v.Name)
                    local finalTarget = baseTarget + offset

                    local startPos = hrp.Position
                    for i = 1, 5 do
                        if isnetworkowner(hrp) then
                            local alpha = i / 5
                            hrp.CFrame = CFrame.new(startPos:Lerp(finalTarget, alpha))
                            task.wait(0.03)
                        else
                            break
                        end
                    end

                    if isnetworkowner(hrp) then
                        hrp.CFrame = CFrame.new(finalTarget)

                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                        hum.PlatformStand = true
                        hum.AutoRotate = false

                        local anim = hum:FindFirstChildOfClass("Animator")
                        if anim then anim.Parent = nil end

                        for _, part in ipairs(v:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                part.Anchored = false
                                part.Massless = true
                            end
                        end

                        local bp = attachBodyPosition(v, finalTarget)
                        if bp then
                            frozenEnemies[v] = {
                                bodyPos = bp,
                                hrp = hrp,
                                hum = hum,
                                targetPos = finalTarget
                            }
                        end
                    end
                end
            end
        end

        startFrozenMonitor()
    end)
end
Useskills = function(weapon, skill)
  if weapon == "Melee" then
    weaponSc("Melee")
    if skill == "Z" then
      vim1:SendKeyEvent(true, "Z", false, game);
      vim1:SendKeyEvent(false, "Z", false, game);
    elseif skill == "X" then
      vim1:SendKeyEvent(true, "X", false, game);
      vim1:SendKeyEvent(false, "X", false, game);
    elseif skill == "C" then
      vim1:SendKeyEvent(true, "C", false, game);
      vim1:SendKeyEvent(false, "C", false, game);
    end
  elseif weapon == "Sword" then
    weaponSc("Sword")
    if skill == "Z" then
      vim1:SendKeyEvent(true, "Z", false, game);
      vim1:SendKeyEvent(false, "Z", false, game);
    elseif skill == "X" then
      vim1:SendKeyEvent(true, "X", false, game);
      vim1:SendKeyEvent(false, "X", false, game);
    end
  elseif weapon == "Blox Fruit" then
    weaponSc("Blox Fruit")
    if skill == "Z" then
      vim1:SendKeyEvent(true, "Z", false, game);
      vim1:SendKeyEvent(false, "Z", false, game);
    elseif skill == "X" then
      vim1:SendKeyEvent(true, "X", false, game);
      vim1:SendKeyEvent(false, "X", false, game);
    elseif skill == "C" then
      vim1:SendKeyEvent(true, "C", false, game);
      vim1:SendKeyEvent(false, "C", false, game);        
    elseif skill == "V" then
      vim1:SendKeyEvent(true, "V", false, game);
      vim1:SendKeyEvent(false, "V", false, game);
    end
  elseif weapon == "Gun" then
    weaponSc("Gun")
    if skill == "Z" then
      vim1:SendKeyEvent(true, "Z", false, game);
      vim1:SendKeyEvent(false, "Z", false, game);
    elseif skill == "X" then
      vim1:SendKeyEvent(true, "X", false, game);
      vim1:SendKeyEvent(false, "X", false, game);
    end
  end
  if weapon == "nil" and skill == "Y" then
    vim1:SendKeyEvent(true, "Y", false, game);
    vim1:SendKeyEvent(false, "Y", false, game);
  end
end
local gg = getrawmetatable(game)
local old = gg.__namecall
setreadonly(gg, false)
gg.__namecall = newcclosure(function(...)
  local method = getnamecallmethod()
  local args = {...}    
    if tostring(method) == "FireServer" then
      if tostring(args[1]) == "RemoteEvent" then
        if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
          if (_G.FarmMastery_G and not SoulGuitar) or (_G.FarmMastery_Dev) or (_G.FarmBlazeEM) or (_G.Prehis_Skills) or (_G.SeaBeast1 or _G.FishBoat or _G.PGB or _G.Leviathan1 or _G.Complete_Trials) or (_G.AimMethod and ABmethod == "AimBots Skill") or (_G.AimMethod and ABmethod == "Auto Aimbots") then
            args[2] = MousePos
            return old(unpack(args))
          end
        end
      end
    end
  return old(...)
end)
GetConnectionEnemies = function(a)
  for i,v in pairs(replicated:GetChildren()) do
    if v:IsA("Model") and  ((typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
      return v
    end
  end
  for i,v in next,game.Workspace.Enemies:GetChildren() do
    if v:IsA("Model") and ((typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a)  and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
      return v
    end
  end
end
LowCpu = function()
  local decalsyeeted = true
  local g = game
  local w = g.Workspace
  local l = g.Lighting
  local t = w.Terrain
  t.WaterWaveSize = 0
  t.WaterWaveSpeed = 0
  t.WaterReflectance = 0
  t.WaterTransparency = 0
  l.GlobalShadows = false
  l.FogEnd = 9e9
  l.Brightness = 0
  settings().Rendering.QualityLevel = "Level01"
  for i, v in pairs(g:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
      v.Material = "Plastic"
      v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
      v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
      v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
      v.BlastPressure = 1
      v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
      v.Enabled = false
    elseif v:IsA("MeshPart") then
      v.Material = "Plastic"
      v.Reflectance = 0
      v.TextureID = 10385902758728957
    end
  end
  for i, e in pairs(l:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
      e.Enabled = false
    end
  end
end
CheckF = function()
  if GetBP("Dragon-Dragon") or GetBP("Gas-Gas") or GetBP("Yeti-Yeti") or GetBP("Kitsune-Kitsune") or GetBP("T-Rex-T-Rex") then return true end
end
CheckBoat = function()
  for i, v in pairs(workspace.Boats:GetChildren()) do
    if tostring(v.Owner.Value) == tostring(plr.Name) then
      return v    
end;
  end;
  return false
end;
CheckEnemiesBoat = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if (v.Name == "FishBoat") and v:FindFirstChild("Health").Value > 0 then
      return true    
end;
  end;
  return false
end;
CheckPirateGrandBrigade = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if (v.Name == "PirateGrandBrigade" or v.Name == "PirateBrigade") and v:FindFirstChild("Health").Value > 0 then
      return true
    end
  end
  return false
end
CheckShark = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if v.Name == "Shark" and Attack.Alive(v) then
      return true    
end;
  end;
  return false
end;
CheckTerrorShark = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if v.Name == "Terrorshark" and Attack.Alive(v) then
      return true    
end;
  end;
  return false
end;
CheckPiranha = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if v.Name == "Piranha" and Attack.Alive(v) then
      return true    
end;
  end;
  return false
end;
CheckFishCrew = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if (v.Name == "Fish Crew Member" or v.Name == "Haunted Crew Member") and Attack.Alive(v) then
      return true    
end;
  end;
  return false
end;
CheckHauntedCrew = function()
  for _,v in pairs(workspace.Enemies:GetChildren()) do
    if (v.Name == "Haunted Crew Member") and Attack.Alive(v) then
      return true    
end;
  end;
  return false
end;
CheckSeaBeast = function()
  if workspace.SeaBeasts:FindFirstChild("SeaBeast1") then
    return true  
end;
  return false
end;
CheckLeviathan = function()
  if workspace.SeaBeasts:FindFirstChild("Leviathan") then
    return true  
end;
  return false
end;
UpdStFruit = function()
  for z,x in next, plr.Backpack:GetChildren() do
  StoreFruit = x:FindFirstChild("EatRemote", true)
    if StoreFruit then
      replicated.Remotes.CommF_:InvokeServer("StoreFruit",StoreFruit.Parent:GetAttribute("OriginalName"),
      plr.Backpack:FindFirstChild(x.Name))
    end
  end
end
collectFruits = function(Succes)
  if Succes then
    local Character = plr.Character
    for _,v1 in pairs(workspace:GetChildren()) do
    if string.find(v1.Name, "Fruit") then v1.Handle.CFrame = Character.HumanoidRootPart.CFrame end
    end
  end
end
Getmoon = function()
  if World1 then
    return Lighting.FantasySky.MoonTextureId
  elseif World2 then
    return Lighting.FantasySky.MoonTextureId
  elseif World3 then
    return Lighting.Sky.MoonTextureId
  end
end
DropFruits = function()
  for _,v3 in next, plr.Backpack:GetChildren() do
    if string.find(v3.Name, "Fruit") then
      EquipWeapon(v3.Name) wait(.1)
      if plr.PlayerGui.Main.Dialogue.Visible == true then plr.PlayerGui.Main.Dialogue.Visible = false end EquipWeapon(v3.Name) plr.Character:FindFirstChild(v3.Name).EatRemote:InvokeServer("Drop")
    end
  end
  for a,b2 in pairs(plr.Character:GetChildren()) do
    if string.find(b2.Name, "Fruit") then EquipWeapon(b2.Name) wait(.1)
    if plr.PlayerGui.Main.Dialogue.Visible == true then plr.PlayerGui.Main.Dialogue.Visible = false end EquipWeapon(b2.Name) plr.Character:FindFirstChild(b2.Name).EatRemote:InvokeServer("Drop")
    end
  end
end
GetBP = function(v)
  return plr.Backpack:FindFirstChild(v) or plr.Character:FindFirstChild(v)
end
GetIn = function(Name)
  for _ ,v1 in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
    if type(v1) == "table" then
      if v1.Name == Name or plr.Character:FindFirstChild(Name) or plr.Backpack:FindFirstChild(Name) then
        return true
	 end
    end
  end
  return false
end
GetM = function(Name)
  for _,tab in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
    if type(tab) == "table" then
	  if tab.Type == "Material" then
	    if tab.Name == Name then
		  return tab.Count
	    end
	  end
    end
  end
return 0
end
GetWP = function(nametool)
  for _,v4 in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
    if type(v4) == "table" then
      if v4.Type == "Sword" then
        if v4.Name == nametool or plr.Character:FindFirstChild(nametool) or plr.Backpack:FindFirstChild(nametool) then
	     return true
	     end
	   end
      end
    end
  return false
end 
getInfinity_Ability = function(Method, Var)
  if not Root then return end
  if Method == "Soru" and Var then
    for _,gc in next, getgc() do
      if plr.Character.Soru then
        if ((typeof(gc) == "function") and (getfenv(gc).script == plr.Character.Soru)) then
          for _, v in next, getupvalues(gc) do
            if (typeof(v) == "table") then
              repeat wait(Sec) v.LastUse = 0 until not Var or (plr.Character.Humanoid.Health <= 0)
            end
          end
        end
      end
    end    
  elseif Method == "Energy" and Var then
    plr.Character.Energy.Changed:connect(function()
      if Var then plr.Character.Energy.Value = Energy end 
    end)
  elseif Method == "Observation" and Var then
    local VisionRadius = plr.VisionRadius
    VisionRadius.Value = math.huge
  end
end
Hop = function()
  pcall(function()
    for count = math.random(1, math.random(40, 75)), 100 do
      local remote = replicated.__ServerBrowser:InvokeServer(count)
	  for _, v in next, remote do
	  if tonumber(v['Count']) < 12 then TeleportService:TeleportToPlaceInstance(game.PlaceId, _) end
	  end    
    end
  end)
end
local block = Instance.new("Part", workspace)
block.Size = Vector3.new(1, 1, 1)
block.Name = "Rip_Indra"
block.Anchored = true
block.CanCollide = false
block.CanTouch = false
block.Transparency = 1
local blockfind = workspace:FindFirstChild(block.Name)
if blockfind and blockfind ~= block then blockfind:Destroy() end
task.spawn(function()while task.wait()do if block and block.Parent==workspace then if shouldTween then getgenv().OnFarm=true else getgenv().OnFarm=false end else getgenv().OnFarm=false end end end)
task.spawn(function()local a=game.Players.LocalPlayer;repeat task.wait()until a.Character and a.Character.PrimaryPart;block.CFrame=a.Character.PrimaryPart.CFrame;while task.wait()do pcall(function()if getgenv().OnFarm then if block and block.Parent==workspace then local b=a.Character and a.Character.PrimaryPart;if b and(b.Position-block.Position).Magnitude<=200 then b.CFrame=block.CFrame else block.CFrame=b.CFrame end end;local c=a.Character;if c then for d,e in pairs(c:GetChildren())do if e:IsA("BasePart")then e.CanCollide=false end end end else local c=a.Character;if c then for d,e in pairs(c:GetChildren())do if e:IsA("BasePart")then e.CanCollide=true end end end end end)end end)
_tp = function(target)
  local character = plr.Character
  if not character or not character:FindFirstChild("HumanoidRootPart") then return end
  local rootPart = character.HumanoidRootPart
  local distance = (target.Position - rootPart.Position).Magnitude
  local tweenInfo = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear)
  local tween = game:GetService("TweenService"):Create(block, tweenInfo, {CFrame = target})    
  if plr.Character.Humanoid.Sit == true then
    block.CFrame = CFrame.new(block.Position.X, target.Y, block.Position.Z)
  end  
  tween:Play()    
  task.spawn(function() while tween.PlaybackState == Enum.PlaybackState.Playing do if not shouldTween then tween:Cancel() break end task.wait(0.1) end end)
end
TeleportToTarget = function(targetCFrame) if (targetCFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude > 1000 then _tp(targetCFrame)else _tp(targetCFrame)end end
notween = function(p) plr.Character.HumanoidRootPart.CFrame = p end
function BTP(p)
    local player = game.Players.LocalPlayer
    local humanoidRootPart = player.Character.HumanoidRootPart
    local humanoid = player.Character.Humanoid
    local playerGui = player.PlayerGui.Main
    local targetPosition = p.Position
    local lastPosition = humanoidRootPart.Position
    repeat
        humanoid.Health = 0
        humanoidRootPart.CFrame = p
        playerGui.Quest.Visible = false
        if (humanoidRootPart.Position - lastPosition).Magnitude > 1 then
            lastPosition = humanoidRootPart.Position
            humanoidRootPart.CFrame = p
        end
        task.wait(0.5)
    until (p.Position - humanoidRootPart.Position).Magnitude <= 2000
end
spawn(function()
  while task.wait() do
    pcall(function()
      if _G.SailBoat_Hydra or _G.WardenBoss or _G.AutoFactory or _G.HighestMirage or _G.HCM or _G.PGB or _G.Leviathan1 or _G.UPGDrago or _G.Complete_Trials or _G.TpDrago_Prehis or _G.BuyDrago or _G.AutoFireFlowers or _G.DT_Uzoth or _G.AutoBerry or _G.Prehis_Find or _G.Prehis_Skills or _G.Prehis_DB or _G.Prehis_DE or _G.FarmBlazeEM or _G.Dojoo or _G.CollectPresent or _G.AutoLawKak or _G.TpLab or _G.AutoPhoenixF or _G.AutoFarmChest or _G.AutoHytHallow or _G.LongsWord or _G.BlackSpikey or _G.AutoHolyTorch or _G.TrainDrago  or _G.AutoSaber or _G.FarmMastery_Dev or _G.CitizenQuest or _G.AutoEctoplasm or _G.KeysRen or _G.Auto_Rainbow_Haki or _G.obsFarm or _G.AutoBigmom or _G.Doughv2 or _G.AuraBoss or _G.Raiding or _G.Auto_Cavender or _G.TpPly or _G.Bartilo_Quest or _G.Level or _G.FarmEliteHunt or _G.AutoZou or _G.AutoFarm_Bone or getgenv().AutoMaterial or _G.CraftVM or _G.FrozenTP or _G.TPDoor or _G.AcientOne or _G.AutoFarmNear or _G.AutoRaidCastle or _G.DarkBladev3 or _G.AutoFarmRaid or _G.Auto_Cake_Prince or _G.Addealer or _G.TPNpc or _G.TwinHook or _G.FindMirage or _G.FarmChestM or _G.Shark or _G.TerrorShark or _G.Piranha or _G.MobCrew or _G.SeaBeast1 or _G.FishBoat or _G.AutoPole or _G.AutoPoleV2 or _G.Auto_SuperHuman or _G.AutoDeathStep or _G.Auto_SharkMan_Karate or _G.Auto_Electric_Claw or _G.AutoDragonTalon or _G.Auto_Def_DarkCoat or _G.Auto_God_Human or _G.Auto_Tushita or _G.AutoMatSoul or _G.AutoKenVTWO or _G.AutoSerpentBow or _G.AutoFMon or _G.Auto_Soul_Guitar or _G.TPGEAR or _G.AutoSaw or _G.AutoTridentW2 or _G.Auto_StartRaid or _G.AutoEvoRace or _G.AutoGetQuestBounty or _G.MarinesCoat or _G.TravelDres or _G.Defeating or _G.DummyMan or _G.Auto_Yama or _G.Auto_SwanGG or _G.SwanCoat or _G.AutoEcBoss or _G.Auto_Mink or _G.Auto_Human or _G.Auto_Skypiea or _G.Auto_Fish or _G.CDK_TS or _G.CDK_YM or _G.CDK or _G.AutoFarmGodChalice or _G.AutoFistDarkness or _G.AutoMiror or _G.Teleport or _G.AutoKilo or _G.AutoGetUsoap or _G.Praying or _G.TryLucky or _G.AutoColShad or _G.AutoUnHaki or _G.Auto_DonAcces or _G.AutoRipIngay or _G.DragoV3 or _G.DragoV1 or _G.SailBoats or NextIs or _G.FarmGodChalice or _G.IceBossRen or senth or senth2 or _G.Lvthan or _G.beasthunter or _G.DangerLV or _G.Relic123 or _G.tweenKitsune or _G.Collect_Ember or _G.AutofindKitIs or _G.snaguine or _G.TwFruits or _G.tweenKitShrine or _G.Tp_LgS or _G.Tp_MasterA or _G.tweenShrine or _G.FarmMastery_G or _G.FarmMastery_S or _G.FarmPhaBinh or _G.FarmTyrant then
        shouldTween = true
        if not plr.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
          local Noclip = Instance.new("BodyVelocity")
          Noclip.Name = "BodyClip"
          Noclip.Parent = plr.Character.HumanoidRootPart
          Noclip.MaxForce = Vector3.new(100000,100000,100000)
          Noclip.Velocity = Vector3.new(0,0,0)
        end        
        if not plr.Character:FindFirstChild('highlight') then
    local Test = Instance.new('Highlight')
    Test.Name = "highlight"
    Test.Enabled = true
    Test.FillColor = Color3.fromRGB(0, 191, 255) -- xanh nước biển
    Test.OutlineColor = Color3.fromRGB(255, 255, 255)
    Test.FillTransparency = 0.5
    Test.OutlineTransparency = 0.2
    Test.Parent = plr.Character
end
        for _, no in pairs(plr.Character:GetDescendants()) do if no:IsA("BasePart") then no.CanCollide = false end end
      else
        shouldTween = false
        if plr.Character.HumanoidRootPart:FindFirstChild("BodyClip") then plr.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy() end
        if plr.Character:FindFirstChild('highlight') then plr.Character:FindFirstChild('highlight'):Destroy() end	        
      end
    end)
  end
end)
QuestB=function()if World1 then if _G.FindBoss=="The Gorilla King"then bMon="The Gorilla King"Qname="JungleQuest"Qdata=3;PosQBoss=CFrame.new(-1601.6553955078,36.85213470459,153.38809204102)PosB=CFrame.new(-1088.75977,8.13463783,-488.559906,-0.707134247,0,0.707079291,0,1,0,-0.707079291,0,-0.707134247)elseif _G.FindBoss=="Bobby"then bMon="Bobby"Qname="BuggyQuest1"Qdata=3;PosQBoss=CFrame.new(-1140.1761474609,4.752049446106,3827.4057617188)PosB=CFrame.new(-1087.3760986328,46.949409484863,4040.1462402344)elseif _G.FindBoss=="The Saw"then bMon="The Saw"PosB=CFrame.new(-784.89715576172,72.427383422852,1603.5822753906)elseif _G.FindBoss=="Yeti"then bMon="Yeti"Qname="SnowQuest"Qdata=3;PosQBoss=CFrame.new(1386.8073730469,87.272789001465,-1298.3576660156)PosB=CFrame.new(1218.7956542969,138.01184082031,-1488.0262451172)elseif _G.FindBoss=="Mob Leader"then bMon="Mob Leader"PosB=CFrame.new(-2844.7307128906,7.4180502891541,5356.6723632813)elseif _G.FindBoss=="Vice Admiral"then bMon="Vice Admiral"Qname="MarineQuest2"Qdata=2;PosQBoss=CFrame.new(-5036.2465820313,28.677835464478,4324.56640625)PosB=CFrame.new(-5006.5454101563,88.032081604004,4353.162109375)elseif _G.FindBoss=="Saber Expert"then bMon="Saber Expert"PosB=CFrame.new(-1458.89502,29.8870335,-50.633564)elseif _G.FindBoss=="Warden"then bMon="Warden"Qname="ImpelQuest"Qdata=1;PosB=CFrame.new(5278.04932,2.15167475,944.101929,0.220546961,-4.49946401e-06,0.975376427,-1.95412576e-05,1,9.03162072e-06,-0.975376427,-2.10519756e-05,0.220546961)PosQBoss=CFrame.new(5191.86133,2.84020686,686.438721,-0.731384635,0,0.681965172,0,1,0,-0.681965172,0,-0.731384635)elseif _G.FindBoss=="Chief Warden"then bMon="Chief Warden"Qname="ImpelQuest"Qdata=2;PosB=CFrame.new(5206.92578,0.997753382,814.976746,0.342041343,-0.00062915677,0.939684749,0.00191645394,0.999998152,-2.80422337e-05,-0.939682961,0.00181045406,0.342041939)PosQBoss=CFrame.new(5191.86133,2.84020686,686.438721,-0.731384635,0,0.681965172,0,1,0,-0.681965172,0,-0.731384635)elseif _G.FindBoss=="Swan"then bMon="Swan"Qname="ImpelQuest"Qdata=3;PosB=CFrame.new(5325.09619,7.03906584,719.570679,-0.309060812,0,0.951042235,0,1,0,-0.951042235,0,-0.309060812)PosQBoss=CFrame.new(5191.86133,2.84020686,686.438721,-0.731384635,0,0.681965172,0,1,0,-0.681965172,0,-0.731384635)elseif _G.FindBoss=="Magma Admiral"then bMon="Magma Admiral"Qname="MagmaQuest"Qdata=3;PosQBoss=CFrame.new(-5314.6220703125,12.262420654297,8517.279296875)PosB=CFrame.new(-5765.8969726563,82.92064666748,8718.3046875)elseif _G.FindBoss=="Fishman Lord"then bMon="Fishman Lord"Qname="FishmanQuest"Qdata=3;PosQBoss=CFrame.new(61122.65234375,18.497442245483,1569.3997802734)PosB=CFrame.new(61260.15234375,30.950881958008,1193.4329833984)elseif _G.FindBoss=="Wysper"then bMon="Wysper"Qname="SkyExp1Quest"Qdata=3;PosQBoss=CFrame.new(-7861.947265625,5545.517578125,-379.85974121094)PosB=CFrame.new(-7866.1333007813,5576.4311523438,-546.74816894531)elseif _G.FindBoss=="Thunder God"then bMon="Thunder God"Qname="SkyExp2Quest"Qdata=3;PosQBoss=CFrame.new(-7903.3828125,5635.9897460938,-1410.923828125)PosB=CFrame.new(-7994.984375,5761.025390625,-2088.6479492188)elseif _G.FindBoss=="Cyborg"then bMon="Cyborg"Qname="FountainQuest"Qdata=3;PosQBoss=CFrame.new(5258.2788085938,38.526931762695,4050.044921875)PosB=CFrame.new(6094.0249023438,73.770050048828,3825.7348632813)elseif _G.FindBoss=="Ice Admiral"then bMon="Ice Admiral"Qdata=nil;PosQBoss=CFrame.new(1266.08948,26.1757946,-1399.57678,-0.573599219,0,-0.81913656,0,1,0,0.81913656,0,-0.573599219)PosB=CFrame.new(1266.08948,26.1757946,-1399.57678,-0.573599219,0,-0.81913656,0,1,0,0.81913656,0,-0.573599219)elseif _G.FindBoss=="Greybeard"then bMon="Greybeard"Qdata=nil;PosQBoss=CFrame.new(-5081.3452148438,85.221641540527,4257.3588867188)PosB=CFrame.new(-5081.3452148438,85.221641540527,4257.3588867188)end end;if World2 then if _G.FindBoss=="Diamond"then bMon="Diamond"Qname="Area1Quest"Qdata=3;PosQBoss=CFrame.new(-427.5666809082,73.313781738281,1835.4208984375)PosB=CFrame.new(-1576.7166748047,198.59265136719,13.724286079407)elseif _G.FindBoss=="Jeremy"then bMon="Jeremy"Qname="Area2Quest"Qdata=3;PosQBoss=CFrame.new(636.79943847656,73.413787841797,918.00415039063)PosB=CFrame.new(2006.9261474609,448.95666503906,853.98284912109)elseif _G.FindBoss=="Fajita"then bMon="Fajita"Qname="MarineQuest3"Qdata=3;PosQBoss=CFrame.new(-2441.986328125,73.359344482422,-3217.5324707031)PosB=CFrame.new(-2172.7399902344,103.32216644287,-4015.025390625)elseif _G.FindBoss=="Don Swan"then bMon="Don Swan"PosB=CFrame.new(2286.2004394531,15.177839279175,863.8388671875)elseif _G.FindBoss=="Smoke Admiral"then bMon="Smoke Admiral"Qname="IceSideQuest"Qdata=3;PosQBoss=CFrame.new(-5429.0473632813,15.977565765381,-5297.9614257813)PosB=CFrame.new(-5275.1987304688,20.757257461548,-5260.6669921875)elseif _G.FindBoss=="Awakened Ice Admiral"then bMon="Awakened Ice Admiral"Qname="FrostQuest"Qdata=3;PosQBoss=CFrame.new(5668.9780273438,28.519989013672,-6483.3520507813)PosB=CFrame.new(6403.5439453125,340.29766845703,-6894.5595703125)elseif _G.FindBoss=="Tide Keeper"then bMon="Tide Keeper"Qname="ForgottenQuest"Qdata=3;PosQBoss=CFrame.new(-3053.9814453125,237.18954467773,-10145.0390625)PosB=CFrame.new(-3795.6423339844,105.88877105713,-11421.307617188)elseif _G.FindBoss=="Darkbeard"then bMon="Darkbeard"Qdata=nil;PosQBoss=CFrame.new(3677.08203125,62.751937866211,-3144.8332519531)PosB=CFrame.new(3677.08203125,62.751937866211,-3144.8332519531)elseif _G.FindBoss=="Cursed Captaim"then bMon="Cursed Captain"Qdata=nil;PosQBoss=CFrame.new(916.928589,181.092773,33422)PosB=CFrame.new(916.928589,181.092773,33422)elseif _G.FindBoss=="Order"then bMon="Order"Qdata=nil;PosQBoss=CFrame.new(-6217.2021484375,28.047645568848,-5053.1357421875)PosB=CFrame.new(-6217.2021484375,28.047645568848,-5053.1357421875)end end;if World3 then if _G.FindBoss=="Stone"then bMon="Stone"Qname="PiratePortQuest"Qdata=3;PosQBoss=CFrame.new(-289.76705932617,43.819011688232,5579.9384765625)PosB=CFrame.new(-1027.6512451172,92.404174804688,6578.8530273438)elseif _G.FindBoss=="Hydra Leader"then bMon="Hydra Leader"Qname="AmazonQuest2"Qdata=3;PosQBoss=CFrame.new(5821.89794921875,1019.0950927734375,-73.71923065185547)PosB=CFrame.new(5821.89794921875,1019.0950927734375,-73.71923065185547)elseif _G.FindBoss=="Kilo Admiral"then bMon="Kilo Admiral"Qname="MarineTreeIsland"Qdata=3;PosQBoss=CFrame.new(2179.3010253906,28.731239318848,-6739.9741210938)PosB=CFrame.new(2764.2233886719,432.46154785156,-7144.4580078125)elseif _G.FindBoss=="Captain Elephant"then bMon="Captain Elephant"Qname="DeepForestIsland"Qdata=3;PosQBoss=CFrame.new(-13232.682617188,332.40396118164,-7626.01171875)PosB=CFrame.new(-13376.7578125,433.28689575195,-8071.392578125)elseif _G.FindBoss=="Beautiful Pirate"then bMon="Beautiful Pirate"Qname="DeepForestIsland2"Qdata=3;PosQBoss=CFrame.new(-12682.096679688,390.88653564453,-9902.1240234375)PosB=CFrame.new(5283.609375,22.56223487854,-110.78285217285)elseif _G.FindBoss=="Cake Queen"then bMon="Cake Queen"Qname="IceCreamIslandQuest"Qdata=3;PosQBoss=CFrame.new(-819.376709,64.9259796,-10967.2832,-0.766061664,0,0.642767608,0,1,0,-0.642767608,0,-0.766061664)PosB=CFrame.new(-678.648804,381.353943,-11114.2012,-0.908641815,0.00149294338,0.41757378,0.00837114919,0.999857843,0.0146408929,-0.417492568,0.0167988986,-0.90852499)elseif _G.FindBoss=="Longma"then bMon="Longma"Qdata=nil;PosQBoss=CFrame.new(-10238.875976563,389.7912902832,-9549.7939453125)PosB=CFrame.new(-10238.875976563,389.7912902832,-9549.7939453125)elseif _G.FindBoss=="Soul Reaper"then bMon="Soul Reaper"Qdata=nil;PosQBoss=CFrame.new(-9524.7890625,315.80429077148,6655.7192382813)PosB=CFrame.new(-9524.7890625,315.80429077148,6655.7192382813)end end end
QuestBeta = function()
  local Neta = QuestB()
  return {
    [0] = _G.FindBoss,
    [1] = bMon,
    [2] = Qdata,
    [3] = Qname,
    [4] = PosB
    }  
end
	QuestCheck = function()
		local a = game.Players.LocalPlayer.Data.Level.Value;
		if World1 then
			if a == 1 or a <= 9 then
				if tostring(TeamSelf) == "Marines" then
					Mon = "Trainee"
					Qname = "MarineQuest"
					Qdata = 1;
					NameMon = "Trainee"
					PosM = CFrame.new(-2709.67944, 24.5206585, 2104.24585, -0.744724929, -3.97967455e-08, -0.667371571, 4.32403588e-08, 1, -1.07884304e-07, 0.667371571, -1.09201515e-07, -0.744724929)
					PosQ = CFrame.new(-2709.67944, 24.5206585, 2104.24585, -0.744724929, -3.97967455e-08, -0.667371571, 4.32403588e-08, 1, -1.07884304e-07, 0.667371571, -1.09201515e-07, -0.744724929)
				elseif tostring(TeamSelf) == "Pirates" then
					Mon = "Bandit"
					Qdata = 1;
					Qname = "BanditQuest1"
					NameMon = "Bandit"
					PosM = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
					PosQ = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
				end
			elseif a == 10 or a <= 14 then
				Mon = "Monkey"
				Qdata = 1;
				Qname = "JungleQuest"
				NameMon = "Monkey"
				PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
				PosM = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
			elseif a == 15 or a <= 29 then
				Mon = "Gorilla"
				Qdata = 2;
				Qname = "JungleQuest"
				NameMon = "Gorilla"
				PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
				PosM = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
			elseif a == 30 or a <= 39 then
				Mon = "Pirate"
				Qdata = 1;
				Qname = "BuggyQuest1"
				NameMon = "Pirate"
				PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
				PosM = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
			elseif a == 40 or a <= 59 then
				Mon = "Brute"
				Qdata = 2;
				Qname = "BuggyQuest1"
				NameMon = "Brute"
				PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
				PosM = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
			elseif a == 60 or a <= 74 then
				Mon = "Desert Bandit"
				Qdata = 1;
				Qname = "DesertQuest"
				NameMon = "Desert Bandit"
				PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
				PosM = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
			elseif a == 75 or a <= 89 then
				Mon = "Desert Officer"
				Qdata = 2;
				Qname = "DesertQuest"
				NameMon = "Desert Officer"
				PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
				PosM = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
			elseif a == 90 or a <= 99 then
				Mon = "Snow Bandit"
				Qdata = 1;
				Qname = "SnowQuest"
				NameMon = "Snow Bandit"
				PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
				PosM = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
			elseif a == 100 or a <= 119 then
				Mon = "Snowman"
				Qdata = 2;
				Qname = "SnowQuest"
				NameMon = "Snowman"
				PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
				PosM = CFrame.new(6241.9951171875, 51.522083282471, -1243.9771728516)
			elseif a == 120 or a <= 149 then
				Mon = "Chief Petty Officer"
				Qdata = 1;
				Qname = "MarineQuest2"
				NameMon = "Chief Petty Officer"
				PosQ = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
			elseif a == 150 or a <= 174 then
				Mon = "Sky Bandit"
				Qdata = 1;
				Qname = "SkyQuest"
				NameMon = "Sky Bandit"
				PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
				PosM = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
			elseif a == 175 or a <= 189 then
				Mon = "Dark Master"
				Qdata = 2;
				Qname = "SkyQuest"
				NameMon = "Dark Master"
				PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
				PosM = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
			elseif a == 190 or a <= 209 then
				Mon = "Prisoner"
				Qdata = 1;
				Qname = "PrisonerQuest"
				NameMon = "Prisoner"
				PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
				PosM = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
			elseif a == 210 or a <= 249 then
				Mon = "Dangerous Prisoner"
				Qdata = 2;
				Qname = "PrisonerQuest"
				NameMon = "Dangerous Prisoner"
				PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
				PosM = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
			elseif a == 250 or a <= 274 then
				Mon = "Toga Warrior"
				Qdata = 1;
				Qname = "ColosseumQuest"
				NameMon = "Toga Warrior"
				PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
				PosM = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
			elseif a == 275 or a <= 299 then
				Mon = "Gladiator"
				Qdata = 2;
				Qname = "ColosseumQuest"
				NameMon = "Gladiator"
				PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
				PosM = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
			elseif a == 300 or a <= 324 then
				Boubty = false;
				Mon = "Military Soldier"
				Qdata = 1;
				Qname = "MagmaQuest"
				NameMon = "Military Soldier"
				PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
				PosM = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
			elseif a == 325 or a <= 374 then
				Mon = "Military Spy"
				Qdata = 2;
				Qname = "MagmaQuest"
				NameMon = "Military Spy"
				PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
				PosM = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
			elseif a == 375 or a <= 399 then
				Mon = "Fishman Warrior"
				Qdata = 1;
				Qname = "FishmanQuest"
				NameMon = "Fishman Warrior"
				PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
				PosM = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
				end
			elseif a == 400 or a <= 449 then
				Mon = "Fishman Commando"
				Qdata = 2;
				Qname = "FishmanQuest"
				NameMon = "Fishman Commando"
				PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
				PosM = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
				end
			elseif a == 450 or a <= 474 then
				Mon = "God's Guard"
				Qdata = 1;
				Qname = "SkyExp1Quest"
				NameMon = "God's Guard"
				PosQ = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, 0, 1, -0, 0.0871884301, 0, 0.996191859)
				PosM = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.82275, 872.54248, -1667.55688))
				end
			elseif a == 475 or a <= 524 then
				Mon = "Shanda"
				Qdata = 2;
				Qname = "SkyExp1Quest"
				NameMon = "Shanda"
				PosQ = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
				PosM = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
				end
			elseif a == 525 or a <= 549 then
				Mon = "Royal Squad"
				Qdata = 1;
				Qname = "SkyExp2Quest"
				NameMon = "Royal Squad"
				PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)
			elseif a == 550 or a <= 624 then
				Mon = "Royal Soldier"
				Qdata = 2;
				Qname = "SkyExp2Quest"
				NameMon = "Royal Soldier"
				PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
			elseif a == 625 or a <= 649 then
				Mon = "Galley Pirate"
				Qdata = 1;
				Qname = "FountainQuest"
				NameMon = "Galley Pirate"
				PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
				PosM = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
			elseif a >= 650 then
				Mon = "Galley Captain"
				Qdata = 2;
				Qname = "FountainQuest"
				NameMon = "Galley Captain"
				PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
				PosM = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
			end
		elseif World2 then
			if a == 700 or a <= 724 then
				Mon = "Raider"
				Qdata = 1;
				Qname = "Area1Quest"
				NameMon = "Raider"
				PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
				PosM = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
			elseif a == 725 or a <= 774 then
				Mon = "Mercenary"
				Qdata = 2;
				Qname = "Area1Quest"
				NameMon = "Mercenary"
				PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
				PosM = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
			elseif a == 775 or a <= 799 then
				Mon = "Swan Pirate"
				Qdata = 1;
				Qname = "Area2Quest"
				NameMon = "Swan Pirate"
				PosQ = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, 0, 0.99026376, 0, 1, 0, -0.99026376, 0, 0.139203906)
				PosM = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625)
			elseif a == 800 or a <= 874 then
				Mon = "Factory Staff"
				Qname = "Area2Quest"
				Qdata = 2;
				NameMon = "Factory Staff"
				PosQ = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.07732087e-10, -0.0319722369)
				PosM = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)
			elseif a == 875 or a <= 899 then
				Mon = "Marine Lieutenant"
				Qdata = 1;
				Qname = "MarineQuest3"
				NameMon = "Marine Lieutenant"
				PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
				PosM = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)
			elseif a == 900 or a <= 949 then
				Mon = "Marine Captain"
				Qdata = 2;
				Qname = "MarineQuest3"
				NameMon = "Marine Captain"
				PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
				PosM = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625)
			elseif a == 950 or a <= 974 then
				Mon = "Zombie"
				Qdata = 1;
				Qname = "ZombieQuest"
				NameMon = "Zombie"
				PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
				PosM = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)
			elseif a == 975 or a <= 999 then
				Mon = "Vampire"
				Qdata = 2;
				Qname = "ZombieQuest"
				NameMon = "Vampire"
				PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
				PosM = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)
			elseif a == 1000 or a <= 1049 then
				Mon = "Snow Trooper"
				Qdata = 1;
				Qname = "SnowMountainQuest"
				NameMon = "Snow Trooper"
				PosQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
				PosM = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)
			elseif a == 1050 or a <= 1099 then
				Mon = "Winter Warrior"
				Qdata = 2;
				Qname = "SnowMountainQuest"
				NameMon = "Winter Warrior"
				PosQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
				PosM = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)
			elseif a == 1100 or a <= 1124 then
				Mon = "Lab Subordinate"
				Qdata = 1;
				Qname = "IceSideQuest"
				NameMon = "Lab Subordinate"
				PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578)
				PosM = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)
			elseif a == 1125 or a <= 1174 then
				Mon = "Horned Warrior"
				Qdata = 2;
				Qname = "IceSideQuest"
				NameMon = "Horned Warrior"
				PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578)
				PosM = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)
			elseif a == 1175 or a <= 1199 then
				Mon = "Magma Ninja"
				Qdata = 1;
				Qname = "FireSideQuest"
				NameMon = "Magma Ninja"
				PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
				PosM = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
			elseif a == 1200 or a <= 1249 then
				Mon = "Lava Pirate"
				Qdata = 2;
				Qname = "FireSideQuest"
				NameMon = "Lava Pirate"
				PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
				PosM = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
			elseif a == 1250 or a <= 1274 then
				Mon = "Ship Deckhand"
				Qdata = 1;
				Qname = "ShipQuest1"
				NameMon = "Ship Deckhand"
				PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
				PosM = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
				end
			elseif a == 1275 or a <= 1299 then
				Mon = "Ship Engineer"
				Qdata = 2;
				Qname = "ShipQuest1"
				NameMon = "Ship Engineer"
				PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
				PosM = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
				end
			elseif a == 1300 or a <= 1324 then
				Mon = "Ship Steward"
				Qdata = 1;
				Qname = "ShipQuest2"
				NameMon = "Ship Steward"
				PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
				PosM = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
				end
			elseif a == 1325 or a <= 1349 then
				Mon = "Ship Officer"
				Qdata = 2;
				Qname = "ShipQuest2"
				NameMon = "Ship Officer"
				PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
				PosM = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
					replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
				end
			elseif a == 1350 or a <= 1374 then
				Mon = "Arctic Warrior"
				Qdata = 1;
				Qname = "FrostQuest"
				NameMon = "Arctic Warrior"
				PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
				PosM = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)
				if _G.Level and (PosQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 1000 then
					BTP(PosM)
				end
			elseif a == 1375 or a <= 1424 then
				Mon = "Snow Lurker"
				Qdata = 2;
				Qname = "FrostQuest"
				NameMon = "Snow Lurker"
				PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
				PosM = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)
			elseif a == 1425 or a <= 1449 then
				Mon = "Sea Soldier"
				Qdata = 1;
				Qname = "ForgottenQuest"
				NameMon = "Sea Soldier"
				PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376)
				PosM = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)
			elseif a >= 1450 then
				Mon = "Water Fighter"
				Qdata = 2;
				Qname = "ForgottenQuest"
				NameMon = "Water Fighter"
				PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376)
				PosM = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)
			end
		elseif World3 then
			if a == 1500 or a <= 1524 then
				Mon = "Pirate Millionaire"
				Qdata = 1;
				Qname = "PiratePortQuest"
				NameMon = "Pirate Millionaire"
				PosQ = CFrame.new(-712.8272705078125, 98.5770492553711, 5711.9541015625)
				PosM = CFrame.new(-712.8272705078125, 98.5770492553711, 5711.9541015625)
			elseif a == 1525 or a <= 1574 then
				Mon = "Pistol Billionaire"
				Qdata = 2;
				Qname = "PiratePortQuest"
				NameMon = "Pistol Billionaire"
				PosQ = CFrame.new(-723.4331665039062, 147.42906188964844, 5931.9931640625)
				PosM = CFrame.new(-723.4331665039062, 147.42906188964844, 5931.9931640625)
			elseif a == 1575 or a <= 1599 then
				Mon = "Dragon Crew Warrior"
				Qdata = 1;
				Qname = "AmazonQuest"
				NameMon = "Dragon Crew Warrior"
				PosQ = CFrame.new(6779.03271484375, 111.16865539550781, -801.2130737304688)
				PosM = CFrame.new(6779.03271484375, 111.16865539550781, -801.2130737304688)
			elseif a == 1600 or a <= 1624 then
				Mon = "Dragon Crew Archer"
				Qname = "AmazonQuest"
				Qdata = 2;
				NameMon = "Dragon Crew Archer"
				PosQ = CFrame.new(6955.8974609375, 546.6658935546875, 309.0401306152344)
				PosM = CFrame.new(6955.8974609375, 546.6658935546875, 309.0401306152344)
			elseif a == 1625 or a <= 1649 then
				Mon = "Hydra Enforcer"
				Qname = "VenomCrewQuest"
				Qdata = 1;
				NameMon = "Hydra Enforcer"
				PosQ = CFrame.new(4620.61572265625, 1002.2954711914062, 399.0868835449219)
				PosM = CFrame.new(4620.61572265625, 1002.2954711914062, 399.0868835449219)
			elseif a == 1650 or a <= 1699 then
				Mon = "Venomous Assailant"
				Qname = "VenomCrewQuest"
				Qdata = 2;
				NameMon = "Venomous Assailant"
				PosQ = CFrame.new(4697.5918, 1100.65137, 946.401978, 0.579397917, -4.19689783e-10, 0.81504482, -1.49287818e-10, 1, 6.21053986e-10, -0.81504482, -4.81513662e-10, 0.579397917)
				PosM = CFrame.new(4697.5918, 1100.65137, 946.401978, 0.579397917, -4.19689783e-10, 0.81504482, -1.49287818e-10, 1, 6.21053986e-10, -0.81504482, -4.81513662e-10, 0.579397917)
			elseif a == 1700 or a <= 1724 then
				Mon = "Marine Commodore"
				Qdata = 1;
				Qname = "MarineTreeIsland"
				NameMon = "Marine Commodore"
				PosQ = CFrame.new(2180.54126, 27.8156815, -6741.5498, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
				PosM = CFrame.new(2286.0078125, 73.13391876220703, -7159.80908203125)
			elseif a == 1725 or a <= 1774 then
				Mon = "Marine Rear Admiral"
				NameMon = "Marine Rear Admiral"
				Qname = "MarineTreeIsland"
				Qdata = 2;
				PosQ = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
				PosM = CFrame.new(3656.773681640625, 160.52406311035156, -7001.5986328125)
			elseif a == 1775 or a <= 1799 then
				Mon = "Fishman Raider"
				Qdata = 1;
				Qname = "DeepForestIsland3"
				NameMon = "Fishman Raider"
				PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
				PosM = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)
			elseif a == 1800 or a <= 1824 then
				Mon = "Fishman Captain"
				Qdata = 2;
				Qname = "DeepForestIsland3"
				NameMon = "Fishman Captain"
				PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
				PosM = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)
			elseif a == 1825 or a <= 1849 then
				Mon = "Forest Pirate"
				Qdata = 1;
				Qname = "DeepForestIsland"
				NameMon = "Forest Pirate"
				PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
				PosM = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)
			elseif a == 1850 or a <= 1899 then
				Mon = "Mythological Pirate"
				Qdata = 2;
				Qname = "DeepForestIsland"
				NameMon = "Mythological Pirate"
				PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
				PosM = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
			elseif a == 1900 or a <= 1924 then
				Mon = "Jungle Pirate"
				Qdata = 1;
				Qname = "DeepForestIsland2"
				NameMon = "Jungle Pirate"
				PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
				PosM = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)
			elseif a == 1925 or a <= 1974 then
				Mon = "Musketeer Pirate"
				Qdata = 2;
				Qname = "DeepForestIsland2"
				NameMon = "Musketeer Pirate"
				PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
				PosM = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)
			elseif a == 1975 or a <= 1999 then
				Mon = "Reborn Skeleton"
				Qdata = 1;
				Qname = "HauntedQuest1"
				NameMon = "Reborn Skeleton"
				PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
				PosM = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)
			elseif a == 2000 or a <= 2024 then
				Mon = "Living Zombie"
				Qdata = 2;
				Qname = "HauntedQuest1"
				NameMon = "Living Zombie"
				PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
				PosM = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)
			elseif a == 2025 or a <= 2049 then
				Mon = "Demonic Soul"
				Qdata = 1;
				Qname = "HauntedQuest2"
				NameMon = "Demonic Soul"
				PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)
			elseif a == 2050 or a <= 2074 then
				Mon = "Posessed Mummy"
				Qdata = 2;
				Qname = "HauntedQuest2"
				NameMon = "Posessed Mummy"
				PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)
			elseif a == 2075 or a <= 2099 then
				Mon = "Peanut Scout"
				Qdata = 1;
				Qname = "NutsIslandQuest"
				NameMon = "Peanut Scout"
				PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)
			elseif a == 2100 or a <= 2124 then
				Mon = "Peanut President"
				Qdata = 2;
				Qname = "NutsIslandQuest"
				NameMon = "Peanut President"
				PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)
			elseif a == 2125 or a <= 2149 then
				Mon = "Ice Cream Chef"
				Qdata = 1;
				Qname = "IceCreamIslandQuest"
				NameMon = "Ice Cream Chef"
				PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)
			elseif a == 2150 or a <= 2199 then
				Mon = "Ice Cream Commander"
				Qdata = 2;
				Qname = "IceCreamIslandQuest"
				NameMon = "Ice Cream Commander"
				PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				PosM = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)
			elseif a == 2200 or a <= 2224 then
				Mon = "Cookie Crafter"
				Qdata = 1;
				Qname = "CakeQuest1"
				NameMon = "Cookie Crafter"
				PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
				PosM = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)
			elseif a == 2225 or a <= 2249 then
				Mon = "Cake Guard"
				Qdata = 2;
				Qname = "CakeQuest1"
				NameMon = "Cake Guard"
				PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
				PosM = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)
			elseif a == 2250 or a <= 2274 then
				Mon = "Baking Staff"
				Qdata = 1;
				Qname = "CakeQuest2"
				NameMon = "Baking Staff"
				PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
				PosM = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)
			elseif a == 2275 or a <= 2299 then
				Mon = "Head Baker"
				Qdata = 2;
				Qname = "CakeQuest2"
				NameMon = "Head Baker"
				PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
				PosM = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)
			elseif a == 2300 or a <= 2324 then
				Mon = "Cocoa Warrior"
				Qdata = 1;
				Qname = "ChocQuest1"
				NameMon = "Cocoa Warrior"
				PosQ = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
				PosM = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)
			elseif a == 2325 or a <= 2349 then
				Mon = "Chocolate Bar Battler"
				Qdata = 2;
				Qname = "ChocQuest1"
				NameMon = "Chocolate Bar Battler"
				PosQ = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
				PosM = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375)
			elseif a == 2350 or a <= 2374 then
				Mon = "Sweet Thief"
				Qdata = 1;
				Qname = "ChocQuest2"
				NameMon = "Sweet Thief"
				PosQ = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
				PosM = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625)
			elseif a == 2375 or a <= 2399 then
				Mon = "Candy Rebel"
				Qdata = 2;
				Qname = "ChocQuest2"
				NameMon = "Candy Rebel"
				PosQ = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
				PosM = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625)
			elseif a == 2400 or a <= 2449 then
				Mon = "Candy Pirate"
				Qdata = 1;
				Qname = "CandyQuest1"
				NameMon = "Candy Pirate"
				PosQ = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
				PosM = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875)
			elseif a == 2450 or a <= 2474 then
				Mon = "Isle Outlaw"
				Qdata = 1;
				Qname = "TikiQuest1"
				NameMon = "Isle Outlaw"
				PosQ = CFrame.new(-16548.8164, 55.6059914, -172.8125, 0.213092566, -0, -0.977032006, 0, 1, -0, 0.977032006, 0, 0.213092566)
				PosM = CFrame.new(-16479.900390625, 226.6117401123047, -300.3114318847656)
			elseif a == 2475 or a <= 2499 then
				Mon = "Island Boy"
				Qdata = 2;
				Qname = "TikiQuest1"
				NameMon = "Island Boy"
				PosQ = CFrame.new(-16548.8164, 55.6059914, -172.8125, 0.213092566, -0, -0.977032006, 0, 1, -0, 0.977032006, 0, 0.213092566)
				PosM = CFrame.new(-16849.396484375, 192.86505126953125, -150.7853240966797)
			elseif a == 2500 or a <= 2524 then
				Mon = "Sun-kissed Warrior"
				Qdata = 1;
				Qname = "TikiQuest2"
				NameMon = "kissed Warrior"
				PosM = CFrame.new(-16347, 64, 984)
				PosQ = CFrame.new(-16538, 55, 1049)
			elseif a == 2525 or a <= 2550 then
				Mon = "Isle Champion"
				Qdata = 2;
				Qname = "TikiQuest2"
				NameMon = "Isle Champion"
				PosQ = CFrame.new(-16541.0215, 57.3082275, 1051.46118, 0.0410757065, -0, -0.999156058, 0, 1, -0, 0.999156058, 0, 0.0410757065)
				PosM = CFrame.new(-16602.1015625, 130.38734436035156, 1087.24560546875)-- Tiki Outpost
	-- TIKI OUTPOST
			elseif a >= 2551 and a <= 2574 then
				Mon = "Serpent Hunter"
				Qdata = 1;
				Qname = "TikiQuest3";
				NameMon = "Serpent Hunter"
				PosQ = CFrame.new(-16679.4785, 176.7473, 1474.3995)
				PosM = CFrame.new(-16679.4785, 176.7473, 1474.3995)
			elseif a >= 2575 and a <= 2599 then 
				Mon = "Skull Slayer"
				Qdata = 2;
				Qname = "TikiQuest3";
				NameMon = "Skull Slayer"
				PosQ = CFrame.new(-16759.5898, 71.2837, 1595.3399)
				PosM = CFrame.new(-16759.5898, 71.2837, 1595.3399)

			elseif a >= 2600 and a <= 2624 then
				Mon = "Reef Bandit"
				Qdata = 1;
				Qname = "SubmergedQuest1";
				NameMon = "Reef Bandit"
				PosQ = CFrame.new(10882.264, -2086.322, 10034.226) -- NPC Submerged
				PosM = CFrame.new(10736.6191, -2087.8439, 9338.4882)
			elseif a >= 2625 and a <= 2649 then
				Mon = "Coral Pirate"
				Qdata = 2;
				Qname = "SubmergedQuest1";
				NameMon = "Coral Pirate"
				PosQ = CFrame.new(10882.264, -2086.322, 10034.226)
				PosM = CFrame.new(10965.1025, -2158.8842, 9177.2597)
			elseif a >= 2650 and a <= 2674 then
				Mon = "Sea Chanter"
				Qdata = 1;
				Qname = "SubmergedQuest2";
				NameMon = "Sea Chanter"
				PosQ = CFrame.new(10882.264, -2086.322, 10034.226)
				PosM = CFrame.new(10621.0342, -2087.8440, 10102.0332)
			elseif a >= 2675 and a <= 2699 then
				Mon = "Ocean Prophet"
				Qdata = 2;
				Qname = "SubmergedQuest2";
				NameMon = "Ocean Prophet"
				PosQ = CFrame.new(10882.264, -2086.322, 10034.226)
				PosM = CFrame.new(11056.1445, -2001.6717, 10117.4493)
			elseif a >= 2700 and a <= 2724 then
				Mon = "High Disciple"
				Qdata = 1;
				Qname = "SubmergedQuest3";
				NameMon = "High Disciple"
				PosQ = CFrame.new(9636.52441, -1992.19507, 9609.52832)
				PosM = CFrame.new(9828.087890625, -1940.908935546875, 9693.0634765625)
			elseif a >= 2725 and a <= 2800 then
				Mon = "Grand Devotee"
				Qdata = 2;
				Qname = "SubmergedQuest3";
				NameMon = "Grand Devotee"
				PosQ = CFrame.new(9636.52441, -1992.19507, 9609.52832)
				PosM = CFrame.new(9557.5849609375, -1928.0404052734375, 9859.1826171875)
			end
		end
	end
	MaterialMon = function()
		local a = game.Players.LocalPlayer;
		local b = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
		if not b then
			return
		end;
		shouldRequestEntrance = function(c, d)
			local e = (b.Position - c).Magnitude;
			if e >= d then
				replicated.Remotes.CommF_:InvokeServer("requestEntrance", c)
			end
		end;
		if World1 then
			if SelectMaterial == "Angel Wings" then
				MMon = {
					"Shanda",
					"Royal Squad",
					"Royal Soldier",
					"Wysper",
					"Thunder God"
				}
				MPos = CFrame.new(-4698, 845, -1912)
				SP = "Default"
				local c = Vector3.new(-4607.82275, 872.54248, -1667.55688)
				shouldRequestEntrance(c, 10000)
			elseif SelectMaterial == "Leather + Scrap Metal" then
				MMon = {
					"Brute",
					"Pirate"
				}
				MPos = CFrame.new(-1145, 15, 4350)
				SP = "Default"
			elseif SelectMaterial == "Magma Ore" then
				MMon = {
					"Military Soldier",
					"Military Spy",
					"Magma Admiral"
				}
				MPos = CFrame.new(-5815, 84, 8820)
				SP = "Default"
			elseif SelectMaterial == "Fish Tail" then
				MMon = {
					"Fishman Warrior",
					"Fishman Commando",
					"Fishman Lord"
				}
				MPos = CFrame.new(61123, 19, 1569)
				SP = "Default"
				local c = Vector3.new(61163.8515625, 5.342342376708984, 1819.7841796875)
				shouldRequestEntrance(c, 17000)
			end
		elseif World2 then
			if SelectMaterial == "Leather + Scrap Metal" then
				MMon = {
					"Marine Captain"
				}
				MPos = CFrame.new(-2010.5059814453125, 73.00115966796875, -3326.620849609375)
				SP = "Default"
			elseif SelectMaterial == "Magma Ore" then
				MMon = {
					"Magma Ninja",
					"Lava Pirate"
				}
				MPos = CFrame.new(-5428, 78, -5959)
				SP = "Default"
			elseif SelectMaterial == "Ectoplasm" then
				MMon = {
					"Ship Deckhand",
					"Ship Engineer",
					"Ship Steward",
					"Ship Officer"
				}
				MPos = CFrame.new(911.35827636719, 125.95812988281, 33159.5390625)
				SP = "Default"
				local c = Vector3.new(61163.8515625, 5.342342376708984, 1819.7841796875)
				shouldRequestEntrance(c, 18000)
			elseif SelectMaterial == "Mystic Droplet" then
				MMon = {
					"Water Fighter"
				}
				MPos = CFrame.new(-3385, 239, -10542)
				SP = "Default"
			elseif SelectMaterial == "Radioactive Material" then
				MMon = {
					"Factory Staff"
				}
				MPos = CFrame.new(295, 73, -56)
				SP = "Default"
			elseif SelectMaterial == "Vampire Fang" then
				MMon = {
					"Vampire"
				}
				MPos = CFrame.new(-6033, 7, -1317)
				SP = "Default"
			end
		elseif World3 then
			if SelectMaterial == "Scrap Metal" then
				MMon = {
					"Jungle Pirate",
					"Forest Pirate"
				}
				MPos = CFrame.new(-11975.78515625, 331.7734069824219, -10620.0302734375)
				SP = "Default"
			elseif SelectMaterial == "Fish Tail" then
				MMon = {
					"Fishman Raider",
					"Fishman Captain"
				}
				MPos = CFrame.new(-10993, 332, -8940)
				SP = "Default"
			elseif SelectMaterial == "Conjured Cocoa" then
				MMon = {
					"Chocolate Bar Battler",
					"Cocoa Warrior"
				}
				MPos = CFrame.new(620.6344604492188, 78.93644714355469, -12581.369140625)
				SP = "Default"
			elseif SelectMaterial == "Dragon Scale" then
				MMon = {
					"Dragon Crew Archer",
					"Dragon Crew Warrior"
				}
				MPos = CFrame.new(6594, 383, 139)
				SP = "Default"
			elseif SelectMaterial == "Gunpowder" then
				MMon = {
					"Pistol Billionaire"
				}
				MPos = CFrame.new(-84.8556900024414, 85.62061309814453, 6132.0087890625)
				SP = "Default"
			elseif SelectMaterial == "Mini Tusk" then
				MMon = {
					"Mythological Pirate"
				}
				MPos = CFrame.new(-13545, 470, -6917)
				SP = "Default"
			elseif SelectMaterial == "Demonic Wisp" then
				MMon = {
					"Demonic Soul"
				}
				MPos = CFrame.new(-9495.6806640625, 453.58624267578125, 5977.3486328125)
				SP = "Default"
			end
		end
	end
	QuestNeta = function()
		local Neta = QuestCheck()
		return {
			[1] = Mon,
			[2] = Qdata,
			[3] = Qname,
			[4] = PosM,
			[5] = NameMon,
			[6] = PosQ
		}
	end
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

getgenv().PMT_MAX_STEP_DIST = getgenv().PMT_MAX_STEP_DIST or 9000
getgenv().PMT_HOLD_TIME = getgenv().PMT_HOLD_TIME or 3
getgenv().PMT_HOLD_STEP = getgenv().PMT_HOLD_STEP or 0.01
getgenv().PMT_RESPAWN_TIMEOUT = getgenv().PMT_RESPAWN_TIMEOUT or 10
getgenv().PMT_SKIP_IF_NEAR = getgenv().PMT_SKIP_IF_NEAR or 2000

local IslandCF = {
    ["WindMill"] = CFrame.new(979.799, 16.516, 1429.047),
    ["Marine"] = CFrame.new(-2566.43, 6.856, 2045.256),
    ["Middle Town"] = CFrame.new(-690.331, 15.094, 1582.238),
    ["Jungle"] = CFrame.new(-1612.796, 36.852, 149.128),
    ["Pirate Village"] = CFrame.new(-1181.309, 4.751, 3803.546),
    ["Desert"] = CFrame.new(944.158, 20.92, 4373.3),
    ["Snow Island"] = CFrame.new(1347.807, 104.668, -1319.737),
    ["MarineFord"] = CFrame.new(-4914.821, 50.964, 4281.028),
    ["Colosseum"] = CFrame.new(-1427.62, 7.288, -2792.772),
    ["Sky Island 1"] = CFrame.new(-4869.103, 733.461, -2667.018),
    ["Sky Island 2"] = CFrame.new(-11.311, 29.277, 2771.522),
    ["Sky Island 3"] = CFrame.new(-483.734, 332.038, 595.327),
    ["Prison"] = CFrame.new(4875.33, 5.652, 734.85),
    ["Magma Village"] = CFrame.new(-5247.716, 12.884, 8504.969),
    ["Under Water Island"] = CFrame.new(61163.852, 11.68, 1819.784),
    ["Fountain City"] = CFrame.new(5127.128, 59.501, 4105.446),
    ["The Cafe"] = CFrame.new(-380.479, 77.22, 255.826),
    ["Frist Spot"] = CFrame.new(-9515.372, 164.006, 5786.061),
    ["Dark Area"] = CFrame.new(3780.03, 22.652, -3498.586),
    ["Flamingo Mansion"] = CFrame.new(-3032.764, 317.897, -10075.373),
    ["Flamingo Room"] = CFrame.new(2284.414, 15.152, 875.725),
    ["Green Zone"] = CFrame.new(-2448.53, 73.016, -3210.631),
    ["Factory"] = CFrame.new(424.127, 211.162, -427.54),
    ["Colossuim"] = CFrame.new(-1503.622, 219.796, 1369.31),
    ["Zombie Island"] = CFrame.new(-5622.033, 492.196, -781.786),
    ["Two Snow Mountain"] = CFrame.new(753.143, 408.236, -5274.615),
    ["Punk Hazard"] = CFrame.new(-6127.654, 15.952, -5040.286),
    ["Cursed Ship"] = CFrame.new(923.402, 125.057, 32885.875),
    ["Ice Castle"] = CFrame.new(6148.412, 294.387, -6741.117),
    ["Forgotten Island"] = CFrame.new(2681.274, 1682.809, -7190.985),
    ["Sea castle"] = CFrame.new(-5496.452, 313.809, -2857.703),
    ["Mini Sky Island"] = CFrame.new(-288.741, 49326.316, -35248.594),
    ["Great Tree"] = CFrame.new(2681.274, 1682.809, -7190.985),
    ["Port Town"] = CFrame.new(-226.751, 20.603, 5538.34),
    ["Hydra Island"] = CFrame.new(5291.249, 1005.443, 393.762),
    ["Mansion"] = CFrame.new(-12633.672, 459.521, -7425.463),
    ["Haunted Castle"] = CFrame.new(-9366.803, 141.366, 5443.941),
    ["Ice Cream Island"] = CFrame.new(-902.568, 79.932, -10988.848),
    ["Peanut Island"] = CFrame.new(-2062.748, 50.474, -10232.568),
    ["Cake Island"] = CFrame.new(-1884.775, 19.328, -11666.897),
    ["Cocoa Island"] = CFrame.new(87.943, 73.555, -12319.465),
    ["Candy Island"] = CFrame.new(-1014.424, 149.111, -14555.963),
    ["Tiki Outpost"] = CFrame.new(-16218.683, 9.086, 445.618),
    ["Dragon Dojo"] = CFrame.new(5743.319, 1206.91, 936.011),
}

local Alias = {
    ["MiniSky"] = "Mini Sky Island",
    ["Colosseum"] = "Colosseum",
    ["Colossuim"] = "Colossuim",
}

local WorldIslands = {
    World1 = {"WindMill","Marine","Middle Town","Jungle","Pirate Village","Desert","Snow Island","MarineFord","Colosseum","Sky Island 1","Sky Island 2","Sky Island 3","Prison","Magma Village","Under Water Island","Fountain City"},
    World2 = {"The Cafe","Frist Spot","Dark Area","Flamingo Mansion","Flamingo Room","Green Zone","Factory","Colossuim","Zombie Island","Two Snow Mountain","Punk Hazard","Cursed Ship","Ice Castle","Forgotten Island"},
    World3 = {"Sea castle","Mini Sky Island","Great Tree","Port Town","Hydra Island","Mansion","Haunted Castle","Ice Cream Island","Peanut Island","Cake Island","Cocoa Island","Candy Island","Tiki Outpost","Dragon Dojo"},
}

local Id = game.PlaceId

local World1 = Id == 2753915549 or Id == 85211729168715
local World2 = Id == 4442272183 or Id == 79091703265657
local World3 = Id == 7449423635 or Id == 100117331123089

local function getWorldKey()
    if World3 then return "World3" end
    if World2 then return "World2" end
    if World1 then return "World1" end
    
    warn("[PMT] PlaceId không nhận dạng được: " .. tostring(Id) .. " -> fallback World3")
    return "World3"
end
local function normName(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if Alias[name] then name = Alias[name] end
    return name
end

local function dist(a, b) return (a - b).Magnitude end

local function GetChar()
    local c = LP.Character or LP.CharacterAdded:Wait()
    local hrp = c:WaitForChild("HumanoidRootPart", 10)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    return c, hrp, hum
end

local function buildNodes()
    local wk = getWorldKey()
    local list = WorldIslands[wk] or {}
    local nodes = {}
    for _, n in ipairs(list) do
        if IslandCF[n] then nodes[#nodes+1] = n end
    end
    return nodes
end

-- Location = tất cả đảo của world hiện tại
Location = Location or {}
do
    table.clear(Location)
    for _, n in ipairs(buildNodes()) do
        Location[#Location+1] = n
    end
end

local function nearestIsland(pos, nodes)
    local best, bestD
    for _, n in ipairs(nodes) do
        local d = dist(pos, IslandCF[n].Position)
        if not bestD or d < bestD then bestD, best = d, n end
    end
    return best, bestD or math.huge
end

local function dijkstra(nodes, startName, goalName, maxStep)
    local adj = {}
    for _, a in ipairs(nodes) do adj[a] = {} end
    for i = 1, #nodes do
        local ai = nodes[i]
        local ap = IslandCF[ai].Position
        for j = i+1, #nodes do
            local bj = nodes[j]
            local bp = IslandCF[bj].Position
            local d = dist(ap, bp)
            if d <= maxStep then
                adj[ai][bj] = d
                adj[bj][ai] = d
            end
        end
    end
    local distMap, prev, used = {}, {}, {}
    for _, n in ipairs(nodes) do distMap[n] = math.huge end
    distMap[startName] = 0
    while true do
        local u, best = nil, math.huge
        for _, n in ipairs(nodes) do
            if not used[n] and distMap[n] < best then best, u = distMap[n], n end
        end
        if not u or u == goalName then break end
        used[u] = true
        for v, w in pairs(adj[u]) do
            if not used[v] then
                local nd = distMap[u] + w
                if nd < distMap[v] then distMap[v], prev[v] = nd, u end
            end
        end
    end
    if distMap[goalName] == math.huge then return nil end
    local path, cur = {}, goalName
    while cur do
        table.insert(path, 1, cur)
        cur = prev[cur]
    end
    return path
end

local _STOP, _RUN = false, false

local _lastIsland = nil

local function HoldTPAndReset(pos)
    local c, hrp, hum = GetChar()
    if not c then return false end
    local cf = CFrame.new(pos + Vector3.new(0, 10, 0))
    pcall(function()
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    local t0 = os.clock()
    while os.clock() - t0 < getgenv().PMT_HOLD_TIME do
        if _STOP then break end
        if not (hrp and hrp.Parent and hum and hum.Parent and hum.Health > 0) then break end
        pcall(function()
            hrp.CFrame = cf
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        task.wait(getgenv().PMT_HOLD_STEP)
    end
    if _STOP then return false end
    pcall(function() hum.Health = 0 end)
    return true
end

local function WaitRespawn()
    local timeout = getgenv().PMT_RESPAWN_TIMEOUT
    local t0 = os.clock()
    local c = LP.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then return true end
    end
    local respawned = false
    local conn = LP.CharacterAdded:Connect(function(newChar)
        task.spawn(function()
            local hrp = newChar:WaitForChild("HumanoidRootPart", 2)
            local hum = newChar:WaitForChild("Humanoid", 2)
            if hrp and hum and hum.Health > 0 then respawned = true end
        end)
        conn:Disconnect()
    end)
    while os.clock() - t0 < timeout do
        if _STOP then conn:Disconnect() return false end
        if respawned then conn:Disconnect() return true end
        task.wait(0.03)
    end
    conn:Disconnect()
    return respawned
end

function PMT_FastHopTo(targetName)
    targetName = normName(targetName)
    if not (targetName and IslandCF[targetName]) then return false end

    local nodes = buildNodes()
    if #nodes == 0 then return false end

    local startIsland
    if _lastIsland and IslandCF[_lastIsland] then
        startIsland = _lastIsland
    else
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if not WaitRespawn() then return false end
            hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        end
        if not hrp then return false end
        startIsland = nearestIsland(hrp.Position, nodes)
    end

    local path = dijkstra(nodes, startIsland, targetName, getgenv().PMT_MAX_STEP_DIST)

    -- Nếu path không tìm được, thử lại từ vị trí thực (tránh _lastIsland cũ gây lỗi)
    if not path then
        _lastIsland = nil
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            startIsland = nearestIsland(hrp.Position, nodes)
            path = dijkstra(nodes, startIsland, targetName, getgenv().PMT_MAX_STEP_DIST)
        end
        if not path then return false end
    end

    _RUN, _STOP = true, false

    for _, name in ipairs(path) do
        if _STOP then break end
        local pos = IslandCF[name].Position
        local ch = LP.Character
        local hrp2 = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp2 and dist(hrp2.Position, pos) <= getgenv().PMT_SKIP_IF_NEAR then
            _lastIsland = name
            task.wait(0.05)
        else
            if not HoldTPAndReset(pos) or _STOP then break end
            if not WaitRespawn() or _STOP then break end
            _lastIsland = name  -- cập nhật SAU KHI respawn thành công
        end
        task.wait(0.1)
    end

    _RUN = false
    return not _STOP
end

function PMT_StopFastHop()
    _STOP = true
end

function PMT_IsFastHopRunning()
    return _RUN
end

-- Khi đổi target mới -> reset _lastIsland để path được tính lại từ đầu
task.spawn(function()
    local prevTarget = nil
    while task.wait(0.25) do
        if _G.Tpfast and not _RUN then
            local target = _G.Islandtp
            if target and target ~= "" then
                if target ~= prevTarget then
                    _lastIsland = nil
                    prevTarget = target
                end
                _STOP = false
                PMT_FastHopTo(target)
            end
        end
    end
end)

-- Trả về danh sách đảo của world hiện tại (dùng cho UI/dropdown)
function BuildIslandOptions()
    local nodes = buildNodes()
    local out = {}
    for _, name in ipairs(nodes) do
        out[#out+1] = name
    end
    table.sort(out)
    return out
end

local function PMT_IsNearIsland(name, range)
    local cf = IslandCF and IslandCF[name]
    if not cf then return true end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return (hrp.Position - cf.Position).Magnitude <= (range or 2500)
end

local function PMT_EnsureIsland(name, range, tries)
    range = range or 3000
    tries = tries or 3
    if PMT_IsNearIsland(name, range) then return true end
    for _ = 1, tries do
        if not (_G.AutoFarm_Bone and _G.Bypass) then
            return PMT_IsNearIsland(name, range)
        end
        if typeof(PMT_StopFastHop) == "function" then PMT_StopFastHop() end
        if _G.Bypass and typeof(PMT_FastHopTo) == "function" then
            pcall(function() PMT_FastHopTo(name) end)
        else
            local cf = IslandCF and IslandCF[name]
            if cf and typeof(_tp) == "function" then
                pcall(function() _tp(cf) end)
            end
        end
        task.wait(0.25)
        if PMT_IsNearIsland(name, range) then return true end
    end
    return PMT_IsNearIsland(name, range)
end

task.spawn(function()
    while task.wait(3) do
        if _RUN then continue end
        local newNodes = buildNodes()
        table.clear(Location)
        for _, n in ipairs(newNodes) do
            Location[#Location+1] = n
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Config = {
    SwitchDelay = 0.35,
    Range = 60,
    NoAnim = false,
    AutoAttack = false,  -- toggle state
}

task.spawn(function()
    RunService.Stepped:Connect(function()
        if Config.NoAnim and Character and Character:FindFirstChild("Humanoid") then
            local Animator = Character.Humanoid:FindFirstChildOfClass("Animator")
            if Animator then
                for _, Track in pairs(Animator:GetPlayingAnimationTracks()) do
                    Track:Stop()
                end
            end
        end
    end)
end)

local function GetTarget()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end
    local Target = nil
    local MinDist = Config.Range
    local Enemies = Workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, v in pairs(Enemies:GetChildren()) do
            local H = v:FindFirstChild("Humanoid")
            local R = v:FindFirstChild("HumanoidRootPart")
            if H and R and H.Health > 0 then
                local Dist = (R.Position - Root.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Target = R
                end
            end
        end
    end
    return Target
end

local function FindFruit()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")
    if CharTool and CharTool.ToolTip == "Blox Fruit" then return CharTool end
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then return v end
    end
    return nil
end

local function FindAnyMelee()
    local Backpack = Player.Backpack
    local CharTool = Character:FindFirstChildOfClass("Tool")
    if CharTool and CharTool.ToolTip == "Melee" then return CharTool end
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Melee" then return v end
    end
    return nil
end

local LastAttack = 0
RunService.Heartbeat:Connect(function()

    if not Config.AutoAttack then return end

    if not Character or not Character.Parent then
        Character = Player.Character
        if Character then
            Humanoid = Character:FindFirstChild("Humanoid")
        end
        return
    end

    if tick() - LastAttack < Config.SwitchDelay then return end

    local Target = GetTarget()
    if not Target then return end

    local Fruit = FindFruit()
    local Melee = FindAnyMelee()

    if Fruit and Melee then
        LastAttack = tick()
        Humanoid:EquipTool(Fruit)
        if Fruit:FindFirstChild("LeftClickRemote") then
            local Dir = (Target.Position - Character.HumanoidRootPart.Position).Unit
            Fruit.LeftClickRemote:FireServer(Dir, 1)
        end
        Humanoid:EquipTool(Melee)
    end
end)

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
end)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title="Neon X Hub [Blox Fruit]",
    SubTitle="By Mnhatrealz",
    TabWidth=140, 
    Theme="Darker",
    Acrylic=false,
    Size=UDim2.fromOffset(460, 350), 
    MinimizeKey=Enum.KeyCode.End
})
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

--// Nút tròn nhỏ
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(42, 42) -- nhỏ hơn
toggleButton.Position = UDim2.new(0.15, 0, 0.15, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundTransparency = 0.88 -- nền trắng mờ nhẹ
toggleButton.Image = "rbxassetid://78415207349307"
toggleButton.ScaleType = Enum.ScaleType.Fit
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = toggleButton

--// Viền trắng mỏng bên ngoài
local whiteStroke = Instance.new("UIStroke")
whiteStroke.Name = "WhiteBorder"
whiteStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
whiteStroke.Thickness = 3
whiteStroke.Transparency = 0.05
whiteStroke.Color = Color3.fromRGB(255, 255, 255)
whiteStroke.Parent = toggleButton

--// Animation hover/click nhẹ
local normalSize = UDim2.fromOffset(42, 42)
local hoverSize = UDim2.fromOffset(45, 45)

toggleButton.MouseEnter:Connect(function()
	TweenService:Create(toggleButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
		Size = hoverSize,
		BackgroundTransparency = 0.82
	}):Play()
end)

toggleButton.MouseLeave:Connect(function()
	TweenService:Create(toggleButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
		Size = normalSize,
		BackgroundTransparency = 0.88
	}):Play()
end)

--// KÉO THẢ DI CHUYỂN
local dragging = false
local dragStart, startPos
local moved = false
local DRAG_THRESHOLD = 4 -- tránh click bị hiểu là drag

toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		moved = false
		dragStart = input.Position
		startPos = toggleButton.Position

		-- hiệu ứng nhấn
		TweenService:Create(toggleButton, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(40, 40)
		}):Play()
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
			moved = true
		end

		toggleButton.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false

		-- trả size về bình thường/hover
		local mousePos = UIS:GetMouseLocation()
		local absPos = toggleButton.AbsolutePosition
		local absSize = toggleButton.AbsoluteSize
		local isHover =
			mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
			mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y

		TweenService:Create(toggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = isHover and hoverSize or normalSize
		}):Play()
	end
end)

--// Bật / tắt menu (chỉ click khi không kéo)
local isFluentVisible = true

toggleButton.MouseButton1Click:Connect(function()
	if moved then return end -- nếu vừa kéo thì không toggle

	isFluentVisible = not isFluentVisible

	if Window then
		Window:Minimize(not isFluentVisible)
	end
end)
local Tabs = {
Satus = Window:AddTab({Title = "Server Status", Icon = "server"}),
Settings = Window:AddTab({Title = "Farm Settings", Icon = "sliders"}),
Main = Window:AddTab({Title = "Auto Farm", Icon = "home"}),
Travel = Window:AddTab({Title = "Teleport", Icon = "map"}),
Melee = Window:AddTab({Title = "Auto Melee", Icon = "loader"}),
Quests = Window:AddTab({Title = "Items & Quests", Icon = "sword"}),
SeaEvent = Window:AddTab({Title = "Sea Events", Icon = "anchor"}),
Mirage = Window:AddTab({Title = "Race V4", Icon = "flag"}),
Prehistoric = Window:AddTab({Title = "Prehistoric Island", Icon = "tent"}),
Combat = Window:AddTab({Title = "Combat / PvP", Icon = "shield"}),
Fruit = Window:AddTab({Title = "Fruits", Icon = "apple"}),
Shop = Window:AddTab({Title = "Shop", Icon = "shopping-bag"}),
Misc = Window:AddTab({Title = "Miscellaneous", Icon = "menu"})
}
Tabs.Main:AddSection("Farming")
local FarmLevel = Tabs.Main:AddToggle("FarmLevel", {Title = "Auto Farm Level", Description = "", Default = false})
FarmLevel:OnChanged(function(Value)
  _G.Level = Value
end)
spawn(function()
    local plr = game.Players.LocalPlayer
    local replicated = game:GetService("ReplicatedStorage")
    local ws = game:GetService("Workspace")
    local CommF_ = replicated.Remotes.CommF_

    local function getQuestTitle(questGui)
        local container = questGui:FindFirstChild("Container")
        if container then
            local titleObj = container:FindFirstChild("QuestTitle")
            if titleObj then return titleObj.Title.Text end
        end
        return ""
    end

    local function handleNoMob(Root, mobPos)
        if (Root.Position - mobPos.Position).Magnitude > 350 then
            _tp(mobPos)
        else
            Root.CFrame = mobPos * CFrame.new(0, 50, 0)
            Root.Velocity = Vector3.zero
        end
    end

    local function attackMob(Root, mob)
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if not mobRoot then return false end

        repeat
            task.wait()
            if not _G.Level or not mob.Parent or mob.Humanoid.Health <= 0 then break end
            if (Root.Position - mobRoot.Position).Magnitude <= 350 then
                Root.CFrame = mobRoot.CFrame * CFrame.new(0, 15, 0)
                Root.Velocity = Vector3.zero
            else
                _tp(mobRoot.CFrame)
            end
            Attack.Kill(mob, _G.Level)
        until mob.Humanoid.Health <= 0 or not mob.Parent

        return true
    end

    while task.wait(Sec or 0.2) do
        if not _G.Level then continue end

        local ok, err = pcall(function()
            local Character = plr.Character or plr.CharacterAdded:Wait()
            local Root = Character:WaitForChild("HumanoidRootPart")

            local q = QuestNeta()
            if not q or not q[1] then return end

            local questMobName, questID, questIndex, mobPos, questDisplay, questPos =
                q[1], q[2], q[3], q[4], q[5], q[6]

            if not questPos or not mobPos then return end

            local questGui = plr.PlayerGui.Main.Quest
            local questTitle = questGui.Visible and getQuestTitle(questGui) or ""

            -- Accept/start quest if not active
            if not questGui.Visible or not string.find(questTitle, questDisplay or "") then
                CommF_:InvokeServer("AbandonQuest")
                task.wait(0.25)
                if (Root.Position - questPos.Position).Magnitude > 50 then
                    _tp(questPos)
                    return
                end
                CommF_:InvokeServer("StartQuest", questIndex, questID)
                task.wait(0.5)
                return
            end

            -- Find and attack quest mob
            local foundMob = false
            for _, mob in ipairs(ws.Enemies:GetChildren()) do
                if mob.Name == questMobName and Attack.Alive(mob) then
                    foundMob = attackMob(Root, mob)
                    break
                end
            end

            if not foundMob then
                handleNoMob(Root, mobPos)
            end
        end)

        if not ok then
            warn("AUTO FARM ERROR:", err)
        end
    end
end)
local Q = Tabs.Main:AddToggle("Q", {Title = "Auto Farm Cakes", Description = "", Default = false})
Q:OnChanged(function(Value)
_G.Auto_Cake_Prince = Value
end)
spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    
    local plr = Players.LocalPlayer
    local CommF = ReplicatedStorage.Remotes.CommF_
    
    -- Hàm bật/tắt chế độ chống rớt (Anti-Gravity)
    local function SetAntiGravity(enable)
        local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local bv = root:FindFirstChild("AntiGravity")
        
        if enable then
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "AntiGravity"
                bv.Parent = root
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        else
            if bv then
                bv:Destroy()
            end
        end
    end

    local lastAutoFarm = false  -- ← BIẾN KIỂM TRA "VỪA BẬT"

    while task.wait(0.2) do
        if _G.Auto_Cake_Prince then
            -- === BYPASS TP ĐẾN ĐẢO CAKE ISLAND KHI VỪA BẬT FARM ===
            if not lastAutoFarm then
                lastAutoFarm = true
                if _G.Bypass and typeof(PMT_EnsureIsland) == "function" then
                    print("[PMT] Bypass TP → Cake Island (Auto_Cake_Prince vừa bật)")
                    pcall(function()
                        PMT_EnsureIsland("Cake Island", 3500, 2)  -- range 3500, thử tối đa 2 lần
                    end)
                end
            end

            pcall(function()
                local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                local questUI = plr.PlayerGui.Main.Quest
                local enemies = Workspace.Enemies
                
                -- Vị trí đảo Cake
                local cakeIslandPos = CFrame.new(-2077, 252, -12373)
                
                if not root then return end

                local cakeLoaf = Workspace.Map:FindFirstChild("CakeLoaf")
                local bigMirror = cakeLoaf and cakeLoaf:FindFirstChild("BigMirror")

                -- Logic di chuyển đến đảo nếu quá xa (>3000 stud)
                if not bigMirror or not bigMirror:FindFirstChild("Other") or (cakeIslandPos.Position - root.Position).Magnitude > 3000 then
                    SetAntiGravity(false)
                    _tp(cakeIslandPos)
                    return
                end

                local transparency = 1
                if bigMirror and bigMirror:FindFirstChild("Other") then
                    transparency = bigMirror.Other.Transparency
                end

                -- /// PHẦN 1: ĐÁNH CAKE PRINCE (BOSS) ///
                if transparency == 0 or enemies:FindFirstChild("Cake Prince") then
                    local v = GetConnectionEnemies("Cake Prince")
                    if v then
                        repeat 
                            task.wait()
                            if v and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                local enemyRoot = v.HumanoidRootPart
                                local dist = (root.Position - enemyRoot.Position).Magnitude
                                
                                if dist < 350 then
                                    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 25, 0) 
                                    SetAntiGravity(true)
                                    Attack.Kill2(v, _G.Auto_Cake_Prince)
                                else
                                    SetAntiGravity(false)
                                    Attack.Kill2(v, _G.Auto_Cake_Prince)
                                end
                            end
                        until not _G.Auto_Cake_Prince or not v.Parent or v.Humanoid.Health <= 0
                        SetAntiGravity(false)
                    else
                        if transparency == 0 then
                             local waitPos = CFrame.new(-2151.82, 149.32, -12404.91)
                             if (root.Position - waitPos.Position).Magnitude > 50 then
                                 _tp(waitPos)
                             end
                        end
                    end

                else
                    local CakePrinceMobs = {"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"}
                    
                    local targetMob = nil
                    for _, mobName in ipairs(CakePrinceMobs) do
                        targetMob = GetConnectionEnemies({mobName})
                        if targetMob then break end
                    end
                    
                    if not targetMob then
                         local shortestDistance = 500
                         for _, enemy in pairs(enemies:GetChildren()) do
                            if table.find(CakePrinceMobs, enemy.Name) and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                                local dist = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance = dist
                                    targetMob = enemy
                                end
                            end
                         end
                    end
                    
                    if targetMob then
                        local v = targetMob
                        
                        if _G.AcceptQuestC and not questUI.Visible then
                             local questPos = CFrame.new(-1927.92, 37.8, -12842.54)
                             SetAntiGravity(false)
                             
                             if (questPos.Position - root.Position).Magnitude > 350 then
                                  _tp(questPos)
                             else
                                  root.CFrame = questPos
                                  root.Velocity = Vector3.new(0,0,0)
                                  task.wait(0.2)
                                  
                                  local questData = {
                                      {"StartQuest", "CakeQuest2", 2},
                                      {"StartQuest", "CakeQuest2", 1},
                                      {"StartQuest", "CakeQuest1", 1},
                                      {"StartQuest", "CakeQuest1", 2}
                                  }
                                  local randomQuest = questData[math.random(1, #questData)]
                                  CommF:InvokeServer(unpack(randomQuest))
                                  task.wait(0.5)
                             end
                        else
                             repeat 
                                task.wait()
                                if v and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    local enemyRoot = v.HumanoidRootPart
                                    local dist = (root.Position - enemyRoot.Position).Magnitude
                                    
                                    if dist < 350 then
                                        root.CFrame = enemyRoot.CFrame * CFrame.new(0, 25, 0)
                                        SetAntiGravity(true)
                                        Attack.Kill(v, _G.Auto_Cake_Prince)
                                    else
                                        SetAntiGravity(false)
                                        Attack.Kill(v, _G.Auto_Cake_Prince)
                                    end
                                else
                                    break
                                end
                             until not _G.Auto_Cake_Prince or not v.Parent or v.Humanoid.Health <= 0 or transparency == 0
                             
                             SetAntiGravity(false)
                        end
                    else
                        SetAntiGravity(false)
                        if _G.Auto_Cake_Prince and transparency ~= 0 then
                             if (cakeIslandPos.Position - root.Position).Magnitude > 50 then
                                 _tp(cakeIslandPos)
                             end
                        end
                    end
                end
            end)
        else
            -- Tắt script thì reset flag + xóa AntiGravity
            lastAutoFarm = false
            SetAntiGravity(false)
        end
    end
end)
local Q = Tabs.Main:AddToggle("Q", {Title = "Auto Farm Bones", Description = "", Default = false})
Q:OnChanged(function(Value)
  _G.AutoFarm_Bone = Value
end)
if not _G.MobIndex then _G.MobIndex = 1 end

spawn(function()
    -- Hàm xóa lực hút trái đất để nhân vật di chuyển bình thường
    local function RemoveAntiGravity(root)
        if root and root:FindFirstChild("AntiGravity") then
            root.AntiGravity:Destroy()
        end
    end

    local lastAutoFarm = false  -- ← BIẾN KIỂM TRA "VỪA BẬT"

    while task.wait() do 
        if _G.AutoFarm_Bone then
            -- === BYPASS TP ĐẾN ĐẢO HAUNTED CASTLE KHI VỪA BẬT FARM ===
            if not lastAutoFarm then
                lastAutoFarm = true
                if _G.Bypass and typeof(PMT_EnsureIsland) == "function" then
                    print("[PMT] Bypass TP → Haunted Castle (AutoFarm_Bone vừa bật)")
                    pcall(function()
                        PMT_EnsureIsland("Haunted Castle", 3500, 2)  -- range 3500, thử tối đa 2 lần
                    end)
                end
            end

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
                     local questPos = CFrame.new(-9516.99316,172.017181,6078.46533)
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
                                    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 25, 0)
                                    
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
                                    Attack.Kill(bone, _G.AutoFarm_Bone) 
                                end
                            end
                        else
                            break 
                        end
                    until not _G.AutoFarm_Bone or bone.Humanoid.Health <= 0 or not bone.Parent or (_G.AcceptQuestC and not questUI.Visible)
                    
                    RemoveAntiGravity(root)
                else
                    RemoveAntiGravity(root)

                    _G.MobIndex = _G.MobIndex + 1
                    if _G.MobIndex > #BonesTable then
                        _G.MobIndex = 1
                    end
                    print("Đang chuyển sang farm: " .. BonesTable[_G.MobIndex])
                    task.wait(0.5)
                end
            end)
        else
            -- Tắt farm → reset flag để lần sau bật lại sẽ TP lại
            lastAutoFarm = false
            local player = game.Players.LocalPlayer
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then RemoveAntiGravity(root) end
        end
    end
end)
local Q = Tabs.Main:AddToggle("Q", {Title = "Accept Quests Bone/Cakes", Description = "", Default = false})
Q:OnChanged(function(Value)
  _G.AcceptQuestC = Value
end)
Tabs.Main:AddSection("Farm Misc")

local ClosetMons = Tabs.Main:AddToggle("ClosetMons", {Title = "Auto Farm Nearest", Description = "", Default = false})
ClosetMons:OnChanged(function(Value)
  _G.AutoFarmNear = Value
end)
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoFarmNear then
                local player = game.Players.LocalPlayer
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                
                if root then
                    for i, v in pairs(workspace.Enemies:GetChildren()) do
                        -- Kiểm tra quái còn sống và có HumanoidRootPart
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            
                            repeat 
                                task.wait()
                                -- Kiểm tra lại điều kiện ngắt vòng lặp
                                if not _G.AutoFarmNear or not v.Parent or v.Humanoid.Health <= 0 then break end
                                
                                local enemyRoot = v:FindFirstChild("HumanoidRootPart")
                                
                                if enemyRoot and root then
                                    local dist = (root.Position - enemyRoot.Position).Magnitude
                                    
                                    -- /// LOGIC TP GIỐNG FARM BONE ///
                                    if dist < 350 then
                                        root.CFrame = enemyRoot.CFrame * CFrame.new(0, 15, 0)
                                        root.Velocity = Vector3.new(0, 0, 0) -- Giữ nhân vật đứng im không bị trôi
                                        Attack.Kill(v, _G.AutoFarmNear)
                                    else
                                        Attack.Kill(v, _G.AutoFarmNear)
                                    end
                                end
                                
                            until not _G.AutoFarmNear or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                end
            end
        end)
    end
end) 
Tabs.Settings:AddSection("Settings / Config")
local _Weapon = {"Melee","Sword","Blox Fruit","Gun"}
local Weapon_Config = Tabs.Settings:AddDropdown("Weapon_Config",{Title = "Select Weapon",Values = _Weapon,Multi = false,Default = 1})
Weapon_Config:OnChanged(function(Value)
  _G.ChooseWP = Value
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
local AutoAttack = Tabs.Settings:AddToggle("AutoAttack", {
    Title = "Dual Devil Fruit M1",
    Description = "Super Fast Farm",
    Default = false,
})
AutoAttack:OnChanged(function(Value)
    Config.AutoAttack = Value
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local CommF = ReplicatedStorage.Remotes.CommF_

-- Equip Buddha
local function EquipBuddha()
    local char = Player.Character
    if not char or not char:FindFirstChild("Humanoid") then return false end

    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("buddha") then
            char.Humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

local BuddhaZToggle = Tabs.Settings:AddToggle("BuddhaZ", {
    Title = "Auto Z Buddha",
    Description = "Fast Farming",
    Default = false
})

BuddhaZToggle:OnChanged(function(Value)
    if not Value then return end

    task.spawn(function()
        pcall(function()

            EquipBuddha()
            task.wait(0.25)

            CommF:InvokeServer("ActivateAbility", "Buddha")
            task.wait(0.25)

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
        end)

        task.wait(0.4)
        Fluent.Options.BuddhaZ:SetValue(false)
    end)
end)
local Bringmob = Tabs.Settings:AddToggle("Bringmob", {Title = "Bring Mobs", Description = "", Default = true})
Bringmob:OnChanged(function(Value)
  _B = Value
end)
local BringRadius = Tabs.Settings:AddSlider("BringRadius", {
    Title = "Bring Radius",
    Description = "",
    Default = 300,
    Min = 100,
    Max = 300,
    Rounding = true
})
BringRadius:OnChanged(function(Value)
    _R = Value
end)

local BusuAura = Tabs.Settings:AddToggle("BusuAura", {Title = "Auto Haki", Description = "", Default = true})
BusuAura:OnChanged(function(Value)
  Boud = Value
end)
spawn(function()
  while wait(Sec) do
    pcall(function()
      if Boud then
      local _HasBuso = {"HasBuso","Buso"}
  	  if not plr.Character:FindFirstChild(_HasBuso[1]) then replicated.Remotes.CommF_:InvokeServer(_HasBuso[2]) end
      end
    end)
  end
end)

--thông báo 
Tabs.Satus:AddSection("Satus Server")
local MobKilled = Tabs.Satus:AddParagraph({
    Title = "Cake Princes :",
    Content = ""
})
spawn(function()
  while wait(.2) do
    pcall(function()
  	  local Killed = string.match(replicated.Remotes.CommF_:InvokeServer("CakePrinceSpawner"),"%d+")
      if Killed then
        MobKilled:SetDesc(" Killed : " ..(500 - Killed))
      end
    end)
  end
end)
--travel
Tabs.Travel:AddSection("Bypass Tp Island")
Island_Config = Tabs.Travel:AddDropdown("Island_Config",{
    Title = "Select Island",
    Values = BuildIslandOptions(),
    Multi = false,
    Default = 1
})
Island_Config:OnChanged(function(Value)
    _G.Islandtp = Value
end)

local FastHop = Tabs.Travel:AddToggle("FastHop",{
    Title = "Auto Travel",
    Default = false
})
FastHop:OnChanged(function(Value)
    _G.Tpfast = Value
    if not Value then
        PMT_StopFastHop()
    end
end)
Tabs.Travel:AddSection("Travel Tween - Sea")
Tabs.Travel:AddButton({Title = "Teleport Sea 1", Description = "",
Callback = function()
  replicated.Remotes.CommF_:InvokeServer("TravelMain")
end})
Tabs.Travel:AddButton({Title = "Teleport Sea 2", Description = "",
Callback = function()
  replicated.Remotes.CommF_:InvokeServer("TravelDressrosa")
end})
Tabs.Travel:AddButton({Title = "Teleport Sea 3", Description = "",
Callback = function()
  replicated.Remotes.CommF_:InvokeServer("TravelZou")
end})
Tabs.Travel:AddSection("Travel - Island")
Location = {}
for i,v in pairs(workspace["_WorldOrigin"].Locations:GetChildren()) do  
  table.insert(Location ,v.Name)
end
Travelllll = Tabs.Travel:AddDropdown("Travelllll",{Title = "Select Travel",Values = Location,Multi = false,Default = 1})
Travelllll:OnChanged(function(Value)
  _G.Island = Value
end)
GoIsland = Tabs.Travel:AddToggle("GoIsland", {Title = "Auto Travel", Description = "Tween", Default = false})
GoIsland:OnChanged(function(Value)
  _G.Teleport = Value
  if Value then
    for i,v in pairs(workspace["_WorldOrigin"].Locations:GetChildren()) do
      if v.Name == _G.Island then
        repeat wait()
	     _tp(v.CFrame * CFrame.new(0, 30, 0)) 
        until not _G.Teleport or Root.CFrame == v.CFrame
      end
    end
  end
end)
Tabs.Travel:AddSection("Travel - Portal")
if World1 then
  Location_Portal = {
    "Sky",
    "UnderWater"
  }
elseif World2 then
  Location_Portal = {
    "SwanRoom",
    "Cursed Ship"
  }
elseif World3 then
  Location_Portal = {
    "Castle On The Sea",
    "Mansion Cafe",
    "Hydra Teleport",
    "Canvendish Room",
    "Temple of Time"
  }
end

PortalTP = Tabs.Travel:AddDropdown("PortalTP",{Title = "Select Portal",Values = Location_Portal,Multi = false,Default = 1})
PortalTP:OnChanged(function(Value)
  _G.Island_PT = Value
end)
Tabs.Travel:AddButton({Title = "Auto Tween", Description = "",Callback = function()
  if _G.Island_PT == "Sky" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894, 5547, -380))
  elseif _G.Island_PT == "UnderWater" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163, 11, 1819))
  elseif _G.Island_PT == "SwanRoom" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(2285, 15, 905))
  elseif _G.Island_PT == "Cursed Ship" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923, 126, 32852))
  elseif _G.Island_PT == "Castle On The Sea" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5097.93164, 316.447021, -3142.66602, -0.405007899, -4.31682743e-08, 0.914313197, -1.90943332e-08, 1, 3.8755779e-08, -0.914313197, -1.76180437e-09, -0.405007899))
  elseif _G.Island_PT == "Mansion Cafe" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
  elseif _G.Island_PT == "Hydra Teleport" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(5643.45263671875, 1013.0858154296875, -340.51025390625))
  elseif _G.Island_PT == "Canvendish Room" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(5314.54638671875, 22.562219619750977, -127.06755065917969))
  elseif _G.Island_PT == "Temple of Time" then
    replicated.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(28310.0234, 14895.1123, 109.456741, -0.469690144, -2.85620132e-08, -0.882831335, -3.23509219e-08, 1, -1.51411736e-08, 0.882831335, 2.14487486e-08, -0.469690144))
  end
end})
--fruit
RandomFF = Tabs.Fruit:AddToggle("RandomFF", {Title = "Random Fruit", Description = "", Default = false})
RandomFF:OnChanged(function(Value)
  _G.Random_Auto = Value
end)
spawn(function()
  while wait(Sec) do
   	pcall(function()
      if _G.Random_Auto then replicated.Remotes.CommF_:InvokeServer("Cousin","Buy") end 
    end)
  end
end)
DropF = Tabs.Fruit:AddToggle("DropF", {Title = "Drop Fruit", Description = "", Default = false})
DropF:OnChanged(function(Value)
  _G.DropFruit = Value
end)
spawn(function()
  while wait(Sec) do
    if _G.DropFruit then
      pcall(function() DropFruits() end)
    end
  end
end)
StoredF = Tabs.Fruit:AddToggle("StoredF", {Title = "Store Fruit", Description = "", Default = false})
StoredF:OnChanged(function(Value)
  _G.StoreF = Value
end)
spawn(function()
  while wait(Sec) do
    if _G.StoreF then
      pcall(function() UpdStFruit() end)
    end
  end
end)
TwF = Tabs.Fruit:AddToggle("TwF", {Title = "Tween Fruit", Description = "", Default = false})
TwF:OnChanged(function(Value)
  _G.TwFruits = Value
end)
spawn(function()
  while wait(Sec) do
    if _G.TwFruits then
      pcall(function()
        for _,x1 in pairs(workspace:GetChildren()) do
	    if string.find(x1.Name, "Fruit") then _tp(x1.Handle.CFrame) end
	    end
      end)
    end
  end
end)
BringF = Tabs.Fruit:AddToggle("BringF", {Title = " Bring Fruit", Description = "", Default = false})
BringF:OnChanged(function(Value)
  _G.InstanceF = Value
end)
spawn(function()
  while wait(Sec) do
    if _G.InstanceF then
      pcall(function() collectFruits(_G.InstanceF) end)
    end
  end
end)
--misc
Tabs.Misc:AddSection("Server Hop")
Tabs.Misc:AddButton({Title = "Rejoin Server", Description = "",Callback = function()
  game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end})
Tabs.Misc:AddButton({Title = "Hop Server", Description = "",Callback = function()
  Hop()
end})
Tabs.Misc:AddButton({Title = "Hop to Lowest Players", Description = "",Callback = function()
  local Http = game:GetService("HttpService")
  local TPS = game:GetService("TeleportService")
  local Api = "https://games.roblox.com/v1/games/"
  local _place = game.PlaceId
  local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
   function ListServers(cursor)
     local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
     return Http:JSONDecode(Raw)
   end
   local Server, Next; repeat
   local Servers = ListServers(Next)
   Server = Servers.data[1]
   Next = Servers.nextPageCursor
  until Server
  TPS:TeleportToPlaceInstance(_place,Server.id,plr)
end})

Tabs.Misc:AddButton({Title = "Hop to Low Pings Server", Description = "",Callback = function()
local HTTPService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StatsService = game:GetService("Stats")
local function fetchServersData(placeId, limit)
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=%d", placeId, limit)
    local success, response = pcall(function()
        return HTTPService:JSONDecode(game:HttpGet(url))
    end)
  if success and response and response.data then
	return response.data
  end
    return nil
  end
  local placeId = game.PlaceId
  local serverLimit = 100
  local servers = fetchServersData(placeId, serverLimit)
  if not servers then return end
  local lowestPingServer = servers[1]
  for _, server in pairs(servers) do
    if server["ping"] < lowestPingServer["ping"] and server.maxPlayers > server.playing then
      lowestPingServer = server
    end
  end
  local commonLoadTime = 0.5
  task.wait(commonLoadTime)
  local pingThreshold = 100
  local serverStats = StatsService.Network.ServerStatsItem
  local dataPing = serverStats["Data Ping"]:GetValueString()
  local pingValue = tonumber(dataPing:match("(%d+)"))
  if pingValue >= pingThreshold then
    TeleportService:TeleportToPlaceInstance(placeId, lowestPingServer.id)
  else
    --pings
  end
end})

local JobID = Tabs.Misc:AddInput("JobID", {Title = "JobID",Default = "",Placeholder = "",
Numeric = false, -- Only allows numbers
Finished = false, -- Only calls callback when you press enter
Callback = function(Value)
  _G.JobId = Value
end})
spawn(function()
  while wait(Sec) do
    if _G.JobId then
      pcall(function()
        local Connection
        Connection = plr.OnTeleport:Connect(function(br)
          if br == Enum.TeleportState.Failed then
          Connection:Disconnect()
          if workspace:FindFirstChild("Message") then workspace.Message:Destroy() end
          end
        end)
      end)
    end
  end
end)

Tabs.Misc:AddButton({Title = "Teleport [Job ID]", Description = "",Callback = function()
  replicated['__ServerBrowser']:InvokeServer("teleport",_G.JobId)
end})
Tabs.Misc:AddButton({Title = "Copy JobID", Description = "",Callback = function()
  setclipboard(tostring(game.JobId))
end})

Tabs.Misc:AddSection("Set Team")

Tabs.Misc:AddButton({Title = "Set Pirate Team", Description = "",Callback = function()
  Pirates()
end})  
Tabs.Misc:AddButton({Title = "Set Marine Team", Description = "",Callback = function()
  Marines()
end})
Tabs.Misc:AddSection("Graphics")
Tabs.Misc:AddButton({Title = "Remove Sky Fog", Description = "",Callback = function()
  if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
  if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
  if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end
end})
briggt1 = Tabs.Misc:AddToggle("briggt1", {Title = "Turn on Full Bright", Description = "", Default = true})
briggt1:OnChanged(function(Value)
  bright = Value
  if Value == true then
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
  else
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
    Lighting.ColorShift_Top = Color3.new(0, 0, 0)
  end  
end)
walkWater = Tabs.Misc:AddToggle("walkWater", {Title = "Turn on Walk on Water", Description = "walk on water", Default = true})
walkWater:OnChanged(function(Value)
  _G.WalkWater_Part = Value
  if _G.WalkWater_Part then
    game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000)
  else
    game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000, 80, 1000)
  end
end)
Tabs.Misc:AddButton({Title = "Turn on Fast Mode", Description = "",Callback = function()
  for _,zx in next, workspace:GetDescendants() do
  if table.find(Past, zx.ClassName) then  zx.Material = "Plastic" end
  end
end})
Tabs.Misc:AddButton({Title = "Turn on Low CPU", Description = "",Callback = function()
  LowCpu()
end})

