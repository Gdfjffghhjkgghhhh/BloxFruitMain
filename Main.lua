-- ts file was generated at discord.gg/25ms

repeat
    wait()
until game:IsLoaded()

if getgenv().ZinnerExecuted then
    print('Script Already Executed')
else
    getgenv().ZinnerExecuted = true

    local u1 = tick()

    repeat
        wait()
    until game:GetService('Players') and game:GetService('Players').LocalPlayer
    repeat
        wait()
        pcall(function()
            local v2 = next
            local v3, v4 = getconnections(game:GetService('Players').LocalPlayer.PlayerGui['Main (minimal)'].ChooseTeam.Container[getgenv().Team or 'Pirates'].Frame.TextButton.Activated)

            while true do
                local v5

                v4, v5 = v2(v3, v4)

                if v4 == nil then
                    break
                end

                v5.Function()
            end
        end)
    until game:GetService('Players').LocalPlayer.Team ~= nil

    local v6 = next
    local v7, v8 = game.ReplicatedStorage.NPCs:GetChildren()
    local v9 = {}
    local u10 = {
        ['Fast Attack'] = true,
        ['Bring Monsters'] = true,
        ['Weapon Type'] = 'Melee',
        ['Chest Counts'] = 30,
        Points = 1,
        ['Bring Range'] = 350,
        ['Tween Speed'] = 180,
    }
    local u11 = {}
    local u12 = {}
    local u13 = nil
    local u14 = nil
    local u15 = {}

    while true do
        local v16

        v8, v16 = v6(v7, v8)

        if v8 == nil then
            break
        end

        table.insert(v9, v16)
    end

    local v17 = next
    local v18, v19 = game.Workspace.NPCs:GetChildren()

    while true do
        local v20

        v19, v20 = v17(v18, v19)

        if v19 == nil then
            break
        end

        table.insert(v9, v20)
    end

    getgenv().Save1MFruit = {}
    getgenv().Save1MFruitName = {}

    local u21 = loadstring(game:HttpGet('https://raw.githubusercontent.com/HoangNguyenk8/Scripts/refs/heads/main/BloxFruits/Modules/Cached.luau'))()

    u21.LocalPlayer.Idled:Connect(function()
        game:GetService('VirtualUser'):Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService('VirtualUser'):Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)

    if u21.World ~= 1 then
        if u21.World ~= 2 then
            if u21.World == 3 then
                Sea3 = true
            end
        else
            Sea2 = true
        end
    else
        Sea1 = true
    end

    function u11.SaveSettings(_, p22, p23)
        if p22 ~= nil then
            u10[p22] = p23
        end
        if not isfolder('Zinner Hub Next Gen') then
            makefolder('Zinner Hub Next Gen')
        end
        if not isfolder('Zinner Hub Next Gen/Blox Fruits') then
            makefolder('Zinner Hub Next Gen/Blox Fruits')
        end

        writefile('Zinner Hub Next Gen/Blox Fruits/' .. u21.LocalPlayer.Name .. '.json', game:GetService('HttpService'):JSONEncode(u10))
    end
    function u11.ReadSettings(p24)
        local v25, v26 = pcall(function()
            if not isfolder('Zinner Hub Next Gen') then
                p24:SaveSettings()
            end

            return game:GetService('HttpService'):JSONDecode(readfile('Zinner Hub Next Gen/Blox Fruits/' .. u21.LocalPlayer.Name .. '.json'))
        end)

        if v25 then
            return v26
        end

        p24:SaveSettings()

        return p24:ReadSettings()
    end

    local u27 = u11:ReadSettings()

    function u11.New(_, p28, p29)
        local v30 = Instance.new(p28)
        local v31 = next
        local v32 = nil

        while true do
            local v33

            v32, v33 = v31(p29, v32)

            if v32 == nil then
                break
            end

            v30[v32] = v33
        end

        return v30
    end
    function u11.Loop(_, p34)
        local v35 = coroutine.create(p34)

        coroutine.resume(v35)
    end

    u11:Loop(function()
        while task.wait(0.05) do
            if u27['Fast Attack'] then
                pcall(u21.FastLoader.Attack)
            end
        end
    end)

    function u11.GetDistance(_, p36, p37)
        if typeof(p36) ~= 'CFrame' or not p36 then
            p36 = CFrame.new(p36)
        end

        return (p36.Position - (p37 and (typeof(p37) == 'CFrame' and p37 and true or false or CFrame.new(p37)) or u21.LocalPlayer.Character.PrimaryPart).Position).Magnitude
    end
    function u11.GetPortals(p38, p39)
        local v40 = {
            {
                SkyArena1 = Vector3.new(-4654, 872, -1759),
                SkyArena2 = Vector3.new(-7894, 5547, -380),
                UndeyWaterCity1 = Vector3.new(61163, 11, 1819),
                UndeyWaterCity2 = Vector3.new(3864, 5, -1926),
            },
            {
                Mansion = Vector3.new(-288, 305, 613),
                SwanRoom = Vector3.new(2284, 15, 897),
                OutShip = Vector3.new(-6518, 83, -145),
                InShip = Vector3.new(923, 125, 32883),
            },
            {
                Mansion = Vector3.new(-12550, 337, -7476),
                CastleOnTheSea = Vector3.new(-5134, 314, -3106),
                HydraIsland = Vector3.new(5681, 1013, -313),
                TempleOfTime = Vector3.new(28294, 14896, 103),
            },
        }
        local v41 = Vector3.new(0, 0, 0)
        local _huge = math.huge
        local v43, v44, v45 = pairs(v40[u21.World])

        while true do
            local v46

            v45, v46 = v43(v44, v45)

            if v45 == nil then
                break
            end
            if v41 ~= v46 and p38:GetDistance(v46, p39) <= _huge then
                _huge = p38:GetDistance(v46, p39)
                v41 = v46
            end
        end

        return v41
    end
    function u11.IsInArena(p47, p48)
        local v49 = next
        local v50, v51 = workspace._WorldOrigin.Locations:GetChildren()

        while true do
            local v52

            v51, v52 = v49(v50, v51)

            if v51 == nil then
                break
            end
            if v52:IsA('Part') and (p47:GetDistance(p48.Position, v52.Position) <= (v52:GetAttribute('Bounds') and (v52:GetAttribute('Bounds').Max or 600) or 600) and u21.LocalPlayer:GetAttribute('CurrentLocation') == v52.Name) then
                return true
            end
        end

        return false
    end
    function u11.Tweento(p53, p54)
        if u21.LocalPlayer and u21.LocalPlayer.Character and (u21.LocalPlayer.Character:FindFirstChild('Humanoid') and u21.LocalPlayer.Character.Humanoid.Health > 0 and u21.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')) then
            local v55 = p53:GetDistance(p54)
            local v56 = p53:GetPortals(p54)

            p53:SetNoClip(true)

            if v55 <= 50 then
                if tween then
                    tween:Pause()
                    tween:Cancel()
                end

                u21.LocalPlayer.Character.PrimaryPart.CFrame = p54

                return
            end
            if u11:IsInArena(p54) or (not u21.UnlockPortal or u21.World ~= 3) and u21.World == 3 or p53:GetDistance(v56, p54) + 250 > v55 then
                if u27['Same Y'] then
                    local _CFrame = u21.LocalPlayer.Character.PrimaryPart.CFrame

                    u21.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(_CFrame.X, p54.Y, _CFrame.Z)
                end

                local v58 = v55 <= 60 and TweenInfo.new(v55 / u27['Tween Speed'] * 1.8, Enum.EasingStyle.Linear) or TweenInfo.new(v55 / u27['Tween Speed'], Enum.EasingStyle.Linear)

                tween = u21.TweenService:Create(u21.LocalPlayer.Character.PrimaryPart, v58, {CFrame = p54})

                tween:Play()
            else
                if tween then
                    tween:Cancel()
                end

                u21.CommF_:InvokeServer('requestEntrance', v56)
            end
        end
    end
    function u11.InstanceTween(_, p59)
        u21.LocalPlayer.Character.PrimaryPart.CFrame = p59
    end
    function u11.Find(_, p60, p61)
        return p60:FindFirstChild(p61)
    end
    function u11.SetNoClip(p62, p63)
        if p63 then
            if not p62:Find(u21.LocalPlayer.Character:WaitForChild('Head'), 'BodyVelocity') then
                p62:New('BodyVelocity', {
                    Parent = u21.LocalPlayer.Character:WaitForChild('Head'),
                    MaxForce = Vector3.new(math.huge, math.huge, math.huge),
                    Velocity = Vector3.new(0, 0, 0),
                })
            end

            local v64 = next
            local v65, v66 = u21.LocalPlayer.Character:GetDescendants()

            while true do
                local v67

                v66, v67 = v64(v65, v66)

                if v66 == nil then
                    break
                end
                if v67:IsA('BasePart') then
                    v67.CanCollide = false
                end
            end
        elseif p62:Find(u21.LocalPlayer.Character:WaitForChild('Head'), 'BodyVelocity') then
            u21.LocalPlayer.Character:WaitForChild('Head'):FindFirstChild('BodyVelocity'):Destroy()
        end
    end
    function u11.CheckTool(_, p68)
        local v69 = next
        local v70, v71 = u21.LocalPlayer.Backpack:GetChildren()

        while true do
            local v72

            v71, v72 = v69(v70, v71)

            if v71 == nil then
                break
            end
            if tostring(v72) == p68 or v72.Name == p68 then
                return v72
            end
        end

        local v73 = next
        local v74, v75 = u21.LocalPlayer.Character:GetChildren()

        while true do
            local v76

            v75, v76 = v73(v74, v75)

            if v75 == nil then
                break
            end
            if tostring(v76) == p68 or v76.Name == p68 then
                return v76
            end
        end
    end
    function u11.GetCurrentWeapon(_)
        local v77 = next
        local v78, v79 = u21.LocalPlayer.Backpack:GetChildren()

        while true do
            local v80

            v79, v80 = v77(v78, v79)

            if v79 == nil then
                break
            end
            if v80:IsA('Tool') and v80.ToolTip == u27['Weapon Type'] then
                return v80.Name
            end
        end

        local v81 = next
        local v82, v83 = u21.LocalPlayer.Character:GetChildren()

        while true do
            local v84

            v83, v84 = v81(v82, v83)

            if v83 == nil then
                break
            end
            if v84:IsA('Tool') and v84.ToolTip == u27['Weapon Type'] then
                return v84.Name
            end
        end
    end
    function u11.GetWPType(_, p85)
        local v86 = next
        local v87, v88 = u21.LocalPlayer.Backpack:GetChildren()

        while true do
            local v89

            v88, v89 = v86(v87, v88)

            if v88 == nil then
                break
            end
            if v89:IsA('Tool') and v89.ToolTip == p85 then
                return v89
            end
        end

        local v90 = next
        local v91, v92 = u21.LocalPlayer.Character:GetChildren()

        while true do
            local v93

            v92, v93 = v90(v91, v92)

            if v92 == nil then
                break
            end
            if v93:IsA('Tool') and v93.ToolTip == p85 then
                return v93
            end
        end
    end
    function u11.EquipTool(p94, p95)
        local v96 = p94:Find(u21.LocalPlayer.Backpack, p95)

        if v96 and p94:Find(u21.LocalPlayer.Character, 'HumanoidRootPart') then
            u21.LocalPlayer.Character.Humanoid:EquipTool(v96)
        end
    end
    function u11.EnableBuso(p97)
        if not p97:Find(u21.LocalPlayer.Character, 'HasBuso') then
            u21.CommF_:InvokeServer('Buso')
        end
    end
    function u11.IsAlive(p98, p99)
        local v100 = p99 and p99.Parent and (not p98:Find(p99, 'VehicleSeat') and p98:Find(p99, 'Humanoid'))

        if v100 then
            if p99.Humanoid.Health <= 0 then
                v100 = false
            else
                v100 = p98:Find(p99, 'HumanoidRootPart')
            end
        end

        return v100
    end
    function u11.MakeSureForBring(p101, p102)
        if p102 then
            p102.Humanoid.WalkSpeed = 0
            p102.Humanoid.JumpPower = 0

            local v103 = next
            local v104, v105 = p102:GetChildren()

            while true do
                local v106

                v105, v106 = v103(v104, v105)

                if v105 == nil then
                    break
                end
                if v106:IsA('Part') or v106:IsA('BasePart') then
                    v106.CanCollide = false
                end
            end

            if not p101:Find(p102.HumanoidRootPart, 'Lock') then
                p101:New('BodyVelocity', {
                    Name = 'Lock',
                    Parent = p102.HumanoidRootPart,
                    Velocity = Vector3.new(0, 0, 0),
                    MaxForce = Vector3.new(10000, 10000, 10000),
                })
            end
        end
    end
    function u11.TweenObject(_, p107, p108, p109)
        if p107 then
            game:GetService('TweenService'):Create(p107, TweenInfo.new(p108, Enum.EasingStyle.Linear), {CFrame = p109}):Play()
        end
    end
    function u11.BringMonsters(p110, p111)
        if p111 then
            pcall(sethiddenproperty, u21.LocalPlayer, 'SimulationRadius', math.huge)

            local v112 = u21.WS.Enemies:GetChildren()
            local _CFrame2 = p111.HumanoidRootPart.CFrame

            for v114 = 1, #v112 do
                local v115 = v112[v114]

                if v115 then
                    if v115.Name == p111.Name then
                        if p110:IsAlive(v115) then
                            if isnetworkowner(v115.HumanoidRootPart) then
                                if p110:GetDistance(v115.HumanoidRootPart.Position) <= u27['Bring Range'] then
                                    if not p110:Find(v115.HumanoidRootPart, 'Lock') then
                                        v115:SetPrimaryPartCFrame(_CFrame2)
                                        p110:MakeSureForBring(v115)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    function u11.CheckSea(_, p116)
        return p116 == 1 and game.PlaceId == 2753915549 and true or (p116 == 2 and game.PlaceId == 4442272183 and true or p116 == 3 and game.PlaceId == 7449423635)
    end
    function u11.UpdateQuests(p117)
        local v118 = {}
        local _Value = u21.LocalPlayer.Data.Level.Value
        local v120 = 0

        if 700 <= _Value and p117:CheckSea(1) then
            v118.Mob = 'Galley Captain'
            v118.Name = 'FountainQuest'
            v118.ID = 2
        elseif 1500 <= _Value and p117:CheckSea(2) then
            v118.Mob = 'Water Fighter'
            v118.Name = 'ForgottenQuest'
            v118.ID = 2
        else
            local v121, v122, v123 = pairs(u21.Quests)

            while true do
                local v124

                v123, v124 = v121(v122, v123)

                if v123 == nil then
                    break
                end

                local v125, v126, v127 = pairs(v124)
                local v128 = v123

                while true do
                    local v129

                    v127, v129 = v125(v126, v127)

                    if v127 == nil then
                        break
                    end

                    local v130, v131, v132 = pairs(v129.Task)
                    local v133 = v127

                    while true do
                        local v134

                        v132, v134 = v130(v131, v132)

                        if v132 == nil then
                            break
                        end
                        if v129.LevelReq <= _Value and (v120 <= v129.LevelReq and (v129.Task[v132] > 1 and not table.find(u21.BlackListQuests, v128))) then
                            v120 = v129.LevelReq
                            v118 = {
                                Mob = v132,
                                Name = v128,
                                ID = v133,
                            }
                        end
                    end
                end
            end
        end

        return v118
    end
    function u11.QuestNPC(_)
        local v135, v136, v137 = pairs(u21.GuideModule.Data.NPCList)

        while true do
            local v138

            v137, v138 = v135(v136, v137)

            if v137 == nil then
                break
            end
            if v138.NPCName == u21.GuideModule.Data.LastClosestNPC then
                return CFrame.new(v137.Position)
            end
        end
    end

    local u139 = u27

    repeat
        wait()

        local v140 = u11
    until u11.QuestNPC(v140)

    function u11.CheckQuestData(_)
        local v141 = next
        local _Data = u21.GuideModule.Data
        local v143 = nil

        while true do
            local v144

            v143, v144 = v141(_Data, v143)

            if v143 == nil then
                break
            end
            if v143 == 'QuestData' then
                return true
            end
        end

        return false
    end
    function u11.GetQuestData(p145)
        if p145:CheckQuestData() then
            local v146, _ = next(u21.GuideModule.Data.QuestData.Task, nil)

            if v146 ~= nil then
                return v146
            end
        end
    end
    function u11.GetDifferentQuest(p147)
        local v148, v149, v150 = pairs(u21.Quests)
        local v151 = {}

        while true do
            local v152

            v150, v152 = v148(v149, v150)

            if v150 == nil then
                break
            end

            local v153, v154, v155 = pairs(v152)

            while true do
                local v156

                v155, v156 = v153(v154, v155)

                if v155 == nil then
                    break
                end

                local v157, v158, v159 = pairs(v156.Task)

                while true do
                    local v160

                    v159, v160 = v157(v158, v159)

                    if v159 == nil then
                        break
                    end
                    if v159 == p147:UpdateQuests().Mob then
                        local v161, v162, v163 = pairs(v152)

                        while true do
                            local v164

                            v163, v164 = v161(v162, v163)

                            if v163 == nil then
                                break
                            end

                            local v165, v166, v167 = pairs(v164.Task)

                            while true do
                                local v168

                                v167, v168 = v165(v166, v167)

                                if v167 == nil then
                                    break
                                end
                                if v164.LevelReq <= u21.LocalPlayer.Data.Level.Value and 1 < v168 then
                                    table.insert(v151, v167)
                                end
                            end
                        end
                    end
                end
            end
        end

        return v151
    end
    function u11.UpdateDoubleQuest(p169)
        local v170 = {}

        if u139['Double Quest'] and (u21.LocalPlayer.Data.Level.Value >= 10 and (p169:CheckQuestData() and (p169:GetQuestData() and (p169:UpdateQuests().Mob == p169:GetQuestData() and #p169:GetDifferentQuest() >= 2)))) then
            local v171, v172, v173 = pairs(u21.Quests)

            while true do
                local v174

                v173, v174 = v171(v172, v173)

                if v173 == nil then
                    break
                end

                local v175, v176, v177 = pairs(v174)
                local v178 = v173

                while true do
                    local v179

                    v177, v179 = v175(v176, v177)

                    if v177 == nil then
                        break
                    end

                    local v180, v181, v182 = pairs(v179.Task)

                    while true do
                        local v183

                        v182, v183 = v180(v181, v182)

                        if v182 == nil then
                            break
                        end
                        if v182 == p169:UpdateQuests().Mob then
                            local v184, v185, v186 = pairs(v174)

                            while true do
                                local v187

                                v186, v187 = v184(v185, v186)

                                if v186 == nil then
                                    break
                                end

                                local v188, v189, v190 = pairs(v187.Task)
                                local v191 = v186

                                while true do
                                    local v192

                                    v190, v192 = v188(v189, v190)

                                    if v190 == nil then
                                        break
                                    end
                                    if v187.LevelReq <= u21.LocalPlayer.Data.Level.Value and (1 < v192 and v190 ~= p169:UpdateQuests().Mob) then
                                        v170 = {
                                            Mob = v190,
                                            Name = v178,
                                            ID = v191,
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            v170 = {
                Mob = p169:UpdateQuests().Mob,
                Name = p169:UpdateQuests().Name,
                ID = p169:UpdateQuests().ID,
            }
        end

        return v170
    end
    function u11.GetChests(p193)
        local _huge2 = math.huge
        local __ChestTagged = u21.CollectionService:GetTagged('_ChestTagged')
        local v196 = nil

        for v197 = 1, #__ChestTagged do
            local v198 = __ChestTagged[v197]

            if v198.Parent then
                if not v198:GetAttribute('IsDisabled') then
                    if p193:GetDistance(v198.Position) <= _huge2 then
                        _huge2 = p193:GetDistance(v198.Position)
                        v196 = v198
                    end
                end
            end
        end

        return v196
    end
    function u11.RedeemCodes(_)
        local v199 = loadstring(game:HttpGet('https://raw.githubusercontent.com/HoangNguyenk8/Roblox/refs/heads/main/Util/Codes.luau'))()
        local v200, v201, v202 = pairs(v199)

        while true do
            local v203

            v202, v203 = v200(v201, v202)

            if v202 == nil then
                break
            end

            u21.Remotes.Redeem:InvokeServer(v203)
        end
    end
    function u11.BuyMelee(_, p204)
        local v205 = next
        local _AllMelee = u21.AllMelee
        local v207 = nil

        while true do
            local v208

            v207, v208 = v205(_AllMelee, v207)

            if v207 == nil then
                break
            end
            if v207 == p204 then
                u21.CommF_:InvokeServer(table.unpack(v208), true)
                u21.CommF_:InvokeServer(table.unpack(v208))
            end
        end
    end
    function u11.CheckQuest(_, p209)
        local _Visible = u21.LocalPlayer.PlayerGui.Main.Quest.Visible

        if _Visible then
            _Visible = string.find(u21.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, p209 or '')
        end

        return _Visible
    end
    function u11.GetMobs(p211, p212, p213)
        local _huge3 = math.huge
        local v215, v216, v217 = pairs(u21.WS.Enemies:GetChildren())
        local v218 = nil

        while true do
            local v219

            v217, v219 = v215(v216, v217)

            if v217 == nil then
                break
            end
            if (type(p212) == 'table' and table.find(p212, v219.Name) or type(p212) == 'string' and v219.Name == p212) and (p211:IsAlive(v219) and p211:GetDistance(v219:WaitForChild('HumanoidRootPart').Position) <= _huge3) then
                _huge3 = p211:GetDistance(v219:WaitForChild('HumanoidRootPart').Position)
                v218 = v219
            end
        end

        if p213 then
            local v220, v221, v222 = pairs(u21.RS:GetChildren())

            while true do
                local v223

                v222, v223 = v220(v221, v222)

                if v222 == nil then
                    break
                end
                if (type(p212) == 'table' and table.find(p212, v223.Name) or type(p212) == 'string' and v223.Name == p212) and (p211:IsAlive(v223) and p211:GetDistance(v223:WaitForChild('HumanoidRootPart').Position) <= _huge3) then
                    _huge3 = p211:GetDistance(v223:WaitForChild('HumanoidRootPart').Position)
                    v218 = v223
                end
            end
        end

        return v218
    end
    function u11.GetCirclePoint(p224, p225, p226)
        if not Angle then
            Angle = 0
        end

        Angle = Angle + (tonumber(u139['Farm Speed']) or 14)

        local v227 = math.sin(math.rad(Angle)) * p225
        local v228 = tonumber(u139['Farm Distance']) or 15
        local v229 = math.cos(math.rad(Angle)) * p225

        if p224:GetDistance(p226.CFrame) > 100 then
            return p226.CFrame
        else
            return p226.CFrame + Vector3.new(v227, v228, v229)
        end
    end
    function u11.KillMob(p230, p231)
        pcall(function()
            if p231 then
                if game.Players.LocalPlayer.Character.Humanoid.Sit then
                    game.Players.LocalPlayer.Character.Humanoid.Sit = false
                end

                local v232 = p230:GetMobs(p231.Name, true)

                if v232 then
                    p230:EnableBuso()
                    p230:EquipTool(p230:GetCurrentWeapon())
                    p230:BringMonsters(v232)
                    p230:Tweento(u11:GetCirclePoint(8, v232.HumanoidRootPart))
                end
            end
        end)
    end
    function u11.CheckEyes(p233)
        return not p233:CheckSea(3) and 'Only Sea 3' or workspace.Map.TikiOutpost.IslandModel.IslandChunks.E:FindFirstChild('Eye4').Transparency == 0
    end
    function u11.SpyStatus(p234)
        if not p234:CheckSea(3) then
            return 'Only sea 3'
        end

        local _InfoLeviathan = u21.CommF_:InvokeServer('InfoLeviathan', '1')

        return workspace.Map:FindFirstChild('LeviathanGate') and 'Frozen Dimension Spawn' or (_InfoLeviathan == 5 and 'The Leviathan is out there! Go find it before it causes more destruction' or (_InfoLeviathan == -1 and "I don't know anything yet" or 'Buy 1500f'))
    end
    function u11.StatusTikiBoss(p236)
        return p236:CheckSea(3) and (p236:GetMobs('Tyrant of the Skies') or p236:CheckEyes() and 'Can summon' or ("Can't Summon" or 'Spawned')) or 'Only sea 3'
    end
    function u11.GetTimeElapsed(_, p237)
        local v238 = tick() - p237
        local v239 = math.floor(v238 / 3600)
        local v240 = math.floor(v238 % 3600 / 60)
        local v241 = v238 % 60

        return string.format('%d Hours %d Minutes %d Seconds', v239, v240, v241)
    end
    function u11.GetElites(p242)
        return p242:GetMobs(u21.Elites, true)
    end
    function u11.JoinJob(_, p243)
        game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, p243, u21.LocalPlayer)
    end
    function u11.HopLessPlayers(p244)
        local v245 = http_request({
            Url = 'https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100',
            Method = 'GET',
        })
        local v246 = game:GetService('HttpService'):JSONDecode(v245.Body)
        local v247, v248, v249 = pairs(v246.data)

        while true do
            local v250

            v249, v250 = v247(v248, v249)

            if v249 == nil then
                break
            end
            if v250.playing <= 4 and game.JobId ~= v250.id then
                p244:JoinJob(v250.id)
            end
        end
    end
    function u11.UpdateBossList(p251)
        local v252 = next
        local _AllBoss = u21.AllBoss
        local v254 = nil
        local v255 = {}

        while true do
            local v256

            v254, v256 = v252(_AllBoss, v254)

            if v254 == nil then
                break
            end
            if p251:GetMobs(v254, true) then
                table.insert(v255, v254)
            end
        end

        return #v255 == 0 and {
            'Deo co boss',
        } or v255
    end
    function u11.CheckRace(_)
        local _RaceEnergy = u21.LocalPlayer.Character:FindFirstChild('RaceEnergy')
        local _Wenlocktoad = u21.CommF_:InvokeServer('Wenlocktoad', '1')
        local _Alchemist = u21.CommF_:InvokeServer('Alchemist', '1')
        local _Value2 = u21.LocalPlayer.Data.Race.Value

        if _RaceEnergy then
            return _Value2 .. ' V4'
        elseif _Wenlocktoad == -2 then
            return _Value2 .. ' V3'
        elseif _Alchemist == -2 then
            return _Value2 .. ' V2'
        else
            return _Value2 .. ' V1'
        end
    end
    function u11.HopServers(_)
        local _TextBox = game:GetService('Players').LocalPlayer.PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox
        local ___ServerBrowser = u21.RS.__ServerBrowser

        _TextBox.Text = 'Singapore'

        spawn(function()
            Library:Notify({
                Title = 'Zinner Hub',
                Content = 'Hop Servers After 5 Seconds',
                Duration = 6,
            })
            wait(5)
            Library:Notify({
                Title = 'Zinner Hub',
                Content = 'Hop Servers',
                Duration = 6,
            })
        end)

        for v263 = 1, math.huge do
            local v264 = next
            local v265, v266 = ___ServerBrowser:InvokeServer(v263)

            while true do
                local v267

                v266, v267 = v264(v265, v266)

                if v266 == nil then
                    break
                end
                if v266 ~= game.JobId and v267.Count <= 11 then
                    u21.RS.__ServerBrowser:InvokeServer('teleport', v266)
                    task.wait()
                end
            end
        end
    end
    function u11.CheckMeleeMastery(p268, p269, p270)
        local _Melee = p268:GetWPType('Melee')

        return _Melee and (_Melee.Name == p269 and (_Melee:FindFirstChild('Level') and p270 <= _Melee.Level.Value)) and true or false
    end
    function u11.TakeQuestV3(_)
        if u21.CommF_:InvokeServer('Wenlocktoad', '1') == 0 then
            u21.CommF_:InvokeServer('Wenlocktoad', '2')
        end
    end
    function u11.UpV3(_)
        u21.CommF_:InvokeServer(unpack({
            'Wenlocktoad',
            '3',
        }))
    end
    function u11.CheckInventory(_, p272)
        if p272 and type(p272) == 'string' then
            local v273 = next
            local _getInventory, v275 = u21.CommF_:InvokeServer('getInventory')

            while true do
                local v276

                v275, v276 = v273(_getInventory, v275)

                if v275 == nil then
                    break
                end
                if v276.Name:lower() == p272:lower() then
                    return true
                end
            end

            return false
        end
    end
    function u11.GetBoss(_, p277)
        local v278 = next
        local _AllBoss2 = u21.AllBoss
        local v280 = nil

        while true do
            local v281

            v280, v281 = v278(_AllBoss2, v280)

            if v280 == nil then
                break
            end
            if v280 == p277 then
                return v280, v281
            end
        end
    end
    function u11.CheckQuest(_, p282)
        local _Visible2 = u21.LocalPlayer.PlayerGui.Main.Quest.Visible

        if _Visible2 then
            _Visible2 = string.find(u21.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, p282 or '')
        end

        return _Visible2
    end
    function u11.GetBartiloPlates(_, p284)
        local v285, v286, v287 = pairs(workspace.Map.Dressrosa.BartiloPlates:GetChildren())

        while true do
            local v288

            v287, v288 = v285(v286, v287)

            if v287 == nil then
                break
            end
            if string.find(v288.Name, p284) and v288.BrickColor == BrickColor.new('Sand yellow') then
                return v288
            end
        end
    end
    function u11.GetMoonTexture(_)
        if u11:CheckSea(1) or u11:CheckSea(2) then
            return not game:GetService('Lighting'):FindFirstChild('FantasySky') and 'http://www.roblox.com/asset/?id=9709150401' or game:GetService('Lighting').FantasySky.MoonTextureId
        end
        if u11:CheckSea(3) then
            return game:GetService('Lighting').Sky.MoonTextureId
        end
    end

    local v289 = next
    local _FruitPrice = u21['Fruit Price']
    local v291 = nil

    while true do
        local v292

        v291, v292 = v289(_FruitPrice, v291)

        if v291 == nil then
            break
        end
        if v292 >= 1000000 then
            getgenv().Save1MFruit[v291] = v292

            table.insert(getgenv().Save1MFruitName, v291:split('-')[1] .. ' Fruit')
        end
    end

    function u11.GetFruitInventory(_, p293)
        local _huge4 = math.huge
        local v295 = next
        local _getInventory2, v297 = u21.CommF_:InvokeServer('getInventory')
        local v298 = nil

        while true do
            local v299

            v297, v299 = v295(_getInventory2, v297)

            if v297 == nil then
                break
            end
            if v299.Type == 'Blox Fruit' then
                if p293 then
                    if v299.Value >= 1000000 and v299.Value < _huge4 then
                        _huge4 = v299.Value
                        v298 = v299.Name
                    end
                elseif not getgenv().Save1MFruit[v299.Name:split('-') .. ' Fruit'] then
                    v298 = v299.Name
                end
            end
        end

        return v298
    end
    function u11.Detect1MFruit(_)
        local v300 = next
        local v301, v302 = u21.LocalPlayer.Backpack:GetChildren()

        while true do
            local v303

            v302, v303 = v300(v301, v302)

            if v302 == nil then
                break
            end
            if v303:IsA('Tool') and (not v303:FindFirstChild('Data') and table.find(getgenv().Save1MFruitName, v303.Name)) then
                return v303.Name
            end
        end

        local v304 = next
        local v305, v306 = u21.LocalPlayer.Character:GetChildren()

        while true do
            local v307

            v306, v307 = v304(v305, v306)

            if v306 == nil then
                break
            end
            if v307:IsA('Tool') and (not v307:FindFirstChild('Data') and table.find(getgenv().Save1MFruitName, v307.Name)) then
                return v307.Name
            end
        end
    end
    function u11.GetMoonPhase(_)
        local v308 = u11:GetMoonTexture()
        local v309 = {
            'http://www.roblox.com/asset/?id=9709150401',
            'http://www.roblox.com/asset/?id=9709150086',
            'http://www.roblox.com/asset/?id=9709149680',
            'http://www.roblox.com/asset/?id=9709149431',
            'http://www.roblox.com/asset/?id=9709149052',
            'http://www.roblox.com/asset/?id=9709143733',
            'http://www.roblox.com/asset/?id=9709139597',
            'http://www.roblox.com/asset/?id=9709135895',
        }

        return v308 ~= v309[4] and (v308 ~= v309[5] and 'Bad Moon' or 'Next Night') or 'Full Moon'
    end
    function u11.OpenDungoenDoor(_)
        local _Combo = workspace.Map.CircleIsland.Lab.Combo
        local v311 = next
        local v312, v313 = _Combo:GetChildren()

        while true do
            local v314

            v313, v314 = v311(v312, v313)

            if v313 == nil then
                break
            end
            if u21.Combo[v314.Name] then
                local _Combo2 = u21.Combo
                local v316 = nil
                local v317 = nil

                while true do
                    local v318

                    v317, v318 = _Combo2(v316, v317)

                    if v317 == nil then
                        break
                    end
                    if _Combo[v317].Color ~= v318[2] then
                        fireclickdetector(_Combo[v318[1] ].ClickDetector)
                        task.wait()
                    end
                end
            end
        end
    end
    function u11.GetTime(_)
        return (game.Lighting.ClockTime >= 18 or game.Lighting.ClockTime <= 5) and 'Night' or 'Day'
    end
    function u11.SendKey(_, p319, p320)
        game:GetService('VirtualInputManager'):SendKeyEvent(true, p319, false, game)
        wait(p320 or 0.1)
        game:GetService('VirtualInputManager'):SendKeyEvent(false, p319, false, game)
    end
    function u11.RandomEquipWeapon(_)
        local v321 = next
        local v322 = {
            'Melee',
            'Sword',
            'Gun',
            'Blox Fruit',
        }
        local v323 = nil

        while true do
            local v324

            v323, v324 = v321(v322, v323)

            if v323 == nil then
                break
            end

            u11:EquipTool(u11:GetWPType(v324).Name)
            wait(0.2)
        end
    end
    function u11.GetTreeOnBirdArena(_)
        local v325, v326, v327 = pairs(workspace.Map.TikiOutpost.IslandModel.IslandChunks.D.EagleBossArena:GetChildren())

        while true do
            local v328

            v327, v328 = v325(v326, v327)

            if v327 == nil then
                break
            end
            if v328.Name == 'Tree' and v328.PrimaryPart then
                return v328
            end
        end
    end
    function u11.GetSkill(p329, p330, p331)
        local v332 = next
        local v333, v334 = u21.LocalPlayer.PlayerGui.Main.Skills:GetChildren()

        while true do
            local v335

            v334, v335 = v332(v333, v334)

            if v334 == nil then
                break
            end

            local v336 = p329:GetWPType(p330)
            local v337 = next
            local v338, v339 = v335:GetChildren()

            while true do
                local v340

                v339, v340 = v337(v338, v339)

                if v339 == nil then
                    break
                end
                if v335.Name == v336.Name and (v340.Name ~= 'Template' and (table.find(p331, v340.Name) and (v340.Title.TextColor3 == Color3.fromRGB(255, 255, 255) and (v340:FindFirstChild('Cooldown') and v340.Cooldown.AbsoluteSize.X < 5)))) then
                    return {
                        v335.Name,
                        v340.Name,
                    }
                end
            end
        end
    end
    function u11.GetPlates(_)
        local v341, v342, v343 = pairs(workspace.Map.Jungle.QuestPlates:GetChildren())

        while true do
            local v344

            v343, v344 = v341(v342, v343)

            if v343 == nil then
                break
            end
            if v344:FindFirstChild('Button') and v344.Button:FindFirstChild('TouchInterest') then
                return v344.Button.CFrame
            end
        end
    end
    function u11.GetLocalShip(_)
        local v345 = next
        local v346, v347 = game.Workspace.Boats:GetChildren()

        while true do
            local v348

            v347, v348 = v345(v346, v347)

            if v347 == nil then
                break
            end
            if v348:FindFirstChild('Owner') and tostring(v348.Owner.Value) == game.Players.LocalPlayer.Name then
                return v348
            end
        end
    end
    function u11.DisableSailBoat(p349)
        if p349:Find(u21.LocalPlayer.Character.PrimaryPart, 'SailBoat') then
            u21.LocalPlayer.Character.PrimaryPart.SailBoat:Destroy()
        end
    end
    function u11.NoClipCharacter(_)
        local v350 = next
        local v351, v352 = u21.LocalPlayer.Character:GetDescendants()

        while true do
            local v353

            v352, v353 = v350(v351, v352)

            if v352 == nil then
                break
            end
            if v353:IsA('BasePart') then
                v353.CanCollide = false
            end
        end
    end
    function u11.NoClipBoat(p354)
        if p354:GetLocalShip() then
            local v355 = next
            local v356, v357 = p354:GetLocalShip():GetDescendants()

            while true do
                local v358

                v357, v358 = v355(v356, v357)

                if v357 == nil then
                    break
                end
                if (v358:IsA('Part') or v358:IsA('BasePart')) and v358.CanCollide == true then
                    v358.CanCollide = false
                end
            end
        end
    end
    function u11.SailBoatTo(p359, p360, p361, p362, p363)
        if p360 == false then
            p359:DisableSailBoat()

            return
        elseif u21.LocalPlayer.Character.Humanoid.Sit ~= false then
            if p359:GetLocalShip() then
                local _VehicleSeat = p359:GetLocalShip().VehicleSeat

                if not p359:Find(u21.LocalPlayer.Character.PrimaryPart, 'SailBoat') then
                    local _New = p359.New
                    local v366 = 'BodyVelocity'
                    local v367 = {
                        Name = 'SailBoat',
                        Parent = u21.LocalPlayer.Character.PrimaryPart,
                        MaxForce = Vector3.new(math.huge, math.huge, math.huge),
                    }

                    if typeof(p361) ~= 'Vector3' or not p361 then
                        p361 = p361.Position
                    end

                    v367.Velocity = p361.Unit * (p362 or 180)

                    _New(p359, v366, v367)
                end

                p359:NoClipCharacter()
                p359:NoClipBoat()

                _VehicleSeat.CFrame = CFrame.new(_VehicleSeat.CFrame.X, p363 or 50, _VehicleSeat.CFrame.Z)
            end
        else
            return
        end
    end
    function u11.StoreFruits(_)
        if not getgenv().CantStore then
            local v368, v369, v370 = pairs(u21.LocalPlayer.Backpack:GetChildren())

            while true do
                local v371

                v370, v371 = v368(v369, v370)

                if v370 == nil then
                    break
                end
                if string.find(v371.Name, 'Fruit') then
                    u21.CommF_:InvokeServer('StoreFruit', v371:GetAttribute('OriginalName'), v371)
                end
            end

            local v372, v373, v374 = pairs(u21.LocalPlayer.Character:GetChildren())

            while true do
                local v375

                v374, v375 = v372(v373, v374)

                if v374 == nil then
                    break
                end
                if string.find(v375.Name, 'Fruit') then
                    u21.CommF_:InvokeServer('StoreFruit', v375:GetAttribute('OriginalName'), v375)
                end
            end
        end
    end
    function u11.GetFruitSpawned(_)
        local v376 = next
        local v377, v378 = u21.WS:GetChildren()

        while true do
            local v379

            v378, v379 = v376(v377, v378)

            if v378 == nil then
                break
            end
            if v379:IsA('Model') and (string.find(v379.Name, 'Fruit') and (v379.Parent and v379:FindFirstChild('Handle'))) then
                return v379
            end
        end
    end
    function u11.GetNearRaidEnemies(_)
        local v380 = next
        local v381, v382 = u21.WS.Enemies:GetChildren()

        while true do
            local v383

            v382, v383 = v380(v381, v382)

            if v382 == nil then
                break
            end
            if u11:IsAlive(v383) and (u11:GetDistance(v383.HumanoidRootPart.Position) <= 1500 and u21.LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer.Visible) then
                return v383
            end
        end
    end
    function u11.SeaEventFunc(p384)
        local v385 = not (u139['Auto Shark and Fish Crew Member'] and p384:GetMobs({
            'Fish Crew Member',
            'Shark',
        })) and (not (u139['Auto Terror Shark'] and p384:GetMobs('Terrorshark')) and u139['Auto Piranha'])

        if v385 then
            v385 = p384:GetMobs('Auto Piranha')
        end

        return v385
    end
    function u11.GetRaidIsland(_, p386)
        local v387 = next
        local v388, v389 = u21.WS._WorldOrigin.Locations:GetChildren()

        while true do
            local v390

            v389, v390 = v387(v388, v389)

            if v389 == nil then
                break
            end
            if v390:IsA('Part') and string.find(v390.Name, 'Island ' .. tostring(p386)) and u11:GetDistance(v390.Position) <= 2000 then
                return v390
            end
        end
    end
    function u11.GetZones(_)
        local _SelectZone = u139['Select Zone']

        if _SelectZone == 'Zone 1' then
            return Vector3.new(-21354, 37, 656)
        end
        if _SelectZone == 'Zone 2' then
            return Vector3.new(-25180, 37, 656)
        end
        if _SelectZone == 'Zone 3' then
            return Vector3.new(-29086, 37, 656)
        end
        if _SelectZone == 'Zone 4' then
            return Vector3.new(-32046, 37, 656)
        end
        if _SelectZone == 'Zone 5' then
            return Vector3.new(-36872, 37, 656)
        end
        if _SelectZone == 'Zone 6' then
            return Vector3.new(-45061, 37, 656)
        end
        if _SelectZone == 'Infinity' then
            local _ = Vector3.new
        end
    end
    function u11.GetPirateRaid(p392)
        local v393 = next
        local v394, v395 = game.ReplicatedStorage:GetChildren()

        while true do
            local v396

            v395, v396 = v393(v394, v395)

            if v395 == nil then
                break
            end
            if v396:IsA('Model') and (p392:IsAlive(v396) and p392:GetDistance(v396.HumanoidRootPart.Position, CFrame.new(-5546.51708984375, 313.8009948730469, -2966.331787109375).Position) <= 1000) then
                return v396
            end
        end

        local v397 = next
        local v398, v399 = game.Workspace.Enemies:GetChildren()

        while true do
            local v400

            v399, v400 = v397(v398, v399)

            if v399 == nil then
                break
            end
            if v400:IsA('Model') and (p392:IsAlive(v400) and p392:GetDistance(v400.HumanoidRootPart.Position, CFrame.new(-5546.51708984375, 313.8009948730469, -2966.331787109375).Position) <= 1000) then
                return v400
            end
        end
    end
    function u11.CheckNotify(_, p401)
        local v402, v403, v404 = pairs(u21.LocalPlayer.PlayerGui.Notifications:GetChildren())

        while true do
            local v405

            v404, v405 = v402(v403, v404)

            if v404 == nil then
                break
            end
            if v405:IsA('TextLabel') and (v405 and (v405.Text and string.find(string.lower(v405.Text), p401))) then
                return true
            end
        end

        return false
    end
    function u11.GetAllBossSpawned(p406)
        local v407 = next
        local _AllBoss3 = u21.AllBoss
        local v409 = nil
        local v410 = {}

        while true do
            local v411

            v409, v411 = v407(_AllBoss3, v409)

            if v409 == nil then
                break
            end
            if p406:GetMobs(v409, true) then
                table.insert(v410, v409)
            end
        end

        return table.concat(v410, ',')
    end
    function u11.CheckCakePrinceSkill(p412)
        local v413 = {
            A = workspace._WorldOrigin:FindFirstChild('Ring'),
            B = workspace._WorldOrigin:FindFirstChild('Fist'),
        }

        if v413.A or v413.B then
            if v413.A and p412:GetDistance(v413.A.Position) <= 400 then
                return true
            end
            if v413.B and p412:GetDistance(v413.B.Position) <= 400 then
                return true
            end
        end

        return false
    end
    function u11.BuildLibrary(_)
        Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/HoangNguyenk8/Scripts/refs/heads/main/UI-Library/ZinnerV1.luau'))()
        Window = Library:Window({
            Title = 'Zinner Hub',
            Description = 'Blox Fruits [Freemium]',
        })
        FPS = 0

        local _ScreenGui = Instance.new('ScreenGui')

        _ScreenGui.Parent = game.CoreGui

        local _ImageButton = Instance.new('ImageButton')

        _ImageButton.Parent = _ScreenGui
        _ImageButton.Size = UDim2.new(0, 60, 0, 60)
        _ImageButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        _ImageButton.BackgroundTransparency = 0
        _ImageButton.Image = 'rbxassetid://94302528053534'
        _ImageButton.AnchorPoint = Vector2.new(0.5, 0.5)
        _ImageButton.Position = UDim2.new(0.2, 0, 0.2, 0)
        _ImageButton.BackgroundColor3 = Color3.new(0, 0, 0)
        _ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        _ImageButton.BorderSizePixel = 0
        _ImageButton.Draggable = true

        local _UICorner = Instance.new('UICorner')

        _UICorner.Parent = _ImageButton
        _UICorner.CornerRadius = UDim.new(0, 100)

        _ImageButton.MouseButton1Click:Connect(function()
            game:GetService('VirtualInputManager'):SendKeyEvent(true, 'RightControl', false, game)
            game:GetService('VirtualInputManager'):SendKeyEvent(false, 'RightControl', false, game)
        end)
        game:GetService('RunService').RenderStepped:Connect(function(p417)
            FPS = math.floor(1 / p417)
        end)
    end
    function u11.BuildUI(p418, p419, p420)
        local v421 = p420[1]

        if v421 == 'Toggle' then
            local u422 = p420[2]

            u422.OnChanged = u422.OnChanged or function(_) end
            u422.Default = u422.Default or u139[u422.Title]
            u422.Callback = u422.Callback or function(p423)
                u422.OnChanged(p423)
                p418:SaveSettings(u422.Title, p423)
            end

            return p419:AddToggle(u422)
        end
        if v421 == 'Button' then
            return p419:AddButton(p420[2])
        end
        if v421 == 'Dropdown' then
            local u424 = p420[2]

            u424.Multi = u424.Multi or false

            if u424.Multi and not u139[u424.Title] then
                u139[u424.Title] = {}
            end

            u424.Default = u424.Default or u139[u424.Title]
            u424.Callback = u424.Callback or function(p425)
                p418:SaveSettings(u424.Title, p425)
            end

            return p419:AddDropdown(u424)
        end
        if v421 == 'Slider' then
            local u426 = p420[2]
            local _Title = u426.Title

            u426.Default = u426.Default or (u139[_Title] or u426.Min)
            u426.Callback = u426.Callback or function(p428)
                p418:SaveSettings(u426.Title, p428)
            end

            return p419:AddSlider(u426)
        end
        if v421 == 'Input' then
            local u429 = p420[2]

            u429.Default = u429.Default or u139[u429.Title]
            u429.Callback = u429.Callback or function(p430)
                p418:SaveSettings(u429.Title, p430)
            end

            return p419:AddInput(u429)
        end
        if v421 == 'Section' then
            return p419:AddSeperator(p420[2].Title)
        end
        if v421 == 'Label' then
            return p419:AddParagraph(p420[2])
        end

        print('[ Build UI ] Invaild Type!')
    end
    function u11.CreateFunction(_, p431)
        local v432 = p431 or {}

        v432.Name = v432.Name or v432[1]
        v432.Function = v432.Function or v432[2]
        v432.Sea = v432.Sea or v432[3]

        if not u12[v432.Name] then
            table.insert(u12, {
                Name = v432.Name,
                Function = v432.Function,
                Sea = v432.Sea,
            })
            print('[Zinner Hub] Function Create [' .. v432.Name .. ' - ' .. tostring(v432.Function) .. ']')
        end
    end
    function u11.LoadCached(p433)
        function RemoveLv(p434)
            return tostring(p434):gsub(' %[Lv. %d+%]', '')
        end

        local _Folder = p433:New('Folder', {
            Name = 'Cached',
            Parent = workspace,
        })
        local v436 = {}
        local v437 = {}

        repeat
            wait()
        until _Folder

        local v438 = next
        local v439, v440 = u21.WS._WorldOrigin.EnemySpawns:GetChildren()

        while true do
            local v441

            v440, v441 = v438(v439, v440)

            if v440 == nil then
                break
            end

            v441.Name = RemoveLv(v441)

            table.insert(v436, v441)
        end

        local v442 = next
        local _Quests = u21.Quests
        local v444 = nil

        while true do
            local v445

            v444, v445 = v442(_Quests, v444)

            if v444 == nil then
                break
            end

            local v446 = next
            local v447 = nil

            while true do
                local v448

                v447, v448 = v446(v445, v447)

                if v447 == nil then
                    break
                end

                local v449 = next
                local _Task = v448.Task
                local v451 = nil

                while true do
                    local v452

                    v451, v452 = v449(_Task, v451)

                    if v451 == nil then
                        break
                    end
                    if v448.Task[v451] > 1 then
                        table.insert(v437, v451)
                    end
                end
            end
        end

        local v453 = next
        local v454, v455 = u21.WS.Enemies:GetChildren()

        while true do
            local v456

            v455, v456 = v453(v454, v455)

            if v455 == nil then
                break
            end
            if table.find(v437, v456.Name) then
                table.insert(v436, v456)
            end
        end

        local v457 = next
        local v458, v459 = u21.RS:GetChildren()

        while true do
            local v460

            v459, v460 = v457(v458, v459)

            if v459 == nil then
                break
            end
            if table.find(v437, v460.Name) then
                table.insert(v436, v460)
            end
        end

        local v461 = next
        local v462, v463 = getnilinstances()

        while true do
            local v464

            v463, v464 = v461(v462, v463)

            if v463 == nil then
                break
            end
            if table.find(v437, v464.Name) then
                table.insert(v436, v464)
            end
        end

        local v465 = next
        local v466 = nil

        while true do
            local v467

            v466, v467 = v465(v436, v466)

            if v466 == nil then
                break
            end
            if v467:IsA('Part') then
                v467:Clone().Parent = u21.WS.Cached
            elseif v467:IsA('Model') and v467:FindFirstChild('HumanoidRootPart') then
                p433:New('Part', {
                    Parent = u21.WS.Cached,
                    Name = v467.Name,
                    Size = Vector3.new(1, 1, 1),
                    Transparency = 1,
                    CanCollide = false,
                    Anchored = true,
                    CFrame = v467.HumanoidRootPart.CFrame,
                })
            end
        end
    end
    function u11.LoopForSlowRemotes(p468)
        p468:Loop(function()
            while wait() do
                if u21.CommF_:InvokeServer('GetUnlockables').DefeatedIndraTrueForm then
                    u21.UnlockPortal = true
                end
                if u21.CommF_:InvokeServer('TalkTrevor', '1') == 0 then
                    u21.Gift1MFruit = true
                end
            end
        end)
        p468:Loop(function()
            while wait() do
                if u139['Auto Upgraded Race V1 - V3'] then
                    local v469 = p468

                    if string.find(v469:CheckRace(), 'V2') then
                        p468:TakeQuestV3()
                        p468:UpV3()
                    end

                    u13 = p468:CheckRace()
                end
            end
        end)
        p468:Loop(function()
            while wait() do
                if u139['Auto Castle Raid'] and (p468:CheckSea(3) and p468:GetPirateRaid()) then
                    local v470 = tick()

                    repeat
                        wait()

                        getgenv().IsCastleRaid = true
                    until tick() - v470 >= 20 or not u139['Auto Castle Raid'] or p468:CheckNotify('good job!')

                    getgenv().IsCastleRaid = false
                end
            end
        end)
        p468:Loop(function()
            while wait() do
                if SpamSkill then
                    pcall(function()
                        if u139['Use Melee'] and u11:GetSkill('Melee', u139['Melee Skills']) then
                            local _Melee2 = u11:GetSkill('Melee', u139['Melee Skills'])

                            u11:EquipTool(_Melee2[1])
                            u11:SendKey(_Melee2[2])
                        elseif u139['Use Sword'] and u11:GetSkill('Sword', u139['Sword Skills']) then
                            local _Sword = u11:GetSkill('Sword', u139['Sword Skills'])

                            u11:EquipTool(_Sword[1])
                            u11:SendKey(_Sword[2])
                        elseif u139['Use Gun'] and u11:GetSkill('Gun', u139['Gun Skills']) then
                            local _Gun = u11:GetSkill('Gun', u139['Gun Skills'])

                            u11:EquipTool(_Gun[1])
                            u11:SendKey(_Gun[2])
                        elseif u139['Use Blox Fruits'] and u11:GetSkill('Blox Fruit', u139['Blox Fruit Skills']) then
                            local _BloxFruit = u11:GetSkill('Blox Fruit', u139['Blox Fruit Skills'])

                            u11:EquipTool(_BloxFruit[1])
                            u11:SendKey(_BloxFruit[2])
                        else
                            u11:RandomEquipWeapon()
                        end
                    end)
                end
            end
        end)
    end
    function u11.MakeFarm(p475)
        local u476 = {
            'Reborn Skeleton',
            'Living Zombie',
            'Demonic Soul',
            'Posessed Mummy',
        }
        local u477 = {
            'Cookie Crafter',
            'Cake Guard',
            'Baking Staff',
            'Head Baker',
        }

        u21.CommF_:InvokeServer('TushitaProgress')
        u21.CommF_:InvokeServer('EliteHunter', 'Progress')

        function CheckStack(p478)
            if p478 == 'Start Farm' then
                if u139['Auto Elite Hunter'] and u11:GetElites() then
                    return true
                end
                if u139['Auto Factory'] and u11:GetMobs('Core', true) then
                    return true
                end
                if u139['Auto Tyrant of the Skies'] and u11:GetMobs('Tyrant of the Skies', true) then
                    return true
                end
                if u139['Auto Darkbeard'] and u11:GetMobs('Darkbeard', true) then
                    return true
                end
                if u139['Auto Admin'] and u11:GetMobs(u21.Mobs.ripindra, true) then
                    return true
                end
                if u139['Auto Dough King'] and u11:GetMobs('Dough King', true) then
                    return true
                end
                if u139['Auto Travel Dressrosa'] and (Sea1 and u21.LocalPlayer.Data.Level.Value >= 700) and u21.CommF_:InvokeServer('DressrosaQuestProgress', 'Dressrosa') ~= 0 then
                    return true
                end
                if u139['Auto Teleport Fruits'] and u11:GetFruitSpawned() then
                    return true
                end
                if u139['Auto Bartilo'] and Sea2 and (not u11:CheckInventory('Warrior Helmet') and u21.LocalPlayer.Data.Level.Value >= 850 and (u21.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo') ~= 1 or u21.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo') == 1 and u11:GetMobs('Jeremy', true))) then
                    return true
                end
                if u139['Auto Soul Reaper'] and u11:GetMobs('Soul Reaper', true) then
                    return
                end
            end
        end

        p475:CreateFunction({
            'Start Farm',
            function()
                if CheckStack('Start Farm') then
                    return
                end
                if u139['Farm Mode'] == 'Bone' and Sea3 then
                    if p475:GetMobs(u476) then
                        local v479 = p475:GetMobs(u476)

                        repeat
                            task.wait()
                            p475:KillMob(v479)
                        until CheckStack('Start Farm') or not u139['Start Farm'] or (not p475:IsAlive(v479) or u139['Farm Mode'] ~= 'Bone')
                    else
                        p475:Tweento(CFrame.new(-9496, 172, 6102))
                    end
                end
                if u139['Farm Mode'] == 'Cake' and Sea3 then
                    u21.CommF_:InvokeServer('CakePrinceSpawner')

                    if p475:GetMobs('Cake Prince', true) then
                        while true do
                            if true then
                                task.wait()

                                if p475:CheckCakePrinceSkill() then
                                    p475:Tweento(p475:GetMobs('Cake Prince', true).HumanoidRootPart.CFrame * CFrame.new(0, 120, 0))
                                else
                                    p475:KillMob(p475:GetMobs('Cake Prince', true))
                                end
                            end
                            if not p475:GetMobs('Cake Prince', true) or (CheckStack('Start Farm') or (not u139['Start Farm'] or u139['Farm Mode'] ~= 'Cake')) then
                            end
                        end
                    end
                    if not p475:GetMobs(u477) then
                        p475:Tweento(CFrame.new(-2008, 37, -12013))
                    end

                    local v480 = p475:GetMobs(u477, true)

                    if not v480 then
                    end

                    task.wait()
                    p475:KillMob(v480)

                    if p475:IsAlive(v480) and (not CheckStack('Start Farm') and (u139['Start Farm'] and u139['Farm Mode'] == 'Cake')) then
                    end
                end
                if u139['Farm Mode'] == 'Level' then
                    if u21.LocalPlayer.Data.Level.Value >= 50 and u21.LocalPlayer.Data.Level.Value < 150 then
                        local _Shanda = p475:GetMobs('Shanda')

                        if _Shanda and p475:IsAlive(_Shanda) then
                            repeat
                                task.wait()
                                p475:KillMob(_Shanda)
                            until CheckStack('Start Farm') or u21.LocalPlayer.Data.Level.Value >= 150 or not (p475:IsAlive(_Shanda) and u139['Start Farm'])
                        elseif not _Shanda then
                            p475:Tweento(CFrame.new(-7681.5751953125, 5567.17041015625, -498.3719482421875))
                        end
                    end
                    if u21.LocalPlayer.Data.Level.Value < 10 or u21.LocalPlayer.Data.Level.Value >= 50 then
                        if u21.LocalPlayer.Data.Level.Value < 10 or u21.LocalPlayer.Data.Level.Value >= 150 then
                            if u21.LocalPlayer.PlayerGui.Main.Quest.Visible ~= false then
                                if p475:GetMobs(p475:GetQuestData()) then
                                    local v482 = p475:GetMobs(p475:GetQuestData())

                                    repeat
                                        task.wait()
                                        p475:KillMob(v482)
                                    until CheckStack('Start Farm') or (p475:IsAlive(v482) or (u21.LocalPlayer.PlayerGui.Main.Quest.Visible == false or (u139['Start Farm'] == false or u139['Farm Mode'] ~= 'Level')))
                                else
                                    local v483 = next
                                    local v484, v485 = u21.WS.Cached:GetChildren()

                                    while true do
                                        local v486

                                        v485, v486 = v483(v484, v485)

                                        if v485 == nil then
                                            break
                                        end

                                        local v487 = p475

                                        if v486.Name == v487:GetQuestData() and not p475:GetMobs(p475:GetQuestData()) then
                                            repeat
                                                wait()
                                                p475:Tweento(v486.CFrame * CFrame.new(0, 20, 0))
                                                wait(1)
                                            until p475:GetMobs(p475:GetQuestData()) or (CheckStack('Start Farm') or (u139['Start Farm'] == false or u139['Farm Mode'] ~= 'Level')) or p475:GetDistance(v486.Position) <= 30
                                        end
                                    end
                                end
                            elseif p475:GetDistance(p475:QuestNPC()) > 10 then
                                p475:Tweento(p475:QuestNPC())
                            else
                                local v488 = p475

                                u21.CommF_:InvokeServer('StartQuest', p475:UpdateDoubleQuest().Name, v488:UpdateDoubleQuest().ID)
                            end
                        end
                    else
                        local _SkyBandit = p475:GetMobs('Sky Bandit')

                        if _SkyBandit and p475:IsAlive(_SkyBandit) then
                            task.wait()
                            p475:KillMob(_SkyBandit)

                            if CheckStack('Start Farm') or u21.LocalPlayer.Data.Level.Value >= 150 or not (p475:IsAlive(_SkyBandit) and u139['Start Farm']) then
                            end
                        end
                        if not _SkyBandit then
                            p475:Tweento(CFrame.new(-4955.66455078125, 296.11083984375, -2900.101806640625))
                        end
                    end
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Auto Upgraded Race V1 - V3',
            function()
                if not u13 then
                    return
                end
                if string.find(u13, 'V1') then
                    local _Alchemist2 = u21.CommF_:InvokeServer('Alchemist', '1')

                    if _Alchemist2 ~= 1 and _Alchemist2 ~= 2 then
                        u21.CommF_:InvokeServer('Alchemist', '2')

                        return
                    end
                    if _Alchemist2 == 2 then
                        u21.CommF_:InvokeServer('Alchemist', '3')

                        return
                    end
                    if not p475:CheckTool('Flower 1') then
                        if u21.Lighting.ClockTime < 18 and u21.Lighting.ClockTime >= 5 then
                            print('Hop Because Time Is Not Night')
                            p475:HopServers()
                        end

                        p475:Tweento(u21.WS.Flower1.CFrame)
                    end
                    if not p475:CheckTool('Flower 2') then
                        p475:Tweento(u21.WS.Flower2.CFrame)
                    end
                    if p475:GetMobs('Swan Pirate') then
                        task.wait()
                        p475:KillMob(p475:GetMobs('Swan Pirate'))

                        if not p475:GetMobs('Swan Pirate') or (p475:CheckTool('Flower 3') or u139['Auto Upgraded Race V1 - V3'] == false) then
                        end
                    end

                    local v491 = next
                    local v492, v493 = u21.WS.Cached:GetChildren()

                    while true do
                        local v494

                        v493, v494 = v491(v492, v493)

                        if v493 == nil then
                            break
                        end
                        if v494.Name == 'Swan Pirate' and not p475:GetMobs('Swan Pirate') then
                            repeat
                                wait()
                                p475:Tweento(v494.CFrame * CFrame.new(0, 20, 0))
                                task.wait(1)
                            until u139['Auto Upgraded Race V1 - V3'] == false or p475:GetDistance(v494.Position) <= 30
                        end
                    end
                end
                if string.find(u13, 'V2') then
                    if u13 == 'Mink V2' then
                        local v495 = p475:GetChests()

                        if not v495 then
                        end

                        while true do
                            task.wait()
                            p475:Tweento(v495.CFrame)

                            if p475:GetDistance(v495.Position) <= 10 then
                                firetouchinterest(v495, u21.LocalPlayer.Character.PrimaryPart, 0)
                                firetouchinterest(v495, u21.LocalPlayer.Character.PrimaryPart, 1)
                            end
                            if not v495 or (not v495.Parent or (u139['Auto Upgraded Race V1 - V3'] == false or (v495:GetAttribute('IsDisabled') or u13 ~= 'Mink V2'))) then
                            end
                        end
                    end
                    if u13 == 'Human V2' then
                        local v496 = {
                            Jeremy = p475:GetMobs('Jeremy', true),
                            Diamond = p475:GetMobs('Diamond', true),
                            Orbitus = p475:GetMobs('Orbitus', true),
                        }
                        local v497 = {}

                        if not Killed then
                            Killed = 0
                        end

                        local v498 = next
                        local v499 = nil

                        while true do
                            local v500

                            v499, v500 = v498(v496, v499)

                            if v499 == nil then
                                break
                            end
                            if v500 then
                                table.insert(v497, v500)
                            end
                        end

                        if Killed < 3 and #v497 < 3 then
                            p475:HopServers()

                            return
                        end

                        local v501 = next
                        local v502 = nil

                        while true do
                            local v503

                            v502, v503 = v501(v497, v502)

                            if v502 == nil then
                                break
                            end
                            if v503 then
                                repeat
                                    task.wait()
                                    p475:KillMob(v503)
                                until not p475:IsAlive(v503) or u139['Auto Upgraded Race V1 - V3'] == false

                                Killed = Killed + 1
                            end
                        end
                    end
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Auto Boss',
            function()
                local v504, v505 = p475:GetBoss(u139['Boss List'])

                if p475:GetMobs(v504, true) then
                    if u139['Claim Quest'] and (v505.IsQuest and u21.LocalPlayer.Data.Level.Value >= v505.LevelReq) and not p475:CheckQuest(v504) then
                        if p475:GetDistance(v505.Quest[2]) > 10 then
                            p475:Tweento(v505.Quest[2])
                        else
                            u21.CommF_:InvokeServer('StartQuest', v505.Quest[1], 3)
                        end
                    else
                        local v506 = ((not u139['Claim Quest'] or (not v505.IsQuest or u21.LocalPlayer.Data.Level.Value < v505.LevelReq) or p475:CheckQuest(v504)) and true or false) and p475:GetMobs(v504, true)

                        if v506 then
                            repeat
                                task.wait()
                                p475:KillMob(v506)
                            until not p475:IsAlive(v506) or (p475:CheckQuest(v504) or u139['Auto Boss'] == false)
                        end
                    end
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Auto Chest',
            function()
                if u139['Stop After Legendary Items'] and (p475:CheckTool("God's Chalice") or p475:CheckTool('Fist Of Darkness')) then
                    return
                end

                local v507 = p475:GetChests()

                if v507 then
                    while true do
                        task.wait()
                        p475:Tweento(v507.CFrame)

                        if p475:GetDistance(v507.Position) <= 10 then
                            firetouchinterest(v507, u21.LocalPlayer.Character.PrimaryPart, 0)
                            firetouchinterest(v507, u21.LocalPlayer.Character.PrimaryPart, 1)
                        end
                        if u139['Auto Chest [ HOP ]'] and u21.TotalChest >= tonumber(u139['Chest Counts']) then
                            p475:HopServers()
                        end
                        if not v507 or (not v507.Parent or (u139['Auto Chest'] == false or v507:GetAttribute('IsDisabled'))) or u139['Stop After Legendary Items'] and (p475:CheckTool("God's Chalice") or p475:CheckTool('Fist Of Darkness')) then
                            u21.TotalChest = u21.TotalChest + 1
                        end
                    end
                else
                    return
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Auto Elite Hunter',
            function()
                if p475:GetElites() then
                    if p475:CheckQuest(p475:GetElites().Name) then
                        repeat
                            task.wait()
                            p475:KillMob(p475:GetElites())
                        until not p475:GetElites() or u139['Auto Elite Hunter'] == false
                    else
                        u21.CommF_:InvokeServer('EliteHunter')
                    end
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Factory',
            function()
                if p475:GetMobs('Core', true) then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs('Core', true))
                    until not p475:GetMobs('Core', true) or u139['Auto Factory'] == false
                end
            end,
            Sea2,
        })
        p475:CreateFunction({
            'Auto Admin',
            function()
                if p475:GetMobs(u21.Mobs.ripindra, true) then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs(u21.Mobs.ripindra, true))
                    until not p475:GetMobs(u21.Mobs.ripindra, true) or u139['Auto Admin'] == false
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Darkbeard',
            function()
                if p475:GetMobs(u21.Mobs.ripindra, true) then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs(u21.Mobs.ripindra, true))
                    until not p475:GetMobs(u21.Mobs.ripindra, true) or u139['Auto Darkbeard'] == false
                elseif p475:CheckTool('Fist Of Darkness') then
                    p475:EquipTool('Fist Of Darkness')
                    p475:Tweento(u21.WS.Map.DarkbeardArena.Summoner.Detection.CFrame)
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Tyrant Of The Skies',
            function()
                if SpamSkill and p475:GetMobs('Tyrant of the Skies', true) then
                    SpamSkill = false
                end
                if p475:GetMobs('Tyrant of the Skies', true) then
                    task.wait()
                    p475:KillMob(p475:GetMobs('Tyrant of the Skies', true))

                    if not p475:GetMobs('Tyrant of the Skies', true) or u139['Auto Tyrant Of The Skies'] == false then
                    end
                end
                if p475:CheckEyes() then
                    if p475:GetTreeOnBirdArena() then
                        local v508 = p475:GetTreeOnBirdArena()

                        if p475:GetDistance(v508.PrimaryPart.Position) > 10 then
                            p475:Tweento(v508.PrimaryPart.CFrame)
                        else
                            SpamSkill = true
                        end
                    else
                        p475:Tweento(CFrame.new(-16217, 155, 1389))
                    end
                end
                if p475:GetMobs(u21.Mobs.TikiOutpost) then
                    task.wait()
                    p475:KillMob(p475:GetMobs(u21.Mobs.TikiOutpost))

                    if not p475:GetMobs(u21.Mobs.TikiOutpost) or u139['Auto Tyrant Of The Skies'] == false then
                    end
                end

                local v509 = next
                local v510, v511 = u21.WS.Cached:GetChildren()

                while true do
                    local v512

                    v511, v512 = v509(v510, v511)

                    if v511 == nil then
                        break
                    end
                    if table.find(u21.Mobs.TikiOutpost, v512.Name) and not p475:GetMobs(u21.Mobs.TikiOutpost) then
                        repeat
                            wait()
                            p475:Tweento(v512.CFrame * CFrame.new(0, 20, 0))
                            task.wait(1)
                        until u139['Tyrant Of The Skies'] == false or (p475:GetDistance(v512.Position) <= 30 or p475:CheckEyes())
                    end
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Saber',
            function()
                if not u11:CheckInventory('Saber') and u21.LocalPlayer.Data.Level.Value >= 200 then
                    if workspace.Map.Jungle.Final.Part.CanCollide then
                        if workspace.Map.Jungle.QuestPlates.Door.CanCollide then
                            pcall(function()
                                u11:Tweento(u11:GetPlates())
                            end)
                        end
                        if workspace.Map.Desert.Burn.Fire.CanCollide then
                            if u11:CheckTool('Torch') then
                                u11:EquipTool('Torch')
                                u11:Tweento(CFrame.new(1115.25354, 4.95647621, 4349.24463, -0.624247193, 5.46374288e-8, 0.781226873, -1.33858959e-8, 1, -8.06341163e-8, -0.781226873, -6.07930417e-8, -0.624247193))
                            else
                                u11:Tweento(workspace.Map.Jungle.Torch.CFrame)
                            end
                        end

                        local _ProQuestProgress = u21.CommF_:InvokeServer('ProQuestProgress', 'RichSon')

                        if _ProQuestProgress ~= 0 and _ProQuestProgress ~= 1 then
                            if u11:CheckTool('Cup') then
                                u11:EquipTool('Cup')
                                wait(0.4)
                                u21.CommF_:InvokeServer('ProQuestProgress', 'FillCup', u11:CheckTool('Cup'))
                                wait(0.2)
                                u21.CommF_:InvokeServer('ProQuestProgress', 'SickMan')
                            else
                                u11:Tweento(workspace.Map.Desert.Cup.CFrame)
                            end
                        end
                        if _ProQuestProgress == 0 then
                            if u11:GetMobs('Mob Leader', true) then
                                local _MobLeader = u11:GetMobs('Mob Leader', true)

                                task.wait()
                                u11:KillMob(_MobLeader)

                                if not _MobLeader or (not u11:IsAlive(_MobLeader) or u139['Auto Saber'] == false) then
                                end
                            end

                            u11:Tweento(CFrame.new(-2836, 7, 5484))
                        elseif _ProQuestProgress == 1 then
                            if u11:CheckTool('Relic') then
                                u11:EquipTool('Relic')
                                u11:Tweento(CFrame.new(-1404, 29, 4))
                            else
                                local v515 = CFrame.new(-908, 14, 4077)

                                if u11:GetDistance(v515.Position) <= 10 then
                                    u21.CommF_:InvokeServer('ProQuestProgress', 'RichSon')
                                else
                                    u11:Tweento(v515)
                                end
                            end
                        end
                    elseif u11:GetMobs('Saber Expert', true) then
                        local _SaberExpert = u11:GetMobs('Saber Expert', true)

                        repeat
                            task.wait()
                            u11:KillMob(_SaberExpert)
                        until not u11:IsAlive(_SaberExpert) or (not _SaberExpert.Parent or u139['Auto Saber'] == false)
                    else
                        p475:HopServers()
                    end
                end
            end,
            Sea1,
        })
        p475:CreateFunction({
            'Auto Travel Dressrosa',
            function()
                if u21.CommF_:InvokeServer('DressrosaQuestProgress', 'Dressrosa') == 0 then
                    u21.CommF_:InvokeServer('TravelDressrosa')
                elseif u21.LocalPlayer.Data.Level.Value >= 700 and u11:CheckSea(1) then
                    if workspace.Map.Ice.Door.CanCollide then
                        if u11:CheckTool('Key') then
                            u11:EquipTool('Key')
                            u11:Tweento(CFrame.new(1347.44092, 37.3843765, -1322.61816, 0.810376644, -1.14628271e-8, 0.585909247, -4.94534582e-8, 1, 8.79637199e-8, -0.585909247, -1.00258987e-7, 0.810376644))
                        else
                            NPCKey = CFrame.new(4852.2895507813, 5.651451587677, 718.53070068359)

                            if u11:GetDistance(NPCKey.Position) <= 10 then
                                u21.CommF_:InvokeServer('DressrosaQuestProgress', 'Detective')
                            else
                                u11:Tweento(NPCKey)
                            end
                        end
                    elseif u11:GetMobs('Ice Admiral', true) then
                        local _IceAdmiral = u11:GetMobs('Ice Admiral', true)

                        repeat
                            task.wait()
                            u11:KillMob(_IceAdmiral)
                        until not (u139['Auto Travel Dressrosa'] and u11:IsAlive(_IceAdmiral))

                        u21.CommF_:InvokeServer('TravelDressrosa')
                    else
                        u11:Tweento(CFrame.new(1347.7124, 37.3751602, -1325.6488))
                    end
                end
            end,
            Sea1,
        })
        p475:CreateFunction({
            'Auto Bartilo',
            function()
                if u21.LocalPlayer.Data.Level.Value < 850 or (u21.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo') == 3 or u11:CheckInventory('Warrior Helmet')) then
                    return
                else
                    local _BartiloQuestProgress = u21.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo')

                    if _BartiloQuestProgress == 0 then
                        if u21.LocalPlayer.PlayerGui.Main.Quest.Visible == false or not string.find(u21.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, 'Swan Pirate') then
                            if u11:GetDistance(CFrame.new(-456.28952, 73.0200958, 299.895966).Position) > 10 then
                                u11:Tweento(CFrame.new(-456.28952, 73.0200958, 299.895966))
                            else
                                u21.CommF_:InvokeServer('StartQuest', 'BartiloQuest', 1)
                            end
                        end
                        if not (u21.LocalPlayer.PlayerGui.Main.Quest.Visible and string.find(u21.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, 'Swan Pirate')) then
                        end
                        if u11:GetMobs('Swan Pirate') then
                            local _SwanPirate = u11:GetMobs('Swan Pirate')

                            if not _SwanPirate then
                            end

                            task.wait()
                            u11:KillMob(_SwanPirate)

                            if u11:IsAlive(_SwanPirate) and _BartiloQuestProgress ~= 1 then
                            end
                        else
                            u11:Tweento(CFrame.new(961.625732421875, 121.69786071777344, 1304.241943359375))
                        end
                    end
                    if _BartiloQuestProgress == 1 then
                        local v520 = u11:GetMobs('Jeremy', true) and u11:GetMobs('Jeremy', true)

                        if not v520 then
                        end

                        task.wait()
                        u11:KillMob(v520)

                        if u11:IsAlive(v520) and _BartiloQuestProgress ~= 2 then
                        end
                    end
                    if _BartiloQuestProgress ~= 2 then
                    end
                    if u11:GetDistance(CFrame.new(-1835.65, 10.4325, 1679.75).Position) > 200 then
                        u11:Tweento(CFrame.new(-1835.65, 10.4325, 1679.75))
                    end

                    while true do
                        if true then
                            wait(0.3)

                            if u11:GetBartiloPlates('Plate1') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate1').CFrame)
                            elseif u11:GetBartiloPlates('Plate2') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate2').CFrame)
                            elseif u11:GetBartiloPlates('Plate3') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate3').CFrame)
                            elseif u11:GetBartiloPlates('Plate4') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate4').CFrame)
                            elseif u11:GetBartiloPlates('Plate5') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate5').CFrame)
                            elseif u11:GetBartiloPlates('Plate6') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate6').CFrame)
                            elseif u11:GetBartiloPlates('Plate7') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate7').CFrame)
                            elseif u11:GetBartiloPlates('Plate8') then
                                u11:InstanceTween(u11:GetBartiloPlates('Plate8').CFrame)
                            end
                        end
                        if _BartiloQuestProgress == 3 or u139['Auto Bartilo'] ~= true or p475:CheckInventory('Warrior Helmet') then
                        end
                    end
                end
            end,
            Sea2,
        })
        p475:CreateFunction({
            'Auto Soul Reaper',
            function()
                if p475:GetMobs('Soul Reaper') then
                    task.wait()
                    p475:KillMob(p475:GetMobs('Soul Reaper'))

                    if not p475:GetMobs('Soul Reaper') or u139['Auto Soul Reaper'] == false then
                    end
                end
                if u11:CheckTool('Hallow Essence') then
                    u11:EquipTool('Hallow Essence')
                    u11:Tweento(CFrame.new(-8932, 146, 6062))
                else
                    u21.CommF_:InvokeServer('Bones', 'Buy', 1, 1)
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Teleport Fruits',
            function()
                if p475:GetFruitSpawned() then
                    p475:Tweento(p475:GetFruitSpawned().Handle.CFrame)
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Kill Raid',
            function()
                if u21.LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
                    local v521 = next
                    local v522, v523 = u21.WS.Enemies:GetChildren()

                    while true do
                        local v524

                        v523, v524 = v521(v522, v523)

                        if v523 == nil then
                            break
                        end
                        if u11:IsAlive(v524) and u11:GetDistance(v524.HumanoidRootPart.Position) <= 1500 then
                            repeat
                                task.wait()
                                u11:KillMob(v524)
                            until u21.LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer.Visible == false or not (u11:IsAlive(v524) and u139['Kill Raid'])
                        end
                    end
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Next Islands',
            function()
                if u21.LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
                    if u139['Kill Raid'] and p475:GetNearRaidEnemies() then
                        return
                    end
                    if p475:GetRaidIsland(5) then
                        p475:Tweento(p475:GetRaidIsland(5).CFrame * CFrame.new(0, 80, 0))
                    elseif p475:GetRaidIsland(4) then
                        p475:Tweento(p475:GetRaidIsland(4).CFrame * CFrame.new(0, 80, 0))
                    elseif p475:GetRaidIsland(3) then
                        p475:Tweento(p475:GetRaidIsland(3).CFrame * CFrame.new(0, 80, 0))
                    elseif p475:GetRaidIsland(2) then
                        p475:Tweento(p475:GetRaidIsland(2).CFrame * CFrame.new(0, 80, 0))
                    elseif p475:GetRaidIsland(1) then
                        p475:Tweento(p475:GetRaidIsland(1).CFrame * CFrame.new(0, 80, 0))
                    end
                end
            end,
            true,
        })
        p475:CreateFunction({
            'Auto Travel Zou',
            function()
                if u21.LocalPlayer.Data.Level.Value >= 1500 and u21.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo') == 3 then
                    if u21.CommF_:InvokeServer('TalkTrevor', '1') ~= 0 then
                        if p475:Detect1MFruit() then
                            p475:EquipTool(p475:Detect1MFruit())

                            if p475:GetDistance(CFrame.new(-339.79840087891, 331.86065673828, 643.83178710938)) > 10 then
                                p475:Tweento(CFrame.new(-339.79840087891, 331.86065673828, 643.83178710938))
                            else
                                for v525 = 1, 3 do
                                    u21.CommF_:InvokeServer('TalkTrevor', tostring(v525))
                                end

                                getgenv().CantStore = false
                            end
                        elseif p475:GetFruitInventory(true) then
                            local v526 = p475

                            print(v526:GetFruitInventory(true))

                            getgenv().CantStore = true

                            u21.CommF_:InvokeServer('LoadFruit', p475:GetFruitInventory(true))
                            task.wait(1)
                        end
                    end
                    if u21.CommF_:InvokeServer('ZQuestProgress', 'Check') then
                        if u21.CommF_:InvokeServer('ZQuestProgress', 'Check') ~= 0 then
                            if p475:GetDistance(CFrame.new(-382, 73, 298)) <= 100 or p475:GetDistance(Vector3.new(-6518, 83, -145)) <= 100 then
                                u21.CommF_:InvokeServer('TravelZou')
                            end
                        elseif u11:GetDistance(workspace.Map.IndraIsland.Part.Position) <= 1000 then
                            local _rip_indra = u11:GetMobs('rip_indra', true)

                            if _rip_indra then
                                repeat
                                    task.wait()
                                    p475:KillMob(_rip_indra)
                                until not (u139['Auto Travel Zou'] and p475:IsAlive(_rip_indra))

                                u21.CommF_:InvokeServer('TravelZou')
                            end
                        elseif u11:GetDistance(CFrame.new(-1926.78772, 12.1678171, 1739.80884).Position) <= 10 then
                            u21.CommF_:InvokeServer('ZQuestProgress', 'Begin')
                        else
                            u11:Tweento(CFrame.new(-1926.78772, 12.1678171, 1739.80884))
                        end
                    else
                        local _DonSwan = p475:GetMobs('Don Swan', true)

                        if _DonSwan then
                            task.wait()
                            p475:KillMob(_DonSwan)

                            if not (u139['Auto Travel Zou'] and p475:IsAlive(_DonSwan)) then
                            end
                        end

                        p475:HopServers()
                    end
                end
            end,
            Sea2,
        })
        p475:CreateFunction({
            'Auto Electric Claw',
            function()
                if u21.CommF_:InvokeServer('BuyElectricClaw') ~= 1 then
                    if u139['Saved Electro Mastery'] then
                        if not electricclawquest then
                            electricclawquest = false
                        end
                        if electricclawquest then
                            if u21.CommF_:InvokeServer('BuyElectricClaw', 'Start') ~= 4 then
                                u21.CommF_:InvokeServer('BuyElectricClaw')
                                Library:Notify({
                                    Title = 'Auto Electric Claw',
                                    Content = 'Complete!',
                                    Duration = 7,
                                })

                                return
                            end

                            p475:Tweento(CFrame.new(-12549, 337, -7470))
                        elseif p475:GetDistance(CFrame.new(-10372, 332, -10129)) > 10 then
                            p475:Tweento(CFrame.new(-10372, 332, -10129))
                        else
                            u21.CommF_:InvokeServer('BuyElectricClaw', 'Start')
                            wait(0.2)

                            electricclawquest = true
                        end
                    elseif p475:CheckTool('Electro') then
                        if p475:CheckTool('Electro') and p475:CheckMeleeMastery('Electro', 400) then
                            p475:SaveSettings('Saved Electro Mastery', true)
                        end
                    else
                        p475:BuyMelee('Electro')
                    end
                else
                    u21.CommF_:InvokeServer('BuyElectricClaw')
                    Library:Notify({
                        Title = 'Auto Electric Claw',
                        Content = 'Complete!',
                        Duration = 7,
                    })
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Rengoku',
            function()
                if p475:CheckInventory('Rengoku') then
                    Library:Notify({
                        Title = 'Script Notification',
                        Content = 'Your Already Have Rengoku',
                        Duration = 5,
                    })
                elseif p475:CheckTool('Hidden Key') then
                    p475:EquipTool('Hidden Key')
                    p475:Tweento(CFrame.new(6571, 299, -6967))
                elseif p475:GetMobs(u21.RengokuMobs, true) then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs(u21.RengokuMobs, true))
                    until not (p475:GetMobs(u21.RengokuMobs, true) and u139['Auto Rengoku']) or p475:CheckTool('Hidden Key')
                else
                    local v529 = next
                    local v530, v531 = u21.WS.Cached:GetChildren()

                    while true do
                        local v532

                        v531, v532 = v529(v530, v531)

                        if v531 == nil then
                            break
                        end
                        if table.find(u21.RengokuMobs, v532.Name) and not p475:GetMobs(u21.RengokuMobs, true) then
                            repeat
                                wait()
                                p475:Tweento(v532.CFrame * CFrame.new(0, 20, 0))
                                wait(1)
                            until p475:GetMobs(u21.RengokuMobs, true) or u139['Auto Rengoku'] == false or p475:GetDistance(v532.Position) <= 30
                        end
                    end
                end
            end,
            Sea2,
        })
        p475:CreateFunction({
            'Auto Dragon Talon',
            function()
                if u21.CommF_:InvokeServer('BuyDragonTalon', true) == 1 then
                    p475:BuyMelee('Dragon Talon')
                elseif u21.CommF_:InvokeServer('BuyDragonTalon', true) ~= 'Set your heart ablaze.' then
                    p475:BuyMelee('Dragon Talon')
                elseif p475:CheckTool('Dragon Claw') then
                    if p475:CheckMeleeMastery('Dragon Talon', 400) then
                        if p475:CheckTool('Fire Essence') then
                            u21.CommF_:InvokeServer('BuyDragonTalon', true)
                        else
                            u21.CommF_:InvokeServer('Bones', 'Buy', 1, 1)
                        end
                    end
                else
                    p475:BuyMelee('Dragon Claw')
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Start Auto Sea Events',
            function()
                if not p475:SeaEventFunc() then
                    if p475:GetLocalShip() then
                        if u21.LocalPlayer.Character.Humanoid.Sit ~= false then
                            repeat
                                wait()
                                p475:SailBoatTo(true, p475:GetZones(), 180, 37)
                            until u21.LocalPlayer.Character.Humanoid.Sit ~= true or not u139['Start Auto Sea Events'] or p475:SeaEventFunc()

                            p475:SailBoatTo(false, p475:GetZones(), nil, nil)
                        else
                            p475:Tweento(p475:GetLocalShip().VehicleSeat.CFrame * CFrame.new(0, 2, 0))
                        end
                    elseif p475:GetDistance(CFrame.new(-16214, 9, 406)) > 10 then
                        p475:Tweento(CFrame.new(-16214, 9, 406))
                    else
                        u21.CommF_:InvokeServer('BuyBoat', u139['Select Boats'] or 'Guardian')
                    end
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Shark and Fish Crew Member',
            function()
                if p475:GetMobs({
                    'Fish Crew Member',
                    'Shark',
                }) then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs({
                            'Fish Crew Member',
                            'Shark',
                        }))
                    until not p475:GetMobs({
                        'Fish Crew Member',
                        'Shark',
                    }) or u139['Auto Shark and Fish Crew Member'] == false
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Terror Shark',
            function()
                if p475:GetMobs('Terrorshark') then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs('Terrorshark'))
                    until not p475:GetMobs('Terrorshark') or u139['Auto Terror Shark'] == false
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Pirates Ship',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Ghost Ship',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Sea Beast',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Piranha',
            function()
                if p475:GetMobs('Piranha') then
                    repeat
                        task.wait()
                        p475:KillMob(p475:GetMobs('Piranha'))
                    until not p475:GetMobs('Piranha') or u139['Auto Piranha'] == false
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Find Leviathan',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Leviathan',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Find Kitsune Island',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Collect Azure Member',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Trade Azure Member',
            function() end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Yama',
            function()
                if p475:CheckInventory('Yama') then
                    Library:Notify({
                        Title = 'Auto Yama',
                        Content = 'You Already Have Yama',
                        Duration = 5,
                    })
                elseif u21.CommF_:InvokeServer('EliteHunter', 'Progress') >= 30 then
                    if u21.WS.Map.Waterfall:FindFirstChild('SealedKatana') then
                        if p475:GetDistance(u21.WS.Map.Waterfall.SealedKatana.Hitbox.Position) > 10 then
                            p475:Tweento(u21.WS.Map.Waterfall.SealedKatana.Hitbox.CFrame)
                        else
                            fireclickdetector(u21.WS.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)
                        end
                    else
                        p475:Tweento(CFrame.new(5250.71924, 19.842907, 453.177002))
                    end
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Castle Raid',
            function()
                local v533 = (p475:GetPirateRaid() or getgenv().IsCastleRaid) and p475:GetPirateRaid()

                if v533 then
                    repeat
                        task.wait()
                        p475:KillMob(v533)
                    until not v533 or (u139['Auto Castle Raid'] == false or not getgenv().IsCastleRaid)
                end
            end,
            Sea3,
        })
        p475:CreateFunction({
            'Auto Tushita',
            function()
                if p475:CheckInventory('Tushita') then
                    Library:Notify({
                        Title = 'Auto Tushita',
                        Content = 'You Already Have Tushita',
                        Duration = 5,
                    })
                elseif u21.CommF_:InvokeServer('TushitaProgress').OpenedDoor then
                    if p475:GetMobs('Longma', true) then
                        local _Longma = p475:GetMobs('Longma', true)

                        repeat
                            task.wait()
                            p475:KillMob(_Longma)
                        until not _Longma or u139['Auto Tushita'] == false or not p475:CheckInventory('Tushita')
                    end
                elseif p475:GetMobs(u21.Mobs.ripindra, true) then
                    if p475:CheckTool('Holy Torch') then
                        p475:EquipTool('Holy Torch')

                        for v535 = 1, 5 do
                            u21.CommF_:InvokeServer('TushitaProgress', 'Torch', v535)
                        end
                    else
                        p475:Tweento(CFrame.new(5717.06592, 18.8161335, 252.124573, 0.926925123, -3.2500004500000004e-8, -0.375246346, 3.45466091e-8, 1, -1.2735254e-9, 0.375246346, -1.17830261e-8, 0.926925123))
                    end
                end
            end,
            Sea3,
        })
        task.spawn(function()
            while task.wait() do
                p475:SetNoClip(false)

                repeat
                    wait()
                until u14

                local v536 = next
                local v537 = u12
                local v538 = nil

                while true do
                    local v539

                    v538, v539 = v536(v537, v538)

                    if v538 == nil then
                        break
                    end
                    if u139[v539.Name] and v539.Sea then
                        p475:SetNoClip(true)
                        v539.Function()
                    end
                end
            end
        end)
    end
    function u11.StartBuildFeature(p540)
        function AddStats(p541)
            p540:SaveSettings('Auto Stats', p541)
            p540:Loop(function()
                while u139['Auto Stats'] and wait() do
                    u21.CommF_:InvokeServer('AddPoint', u139['Select Stats'], u139.Points)
                end
            end)
        end
        function AutoSPHM(p542)
            p540:SaveSettings('Auto Superhuman', p542)
            p540:Loop(function()
                while u139['Auto Superhuman'] and wait() do
                    if u21.CommF_:InvokeServer('BuySuperhuman') == 1 then
                        p540:BuyMelee('Superhuman')

                        return
                    end
                    if u139['Enough Black Leg'] then
                        if u139['Enough Electro'] then
                            if u139['Enough Fishman Karate'] then
                                if u139['Enough Dragon Claw'] then
                                    p540:BuyMelee('Superhuman')
                                    Library:Notify({
                                        Title = 'Auto Melee',
                                        Content = 'Get Superhuman Success!',
                                        Duration = 5,
                                    })

                                    return
                                end
                                if u11:CheckMeleeMastery('Dragon Claw', 300) then
                                    p540:BuyMelee('Superhuman')
                                    p540:SaveSettings('Enough Dragon Claw', true)
                                else
                                    p540:BuyMelee('Dragon Claw')
                                end
                            elseif u11:CheckMeleeMastery('Fishman Karate', 300) then
                                p540:BuyMelee('Dragon Claw')
                                p540:SaveSettings('Enough Fishman Karate', true)
                            else
                                p540:BuyMelee('Fishman Karate')
                            end
                        elseif u11:CheckMeleeMastery('Electro', 300) then
                            p540:BuyMelee('Fishman Karate')
                            p540:SaveSettings('Enough Electro', true)
                        else
                            p540:BuyMelee('Electro')
                        end
                    elseif p540:CheckMeleeMastery('Black Leg', 300) then
                        p540:BuyMelee('Electro')
                        p540:SaveSettings('Enough Black Leg', true)
                    else
                        p540:BuyMelee('Black Leg')
                    end
                end
            end)
        end
        function RandomDevilFruits(p543)
            p540:SaveSettings('Auto Random Devil Fruits', p543)
            p540:Loop(function()
                while u139['Auto Random Devil Fruits'] and wait() do
                    u21.CommF_:InvokeServer('Cousin', 'Buy')
                end
            end)
        end
        function AutoStoreFruit(p544)
            p540:SaveSettings('Auto Store Fruits', p544)
            p540:Loop(function()
                while u139['Auto Store Fruits'] and wait() do
                    p540:StoreFruits()
                end
            end)
        end
        function RandomSuprises(p545)
            p540:SaveSettings('Random Suprises', p545)
            p540:Loop(function()
                while u139['Random Suprises'] and wait() do
                    u21.CommF_:InvokeServer('Bones', 'Buy', 1, 1)
                end
            end)
        end
        function AutoBuyChip(p546)
            p540:SaveSettings('Auto Buy Chip', p546)
            p540:Loop(function()
                while u139['Auto Buy Chip'] and (not getgenv().CantBuy and wait()) do
                    u21.CommF_:InvokeServer('RaidsNpc', 'Select', u139['Select Raid'] or 'Flame')
                end
            end)
        end
        function StartRaidFunc(p547)
            print('Start Raid : ' .. tostring(p547))
            p540:SaveSettings('Start Raid', p547)
            p540:Loop(function()
                while u139['Start Raid'] and wait() do
                    print('Start')

                    if p540:CheckSea(2) then
                        fireclickdetector(workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                    elseif p540:CheckSea(3) then
                        fireclickdetector(u21.WS.Map['Boat Castle'].RaidSummon2.Button.Main.ClickDetector)
                    end
                end
            end)
        end

        u21.LocalPlayer:FindFirstChild('DataLoaded'):Destroy()
        u21.LocalPlayer:FindFirstChild('DataPreloaded'):Destroy()

        local v548 = next
        local _AllMelee2 = u21.AllMelee
        local v550 = nil

        while true do
            local v551

            v550, v551 = v548(_AllMelee2, v550)

            if v550 == nil then
                break
            end

            table.insert(u21.TableMelees, v550)
        end

        table.sort(u21.TableMelees)

        local v565 = {
            {
                {
                    'Status Server',
                    122223674767625,
                },
                {
                    {
                        'Label',
                        {
                            Title = 'Client Elapsed',
                            Content = '0 Hours 0 Minutes 0 Seconds',
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Boss Spawned On Server',
                            Content = 'No One',
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Current FPS : 60',
                            Content = '',
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Mirage Puzzle',
                            Content = "You didn't do mirage puzzle quest",
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Leviathan Status',
                            Content = "i don't know anything yet!",
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Tyrant Of The Skies Status',
                            Content = 'Not enough eyes',
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Race Status',
                            Content = 'Race : Human | V3',
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Elite Status',
                            Content = 'Not spawned',
                        },
                    },
                    {
                        'Label',
                        {
                            Title = 'Moon Status',
                            Content = 'Night | Fullmoon | Time to night : 0 Minutes',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Servers',
                        },
                    },
                    {
                        'Input',
                        {
                            Title = 'Job Id',
                            Description = 'Input any string job id jere to join server selected',
                            PlaceHolder = 'put here',
                            Callback = function(p552)
                                getgenv().JobId = p552
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Copy Job Id',
                            Callback = function()
                                setclipboard(game.JobId)
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Join Job Id',
                            Description = 'Join job id your put in the box',
                            Callback = function()
                                p540:JoinJob(getgenv().JobId)
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Rejoin Server',
                            Callback = function()
                                p540:JoinJob(game.JobId)
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Hop Servers',
                            Callback = function()
                                p540:HopServers()
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Hop Server Less Players',
                            Callback = function()
                                p540:HopLessPlayers()
                            end,
                        },
                    },
                },
            },
            {
                {
                    'Shop',
                    134556077676632,
                },
                {
                    {
                        'Button',
                        {
                            Title = 'To Travel Main',
                            Callback = function()
                                u21.CommF_:InvokeServer('TravelMain')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'To Travel Dressrosa',
                            Callback = function()
                                u21.CommF_:InvokeServer('TravelDressrosa')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'To Travel Zou',
                            Callback = function()
                                u21.CommF_:InvokeServer('TravelZou')
                            end,
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Options',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Random Suprises',
                            Callback = function(p553)
                                RandomSuprises(p553)
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Redeem Codes',
                            Callback = function()
                                p540:RedeemCodes()
                            end,
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Melee List',
                            Description = 'Select melee to buy',
                            Values = u21.TableMelees,
                            Callback = function(p554)
                                p540:BuyMelee(p554)
                            end,
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Haki Options',
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Buy Buso [ 25000$ ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('BuyHaki', 'Buso')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Buy Geppo [ 10000$ ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('BuyHaki', 'Geppo')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Buy Soru [ 100000$ ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('BuyHaki', 'Soru')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Buy Ken [ 750000$ ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('KenTalk', 'Buy')
                            end,
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Fragments',
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Buy Kabucha [ 1500f ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('BlackbeardReward', 'Slingshot', '1')
                                u21.CommF_:InvokeServer('BlackbeardReward', 'Slingshot', '2')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Refund Stats [ 1500f ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('BlackbeardReward', 'Refund', '1')
                                u21.CommF_:InvokeServer('BlackbeardReward', 'Refund', '2')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Reroll Race [ 1500f ]',
                            Callback = function()
                                u21.CommF_:InvokeServer('BlackbeardReward', 'Reroll', '2')
                            end,
                        },
                    },
                },
            },
            {
                {
                    'Configuration',
                    127147149367603,
                },
                {
                    {
                        'Toggle',
                        {
                            Title = 'Same Y',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Awakening',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Buso',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Skills',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Use Melee',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Melee Skills',
                            Values = {
                                'Z',
                                'X',
                                'C',
                                'V',
                            },
                            Multi = true,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Use Sword',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Sword Skills',
                            Values = {
                                'Z',
                                'X',
                            },
                            Multi = true,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Use Gun',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Gun Skills',
                            Values = {
                                'Z',
                                'X',
                            },
                            Multi = true,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Use Blox Fruits',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Blox Fruits Skills',
                            Values = {
                                'Z',
                                'X',
                                'C',
                                'V',
                                'F',
                            },
                            Multi = true,
                        },
                    },
                },
            },
            {
                {
                    'Farmming',
                    127561653320876,
                },
                {
                    {
                        'Dropdown',
                        {
                            Title = 'Weapon Type',
                            Description = 'Choose Weapon Type To Farm',
                            Values = {
                                'Melee',
                                'Sword',
                                'Gun',
                                'Blox Fruit',
                            },
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Farmming',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Farm Mode',
                            Description = 'Select Mode Farm',
                            Values = {
                                'Level',
                                'Cake',
                                'Bone',
                            },
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Double Quest',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Start Farm',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Travel Dressrosa',
                            Description = 'Auto Second Sea',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Travel Zou',
                            Description = 'Auto Third Sea',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Boss',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Boss List',
                            Description = 'List All Boss Now Alive',
                            Default = '',
                            Values = p540:UpdateBossList(),
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Refresh Boss List',
                            Callback = function()
                                u15['Boss List']:Refresh(p540:UpdateBossList())
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Claim Quest',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Boss',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Chest',
                        },
                    },
                    {
                        'Input',
                        {
                            Title = 'Chest Counts',
                            Description = 'Input Quanity Chest To Hop When Total Chest You Claim More Than Quanity Inputed',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Chest',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Chest [HOP]',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Stop After Legendary Items',
                            Description = "Stop When You Have God's Chalice or Fist Of Darkness",
                        },
                    },
                },
            },
            {
                {
                    'Stack Farm',
                    72448332143088,
                },
                {
                    {
                        'Toggle',
                        {
                            Title = 'Auto Bartilo',
                            Description = 'Function Only Sea 2',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Tyrant Of The Skies',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Elite Hunter',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Castle Raid',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Factory',
                            Description = 'Function Only Sea 2',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Admin',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Dough King',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Soul Reaper',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Darkbeard',
                            Description = 'Function Only Sea 2',
                        },
                    },
                },
            },
            {
                {
                    'Get Items',
                    97087268377873,
                },
                {
                    {
                        'Toggle',
                        {
                            Title = 'Auto Superhuman',
                            Description = '',
                            Callback = function(p555)
                                AutoSPHM(p555)
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Electric Claw',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Death Step',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Dragon Talon',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Godhuman',
                            Description = '',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Swords',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Saber',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Pole',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Rengoku',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Yama',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Tushita',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Dual Cursed Katana',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Dragon Sword',
                            Description = '',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Gun',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Soul Guitar',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Dragon Storm',
                            Description = '',
                        },
                    },
                },
            },
            {
                {
                    'Fruits',
                    119340207028601,
                },
                {
                    {
                        'Button',
                        {
                            Title = 'Random Devil Fruits',
                            Callback = function()
                                u21.CommF_:InvokeServer('Cousin', 'Buy')
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Random Devil Fruits',
                            Callback = function(p556)
                                RandomDevilFruits(p556)
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Teleport Fruits',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Store Fruits',
                            Callback = function(p557)
                                AutoStoreFruit(p557)
                            end,
                        },
                    },
                },
            },
            {
                {
                    'Dungeon',
                    134391336101813,
                },
                {
                    {
                        'Dropdown',
                        {
                            Title = 'Select Raid',
                            Values = {
                                'Flame',
                                'Ice',
                                'Quake',
                                'Light',
                                'Dark',
                                'Spider',
                                'Rumble',
                                'Magma',
                                'Buddha',
                                'Sand',
                                'Phoenix',
                                'Dough',
                            },
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Open Dungoen Door',
                            Description = 'Auto Pick Color Screen On CircleIsland In Sea 2',
                            Callback = function()
                                p540:OpenDungoenDoor()
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Buy Chip',
                            Callback = function(p558)
                                AutoBuyChip(p558)
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Start Raid',
                            function(p559)
                                StartRaidFunc(p559)
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Kill Raid',
                            Description = 'Auto kill nearest mob on raid',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Next Islands',
                            Description = 'Auto next islands raid',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Awaken',
                            Description = '',
                        },
                    },
                },
            },
            {
                {
                    'LocalPlayer',
                    98870151777863,
                },
                {
                    {
                        'Dropdown',
                        {
                            Title = 'Select Stats',
                            Description = '',
                            Values = {
                                'Melee',
                                'Sword',
                                'Gun',
                                'Defense',
                                'Demon Fruit',
                            },
                        },
                    },
                    {
                        'Slider',
                        {
                            Title = 'Points',
                            Max = 999,
                            Min = 1,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Stats',
                            Callback = function(p560)
                                AddStats(p560)
                            end,
                        },
                    },
                },
            },
            {
                {
                    'Volcano Event',
                    71385541823712,
                },
                {},
            },
            {
                {
                    'Sea Event',
                    96788654458681,
                },
                {
                    {
                        'Button',
                        {
                            Title = 'No Frog',
                            Callback = function()
                                if game:GetService('Lighting'):FindFirstChild('LightingLayers') then
                                    game:GetService('Lighting'):FindFirstChild('LightingLayers'):Destroy()
                                end
                            end,
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Select Boats',
                            Values = {
                                'Guardian',
                                'Dinghy',
                                'PirateSloop',
                                'PirateBrigade',
                                'PirateGrandBrigade',
                                'MarineSloop',
                                'MarineBrigade',
                                'MarineGrandBrigade',
                                'Beast Hunter',
                            },
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Teleport To Your Local Boat',
                            Callback = function() end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Enable Speed Boats',
                            Description = '',
                        },
                    },
                    {
                        'Slider',
                        {
                            Title = 'Boat Speed',
                            Max = 400,
                            Min = 180,
                            Description = 'Set speed for your local boat',
                        },
                    },
                    {
                        'Dropdown',
                        {
                            Title = 'Select Zone',
                            Values = {
                                'Zone 1',
                                'Zone 2',
                                'Zone 3',
                                'Zone 4',
                                'Zone 5',
                                'Zone 6',
                                'Infinity',
                            },
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Start Auto Sea Events',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Shark and Fish Crew Member',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Terror Shark',
                            Description = '',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Pirates Ship',
                            Description = '',
                            OnChanged = function(p561)
                                if p561 then
                                    Library:Notify({
                                        Title = 'Script Warning',
                                        Content = 'Select Skills In Farm Config Tab',
                                        Duration = 8,
                                    })
                                end
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Ghost Ship',
                            Description = '',
                            OnChanged = function(p562)
                                if p562 then
                                    Library:Notify({
                                        Title = 'Script Warning',
                                        Content = 'Select Skills In Farm Config Tab',
                                        Duration = 8,
                                    })
                                end
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Sea Beast',
                            Description = '',
                            OnChanged = function(p563)
                                if p563 then
                                    Library:Notify({
                                        Title = 'Script Warning',
                                        Content = 'Select Skills In Farm Config Tab',
                                        Duration = 8,
                                    })
                                end
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Piranha',
                            Description = '',
                        },
                    },
                    {
                        'Section',
                        {
                            Title = 'Leviathan',
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Buy Spy Leviathan',
                            Callback = function()
                                u21.CommF_:InvokeServer('InfoLeviathan', '2')
                            end,
                        },
                    },
                    {
                        'Button',
                        {
                            Title = 'Craft Beast Hunter',
                            Callback = function()
                                u21.CommF_:InvokeServer('CraftItem', 'Check', 'LeviathanBoat')
                                u21.CommF_:InvokeServer('CraftItem', 'Craft', 'LeviathanBoat')
                            end,
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Find Leviathan',
                            Description = 'Auto finding leviathan boss',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Leviathan',
                            Description = 'Auto killing leviathan boss',
                            OnChanged = function(p564)
                                if p564 then
                                    Library:Notify({
                                        Title = 'Script Warning',
                                        Content = 'Select Skills In Farm Config Tab',
                                        Duration = 8,
                                    })
                                end
                            end,
                        },
                    },
                    {
                        'Seperator',
                        {
                            Title = 'Kitsune Events',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Find Kitsune Island',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Collect Azure Member',
                            Description = 'Function Only Sea 3',
                        },
                    },
                    {
                        'Toggle',
                        {
                            Title = 'Auto Trade Azure Member',
                            Description = 'Function Only Sea 3',
                        },
                    },
                },
            },
            {
                {
                    'Dojo Trainer',
                    91920478152016,
                },
                {},
            },
            {
                {
                    'Upgraded Race',
                    115164375298022,
                },
                {
                    {
                        'Toggle',
                        {
                            Title = 'Auto Upgraded Race V1 - V3',
                        },
                    },
                },
            },
            {
                {
                    'Settings',
                    139029577506800,
                },
                {
                    {
                        'Slider',
                        {
                            Title = 'Tween Speed',
                            Max = 350,
                            Min = 120,
                        },
                    },
                    {
                        'Slider',
                        {
                            Title = 'Bring Range',
                            Max = 1000,
                            Min = 180,
                        },
                    },
                    {
                        'Slider',
                        {
                            Title = 'Farm Distance',
                            Max = 50,
                            Min = 15,
                        },
                    },
                    {
                        'Slider',
                        {
                            Title = 'Farm Speed',
                            Max = 20,
                            Min = 4,
                        },
                    },
                },
            },
        }
        local v566 = next
        local v567 = v565
        local v568 = nil

        while true do
            local v569

            v568, v569 = v566(v565, v568)

            if v568 == nil then
                break
            end

            local v570 = v567[v568][1][1]
            local v571 = v567[v568][1][2]
            local v572 = Window:AddTab({
                Title = v570,
                Icon = 'rbxassetid://' .. v571,
            })

            print('[Zinner Hub] Created Tab ' .. tostring(v570))

            local v573 = next
            local v574 = v567[v568][2]
            local v575 = nil

            while true do
                local v576

                v575, v576 = v573(v574, v575)

                if v575 == nil then
                    break
                end
                if v576 ~= nil then
                    u15[v576[2].Title] = p540:BuildUI(v572, v576)
                end
            end
        end

        p540:Loop(function()
            while task.wait() do
                u15['Client Elapsed']:SetDesc(p540:GetTimeElapsed(u1))
                u15['Boss Spawned On Server']:SetDesc(p540:GetAllBossSpawned())
                u15['Current FPS : 60']:SetTitle('Current FPS : ' .. FPS)
                u15['Leviathan Status']:SetDesc(p540:SpyStatus())
                u15['Tyrant Of The Skies Status']:SetDesc(p540:StatusTikiBoss())
                u15['Elite Status']:SetDesc(p540:CheckSea(3) and ((p540:GetElites() and 'Spawned' or 'Not spawned') .. ' | Progress : ' .. u21.CommF_:InvokeServer('EliteHunter', 'Progress') or 'Only sea 3') or 'Only sea 3')
                u15['Race Status']:SetDesc('Race : ' .. p540:CheckRace())

                local v577 = p540

                u15['Moon Status']:SetDesc(p540:GetTime() .. ' | ' .. v577:GetMoonPhase() .. ' | Time to night : ' .. math.floor(18 - u21.Lighting.ClockTime) .. ' minutes')
            end
        end)
    end

    u11:BuildLibrary()
    u11:StartBuildFeature()
    u11:LoadCached()
    u11:LoopForSlowRemotes()
    u11:MakeFarm()

    local _ = true
end
