local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerApi = loadstring(game:HttpGet(CONS_INFO.URLS.SERVER_MANAGER_URL))()
local LeaderboardApi = loadstring(game:HttpGet(CONS_INFO.URLS.LEADERBOARD_LIB_URL))()


-- teleportatin support 
local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end

local function CheckAndHandleMatching()
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", generalTimeout)
    
    if leaderstats then
        print("leaderstats loaded — checking duo status...")
        local status = LeaderboardApi.IsDuoMatched(CONS_INFO.hosterName, CONS_INFO.joinerName)
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
end

if MyId == CONS_INFO.joinerId then
    local WrongMatchRejoiner = "loadstring(game:HttpGet('" .. CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL .. "'))()"  
    pcall(TeleportQueue, WrongMatchRejoiner)
else
    pcall(TeleportQueue, print("Status: STABLE AND TESTING B88"))
end

return CheckAndHandleMatching()
