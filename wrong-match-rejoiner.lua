local Players = game:GetService("Players") 
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs
local LeaderboardApi = loadstring(game:HttpGet(CONS_INFO.URLS.LEADERBOARD_LIB_URL))()
local ServerApi = loadstring(game:HttpGet(CONS_INFO.URLS.SERVER_MANAGER_URL))()
--[[local DweetLib = loadstring(game:HttpGet(CONS_INFO.URLS.DWEETR_LIB_URL))()
local Comm = DweetLib.new(CONS_INFO.mySecretKey)]]

-- teleportatin support 
local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end

local status = LeaderboardApi.IsDuoMatched(CONS_INFO.hosterName, CONS_INFO.joinerName)
local hosterJobId

if MyId == CONS_INFO.hosterId then
    hosterJobId = ServerApi.GetCurrentServerInfo().JobId
end

if MyId == CONS_INFO.hosterId and status == false then        -- ← CHANGE THIS TO ALT1'S USERID
    -- send jobid through dweetr
    print("IM HOST!")
elseif MyId == CONS_INFO.joinerId and status == false then
    -- receive jobid through dweetr 
    print("IM JOINER!")
    ServerApi.JoinServerById(CONS_INFO.duelsPlaceId, hosterJobId)
end 

pcall(TeleportQueue, "return")
