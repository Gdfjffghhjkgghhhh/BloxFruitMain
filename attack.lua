loadstring(game:HttpGet("https://raw.githubusercontent.com/TurboLite/Script/refs/heads/main/attack-module.lua"))()

local function GetBladeHits()
local t={}
local function d(v)return(v.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude end
for _,p in pairs({game.Workspace.Enemies,game.Workspace.Characters})do
for _,v in pairs(p:GetChildren())do
if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and v:FindFirstChild("Humanoid") then
if d(v.HumanoidRootPart)<60 then table.insert(t,v)end
end
end
end
return t
end
local function AttackAll()
local plr=game.Players.LocalPlayer
local ch=plr.Character
if not ch then return end
local ew=ch:FindFirstChild("EquippedWeapon")
if not ew then return end
local e=GetBladeHits()
if #e>0 then
local n=game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
n:WaitForChild("RE/RegisterAttack"):FireServer(-math.huge)
local a={nil,{}}
for i,v in pairs(e)do
if not a[1] then a[1]=v.Head end
a[2][i]={v,v.HumanoidRootPart}
end
n:WaitForChild("RE/RegisterHit"):FireServer(unpack(a))
end
end
spawn(function()while task.wait()do AttackAll()end end)

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local Player=Players.LocalPlayer
local Modules=ReplicatedStorage:WaitForChild("Modules")
local Net=Modules:WaitForChild("Net")
local RegisterAttack=Net:WaitForChild("RE/RegisterAttack")
local RegisterHit=Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent=Net:WaitForChild("RE/ShootGunEvent")

getgenv().PMT_GunFast=(getgenv().PMT_GunFast~=false)
getgenv().PMT_GunFast_Delay=getgenv().PMT_GunFast_Delay or 0.02
getgenv().PMT_GunFast_PrimeEvery=getgenv().PMT_GunFast_PrimeEvery or 0.35

local Config={AttackDistance=65,AttackMobs=true,AttackPlayers=true,AttackCooldown=0.01,ComboResetTime=0.3,MaxCombo=4,HitboxLimbs={"RightLowerArm","RightUpperArm","LeftLowerArm","LeftUpperArm","RightHand","LeftHand"},AutoClickEnabled=true}

local FastAttack={}
FastAttack.__index=FastAttack

function FastAttack.new()
local s=setmetatable({Debounce=0,ComboDebounce=0,ShootDebounce=0,M1Combo=0,EnemyRootPart=nil,Connections={},Overheat={Dragonstorm={MaxOverheat=3,Cooldown=0,TotalOverheat=0,Distance=350,Shooting=false}},ShootsPerTarget={["Dual Flintlock"]=2},SpecialShoots={["Skull Guitar"]="TAP",["Bazooka"]="Position",["Cannon"]="Position",["Dragonstorm"]="Overheat"},_GunLastPrime=0,_GunLastShot=0,_LastGunTargetModel=nil,CombatFlags=nil,ShootFunction=nil,HitFunction=nil},FastAttack)
pcall(function()
s.CombatFlags=require(Modules.Flags).COMBAT_REMOTE_THREAD
s.ShootFunction=getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack,9)
local ls=Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
if ls and getsenv then s.HitFunction=getsenv(ls)._G.SendHitsToServer end
end)
return s
end

function FastAttack:IsEntityAlive(e)
local h=e and e:FindFirstChild("Humanoid")
return h and h.Health>0
end

function FastAttack:CheckStun(c,h,tt)
local st=c:FindFirstChild("Stun")
local bs=c:FindFirstChild("Busy")
if h.Sit and (tt=="Sword" or tt=="Melee" or tt=="Blox Fruit") then return false end
if (st and st.Value>0) or (bs and bs.Value) then return false end
return true
end

