repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer

local chooseTeam = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

if not lp.Team or lp.Team.Name ~= "Marines" then
    pcall(function()
        chooseTeam:InvokeServer("SetTeam", "Marines")
    end)
end
