local Logic = {}

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local LeaderboardApi = CONS_INFO.Load(CONS_INFO.URLS.LEADERBOARD_LIB_URL)

-- get points of both client
local hosterShouldLose = LeaderboardApi.ShouldHosterLose(CONS_INFO.hosterName, CONS_INFO.joinerName)
print("DATA ABOUT HOSTER !!!!" , hosterShouldLose)

-- initialize executor specific required APIs
local TeleportQueue = CONS_INFO.Load(CONS_INFO.URLS.EXECUTOR_API_INIT_URL)
if not TeleportQueue then return end --check if it loaded without problems

-- match checking and teleportation trigger
if type(hosterShouldLose) == "string" then
    print("CODE BLOCK 1")
    warn("NO DUO FOUND RUNNING REJOIN HANDLER/LOBBY REFRESHER")
    task.wait(0.2)
    CONS_INFO.Load(CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL)
elseif MyId == CONS_INFO.hosterId and hosterShouldLose == true then        -- ← CHANGE THIS TO ALT1'S USERID
    print("CODE BLOCK 2")
    print("IM A2 -- HOST")
    pcall(TeleportQueue, TELEPORT_HANDLER_SCRIPT) 
elseif MyId == CONS_INFO.joinerId and hosterShouldLose == false then    -- ← CHANGE THIS TO ALT2'S USERID 
    print("CODE BLOCK 3")
    print("IM CD -- JOINER")
    pcall(TeleportQueue, TELEPORT_HANDLER_SCRIPT) 
else
    print("Unknown alt - check UserIds")
end 

if MyId == CONS_INFO.joinerId and hosterShouldLose == true then
    pcall(TeleportQueue, MATCH_HANDLER_SCRIPT)
    print("JOINER MATCHHANDLING ACTIVATED!")
elseif MyId == CONS_INFO.hosterId and hosterShouldLose == false then
    pcall(TeleportQueue, MATCH_HANDLER_SCRIPT)
    print("HOSTER MATCHHANDLING ACTIVATED!")
end
