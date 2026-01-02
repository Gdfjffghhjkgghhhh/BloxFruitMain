getgenv().IslandVariable = {}

local MAP = workspace:GetAttribute("MAP")
getgenv().IslandVariable["CurrentSea"] = MAP:gsub("(%a+)(%d+)", "%1 %2")

if MAP == "Sea1" then
    getgenv().IslandVariable["IsSea1"] = true
    getgenv().IslandVariable["MaxLevelSea"] = 675
elseif MAP == "Sea2" then
    getgenv().IslandVariable["IsSea2"] = true
    getgenv().IslandVariable["MaxLevelSea"] = 1450
elseif MAP == "Sea3" then
    getgenv().IslandVariable["IsSea3"] = true
    getgenv().IslandVariable["MaxLevelSea"] = 2800
else 
    game.Players.LocalPlayer:Kick(string.format("Unsupported game | %s", tostring(game.PlaceId)))
    while task.wait() do end
end

getgenv().IslandVariable.MetaData = {}
getgenv().IslandVariable.RequestPlaces = {
    ["Sea 1"] = {
        ["Whirl Pool"] = CFrame.new(3864.6884765625, 6.736950397491455, -1926.214111328125),
        ["Sky Area 1"] = CFrame.new(-4607.82275, 872.54248, -1667.55688),
        ["Sky Area 2"] = CFrame.new(-7894.61767578125, 5547.1416015625, -380.29119873046875),
        ["Fish Man"] = CFrame.new(61163.8515625, 11.6796875, 1819.7841796875)
    },
    ["Sea 2"] = {
        ["Swan's room"] = CFrame.new(2284.912109375, 15.152046203613281, 905.48291015625),
        ["Mansion"] = CFrame.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
        ["Ghost Ship"] = CFrame.new(923.21252441406, 126.9760055542, 32852.83203125),
        ["Ghost Ship Entrance"] = CFrame.new(-6508.5581054688, 89.034996032715, -132.83953857422)
    },
    ["Sea 3"] = {
        ["Castle on the sea"] = CFrame.new(-5075.50927734375, 314.5155029296875, -3150.0224609375),
        ["Mansion"] = CFrame.new(-12548.998046875, 332.40396118164, -7603.1865234375),
        ["Hydra Island"] = CFrame.new(5661.53027, 1013.38354, -334.961914),
        ["Temple Of Time"] = CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875),
        ["Tiki Outpost"] = CFrame.new(-16813.439453125, 58.2912712097168, 304.87396240234375),
        ["Submerged Island"] = CFrame.new(11520.80078125, -2154.98583984375, 9829.513671875)
    }
}
getgenv().IslandVariable.RequestPlacesForFarm = {
    ["Sea 1"] = {
        ["Whirl Pool"] = CFrame.new(3864.6884765625, 6.736950397491455, -1926.214111328125),
        ["Sky Area 1"] = CFrame.new(-4607.82275, 872.54248, -1667.55688),
        ["Sky Area 2"] = CFrame.new(-7894.61767578125, 5547.1416015625, -380.29119873046875),
        ["Fish Man"] = CFrame.new(61163.8515625, 11.6796875, 1819.7841796875)
    },
    ["Sea 2"] = {
        ["Swan's room"] = CFrame.new(2284.912109375, 100.152046203613281, 905.48291015625),
        ["Mansion"] = CFrame.new(-288.46246337890625, 250.130615234375, 597.9988403320312),
        ["Ghost Ship"] = CFrame.new(923.21252441406, 126.9760055542, 32852.83203125),
        ["Ghost Ship Entrance"] = CFrame.new(-6508.5581054688, 120.034996032715, -132.83953857422)
    },
    ["Sea 3"] = {
        ["Castle on the sea"] = CFrame.new(-5075.50927734375, 188.5155029296875, -3150.0224609375),
        ["Mansion"] = CFrame.new(-12548.998046875, 332.40396118164, -7603.1865234375),
        ["Hydra Island"] = CFrame.new(5661.53027, 900.38354, -334.961914),
        ["Temple Of Time"] = CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875),
        ["Temple Of Time Back"] = CFrame.new(3029.064453125, 199.98846435546875, -7324.943359375),
        ["Tiki Outpost"] = CFrame.new(-16813.439453125, 20.2912712097168, 304.87396240234375),
        ["Submerged Island"] = CFrame.new(11520.80078125, -2154.98583984375, 9829.513671875)
    }
}

getgenv().IslandVariable.RequestPlacesName = {
    ["Sea 1"] = {
        "Whirl Pool",
        "Sky Area 1",
        "Sky Area 2",
        "Fish Man"
    },
    ["Sea 2"] = {
        "Swan's room",
        "Mansion",
        "Ghost Ship",
        "Ghost Ship Entrance"
    },
    ["Sea 3"] = {
        "Castle on the sea",
        "Mansion",
        "Hydra Island",
        "Temple Of Time",
        "Tiki Outpost",
        "Submerged Island"
    }
}

getgenv().IslandVariable.RaceEntrances = {
    ['Cyborg'] = CFrame.new(28492.52734375, 14895.9755859375, -422.6058654785156),
    ["Human"] = CFrame.new(29237.48828125, 14891.052734375, -204.71849060058594),
    ["Mink"] = CFrame.new(29020.9492, 14890.6328, -380.407867, -0.0712743625, 8.85832776e-08, -0.997456729, -3.87927805e-08, 1, 9.15811214e-08, 0.997456729, 4.52215083e-08, -0.0712743625),
    ["Fishman"] = CFrame.new(28224.0938, 14891.2402, -212.507004, 0.0963651389, -3.22392211e-08, 0.995346069, 3.76359344e-09, 1, 3.20255857e-08, -0.995346069, 6.59927724e-10, 0.0963651389),
    ["Ghoul"] = CFrame.new(28673.8555, 14890.334, 454.733765, -0.999887466, -3.48198981e-09, 0.0150030479, -3.48583518e-09, 1, -2.30164096e-10, -0.0150030479, -2.82436352e-10, -0.999887466),
    ["Skypiea"] = CFrame.new(28967.8086, 14919.2803, 234.668045, -0.00638482161, 3.80502279e-08, -0.999979615, 6.83823131e-08, 1, 3.76143845e-08, 0.999979615, -6.8140757e-08, -0.00638482161),
}

getgenv().IslandVariable.HalloweenPortals = {
    ["Port"] = CFrame.new(-342.4343566894531, 20.64616584777832, 5547.345703125),
    ["Tiki Outpostt"] = CFrame.new(-16456.462890625, 527.7887573242188, 436.2318115234375),
    ["Hydra Town"] = CFrame.new(5288.62158203125, 1005.3887939453125, 392.4296875),
    ["Chocolate Land"] = CFrame.new(379.1396179199219, 126.62691497802734, -12720.83984375),
    ["Haunted Castle"] = CFrame.new(-9515.0009765625, 142.1398468017578, 5534.05029296875),
    ["Peanut Land"] = CFrame.new(-2037.8001708984375, 9.712361335754395, -9948.2021484375),
    ["Great Tree"] = CFrame.new(4345.09375, 565.8427124023438, -6159.00439453125),
    ["Hydra Arena"] = CFrame.new(5020.94580078125, 173.56398010253906, -2011.18505859375),
    ["Ice Cream Land"] = CFrame.new(-917.5485229492188, 56.285797119140625, -10858.6962890625),
    ["Cake Land"] = CFrame.new(-2098.970458984375, 70.01806640625, -12128.359375),
    ["Turtle Center"] = CFrame.new(-12007.9794921875, 331.7582702636719, -9178.580078125),
}

getgenv().IslandVariable.HalloweenPortalsName = {
    "Tiki Outpost",
    "Hydra Town",
    "Chocolate Land",
    "Sea Castle",
    "Haunted Castle",
    "Port",
    "Peanut Land",
    "Great Tree",
    "Hydra Arena",
    "Ice Cream Land",
    "Cake Land",
    "Turtle Center"
}

getgenv().IslandVariable.PlacesName = {
    ["Sea 1"] = {
        "Pirate Start Island",
        "Marine Start Island",
        "Middle Town",
        "Jungle",
        "Shank's Room",
        "Pirate Village",
        "Desert",
        "Frozen Village",
        "Marine Fortress",
        "Mob Leader Place",
        "Prison",
        "Colosseum",
        "Skylands",
        "SkyArea1",
        "SkyArea2",
        "Sky Secret Temple",
        "Magma Village",
        "Fish Entrance Island",
        "UnderWater City Gate",
        "UnderWater City",
        "Fountain City"
    },
    ["Sea 2"] = {
        "First Spot",
        "Cafe",
        "Swan Mansion",
        "Swan Room",
        "Factory",
        "Colosseum",
        "Dark Arena",
        "Green bit",
        "Graveyard Island",
        "Snow Mountain",
        "Hot And Cold Island",
        "Cursed Ship Gate",
        "Cursed Ship",
        "Ice Castle",
        "Forgotten Island",
        "Usoap Island",
        "Minisky Island",
        "Indra Island"
    },
    ["Sea 3"] = {
        "Port Town",
        "Hydra Island",
        "Secret Temple",
        "Great Tree",
        "Castle on the sea",
        "Pineapple Town",
        "Mansion",
        "Floating Turtle",
        "Beautiful Pirate Gate",
        "Beautiful Pirate Domain",
        "Friendly Arena",
        "Haunted Castle",
        "Soul Reaper Raid Room",
        "Peanut Island",
        "Ice Cream Island",
        "Sea Of Treats",
        "Tiki Outpost",
        "Mob Trade Anchor",
        "Submerged Island"
    }
}

