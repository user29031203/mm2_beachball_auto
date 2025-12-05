local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PathfindingService = game:GetService("PathfindingService")
local MyId = LocalPlayer.UserId


--DEBUGCONSOLE
game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()
print(CONS_INFO)

-- External Libs 
local TELEPORT_HANDLER_SCRIPT = CONS_INFO.GetReadyLoadText(CONS_INFO.URLS.TELEPORT_HANDLER_URL)
local MATCH_HANDLER_SCRIPT = CONS_INFO.GetReadyLoadText(CONS_INFO.URLS.WRONG_MATCH_HANDLER_URL)
local LeaderboardApi = CONS_INFO.Load(CONS_INFO.URLS.LEADERBOARD_LIB_URL)
local MovementApi = CONS_INFO.Load(CONS_INFO.URLS.MOVEMENT_LIB_URL)

-- initialize executor specific required APIs
local TeleportQueue = CONS_INFO.Load(CONS_INFO.URLS.EXECUTOR_API_INIT_URL)
if not TeleportQueue then return end --check if it loaded without problems

-- be sure everything imported without problems
libs = {LeaderboardApi, MovementApi, CONS_INFO}
for i=0, 4 do
    print(type(libs[i]))
end

if (type(LeaderboardApi) == "table") and
   (type(MovementApi) == "table") and 
   (type(CONS_INFO) == "table") then
    print("All modules loaded successfully!")
else
    warn("CRITICAL: One or more modules failed to load.")
    -- Optional: Stop script
    --return 
end

-- get points of both client
--local hosterShouldLose = LeaderboardApi.ShouldHosterLose(CONS_INFO.hosterName, CONS_INFO.joinerName)
print("DATA ABOUT HOSTER !!!!" , hosterShouldLose)

-- match checking and teleportation trigger
   -- ← CHANGE THIS TO ALT1'S USERID
print("CODE BLOCK 2")
print("IM A2 -- HOST")
-- pcall(TeleportQueue, TELEPORT_HANDLER_SCRIPT) 

pcall(TeleportQueue, MATCH_HANDLER_SCRIPT)
print("HOSTER MATCHHANDLING ACTIVATED!")


