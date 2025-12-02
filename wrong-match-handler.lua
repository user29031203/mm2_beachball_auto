local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerApi = loadstring(game:HttpGet(CONS_INFO.SERVER_MANAGER_URL))()
local LeaderboardApi = loadstring(game:HttpGet(CONS_INFO.LEADERBOARD_LIB_URL))()

local function CheckAndHandleMatching()
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", generalTimeout)
    
    if leaderstats then
        print("leaderstats loaded — checking duo status...")
        local status = LeaderboardApi.IsDuoMatched(altsInfo.hosterName, altsInfo.joinerName)
        -- true was status, it changed to true for testing purposes only
        if status then
            return true
        else 
            print("Matched with a random!")
            ServerApi.JoinRandomServer()
        end
    else
        warn("leaderstats NEVER loaded → Hopping anyway (safe fallback)")
        task.wait(0.1)
        ServerApi.JoinRandomServer()
    end

    return false
end

CheckAndHandleMatching()