getgenv().IslandVariable.Places = {
    ["Sea 1"] = {
        ['Pirate Start Island'] = CFrame.new(781.37255859375, 5.7767753601074, 1437.2399902344),
        ['Marine Start Island'] = CFrame.new(-2606.2143554688, 6.7695031166077, 2043.04553222667),
        ['Middle Town'] = CFrame.new(-655.824158, 7.88708115, 1436.67908),
        ['Jungle'] = CFrame.new(-1334.1259765625, 11.852984428406, 502.03717041016),
        ["Shank's Room"] = CFrame.new(-1455.4440917969, 29.851997375488, -37.440139770508),
        ['Pirate Village'] = CFrame.new(-1187.3435058594, 4.7515587806702, 3809.2456054688),
        ['Desert'] = CFrame.new(1094.14587, 6.47350502, 4192.88721),
        ['Frozen Village'] = CFrame.new(1112.4229736328, 7.3036189079285, -1159.3383789062),
        ['Marine Fortress'] = CFrame.new(-4817.0161132812, 20.651899337769, 4368.0639648438),
        ['Mob Leader Place'] = CFrame.new(-2839.7548828125, 7.3262448310852, 5319.9428710938),
        ['Prison'] = CFrame.new(4874.8125, 5.6519904136658, 735.57012939453),
        ['Colosseum'] = CFrame.new(-1423.5014648438, 7.2882599830627, -2798.2961425781),
        ['Skylands'] = CFrame.new(-4970.21875, 717.707275, -2622.35449),
        ['SkyArea1'] = CFrame.new(-4731.9462890625, 845.27691650391, -1933.5628662109),
        ['SkyArea2'] = CFrame.new(-7884.7309570312, 5545.509765625, -383.34613037109),
        ['Sky Secret Temple'] = CFrame.new(-8018.662109375, 5609.9936523438, -1979.3544921875),
        ['Magma Village'] = CFrame.new(-5231.75879, 8.61593437, 8467.87695),
        ["Fish Entrance Island"] = CFrame.new(3868.501953125, 5.592349529266357, -1917.993408203125),
        ['UnderWater City Gate'] = CFrame.new(3853.0385742188, 5.3731479644775, -1919.4447021484),
        ['UnderWater City'] = CFrame.new(61092.36328125, 18.471633911133, 1711.1674804688),
        ['Fountain City'] = CFrame.new(5053.0297851562, 1.5012743473053, 4054.8439941406),
    },
    ["Sea 2"] = {
        ['First Spot'] = CFrame.new(-11.845784187317, 29.276727676392, 2768.9770507812),
        ['Cafe'] = CFrame.new(-384.03524780273, 73.020072937012, 353.2282409668),
        ['Swan Mansion'] = CFrame.new(-390.096313, 331.886475, 673.464966),
        ['Swan Room'] = CFrame.new(2302.19019, 15.1778421, 663.811035),
        ['Factory'] = CFrame.new(430.42569, 210.019623, -432.504791),
        ['Colosseum'] = CFrame.new(-1836.58191, 44.5890656, 1360.30652),
        ['Dark Arena'] = CFrame.new(3781.985107421875, 14.8506498336792, -3498.081298828125),
        ['Green bit'] = CFrame.new(-2304.93359375, 72.966117858887, -2782.6965332031),
        ['Graveyard Island'] = CFrame.new(-5377.3295898438, 8.9691047668457, -708.45489501953),
        ['Snow Mountain'] = CFrame.new(554.47235107422, 401.42199707031, -5364.732421875),
        ['Hot And Cold Island'] = CFrame.new(-5944.7875976562, 15.951756477356, -5114.8725585938),
        ['Cursed Ship Gate'] = CFrame.new(-6509.4169921875, 83.187019348145, -137.396774291998),
        ['Cursed Ship'] = CFrame.new(902.059143, 124.752518, 33071.8125),
        ['Ice Castle'] = CFrame.new(5662.44140625, 28.191165924072, -5982.9755859375),
        ['Forgotten Island'] = CFrame.new(-3043.31543, 238.881271, -10191.5791),
        ['Usoap Island'] = CFrame.new(4778.2431640625, 8.2086620330811, 2871.4936523438),
        ['Minisky Island'] = CFrame.new(-260.358917, 49325.7031, -35259.3008),
        ['Indra Island'] = CFrame.new(-27007.9363, 9.033, 466.6544),
    },
    ["Sea 3"] = {
        ['Port Town'] = CFrame.new(-527.2267456054688, 20.71989631652832, 5398.4462890625),
        ['Hydra Island'] = CFrame.new(5335.88623046875, 1004.7794799804688, 241.50193786621094),
        ['Secret Temple'] = CFrame.new(5231.6831054688, 7.3780846595764, 1102.6005859375),
        ['Great Tree'] = CFrame.new(2253.0600585938, 24.144220352173, -6405.6694335938),
        ['Castle on the sea'] = CFrame.new(-5026.3584, 323.515503, -2996.28442),
        ['Pineapple Town'] = CFrame.new(-11363.5166, 362.381439, -10327.9727),
        ['Mansion'] = CFrame.new(-12553.0595703125, 337.3874816894531, -7471.96142578125),
        --['Mansion(Insta TP)'] = game:GetService("Workspace").Map.Turtle.TradeTable.P1.CFrame,
        ['Floating Turtle'] = CFrame.new(-12001.6152, 1707.39319, -8789.03711),
        ['Beautiful Pirate Gate'] = CFrame.new(-11990.901367188, 331.80770874023, -8845.5888671875),
        ['Beautiful Pirate Domain'] = CFrame.new(5310.80957, 160.446838, 129.390533),
        ['Friendly Arena'] = CFrame.new(5220.28955, 72.8193436, -1500.86304),
        ['Haunted Castle'] = CFrame.new(-9530.61035, 200.860657, 5763.13477),
        ['Soul Reaper Raid Room'] = CFrame.new(-9522.0957, 315.89975, 6751.88818),
        ['Peanut Island'] = CFrame.new(-2087.0561523438, 11.722011566162, -10002.080078125),
        ['Ice Cream Island'] = CFrame.new(-851.74633789062, 65.819496154785, -10932.150390625),
        ['Sea Of Treats'] = CFrame.new(-1907.1773681640625, 9.565654754638672, -11539.8251953125),
        ["Tiki Outpost"] = CFrame.new(-16256.5566, 9.06057358, 430.995422),
        ["Mob Trade Anchor"] = CFrame.new(-16529.705078125, 108.0355224609375, 748.5739135742188),
        ["Submerged Island"] = CFrame.new(11317.915, -2139.20947, 9725.34863)
    }
}

getgenv().IslandVariable.MobCFrames = {
    ["Bandit"] = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125),
    ["Monkey"] = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209),
    ["Gorilla"] = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875),
    ["Pirate"] = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125),
    ["Brute"] = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875),
    ["Desert Bandit"] = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375),
    ["Desert Officer"] = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875),
    ["Snow Bandit"] = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125),
    ["Snowman"] = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625),
    ["Chief Petty Officer"] = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625),
    ["Sky Bandit"] = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625),
    ["Dark Master"] = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625),
    ["Prisoner"] = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781),
    ["Dangerous Prisoner"] = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375),
    ["Toga Warrior"] = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625),
    ["Gladiator"] = { CFrame.new(-1483, 36, -3188), CFrame.new(-1282, 36, -3059), CFrame.new(-1380, 36, -3405), CFrame.new(-1104, 36, -3260) },
    ["Military Soldier"] = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875),
    ["Military Spy"] = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375),
    ["Fishman Warrior"] = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625),
    ["Fishman Commando"] = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875),
    ["God's Guard"] = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375),
    ["Shanda"] = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531),
    ["Royal Squad"] = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875),
    ["Royal Soldier"] = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625),
    ["Galley Pirate"] = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875),
    ["Galley Captain"] = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375),
    ["Raider"] = {
        CFrame.new(265.562622, 38.0370674, 2497.43481),
        CFrame.new(475.562714, 37.8443794, 2433.43481),
        CFrame.new(549.562744140625, 37.84437942504883, 2190.4345703125),
        CFrame.new(241.5626220703125, 38.051422119140625, 2195.4345703125),
        CFrame.new(-607.43701171875, 37.84437942504883, 2202.43505859375),
        CFrame.new(-917.43701171875, 37.84437942504883, 2250.43505859375),
        CFrame.new(-904.3370361328125, 37.84437942504883, 2501.43505859375),
        CFrame.new(-612.43701171875, 37.84437942504883, 2557.43505859375)
    },
    ["Mercenary"] = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625),
    ["Swan Pirate"] = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625),
    ["Factory Staff"] = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875),
    ["Marine Lieutenant"] = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125),
    ["Marine Captain"] = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625),
    ["Zombie"] = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875),
    ["Vampire"] = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625),
    ["Snow Trooper"] = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875),
    ["Winter Warrior"] = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625),
    ["Lab Subordinate"] = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375),
    ["Horned Warrior"] = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375),
    ["Magma Ninja"] = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375),
    ["Lava Pirate"] = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875),
    ["Ship Deckhand"] = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375),
    ["Ship Engineer"] = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875),
    ["Ship Steward"] = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625),
    ["Ship Officer"] = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625),
    ["Arctic Warrior"] = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125),
    ["Snow Lurker"] = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375),
    ["Sea Soldier"] = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125),
    ["Water Fighter"] = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875),
    ["Pirate Millionaire"] = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375),
    ["Pistol Billionaire"] = CFrame.new(-187.3301544189453, 86.23987579345703, 6013.513671875),
    ["Dragon Crew Warrior"] = CFrame.new(6141.140625, 51.35136413574219, -1340.738525390625),
    ["Dragon Crew Archer"] = CFrame.new(6616.41748046875, 441.7670593261719, 446.0469970703125),
    ["Female Islander"] = CFrame.new(4685.25830078125, 735.8078002929688, 815.3425903320312),
    ["Giant Islander"] = CFrame.new(4729.09423828125, 590.436767578125, -36.97627639770508),
    ["Marine Commodore"] = CFrame.new(2286.0078125, 73.13391876220703, -7159.80908203125),
    ["Marine Rear Admiral"] = CFrame.new(3656.773681640625, 160.52406311035156, -7001.5986328125),
    ["Fishman Raider"] = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625),
    ["Fishman Captain"] = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625),
    ["Forest Pirate"] = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625),
    ["Mythological Pirate"] = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125),
    ["Jungle Pirate"] = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625),
    ["Musketeer Pirate"] = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375),
    ["Reborn Skeleton"] = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625),
    ["Living Zombie"] = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875),
    ["Demonic Soul"] = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625),
    ["Posessed Mummy"] = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625),
    ["Peanut Scout"] = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875),
    ["Peanut President"] = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875),
    ["Ice Cream Chef"] = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125),
    ["Ice Cream Commander"] = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625),
    ["Cookie Crafter"] = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375),
    ["Cake Guard"] = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875),
    ["Baking Staff"] = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375),
    ["Head Baker"] = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125),
    ["Cocoa Warrior"] = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125),
    ["Chocolate Bar Battler"] = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375),
    ["Sweet Thief"] = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625),
    ["Candy Rebel"] = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625),
    ["Candy Pirate"] = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875),
    ["Isle Outlaw"] = CFrame.new(-16479.900390625, 226.6117401123047, -300.3114318847656),
    ["Island Boy"] = CFrame.new(-16849.396484375, 192.86505126953125, -150.7853240966797),
    ["Sun-kissed Warrior"] = CFrame.new(-16347, 64, 984),
    ["Isle Champion"] = CFrame.new(-16602.1015625, 130.38734436035156, 1087.24560546875),
    ["Reef Bandits"] = CFrame.new(10951.1923828125, -2129.016357421875, 9204.857421875),
    ["Coral Pirate"] = CFrame.new(10719.966796875, -2057.72705078125, 9335.9169921875),
    ["Sea Chanter"] = CFrame.new(10627.85546875, -2020.623291015625, 10054.09375),
    ["Ocean Prophet"] = CFrame.new(10987.8828125, -1893.29638671875, 10142.75390625),
    ["High Disciple"] = CFrame.new(9810.33984375, -1942.426025390625, 9675.396484375),
    ["Grand Devotee"] = CFrame.new(9594.40234375, -1959.7091064453125, 9851.576171875),
}

