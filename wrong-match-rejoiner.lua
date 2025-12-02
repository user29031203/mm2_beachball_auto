local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

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

local function shareJobId() 
    ---
end

local status = LeaderboardApi.IsDuoMatched(CONS_INFO.hosterName, CONS_INFO.joinerName)

if not status then
    print("DEBUGGER A1")
end

pcall(TeleportQueue, "return")
