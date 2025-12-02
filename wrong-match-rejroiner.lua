local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local LeaderboardApi = loadstring(game:HttpGet(CONS_INFO.URLS.LEADERBOARD_LIB_URL))()

local function shareJobId() 
    ---
end

local status = LeaderboardApi.IsDuoMatched(CONS_INFO.hosterName, CONS_INFO.joinerName)
print(status)

if not status then
    print(MyId)
    if MyId == CONS_INFO.joinerId then
        -- share jobid via dweetr then join to hoster 
        print("DEBUGGER A1")
    end
end