getgenv().IslandVariable.TripleQuest = {
    ["Sea 1"] = {
        [150] = {
            ["Quest"] = "SkyQuest",
            QuestCFrame = CFrame.new(-4841.83447, 717.669617, -2623.96436),
            [1] = {
                Requirement = 150,
                Mob = "Sky Bandit",
                QuestCheck = "Sky Bandit",
            },
            [2] = {
                Requirement = 175,
                Mob = "Dark Master",
                QuestCheck = "Dark Master",
            },
        },
        [190] = {
            ["Quest"] = "PrisonerQuest",
            QuestCFrame = CFrame.new(5311.4677734375, 1.6553531885147095, 478.103271484375),
            [1] = {
                Requirement = 190,
                Mob = "Prisoner",
                QuestCheck = "Prisoner",
            },
            [2] = {
                Requirement = 210,
                Mob = "Dangerous Prisoner",
                QuestCheck = "Dangerous Prisoner",
            },
        },
        [250] = {
            ["Quest"] = "ColosseumQuest",
            QuestCFrame = CFrame.new(-1576.11743, 7.38933945, -2983.30762),
            [1] = {
                Requirement = 250,
                Mob = "Toga Warrior",
                QuestCheck = "Toga Warrior",
            },
            [2] = {
                Requirement = 275,
                Mob = "Gladiator",
                QuestCheck = "Gladiator",
            },
        },
        [300] = {
            ["Quest"] = "MagmaQuest",
            QuestCFrame = CFrame.new(-5316.55859, 12.2370615, 8517.2998),
            [1] = {
                Requirement = 300,
                Mob = "Military Soldier",
                QuestCheck = "Military Soldier",
            },
            [2] = {
                Requirement = 325,
                Mob = "Military Spy",
                QuestCheck = "Military Spy",
            },
            [3] = {
                Requirement = 350,
                Boss = "Magma Admiral",
                QuestCheck = "Magma Admiral",
                ["Quest"] = "MagmaQuest",
                QuestCFrame = CFrame.new(-5316.55859, 12.2370615, 8517.2998),
            },
        },
        [400] = {
            ["Quest"] = "FishmanQuest",
            QuestCFrame = CFrame.new(61122.5625, 18.4716396, 1568.16504),
            [1] = {
                Requirement = 375,
                Mob = "Fishman Warrior",
                QuestCheck = "Fishman Warrior",
            },
            [2] = {
                Requirement = 400,
                Mob = "Fishman Commando",
                QuestCheck = "Fishman Commando",
            },
            [3] = {
                Requirement = 425,
                Boss = "Fishman Lord",
                QuestCheck = "Fishman Lord",
                ["Quest"] = "FishmanQuest",
                QuestCFrame = CFrame.new(61122.5625, 18.4716396, 1568.16504),
            },
        },
        [475] = {
            ["Quest"] = "SkyExp1Quest",
            QuestCFrame = CFrame.new(-4720.853515625, 845.2769775390625, -1947.7744140625),
            [1] = {
                Requirement = 450,
                Mob = "God's Guard",
                QuestCheck = "God's Guard",
            },
            [2] = {
                Requirement = 475,
                Mob = "Shanda",
                QuestCheck = "Shanda",
            },
            [3] = {
                Requirement = 500,
                Boss = "Wysper",
                QuestCheck = "Wysper",
                ["Quest"] = "SkyExp1Quest",
                QuestCFrame = CFrame.new(-4720.853515625, 845.2769775390625, -1947.7744140625),
            },
        },
        [550] = {
            ["Quest"] = "SkyExp2Quest",
            QuestCFrame = CFrame.new(-7905.25732421875, 5636.03857421875, -1409.6732177734375),
            [1] = {
                Requirement = 525,
                Mob = "Royal Squad",
                QuestCheck = "Royal Squad",
            },
            [2] = {
                Requirement = 550,
                Mob = "Royal Soldier",
                QuestCheck = "Royal Soldier",
            },
            [3] = {
                Requirement = 575,
                Boss = "Thunder God",
                QuestCheck = "Thunder God",
                ["Quest"] = "SkyExp2Quest",
                QuestCFrame = CFrame.new(-7905.25732421875, 5636.03857421875, -1409.6732177734375),
            },    
        },
        [650] = {
            ["Quest"] = "FountainQuest",
            QuestCFrame = CFrame.new(5257.68505859375, 38.50114059448242, 4046.49560546875),
            [1] = {
                Requirement = 625,
                Mob = "Galley Pirate",
                QuestCheck = "Galley Pirate",
            },
            [2] = {
                Requirement = 650,
                Mob = "Galley Captain",
                QuestCheck = "Galley Captain",
            },
            [3] = {
                Requirement = 675,
                Boss = "Cyborg",
                QuestCheck = "Cyborg",
                ["Quest"] = "FountainQuest",
                QuestCFrame = CFrame.new(5257.68505859375, 38.50114059448242, 4046.49560546875),
            },    
        },
    },
    ["Sea 2"] = {
        [700] = {
            ["Quest"] = "Area1Quest",
            QuestCFrame = CFrame.new(-424.080078, 73.0055847, 1836.91589),
            [1] = {
                Requirement = 700,
                Mob = "Raider",
                QuestCheck = "Raider",
            },
            [2] = {
                Requirement = 725,
                Mob = "Mercenary",
                QuestCheck = "Mercenary",
            },
            [3] = {
                Requirement = 750,
                Boss = "Diamond",
                QuestCheck = "Diamond",
                ["Quest"] = "Area1Quest",
                QuestCFrame = CFrame.new(-424.080078, 73.0055847, 1836.91589),
            },       
        },
        [775] = {
            ["Quest"] = "Area2Quest",
            QuestCFrame = CFrame.new(934.597229, 73.3029785, 1250.96814),
            [1] = {
                Requirement = 775,
                Mob = "Swan Pirate",
                QuestCheck = "Swan Pirate",
            },
            [2] = {
                Requirement = 800,
                Mob = "Factory Staff",
                QuestCheck = "Factory Staff",
            },
            [3] = {
                Requirement = 800,
                Boss = "Jeremy",
                QuestCheck = "Jeremy",
                ["Quest"] = "Area2Quest",
                QuestCFrame = CFrame.new(934.597229, 73.3029785, 1250.96814),
            },       
        },
        [875] = {
            ["Quest"] = "MarineQuest3",
            QuestCFrame = CFrame.new(-2442.65015, 73.0511475, -3219.11523),
            [1] = {
                Requirement = 875,
                Mob = "Marine Lieutenant",
                QuestCheck = "Marine Lieutenant",
            },
            [2] = {
                Requirement = 900,
                Mob = "Marine Captain",
                QuestCheck = "Marine Captain",
            },
            [3] = {
                Requirement = 925,
                Boss = "Fajita",
                QuestCheck = "Fajita",
                ["Quest"] = "MarineQuest3",
                QuestCFrame = CFrame.new(-2442.65015, 73.0511475, -3219.11523),
            },         
        },
        [950] = {
            ["Quest"] = "ZombieQuest",
            QuestCFrame = CFrame.new(-5492.79395, 48.5151672, -793.710571),
            [1] = {
                Requirement = 950,
                Mob = "Zombie",
                QuestCheck = "Zombie",
            },
            [2] = {
                Requirement = 975,
                Mob = "Vampire",
                QuestCheck = "Vampire",
            },       
        },
        [1000] = {
            ["Quest"] = "SnowMountainQuest",
            QuestCFrame = CFrame.new(604.964966, 401.457062, -5371.69287),
            [1] = {
                Requirement = 1000,
                Mob = "Snow Trooper",
                QuestCheck = "Snow Trooper",
            },
            [2] = {
                Requirement = 1050,
                Mob = "Winter Warrior",
                QuestCheck = "Winter Warrior",
            }, 
        },
        [1100] = {
            ["Quest"] = "IceSideQuest",
            QuestCFrame = CFrame.new(-6060.10693, 15.9868021, -4904.7876),
            [1] = {
                Requirement = 1100,
                Mob = "Lab Subordinate",
                QuestCheck = "Lab Subordinate",
            },
            [2] = {
                Requirement = 1125,
                Mob = "Horned Warrior",
                QuestCheck = "Horned Warrior",
            },     
            [3] = {
                Requirement = 1150,
                Boss = "Smoke Admiral",
                QuestCheck = "Smoke Admiral",
                ["Quest"] = "IceSideQuest",
                QuestCFrame = CFrame.new(-6060.10693, 15.9868021, -4904.7876),
            },   
        },
        [1175] = {
            ["Quest"] = "FireSideQuest",
            QuestCFrame = CFrame.new(-5431.09473, 15.9868021, -5296.53223),
            [1] = {
                Requirement = 1175,
                Mob = "Magma Ninja",
                QuestCheck = "Magma Ninja",
            },
            [2] = {
                Requirement = 1200,
                Mob = "Lava Pirate",
                QuestCheck = "Lava Pirate",
            },     
            [3] = {
                Requirement = 1150,
                Boss = "Smoke Admiral",
                QuestCheck = "Smoke Admiral",
                ["Quest"] = "IceSideQuest",
                QuestCFrame = CFrame.new(-6060.10693, 15.9868021, -4904.7876),
            }, 
        },
        [1250] = {
            ["Quest"] = "ShipQuest1",
            QuestCFrame = CFrame.new(1037.80127, 125.092171, 32911.6016),
            [1] = {
                Requirement = 1250,
                Mob = "Ship Deckhand",
                QuestCheck = "Ship Deckhand",
            },
            [2] = {
                Requirement = 1275,
                Mob = "Ship Engineer",
                QuestCheck = "Ship Engineer",
            },     
        },
        [1300] = {
            ["Quest"] = "ShipQuest2",
            QuestCFrame = CFrame.new(968.80957, 125.092171, 33244.125),
            [1] = {
                Requirement = 1300,
                Mob = "Ship Steward",
                QuestCheck = "Ship Steward",
            },
            [2] = {
                Requirement = 1325,
                Mob = "Ship Officer",
                QuestCheck = "Ship Officer",
            },     
        },
        [1350] = {
            ["Quest"] = "FrostQuest",
            QuestCFrame = CFrame.new(5669.43506, 28.2117786, -6482.60107),
            [1] = {
                Requirement = 1350,
                Mob = "Arctic Warrior",
                QuestCheck = "Arctic Warrior",
            },
            [2] = {
                Requirement = 1375,
                Mob = "Snow Lurker",
                QuestCheck = "Snow Lurker",
            },      
            [3] = {
                Requirement = 1400,
                Boss = "Awakened Ice Admiral",
                QuestCheck = "Awakened Ice Admiral",
                ["Quest"] = "FrostQuest",
                QuestCFrame = CFrame.new(5669.43506, 28.2117786, -6482.60107),
            },
        },
        [1425] = {
            ["Quest"] = "ForgottenQuest",
            QuestCFrame = CFrame.new(-3053.89648, 236.881363, -10148.2324),
            [1] = {
                Requirement = 1425,
                Mob = "Sea Soldier",
                QuestCheck = "Sea Soldier",
            },
            [2] = {
                Requirement = 1450,
                Mob = "Water Fighter",
                QuestCheck = "Water Fighter",
            },      
            [3] = {
                Requirement = 1475,
                Boss = "Tide Keeper",
                QuestCheck = "Tide Keeper",
                ["Quest"] = "ForgottenQuest",
                QuestCFrame = CFrame.new(-3053.89648, 236.881363, -10148.2324),
            },   
        },
    },    
    ["Sea 3"] = {
        [1500] = {
            ["Quest"] = "PiratePortQuest",
            QuestCFrame = CFrame.new(-292.5743713378906, 43.79322052001953, 5583.04052734375),
            [1] = {
                Requirement = 1500,
                Mob = "Pirate Millionaire",
                QuestCheck = "Pirate Millionaire",
            },
            [2] = {
                Requirement = 1525,
                Mob = "Pistol Billionaire",
                QuestCheck = "Pistol Billionaire",
            },
            [3] = {
                Requirement = 1550,
                Boss = "Stone",
                QuestCheck = "Stone",
                ["Quest"] = "PiratePortQuest",
                QuestCFrame = CFrame.new(-292.5743713378906, 43.79322052001953, 5583.04052734375),
            },

        },
        [1575] = {
            ["Quest"] = "DragonCrewQuest",
            QuestCFrame = CFrame.new(5833.5776367188, 51.575191497803, -1102.7550048828),
            [1] = {
                Requirement = 1575,
                Mob = "Dragon Crew Warrior",
                QuestCheck = "Dragon Crew Warrior",
            },
            [2] = {
                Requirement = 1600,
                Mob = "Dragon Crew Archer",
                QuestCheck = "Dragon Crew Archer",
            },
        },
        
        [1625] = {
            ["Quest"] = "VenomCrewQuest",
            QuestCFrame = CFrame.new(5216.09521484375, 1004.1062622070312, 758.3895874023438),
            [1] = {
                Requirement = 1625,
                Mob = "Hydra Enforcer",
                QuestCheck = "Hydra Enforcer",
            },
            [2] = {
                Requirement = 1650,
                Mob = "Venomous Assailant",
                QuestCheck = "Venomous Assailant",
            },
            [3] = {
                Requirement = 1675,
                Boss = "Island Empress",
                QuestCheck = "Island Empress",
                ["Quest"] = "VenomCrewQuest",
                QuestCFrame = CFrame.new(5216.09521484375, 1004.1062622070312, 758.3895874023438),
            },
        },
        [1700] = {
            ["Quest"] = "MarineTreeIsland",
            QuestCFrame = CFrame.new(2179.2548828125, 28.701448440552, -6739.7299804688),
            [1] = {
                Requirement = 1700,
                Mob = "Marine Commodore",
                QuestCheck = "Marine Commodore",
            },
            [2] = {
                Requirement = 1725,
                Mob = "Marine Rear Admiral",
                QuestCheck = "Marine Rear Admiral",
            },
            [3] = {
                Requirement = 1750,
                Boss = "Kilo Admiral",
                QuestCheck = "Kilo Admiral",
                ["Quest"] = "MarineTreeIsland",
                QuestCFrame = CFrame.new(2179.2548828125, 28.701448440552, -6739.7299804688),
            },
        },
        [1775] = {
            ["Quest"] = "DeepForestIsland3",
            QuestCFrame = CFrame.new(-10580.998046875, 331.75863647461, -8758.193359375),
            [1] = {
                Requirement = 1775,
                Mob = "Fishman Raider",
                QuestCheck = "Fishman Raider",
            },
            [2] = {
                Requirement = 1800,
                Mob = "Fishman Captain",
                QuestCheck = "Fishman Captain",
            },
        },
        
        
        [1825] = {
            ["Quest"] = "DeepForestIsland",
            QuestCFrame = CFrame.new(-13231.467773438, 332.37414550781, -7626.6860351563),
            [1] = {
                Requirement = 1825,
                Mob = "Forest Pirate",
                QuestCheck = "Forest Pirate",
            },
            [2] = {
                Requirement = 1850,
                Mob = "Mythological Pirate",
                QuestCheck = "Mythological Pirate",
            },
            [3] = {
                Requirement = 1875,
                Boss = "Captain Elephant",
                QuestCheck = "Captain Elephant",
                ["Quest"] = "DeepForestIsland",
                QuestCFrame = CFrame.new(-13231.467773438, 332.37414550781, -7626.6860351563),
            },
        },
        [1900] = {
            ["Quest"] = "DeepForestIsland2",
            QuestCFrame = CFrame.new(-12683.189453125, 390.85668945313, -9902.15625),
            [1] = {
                Requirement = 1900,
                Mob = "Jungle Pirate",
                QuestCheck = "Jungle Pirate",
            },
            [2] = {
                Requirement = 1925,
                Mob = "Musketeer Pirate",
                QuestCheck = "Musketeer Pirate",
            },
            [3] = {
                Requirement = 1875,
                Boss = "Captain Elephant",
                QuestCheck = "Captain Elephant",
                ["Quest"] = "DeepForestIsland",
                QuestCFrame = CFrame.new(-13231.467773438, 332.37414550781, -7626.6860351563),
            },
        },
        [1975] = {
            ["Quest"] = "HauntedQuest1",
            QuestCFrame = CFrame.new(-9490.2793, 142.104858, 5565.8501),
            [1] = {
                Requirement = 1975,
                Mob = "Reborn Skeleton",
                QuestCheck = "Reborn Skeleton",
            },
            [2] = {
                Requirement = 2000,
                Mob = "Living Zombie",
                QuestCheck = "Living Zombie",
            },
        },
        [2025] = {
            ["Quest"] = "HauntedQuest2",
            QuestCFrame = CFrame.new(-9506.95313, 172.104858, 6074.63086),
            [1] = {
                Requirement = 2025,
                Mob = "Demonic Soul",
                QuestCheck = "Demonic Soul",
            },
            [2] = {
                Requirement = 2050,
                Mob = "Posessed Mummy",
                QuestCheck = "Posessed Mummy",
            },
        },
        [2075] = {
            ["Quest"] = "NutsIslandQuest",
            QuestCFrame = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875),
            [1] = {
                Requirement = 2075,
                Mob = "Peanut Scout",
                QuestCheck = "Peanut Scout",
            },
            [2] = {
                Requirement = 2100,
                Mob = "Peanut President",
                QuestCheck = "Peanut President",
            },
        },
        [2125] = {
            ["Quest"] = "IceCreamIslandQuest",
            QuestCFrame = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438),
            [1] = {
                Requirement = 2125,
                Mob = "Ice Cream Chef",
                QuestCheck = "Ice Cream Chef",
            },
            [2] = {
                Requirement = 2150,
                Mob = "Ice Cream Commander",
                QuestCheck = "Ice Cream Commander",
            },
            [3] = {
                Requirement = 2175,
                Boss = "Cake Queen",
                QuestCheck = "Cake Queen",
                ["Quest"] = "IceCreamIslandQuest",
                QuestCFrame = CFrame.new(-820.64825439453, 65.819526672363, -10965.79589843),
            },
        },
        [2200] = {
            ["Quest"] = "CakeQuest1",
            QuestCFrame = CFrame.new(-2021.32007, 37.7982254, -12028.7295),
            [1] = {
                Requirement = 2200,
                Mob = "Cookie Crafter",
                QuestCheck = "Cookie Crafter",
            },
            [2] = {
                Requirement = 2225,
                Mob = "Cake Guard",
                QuestCheck = "Cake Guard",
            },
            [3] = {
                Requirement = 2175,
                Boss = "Cake Queen",
                QuestCheck = "Cake Queen",
                ["Quest"] = "IceCreamIslandQuest",
                QuestCFrame = CFrame.new(-820.64825439453, 65.819526672363, -10965.79589843),
            },
        },
        [2250] = {
            ["Quest"] = "CakeQuest2",
            QuestCFrame = CFrame.new(-1927.91602, 37.7981339, -12842.5391),
            [1] = {
                Requirement = 2250,
                Mob = "Baking Staff",
                QuestCheck = "Baking Staff",
            },
            [2] = {
                Requirement = 2275,
                Mob = "Head Baker",
                QuestCheck = "Head Baker",
            },
            [3] = {
                Requirement = 2175,
                Boss = "Cake Queen",
                QuestCheck = "Cake Queen",
                ["Quest"] = "IceCreamIslandQuest",
                QuestCFrame = CFrame.new(-820.64825439453, 65.819526672363, -10965.79589843),
            },
        },
        [2300] = {
            ["Quest"] = "ChocQuest1",
            QuestCFrame = CFrame.new(231.2322235107422, 24.73427391052246, -12195.1396484375),
            [1] = {
                Requirement = 2300,
                Mob = "Cocoa Warrior",
                QuestCheck = "Cocoa Warrior",
            },
            [2] = {
                Requirement = 2325,
                Mob = "Chocolate Bar Battler",
                QuestCheck = "Chocolate Bar Battler",
            },
            [3] = {
                Requirement = 2175,
                Boss = "Cake Queen",
                QuestCheck = "Cake Queen",
                ["Quest"] = "IceCreamIslandQuest",
                QuestCFrame = CFrame.new(-820.64825439453, 65.819526672363, -10965.79589843),
            },
        },
        [2350] = {
            ["Quest"] = "ChocQuest2",
            QuestCFrame = CFrame.new(148.080322265625, 24.79383087158203, -12775.1650390625),
            [1] = {
                Requirement = 2350,
                Mob = "Sweet Thief",
                QuestCheck = "Sweet Thief",
            },
            [2] = {
                Requirement = 2375,
                Mob = "Candy Rebel",
                QuestCheck = "Candy Rebel",
            },
            [3] = {
                Requirement = 2175,
                Boss = "Cake Queen",
                QuestCheck = "Cake Queen",
                ["Quest"] = "IceCreamIslandQuest",
                QuestCFrame = CFrame.new(-820.64825439453, 65.819526672363, -10965.79589843),
            },
        },
        [2400] = {
            ["Quest"] = "CandyQuest1",
            QuestCFrame = CFrame.new(-1147.919677734375, 16.107261657714844, -14444.125),
            [1] = {
                Requirement = 2400,
                Mob = "Candy Pirate",
                QuestCheck = "Candy Pirate",
            },
            [2] = {
                Requirement = 2425,
                Mob = "Snow Demon",
                QuestCheck = "Snow Demon",
            },           
        },
        [2450] = {
            ["Quest"] = "CandyQuest1",
            QuestCFrame = CFrame.new(-1147.919677734375, 16.107261657714844, -14444.125),
            [1] = {
                Requirement = 2400,
                Mob = "Candy Pirate",
                QuestCheck = "Candy Pirate",
            },
            [2] = {
                Requirement = 2425,
                Mob = "Snow Demon",
                QuestCheck = "Snow Demon",
            },   
        },
        [2500] = {
            ["Quest"] = "TikiQuest2",
            QuestCFrame = CFrame.new(-16541.0215, 54.770813, 1051.46118, 0.0410757065, -0, -0.999156058, 0, 1, -0, 0.999156058, 0, 0.0410757065),
    
            [1] = {
                Requirement = 2500,
                QuestCheck = "Sun-kissed Warrior"
            },
            [2] = {
                Requirement = 2525,
                QuestCheck = "Isle Champion"
            }
        }
    },
}

