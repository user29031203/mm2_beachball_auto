local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PathfindingService = game:GetService("PathfindingService")
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- External Libs 
local TELEPORT_HANDLER_SCRIPT = "loadstring(game:HttpGet('" .. CONS_INFO.URLS.TELEPORT_HANDLER_URL .. "'))()"
local MATCH_HANDLER_SCRIPT = "loadstring(game:HttpGet('" .. CONS_INFO.URLS.WRONG_MATCH_HANDLER_URL .. "'))()"
local LeaderboardApi = loadstring(game:HttpGet(CONS_INFO.URLS.LEADERBOARD_LIB_URL))()
local MovementApi = loadstring(game:HttpGet(CONS_INFO.URLS.MOVEMENT_LIB_URL))()

-- teleportatin support 
local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end

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
local hosterShouldLose = LeaderboardApi.ShouldHosterLose(CONS_INFO.hosterName, CONS_INFO.joinerName)
print(hosterShouldJoin)

-- match checking and teleportation trigger

hosterShouldLose = ""
if type(hosterShouldLose) == "string" then
	print("CODE BLOCK 1")
	warn("NO DUO FOUND RUNNING REJOIN HANDLER/LOBBY REFRESHER")
    task.wait(3)
    loadstring(game:HttpGet(CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL))()
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

if type(hosterShouldLose) ~= "string" then
	MovementApi.SmartWalkTo(MovementApi.HosterPos)
end