function FastAttack:GetBladeHits(c,dist)
local pos=c:GetPivot().Position
local bh={}
dist=dist or Config.AttackDistance
local function proc(f)
for _,e in ipairs(f:GetChildren())do
if e~=c and self:IsEntityAlive(e) then
local bp=e:FindFirstChild(Config.HitboxLimbs[math.random(#Config.HitboxLimbs)]) or e:FindFirstChild("HumanoidRootPart")
if bp and (pos-bp.Position).Magnitude<=dist then
if not self.EnemyRootPart then self.EnemyRootPart=bp else table.insert(bh,{e,bp})end
end
end
end
end
if Config.AttackMobs then proc(Workspace.Enemies)end
if Config.AttackPlayers then proc(Workspace.Characters)end
return bh
end

function FastAttack:GetClosestEnemy(c,dist)
local hits=self:GetBladeHits(c,dist)
local cl,md=nil,math.huge
self._LastGunTargetModel=nil
for _,h in ipairs(hits)do
local m=(c:GetPivot().Position-h[2].Position).Magnitude
if m<md then md=m;cl=h[2];self._LastGunTargetModel=h[1] end
end
return cl
end

function FastAttack:GetCombo()
local cb=(tick()-self.ComboDebounce)<=Config.ComboResetTime and self.M1Combo or 0
cb=cb>=Config.MaxCombo and 1 or cb+1
self.ComboDebounce=tick()
self.M1Combo=cb
return cb
end

local function _nv3(p)
if vector and vector.create then return vector.create(p.X,p.Y,p.Z) end
return Vector3.new(p.X,p.Y,p.Z)
end

local function _handle(m)
if not m or not m.Parent then return nil end
for _,d in ipairs(m:GetDescendants())do
if d:IsA("Accessory") then
local h=d:FindFirstChild("Handle")
if h and h:IsA("BasePart") then return h end
end
end
local hrp=m:FindFirstChild("HumanoidRootPart")
if hrp and hrp:IsA("BasePart") then return hrp end
return nil
end

function FastAttack:_PrimeGun(tl)
if not tl or not tl.Parent or tl.Parent~=Player.Character then return end
local now=os.clock()
local ev=tonumber(getgenv().PMT_GunFast_PrimeEvery) or 0.35
if now-(self._GunLastPrime or 0)<ev then return end
self._GunLastPrime=now
pcall(function()tl:Activate()end)
pcall(function()if firesignal and tl.Activated then firesignal(tl.Activated)end end)
end

function FastAttack:ShootInTarget(tp)
if not getgenv().PMT_GunFast then return end
local c=Player.Character
if not self:IsEntityAlive(c) then return end
local tl=c:FindFirstChildOfClass("Tool")
if not tl or tl.ToolTip~="Gun" then return end
self:_PrimeGun(tl)
local now=os.clock()
local del=tonumber(getgenv().PMT_GunFast_Delay) or 0.02
if now-(self._GunLastShot or 0)<del then return end
self._GunLastShot=now
local m=self._LastGunTargetModel
local h=_handle(m)
if not h then return end
pcall(function()ShootGunEvent:FireServer(_nv3(tp),{h})end)
end

function FastAttack:UseNormalClick(c,h,cd)
self.EnemyRootPart=nil
local bh=self:GetBladeHits(c)
if self.EnemyRootPart then
RegisterAttack:FireServer(cd)
if self.CombatFlags and self.HitFunction then
self.HitFunction(self.EnemyRootPart,bh)
else
RegisterHit:FireServer(self.EnemyRootPart,bh)
end
end
end

function FastAttack:UseFruitM1(c,eq,cb)
local t=self:GetBladeHits(c)
if not t[1] then return end
local dir=(t[1][2].Position-c:GetPivot().Position).Unit
eq.LeftClickRemote:FireServer(dir,cb)
end

function FastAttack:Attack()
if not Config.AutoClickEnabled or (tick()-self.Debounce)<Config.AttackCooldown then return end
local c=Player.Character
if not c or not self:IsEntityAlive(c) then return end
local h=c.Humanoid
local eq=c:FindFirstChildOfClass("Tool")
if not eq then return end
local tt=eq.ToolTip
if not table.find({"Melee","Blox Fruit","Sword","Gun"},tt) then return end
local cd=eq:FindFirstChild("Cooldown") and eq.Cooldown.Value or Config.AttackCooldown
if not self:CheckStun(c,h,tt) then return end
local cb=self:GetCombo()
cd=cd+(cb>=Config.MaxCombo and 0.05 or 0)
self.Debounce=cb>=Config.MaxCombo and tt~="Gun" and (tick()+0.05) or tick()
if tt=="Blox Fruit" and eq:FindFirstChild("LeftClickRemote") then
self:UseFruitM1(c,eq,cb)
elseif tt=="Gun" then
local t=self:GetClosestEnemy(c,120)
if t then self:ShootInTarget(t.Position)end
else
self:UseNormalClick(c,h,cd)
end
end

local AttackInstance=FastAttack.new()
table.insert(AttackInstance.Connections,RunService.Stepped:Connect(function()AttackInstance:Attack()end))

RunService.Heartbeat:Connect(function()
if not getgenv().PMT_GunFast then return end
local c=Player.Character
if not c then return end
local tl=c:FindFirstChildOfClass("Tool")
if not tl or tl.ToolTip~="Gun" then return end
AttackInstance:_PrimeGun(tl)
end)

for _,v in pairs(getgc(true))do
if typeof(v)=="function" and iscclosure(v) then
local n=debug.getinfo(v).name
if n=="Attack" or n=="attack" or n=="RegisterHit" then
hookfunction(v,function(...)
AttackInstance:Attack()
return v(...)
end)
end
end
end

local Modules=game.ReplicatedStorage.Modules
local Net=Modules.Net
local Register_Hit,Register_Attack=Net:WaitForChild("RE/RegisterHit"),Net:WaitForChild("RE/RegisterAttack")
local Funcs={}
function GetAllBladeHits()
bladehits={}
for _,v in pairs(workspace.Enemies:GetChildren())do
if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health>0 and (v.HumanoidRootPart.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude<=65 then
table.insert(bladehits,v)
end
end
return bladehits
end
function Getplayerhit()
bladehits={}
for _,v in pairs(workspace.Characters:GetChildren())do
if v.Name~=game.Players.LocalPlayer.Name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health>0 and (v.HumanoidRootPart.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude<=65 then
table.insert(bladehits,v)
end
end
return bladehits
end
function Funcs:Attack()
local bladehits={}
for _,v in pairs(GetAllBladeHits())do table.insert(bladehits,v)end
for _,v in pairs(Getplayerhit())do table.insert(bladehits,v)end
if #bladehits==0 then return end
local args={[1]=nil,[2]={},[4]="078da341"}
for r,v in pairs(bladehits)do
Register_Attack:FireServer(0)
if not args[1] then args[1]=v.Head end
args[2][r]={[1]=v,[2]=v.HumanoidRootPart}
end
Register_Hit:FireServer(unpack(args))
end
spawn(function()
while task.wait(0.05) do
pcall(function()
local ch=game.Players.LocalPlayer.Character
local t=ch and ch:FindFirstChildOfClass("Tool")
if t then Funcs:Attack() end
end)
end
end)