getgenv().IslandVariable.MeleeArgs = {
    ["Dark Step"] = {"BuyBlackLeg"},
    ["Electro"] = {"BuyElectro"},
    ["Water Kung Fu"] = {"BuyFishmanKarate"},
    ["Dragon Breath"] = {"BlackbeardReward", "DragonClaw", "2"},
    ["Superhuman"] = {"BuySuperhuman"},
    ["Death Step"] = {"BuyDeathStep"},
    ["Sharkman Karate"] = {"BuySharkmanKarate"},
    ["Electric Claw"] = {"BuyElectricClaw"},
    ["Dragon Talon"] = {"BuyDragonTalon"},
    ["Godhuman"] = {"BuyGodhuman"},
    ["Sanguine Art"] = {"BuySanguineArt"},
}

getgenv().IslandVariable.MeleesName = {
    ["Sea 1"] = {
        "Dark Step",
        "Electro",
        "Water Kung Fu"
    },
    ["Sea 2"] = {
        "Dark Step",
        "Electro",
        "Water Kung Fu",
        "Dragon Breath",
        "Superhuman",
        "Death Step",
        "Sharkman Karate"
    },
    ["Sea 3"] = {
        "Dark Step",
        "Electro",
        "Water Kung Fu",
        "Dragon Breath",
        "Superhuman",
        "Death Step",
        "Sharkman Karate",
        "Electric Claw",
        "Dragon Talon",
        "Godhuman",
        "Sanguine Art"
    }
}
        
