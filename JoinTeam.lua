repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer

-- chờ Remote chọn team
local chooseTeam = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- nếu chưa có team thì chọn Hải Quân
if not lp.Team or lp.Team.Name ~= "Marines" then
    pcall(function()
        chooseTeam:InvokeServer("SetTeam", "Marines")
    end)
end
