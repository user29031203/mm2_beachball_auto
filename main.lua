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
local MovementApi = CONS_INFO.Load(CONS_INFO.URLS.MOVEMENT_LIB_URL)

-- initialize executor specific required APIs
local TeleportQueue = CONS_INFO.Load(CONS_INFO.URLS.EXECUTOR_API_INIT_URL)
if not TeleportQueue then return end --check if it loaded without problems

-- be sure everything imported without problems
libs = {LeaderboardApi, MovementApi, CONS_INFO}
for i=0, 4 do
    print(type(libs[i]))
end

if (type(MainLogicApi) == "table") and 
   (type(MovementApi) == "table") and 
   (type(CONS_INFO) == "table") then
    print("All modules loaded successfully!")
else
    warn("CRITICAL: One or more modules failed to load.")
    -- Optional: Stop script
    --return 
end

-- main logic run
CONS_INFO.Load(CONS_INFO.URLS.MAIN_LOGIC_URL)


local function move_logic(pos)
    local success, err = pcall(function()
        MovementApi.SmartWalkTo(pos)
    end)
    if not success then 
        print("FAILED MOVEMENT:" .. err)
        -- !!!! FIND A WAY TO DONT RUNNING MAIN_LOGIC() TO PREVENT PCALLS IN THIS CASE !!!!
        --MainLogicApi.MainLogic(instant=true)
    end
end

if type(hosterShouldLose) ~= "string" then
	-- if pathfinding fails, it stands for main.lua loaded so slow and alts matched so fast
    if MyId == CONS_INFO.hosterId then
		move_logic(MovementApi.HosterPos)
	elseif MyId == CONS_INFO.joinerId then
		move_logic(MovementApi.JoinerPos)
	end
end