getgenv().IslandVariable.NPCsMelee = {
    ["Dark Step"] = {
        ["Sea 1"] = CFrame.new(-983.6179809570312, 12.449996948242188, 3990.462890625),
        ["Sea 2"] = CFrame.new(-4998.859375, 42.16721725463867, -4500.34130859375),
        ["Sea 3"] = CFrame.new(-5045.60205078125, 370.010986328125, -3182.304931640625),
    },
    ["Electro"] = {
        ["Sea 1"] = CFrame.new(-5382.7822265625, 12.550003051757812, -2148.818115234375),
        ["Sea 2"] = CFrame.new(-4949.130859375, 41.19999694824219, -4436.5400390625),
        ["Sea 3"] = CFrame.new(-4996.0517578125, 313.2139587402344, -3201.82373046875),
    },
    ["Water Kung Fu"] = {
        ["Sea 1"] = CFrame.new(61586.9609375, 19.587997436523438, 987.5910034179688),
        ["Sea 2"] = CFrame.new(-4989.2958984375, 43.21099853515625, -4457.02880859375),
        ["Sea 3"] = CFrame.new(-5023.9091796875, 371.0299987792969, -3191.45751953125),
    },
    ["Dragon Breath"] = {
        ["Sea 2"] = CFrame.new(699.0289916992188, 185.66099548339844, 654.89501953125),
        ["Sea 3"] = CFrame.new(-4981.162109375, 370.010986328125, -3208.3388671875),
    },
    ["Superhuman"] = {
        ["Sea 2"] = CFrame.new(1377.10546875, 247.45327758789062, -5189.97314453125),
        ["Sea 3"] = CFrame.new(-5004.72119140625, 370.42333984375, -3198.915283203125),
    },
    ["Death Step"] = {
        ["Sea 2"] = CFrame.new(6356.47216796875, 296.1000061035156, -6762.77099609375),
        ["Sea 3"] = CFrame.new(-4999.23046875, 314.0144958496094, -3221.572265625),
    },
    ["Sharkman Karate"] = {
        ["Sea 2"] = CFrame.new(-2599.621826171875, 238.19833374023438, -10315.998046875),
        ["Sea 3"] = CFrame.new(-4971.2060546875, 313.8869323730469, -3223.0791015625),
    },
    ["Electric Claw"] = {
        ["Sea 3"] = CFrame.new(-10371.4716796875, 330.7640075683594, -10131.419921875)
    },
    ["Dragon Talon"] = {
        ["Sea 3"] = CFrame.new(5661.89794921875, 1210.876953125, 863.176025390625)
    },
    ["Godhuman"] = {
        ["Sea 3"] = CFrame.new(-13774.0908203125, 333.7330017089844, -9879.9072265625)
    },
    ["Sanguine Art"] = {
        ["Sea 3"] = CFrame.new(-16515.06640625, 22.811996459960938, -188.572998046875)
    }
}

getgenv().IslandVariable.ShopItems = {
    ["Abilities"] = {
        {
            ["Name"] = "Geppo",
            ["Args"] = {"BuyHaki","Geppo"},
            ["Price"] = {
            ["Beli"] = 10000,
            },
        },
        {
            ["Name"] = "Buso",
            ["Args"] = {"BuyHaki","Buso"},
            ["Price"] = {
            ["Beli"] = 25000,
            },
        },
        {
            ["Name"] = "Soru",
            ["Args"] = {"BuyHaki","Soru"},
            ["Price"] = {
            ["Beli"] = 100000,
            },
        },
        {
            ["Name"] = "Ken",
            ["Args"] = {"KenTalk","Buy"},
            ["Price"] = {
            ["Beli"] = 150000,
            },
        },
    },
    ["Sword"] = {
        {
            ["Name"] = "Katana",
            ["Args"] = {"BuyItem","Katana"},
            ["Price"] = {
            ["Beli"] = 1000,
            },
        },
        {
            ["Name"] = "Cutlass",
            ["Args"] = {"BuyItem","Cutlass"},
            ["Price"] = {
            ["Beli"] = 1000,
            },
        },
        {
            ["Name"] = "Dual Katana",
            ["Args"] = {"BuyItem","Dual Katana"},
            ["Price"] = {
            ["Beli"] = 12000,
            },
        },
        {
            ["Name"] = "Iron Mace",
            ["Args"] = {"BuyItem","Iron Mace"},
            ["Price"] = {
            ["Beli"] = 25000,
            },
        },
        {
            ["Name"] = "Triple Katana",
            ["Args"] = {"BuyItem","Triple Katana"},
            ["Price"] = {
            ["Beli"] = 60000,
            },
        },
        {
            ["Name"] = "Pipe",
            ["Args"] = {"BuyItem","Pipe"},
            ["Price"] = {
            ["Beli"] = 100000,
            },
        },
        {
            ["Name"] = "Dual-Headed Blade",
            ["Args"] = {"BuyItem","Dual-Headed Blade"},
            ["Price"] = {
            ["Beli"] = 400000,
            },
        },
        {
            ["Name"] = "Bisento",
            ["Args"] = {"BuyItem","Bisento"},
            ["Price"] = {
            ["Beli"] = 1000000,
            },
        },
        {
            ["Name"] = "Soul Cane",
            ["Args"] = {"BuyItem","Soul Cane"},
            ["Price"] = {
            ["Beli"] = 750000,
            },
        },
        {
            ["Name"] = "Midnight Blade",
            ["Args"] = {"Ectoplasm","Buy",3},
            ["Price"] = {
            ["Ectoplasm"] = 100,
            },
        },
        {
            ["Name"] = "True Triple Katana",
            ["Args"] = {"MysteriousMan",2},
            ["Price"] = {
            },
        },
    },
    ["Gun"] = {
        {
            ["Name"] = "Slingshot",
            ["Args"] = {"BuyItem","Slingshot"},
            ["Price"] = {
            ["Beli"] = 5000,
            },
        },
        {
            ["Name"] = "Musket",
            ["Args"] = {"BuyItem","Musket"},
            ["Price"] = {
            ["Beli"] = 8000,
            },
        },
        {
            ["Name"] = "Flintlock",
            ["Args"] = {"BuyItem","Flintlock"},
            ["Price"] = {
            ["Beli"] = 10500,
            },
        },
        {
            ["Name"] = "Refined Slingshot",
            ["Args"] = {"BuyItem","Refined Slingshot"},
            ["Price"] = {
            ["Beli"] = 65000,
            },
        },
        {
            ["Name"] = "Cannon",
            ["Args"] = {"BuyItem","Cannon"},
            ["Price"] = {
            ["Beli"] = 100000,
            },
        },
        {
            ["Name"] = "Kabucha",
            ["Args"] = {"BlackbeardReward","Slingshot","2"},
            ["Price"] = {
            ["Fragment"] = 1500,
            },
        },
        {
            ["Name"] = "Bizarre Rifle",
            ["Args"] = {"Ectoplasm","Buy",1},
            ["Price"] = {
            ["Ectoplasm"] = 25,
            },
        },
    },
    ["Accessories"] = {
        {
            ["Name"] = "Black Cape",
            ["Args"] = {"BuyItem","Black Cape"},
            ["Price"] = {
                ["Beli"] = 50000,
            },
        },
        {
            ["Name"] = "Swordsman Hat",
            ["Args"] = {"BuyItem","Swordsman Hat"},
            ["Price"] = {
                ["Beli"] = 150000,
            },
        },
        {
            ["Name"] = "Tomoe Ring",
            ["Args"] = {"BuyItem","Tomoe Ring"},
            ["Price"] = {
                ["Beli"] = 500000,
            },
        },
        {
            ["Name"] = "Ghoul Mask",
            ["Args"] = {"Ectoplasm","Buy",2},
            ["Price"] = {
                ["Ectoplasm"] = 50,
            },
        },
    }
}

