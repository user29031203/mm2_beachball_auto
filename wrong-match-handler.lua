
--DEBUGCONSOLE
game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerApi = CONS_INFO.Load(CONS_INFO.URLS.SERVER_MANAGER_URL)
local LeaderboardApi = CONS_INFO.Load(CONS_INFO.URLS.LEADERBOARD_LIB_URL)

-- initialize executor specific required APIs
local TeleportQueue = CONS_INFO.Load(CONS_INFO.URLS.EXECUTOR_API_INIT_URL)
if not TeleportQueue then return end --check if it loaded without problems

local function CheckAndHandleMatching()
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", CONS_INFO.generalTimeout)
    
    if leaderstats then
        print("leaderstats loaded — checking duo status...")
        local status = LeaderboardApi.IsDuoMatched(CONS_INFO.hosterName, CONS_INFO.joinerName)
        -- true was status, it changed to true for testing purposes only
        if status then
            local hosterShouldLose = LeaderboardApi.ShouldHosterLose(CONS_INFO.hosterName, CONS_INFO.joinerName)
            -- debugging/testing purposes if its false/true
            return true, hosterShouldLose 
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

-- lobby refresh to prevent qeueuing with someone else after win
local function LobbyRefresh()
    local LOBBY_REFRESHER_SCRIPT = CONS_INFO.GetReadyLoadText(CONS_INFO.URLS.LOBBY_REFRESHER_URL)
    pcall(TeleportQueue, LOBBY_REFRESHER_SCRIPT)
end

local IsDuoMatched, hosterShouldLose = CheckAndHandleMatching()
if hosterShouldLose == true and MyId == CONS_INFO.joinerId then
    LobbyRefresh()
elseif hosterShouldLose == false and MyId == CONS_INFO.hosterId then
    LobbyRefresh()
else
    local WRONG_WATCH_REJOINER_SCRIPT = CONS_INFO.GetReadyLoadText(CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL)
    pcall(TeleportQueue, WRONG_WATCH_REJOINER_SCRIPT)
end

return IsDuoMatched