getgenv().IslandVariable.Material = {}
getgenv().IslandVariable.MaterialFarm = {
    CheckMob = {
        ["Magma Ore"] = {
            ["IsMob"] = function (Mob)
                if getgenv().IslandVariable["IsSea1"] then
                    if string.match(Mob.Name,"Military Soldier") or string.match(Mob.Name,"Military Spy") then
                        return true
                    end
                elseif getgenv().IslandVariable["IsSea2"] then
                    if string.match(Mob.Name,"Magma Ninja") or string.match(Mob.Name,"Lava Pirate") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = {CFrame.new(-5458.927734375, 22.050642013549805, -5419.67724609375),CFrame.new(-5377.33251953125, 18.274900436401367, -5125.76416015625)}
            
        },
        ["Ectoplasm"] = {
            ["IsMob"] = function(Mob)
                if string.match(Mob.Name,"Ship Deckhand") or string.match(Mob.Name,"Ship Engineer") or string.match(Mob.Name,"Ship Steward") or string.match(Mob.Name,"Ship Officer") then
                    return true
                end
                return false
            end,
            ["Pos"] = CFrame.new(923.2125244140625, 126.97600555419922, 32852.83203125),

        },
        ["Demonic Wisp"] = {
            ["IsMob"] = function(Mob)
                if string.match(Mob.Name,"Reborn Skeleton") or string.match(Mob.Name,"Living Zombie") or string.match(Mob.Name,"Demonic Soul") or string.match(Mob.Name,"Posessed Mummy") and Mob:FindFirstChild("HumanoidRootPart") and (Mob:FindFirstChild("HumanoidRootPart").Position - Vector3.new(-8736.5771484375, 143.10482788085938, 6034.9375)).magnitude < 3500 then
                    return true
                end
                return false
            end,
            ["Pos"] = CFrame.new(-9501.3447265625, 172.1398468017578, 6036.0341796875),
        },
        ["Bones"] = {
            ["IsMob"] = function(Mob)
                if string.match(Mob.Name,"Reborn Skeleton") or string.match(Mob.Name,"Living Zombie") or string.match(Mob.Name,"Demonic Soul") or string.match(Mob.Name,"Posessed Mummy") and Mob:FindFirstChild("HumanoidRootPart") and (Mob:FindFirstChild("HumanoidRootPart").Position - Vector3.new(-8736.5771484375, 143.10482788085938, 6034.9375)).magnitude < 3500 then
                    return true
                end
                return false
            end,
            ["Pos"] = CFrame.new(-9501.3447265625, 172.1398468017578, 6036.0341796875),
        },
        ["Dragon Scale"] = {
            ["IsMob"] = function (Mob)
                if string.match(Mob.Name,"Dragon Crew Archer") or string.match(Mob.Name,"Dragon Crew Warrior") then
                    return true
                end
                return false
            end,
            ["Pos"] = {CFrame.new(6562.64111328125, 148.20350646972656, -712.1854858398438),
            CFrame.new(6525.68896484375, 378.2054138183594, 16.12466049194336),
            CFrame.new(4143.9814453125, 51.48188018798828, -1238.462890625)}
        } ,
        ["Angel Wings"] = {
            ["IsMob"] = function (Mob)
                if string.match(Mob.Name,"Shanda") or string.match(Mob.Name,"Royal Squad") or string.match(Mob.Name,"Royal Soldier") then
                    return true
                end
                return false
            end,
            ["Pos"] = {CFrame.new(-7640.81103515625, 5545.49169921875, -535.966064453125),
            CFrame.new(-7760.857421875, 5634.2216796875, -1555.6251220703125)}
        } ,
        
        ["Mystic Droplet"] = {
            ["IsMob"] = function(Mob)
                if string.match(Mob.Name,"Sea Soldier") or string.match(Mob.Name,"Water Fighter") then
                    return true
                end
                return false
            end,
            ["Pos"] = CFrame.new(-3246.47509765625, 298.66448974609375, -10551.6650390625),
        },
            
        ["Fish Tail"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea3"] then
                    if string.match(Mob.Name,"Fishman Raider") or string.match(Mob.Name,"Fishman Captain") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = CFrame.new(-10918.5673828125, 331.76263427734375, -8698.3408203125)
        },     
        ["Radioactive Material"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea2"] then
                    if string.match(Mob.Name,"Factory Staff") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = {CFrame.new(-16.391239166259766, 148.9493408203125, -182.6639862060547),CFrame.new(542.0455322265625, 72.95976257324219, 22.46308708190918)}
        },
        ["Vampire Fang"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea2"] then
                    if string.match(Mob.Name,"Vampire") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = CFrame.new(-6022.30810546875, 6.402711391448975, -1302.591552734375),
        },
        ["Conjured Cocoa"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea3"] then
                    if string.match(Mob.Name,"Sweet Thief") or string.match(Mob.Name,"Candy Rebel") or string.match(Mob.Name,"Chocolate Bar Battler") or string.match(Mob.Name,"Cocoa Warrior")   then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = CFrame.new(233.32058715820312, 74.74764251708984, -12498.2861328125),
        },
        ["Mini Tusk"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea3"] then
                    if string.match(Mob.Name,"Forest Pirate") or string.match(Mob.Name,"Mythological Pirate") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = CFrame.new(-13527.8076171875, 523.6344604492188, -7424.10693359375),
        },
        ["Scrap Metal"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea3"] then
                    if string.match(Mob.Name,"Pirate Millionaire") or string.match(Mob.Name,"Pistol Billionaire") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = {CFrame.new(-315.9371337890625, 73.87043762207031, 5939.98193359375),
                CFrame.new(-289.22113037109375, 43.854217529296875, 5574.4697265625),
                CFrame.new(-636.85888671875, 57.015052795410156, 5626.41748046875),
                CFrame.new(-807.3641357421875, 84.8128890991211, 5991.45166015625),
            }
        },
        ["Leather"] = {
            ["IsMob"] = function(Mob)
                if getgenv().IslandVariable["IsSea3"] then
                    if string.match(Mob.Name,"Pirate Millionaire") or string.match(Mob.Name,"Pistol Billionaire") then
                        return true
                    end
                end
                return false
            end,
            ["Pos"] = {CFrame.new(-315.9371337890625, 73.87043762207031, 5939.98193359375),CFrame.new(-289.22113037109375, 43.854217529296875, 5574.4697265625)}
        }
    },
    ["CheckBoss"] =  {"Meteorite",["Meteorite"]={
        ["IsBoss"] = function()
            if getgenv().IslandVariable["IsSea2"] then
                if game.Workspace.Enemies:FindFirstChild("Fajita") then
                    return game.Workspace.Enemies:FindFirstChild("Fajita")
                end
            end
            return false
        end
    }}
}

getgenv().IslandVariable.MaterialName = {
    "Mystic Droplet",
    "Magma Ore",
    "Fish Tail",
    "Vampire Fang",
    "Dragon Scale",
    "Radioactive Material",
    "Conjured Cocoa",
    "Ectoplasm",
    "Mini Tusk",
    "Demonic Wisp",
    "Meteorite",
    "Angel Wings",
    "Scrap Metal",
    "Leather"
}

getgenv().IslandVariable.MaterialSeaChecker = {
    ["Leather"] = "Sea 3",
    ["Scrap Metal"] = "Sea 3",
    ["Mystic Droplet"] = "Sea 2",
    ["Magma Ore"] = "Sea 2",
    ["Ectoplasm"] = "Sea 2",
    ["Bones"]= "Sea 3",
    ["Demonic Wisp"]= "Sea 3",
    ["Fish Tail"] = "Sea 3",
    ["Dragon Scale"] = "Sea 3",
    ["Radioactive Material"] = "Sea 2",
    ["Mini Tusk"] = "Sea 3",
    ["Vampire Fang"] = "Sea 2",
    ["Meteorite"] = "Sea 2",
    ["Conjured Cocoa"] = "Sea 3",
    ["Angel Wings"] = "Sea 1",
}

getgenv().IslandVariable.RaceEntrances = {
    ['Cyborg'] = CFrame.new(28492.52734375, 14895.9755859375, -422.6058654785156),
    ["Human"] = CFrame.new(29237.48828125, 14891.052734375, -204.71849060058594),
    ["Mink"] = CFrame.new(29020.9492, 14890.6328, -380.407867, -0.0712743625, 8.85832776e-08, -0.997456729, -3.87927805e-08, 1, 9.15811214e-08, 0.997456729, 4.52215083e-08, -0.0712743625),
    ["Fishman"] = CFrame.new(28224.0938, 14891.2402, -212.507004, 0.0963651389, -3.22392211e-08, 0.995346069, 3.76359344e-09, 1, 3.20255857e-08, -0.995346069, 6.59927724e-10, 0.0963651389),
    ["Ghoul"] = CFrame.new(28673.8555, 14890.334, 454.733765, -0.999887466, -3.48198981e-09, 0.0150030479, -3.48583518e-09, 1, -2.30164096e-10, -0.0150030479, -2.82436352e-10, -0.999887466),
    ["Skypiea"] = CFrame.new(28967.8086, 14919.2803, 234.668045, -0.00638482161, 3.80502279e-08, -0.999979615, 6.83823131e-08, 1, 3.76143845e-08, 0.999979615, -6.8140757e-08, -0.00638482161),
}

getgenv().IslandVariable.PlacesPosition = {
    SpawnRipIndra = CFrame.new(-5564.91406, 313.950531, -2666.69287, -0.892237544, -1.03326805e-08, -0.451566368, 1.39742387e-08, 1, -5.04931776e-08, 0.451566368, -5.13622034e-08, -0.892237544),
    CenterCastle = Vector3.new(-5581.2353515625, 313.76556396484375, -3064.094970703125),
    DefaultSeaPosition = Vector3.new(0, -10010, 0)
}

getgenv().IslandVariable.AllFruitKeys = {"Z","X","C","V","F"}
getgenv().IslandVariable.Weapon600Mas = {}
getgenv().IslandVariable.GatesInfo = {
    ["Castle"] = {
        CanInstaTP = true,
        Pos = Vector3.new(-5069.12158203125, 314.5155029296875, -3000.46728515625),
    },
    ["Hydra"] = {
        CanInstaTP = true,
        Hitbox = function()
            return game:GetService("Workspace").Map["Boat Castle"].MapTeleportB.Hitbox
        end,
        Pos = Vector3.new(5657.0947265625, 1013.0795288085938, -340.00445556640625),
    },
    ["Mansion"] = {
        CanInstaTP = true,
        Pos = Vector3.new(-12547.1396484375, 337.16827392578125, -7471.8818359375)
    }
}

getgenv().IslandVariable.NPCs = {}
getgenv().IslandVariable.NPCInstances = {}
getgenv().IslandVariable.BlacklistNpcName = {"Boat Dealer","Quest Giver","Dealer","Set Home Point"}

for _, NPC in pairs(workspace.NPCs:GetChildren()) do 
    local IsBlacklist = false
    for _, BlacklistNPC in pairs(getgenv().IslandVariable.BlacklistNpcName) do 
        if string.find(NPC.Name, BlacklistNPC) then
            IsBlacklist = true
            break 
        end
    end
    if (
        NPC:GetAttribute("FloorPos") 
        - getgenv().IslandVariable.PlacesPosition.DefaultSeaPosition
    ).magnitude < 100 then
        IsBlacklist = true 
    end
    if not IsBlacklist then
        table.insert(getgenv().IslandVariable.NPCs, NPC.Name) 
        getgenv().IslandVariable.NPCInstances[NPC.Name] = NPC
    end
end

for _, NPC in pairs(game:GetService("ReplicatedStorage").NPCs:GetChildren()) do 
    local IsBlacklist = false
    for _, BlacklistNPC in pairs(getgenv().IslandVariable.BlacklistNpcName) do 
        if string.find(NPC.Name, BlacklistNPC) then
            IsBlacklist = true
            break 
        end
    end
    if (
        NPC:GetAttribute("FloorPos")
        - getgenv().IslandVariable.PlacesPosition.DefaultSeaPosition
    ).magnitude < 100 then
        IsBlacklist = true 
    end
    if not IsBlacklist then
        table.insert(getgenv().IslandVariable.NPCs, NPC.Name) 
        getgenv().IslandVariable.NPCInstances[NPC.Name] = NPC
    end
end

getgenv().IslandVariable.SkillsV3Name ={
    ["Mink"] = "Agility",
    ["Skypiea"] = "Heavenly Blood",
    ["Ghoul"] = "Heightened Senses",
    ["Fishman"] = "Water Body",
    ["Cyborg"] = "Energy Core",
    ["Human"] = "Last Resort"
}

getgenv().IslandVariable.BossQuest = {
    ["Sea 1"] = {
        ["The Gorilla King"] = {
            Quest = "JungleQuest",
            Require  = 25,
            LvQuest = 3,
            Pos = CFrame.new(-1604.12012, 36.8521118, 154.23732),
        },
        ["Bobby"] = {
            Quest = "BuggyQuest1",
            Require  = 55,
            LvQuest = 3,
            Pos = CFrame.new(-1139.59717, 4.75205183, 3825.16211),
        },
        ["Yeti"] = {
            Quest = "SnowQuest",
            LvQuest = 3,
            Require  = 110,
            Pos = CFrame.new(1384.90247, 87.3078308, -1296.6825),
        },
        ["Vice Admiral"] = {
            Quest = "MarineQuest2",
            LvQuest = 2,
            Require  = 130,
            Pos = CFrame.new(-5035.42285, 28.6520386, 4324.50293),
        },
        ["Warden"] = {
            Quest = "ImpelQuest",
            LvQuest = 1,
            Require  = 220,
            Pos = CFrame.new(5189.8603515625, 3.5371694564819336, 689.46923828125),
        },
        ["Chief Warden"] = {
            Quest = "ImpelQuest",
            LvQuest = 2,
            Require  = 230,
            Pos = CFrame.new(5189.8603515625, 3.5371694564819336, 689.46923828125),
        },
        ["Swan"] = {
            Quest = "ImpelQuest",
            LvQuest = 3,
            Require  = 230,
            Pos = CFrame.new(5189.8603515625, 3.5371694564819336, 689.46923828125),
        },
        ["Magma Admiral"] = {
            Quest = "MagmaQuest",
            LvQuest = 3,
            Require  = 350,
            Pos = CFrame.new(-5317.07666, 12.2721891, 8517.41699),
        },
        ["Fishman Lord"] = {
            Quest = "FishmanQuest",
            LvQuest = 3,
            Require  = 425,
            Pos = CFrame.new(61123.0859, 18.5066795, 1570.18018),
        },
        ["Wysper"] = {
            Quest = "SkyExp1Quest",
            LvQuest = 3,
            Require  = 500,
            Pos = CFrame.new(-7862.94629, 5545.52832, -379.833954),
        },
        ["Thunder God"] = {
            Quest = "SkyExp2Quest",
            LvQuest = 3,
            Require  = 575,
            Pos = CFrame.new(-7902.78613, 5635.99902, -1411.98706),
        },
        ["Cyborg"] = {
            Quest = "FountainQuest",
            LvQuest = 3,
            Require  = 675,
            Pos = CFrame.new(-5253.54834, 38.5361786, 4050.45166),
        },
    },
    ["Sea 2"] = {
        ["Diamond"] = {
            Quest = "Area1Quest",
            LvQuest = 3,
            Require  = 750,
            Pos = CFrame.new(-424.080078, 73.0055847, 1836.91589),
        },
        ["Jeremy"] = {
            Quest = "Area2Quest",
            LvQuest = 3,
            Require  = 850,
            Pos = CFrame.new(632.698608, 73.1055908, 918.666321),
        },
        ["Fajita"] = {
            Quest = "MarineQuest3",
            LvQuest = 3,
            Require  = 925,
            Pos = CFrame.new(-2442.65015, 73.0511475, -3219.11523),          
        },
        ["Smoke Admiral"] = {
            Quest = "IceSideQuest",
            LvQuest = 3,
            Require  = 1150,
            Pos = CFrame.new(-6059.96191, 15.9868021, -4904.7373),          
        },
        ["Awakened Ice Admiral"] = {
            Quest = "FrostQuest",
            LvQuest = 3,
            Require  = 1400,
            Pos = CFrame.new(5669.33203, 28.2118053, -6481.55908),  
        },
        ["Tide Keeper"] = {
            Quest = "ForgottenQuest",
            LvQuest = 3,
            Require  = 1475,
            Pos = CFrame.new(-3053.89648, 236.881363, -10148.2324),  
        },
    },
    ["Sea 3"]  = {
        ["Stone"] = {
            Quest = "PiratePortQuest",
            LvQuest = 3,
            Require  = 1550,
            Pos = CFrame.new(-288.003815, 43.7675667, 5573.12012),  
        },
        ["Island Empress"]  = {
            Quest = "AmazonQuest2",
            LvQuest = 3,
            Require  = 1675,
            Pos = CFrame.new(5444.14355, 601.603821, 751.306763),  
        },
        ["Kilo Admiral"] = {
            Quest = "MarineTreeIsland",
            LvQuest = 3,
            Require  = 1750,
            Pos = CFrame.new(2223.3645, 28.7049141, -6719.18408),
        },
        ["Captain Elephant"] = {
            Quest = "DeepForestIsland",
            LvQuest = 3,
            Require  = 1875,
            Pos = CFrame.new(-13231.1602, 333.744446, -7624.40723),
        },
        ["Cake Queen"] = {
            Quest = "IceCreamIslandQuest",
            LvQuest = 3,
            Require  = 1875,
            Pos = CFrame.new(-821.71612548828, 65.819519042969, -10965.169921875),
        }
    },
}   

getgenv().IslandVariable.AllBoss = {
    ["Sea 1"] = {
        "Saber Expert","The Saw","Bobby","The Gorilla King","Yeti","Vice Admiral",
        "Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper",
        "Thunder God","Cyborg"
    },
    ["Sea 2"] =  {
        "Diamond","Jeremy","Fajita","Smoke Admiral","Awakened Ice Admiral","Tide Keeper",
        "Don Swan","Cursed Captain", "Order"
    },
    ["Sea 3"] = {
        "Stone","Island Empress","Kilo Admiral","Captain Elephant","Cake Queen","Beautiful Pirate",
        "Soul Reaper","rip_indra True Form","Cake Prince","Dough King", "Tyrant of the Skies", "Unbound Werewolf"
    },
}

getgenv().IslandVariable.AutoBlackSmithv1 = {
    ["Dark Blade"] = {
        ["Magma Ore"] = 10,
        ["Dragon Scale"] = 15,
        ["Dark Fragment"] = 1,
    },
    ["Cursed Dual Katana"] = {
        ["Scrap Metal"] = 60,
        ["Mini Tusk"] = 10,
        ["Demonic Wisp"] = 10,
    },
    ["Hallow Scythe"] = {
        ["Scrap Metal"] = 25,
        ["Bones"] = 800,
        ["Demonic Wisp"] = 8,
    },
    ["True Triple Katana"] = {
        ["Leather"] = 50,
        ["Mystic Droplet"] = 20,
        ["Dragon Scale"] = 5,
    },
    ["Spikey Trident"] = {
        ["Scrap Metal"] = 25,
        ["Conjured Cocoa"] = 8,
        ["Mystic Droplet"] = 5,
    },
    ["Koko"] = {
        ["Scrap Metal"] = 15,
        ["Vampire Fang"] = 10,
    },
    ["Tushita"] = {
        ["Leather"] = 6,
        ["Mini Tusk"] = 20,
    },
    ["Pole (2nd Form)"] = {
        ["Scrap Metal"] = 12,
        ["Mystic Droplet"] = 10,
        ["Fish Tail"] = 15,
    },
    ["Saddi"] = {
        ["Leather"] = 10,
        ["Mystic Droplet"] = 8,
    },
    ["Saber"] = {
        ["Scrap Metal"] = 10,
        ["Radioactive Material"] = 5,
        ["Magma Ore"] = 10,
    },
    ["Yama"] = {
        ["Leather"] = 6,
        ["Mini Tusk"] = 20,
    },
    ["Midnight Blade"] = {
        ["Scrap Metal"] = 15,
        ["Ectoplasm"] = 40,
    },
    ["Buddy Sword"] = {
        ["Leather"] = 25,
        ["Conjured Cocoa"] = 8,
        ["Mystic Droplet"] = 5,
    },
    ["Shisui"] = {
        ["Leather"] = 10,
        ["Mystic Droplet"] = 8,
    },
    ["Bisento"] = {
        ["Scrap Metal"] = 15,
        ["Angel Wings"] = 12,
        ["Magma Ore"] = 10,
    },
    ["Pole (1st Form)"] = {
        ["Scrap Metal"] = 20,
        ["Angel Wings"] = 10,
        ["Radioactive Material"] = 10,
    },
    ["Canvander"] = {
        ["Leather"] = 20,
        ["Dragon Scale"] = 6,
    },
    ["Dark Dagger"] = {
        ["Scrap Metal"] = 10,
        ["Dragon Scale"] = 8,
        ["Dark Fragment"] = 1,
    },
    ["Rengoku"] = {
        ["Vampire Fang"] = 8,
        ["Scrap Metal"] = 15,
        ["Magma Ore"] = 20,
    },
    ["Wando"] = {
        ["Leather"] = 10,
        ["Mystic Droplet"] = 8,
    },
    ["Longsword"] = {
        ["Scrap Metal"] = 10,
        ["Radioactive Material"] = 10,
    },
    ["Pipe"] = {
        ["Scrap Metal"] = 10,
        ["Fish Tail"] = 12,
    },
    ["Dragon Trident"] = {
        ["Leather"] = 10,
        ["Dragon Scale"] = 10,
    },
    ["Jitte"] = {
        ["Scrap Metal"] = 15,
        ["Vampire Fang"] = 10,
    },
    ["Dual-Headed Blade"] = {
        ["Scrap Metal"] = 10,
        ["Fish Tail"] = 12,
    },
    ["Gravity Cane"] = {
        ["Scrap Metal"] = 10,
        ["Meteorite"] = 3,
    },
    ["Soul Cane"] = {
        ["Leather"] = 20,
        ["Radioactive Material"] = 5,
    },
    ["Iron Mace"] = {
        ["Leather"] = 10,
        ["Angel Wings"] = 10,
    },
    ["Shark Saw"] = {
        ["Leather"] = 12,
    },
    ["Twin Hooks"] = {
        ["Leather"] = 20,
        ["Mini Tusk"] = 8,
        ["Fish Tail"] = 10,
    },
    ["Triple Katana"] = {
        ["Leather"] = 15,
        ["Scrap Metal"] = 15,
    },
    ["Skull Guitar"] = {
        ["Magma Ore"] = 10,
        ["Dragon Scale"] = 15,
        ["Dark Fragment"] = 1,
    },
    ["Kabucha"] = {
        ["Leather"] = 50,
        ["Dragon Scale"] = 15,
        ["Vampire Fang"] = 3,
    },
    ["Serpent Bow"] = {
        ["Meteorite"] = 1,
        ["Scrap Metal"] = 10,
        ["Vampire Fang"] = 10,
    },
    ["Bazooka"] = {
        ["Magma Ore"] = 10,
        ["Dragon Scale"] = 15,
        ["Dark Fragment"] = 1,
    },
    ["Cannon"] = {
        ["Leather"] = 5,
        ["Fish Tail"] = 5,
        ["Magma Ore"] = 5,
    },
    ["Refined Slingshot"] = {
        ["Scrap Metal"] = 10,
        ["Angel Wings"] = 10,
    },
    ["Bizarre Rifle"] = {
        ["Leather"] = 20,
        ["Angel Wings"] = 10,
        ["Magma Ore"] = 5,
    },
    ["Musket"] = {
        ["Leather"] = 5,
        ["Fish Tail"] = 5,
    },
    ["Flintlock"] = {
        ["Leather"] = 5,
        ["Magma Ore"] = 5,
    },  
    ["Refined Musket"] = {
        ["Scrap Metal"] = 10,
        ["Fish Tail"] = 10,
    },
    ["Acidum Rifle"] = {
        ["Leather"] = 10,
        ["Vampire Fang"] = 8,
    },
}

getgenv().IslandVariable.BypassTPLocations = {
    ["Tiki Outpost"] = {
        {"Tiki", CFrame.new(-16217.7568, 12.2879944, 446.407501, 0, 0, -1, 0, 1, 0, 1, 0, 0)},
        {"Tiki", CFrame.new(-16228.0801, 12.3639984, 446.407501, 0, 0, -1, 0, 1, 0, 1, 0, 0)}
    },
    ["Submerged Island"] = {
        {"SubmergedIsland", CFrame.new(11280.4717, -2131.5105, 9908, 0, 0, 1, 0, 1, 0, -1, 0, 0)},
        {"SubmergedIsland", CFrame.new(11320.6982, -2135.34375, 9726.69824, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)}
    },
    ["Port Town"] = {
        {"Default", CFrame.new(-334.179077, 19.529007, 5520.13672, 0.965929627, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, 0.965929627)},
        {"Default", CFrame.new(-330.886597, 19.529007, 5523.02979, 0.965929627, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, 0.965929627)}
    },
    ["Great Tree"] = {
        {"GreatTree", CFrame.new(2193.32764, 21.5559998, -6694.48096, 0.890025318, 0, 0.4559111, 0, 1, 0, -0.4559111, 0, 0.890025318)},
        {"GreatTree", CFrame.new(2163.52881, 21.2680054, -6778.2666, 0.50289011, 0, -0.864350498, 0, 1, 0, 0.864350498, 0, 0.50289011)}
    },
    ["Floating Turtle"] = {
        {"BigMansion", CFrame.new(-12548.3242, 341.781006, -7487.3125, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        {"PineappleTown", CFrame.new(-11336.5332, 333.213989, -10363.1914, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)},
        {"BigMansion", CFrame.new(-12550.123, 341.781006, -7470.36279, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        {"PineappleTown", CFrame.new(-11352.4404, 333.424988, -10369.3174, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)}
    },
    ["Haunted Castle"] = {
        {"HauntedCastle", CFrame.new(-9452.90527, 141.181, 5529.99121, 0, 0, 1, 0, 1, 0, -1, 0, 0)},
        {"HauntedCastle", CFrame.new(-9554.40527, 141.181, 5459.54102, 0, 0, 1, 0, 1, 0, -1, 0, 0)}
    },
    ["Mansion"] = {
        {"BigMansion", CFrame.new(-12548.3242, 341.781006, -7487.3125, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        {"BigMansion", CFrame.new(-12550.123, 341.781006, -7470.36279, 1, 0, 0, 0, 1, 0, 0, 0, 1)}
    },
    ["Hydra Island"] = {
        {"Hydra1", CFrame.new(5339.17285, 1009.31598, 229.521942, -0.707134247, 0, -0.707079291, 0, 1, 0, 0.707079291, 0, -0.707134247)},
        {"Hydra2", CFrame.new(3499.86499, 63.411499, 1719.13538, 0.406715453, 0, -0.913554907, 0, 1, 0, 0.913554907, 0, 0.406715453)},
        {"Hydra3", CFrame.new(4527.10742, 55.0160065, -1539.63, 0.15644598, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, 0.15644598)},
        {"Hydra1", CFrame.new(5337.35498, 1006.81598, 264.948608, -0.850383282, 0, 0.526163995, 0, 1, 0, -0.526163995, 0, -0.850383282)},
        {"Hydra2", CFrame.new(3466.72119, 56.897995, 1829.18958, 0.15644598, 0, -0.987686574, 0, 1, 0, 0.987686574, 0, 0.15644598)},
        {"Hydra3", CFrame.new(4515.21289, 55.0160065, -1544.92065, 0.15644598, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, 0.15644598)}
    },
    ["North Pole"] = {
        {"CandyCane", CFrame.new(-1068.76855, 22.4250031, -14133.1152, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664)},
        {"CandyCane", CFrame.new(-1007.31049, 25.7925034, -14178.9785, -0.819156051, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, -0.819156051)}
    },
    ["Sea of Treats"] = {
        {"IceCream", CFrame.new(-878.616028, 61.3129959, -10955.4961, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664)},
        {"Loaf", CFrame.new(-1920.25098, 36.6625061, -11930.8926, -0.939700961, 0, 0.341998369, 0, 1, 0, -0.341998369, 0, -0.939700961)},
        {"Peanut", CFrame.new(-2053.69922, 36.9394989, -10213.5596, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247)},
        {"IceCream", CFrame.new(-842.152893, 64.7969971, -10941.2725, -0.819156051, 0, 0.573571265, 0, 1, 0, -0.573571265, 0, -0.819156051)},
        {"Loaf", CFrame.new(-1969.91833, 36.6800079, -11916.6152, -0.573599219, 0, -0.81913656, 0, 1, 0, 0.81913656, 0, -0.573599219)},
        {"Peanut", CFrame.new(-2091.9751, 36.9570007, -10297.0303, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)},
        {"Chocolate", CFrame.new(157.60025, 23.3589935, -12147.4092, -0.819156051, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, -0.819156051)},
        {"Chocolate", CFrame.new(99.4632187, 21.2529984, -12052.2715, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247)}
    },
    ["Castle on the Sea"] = {
        {"SeaCastle", CFrame.new(-5014.87305, 318.181, -3004.52661, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)},
        {"SeaCastle", CFrame.new(-4999.52832, 318.181, -3010.72583, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)}
    }
}

getgenv().IslandVariable.BloxFruitCodes = {"GAMERROBOT_YT","FUDD10","fudd10_v2","BIGNEWS","THEGREATACE","SUB2NOOBMASTER123","Sub2Daigrock","Axiore"
,"TantaiGaming","STRAWHATMAINE","Sub2OfficialNoobie","UPD16","SUB2GAMERROBOT_EXP1","3BVISITS","Enyu_is_Pro","Sub2Fer999","Bluxxy","JCWK"
,"Magicbus","Starcodeheo","kittgaming","ADMINGIVEAWAY","GAMER_ROBOT_1M","Sub2CaptainMaui","15B_BESTBROTHERS","DEVSCOOKING","krazydares","Sub2CaptainMaui","DEVSCOOKING",
"KITT_RESET","Sub2UncleKizaru","SUB2GAMERROBOT_RESET1","NOMOREHACK","BANEXPLOIT","GIFTING_HOURS"}

getgenv().IslandVariable.IsNightC = {
    "18","19","20","21","23","24","00","01","02","03","04"
}

getgenv().IslandVariable.BlacklistedItems = getgenv().IslandVariable.BlacklistedItems or {
    "Hallow Essence",
    "God's Chalice",
    "Sweet Chalice",
    "Microchip",
    "Special Microchip",
    "Fist of Darkness",
    "Core Brain"
}

getgenv().IslandVariable.FishingBaits = {
    "Basic Bait"
}
