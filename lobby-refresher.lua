local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs 
local ServerApi = loadstring(game:HttpGet(CONS_INFO.URLS.SERVER_MANAGER_URL))()

-- initialize executor specific required APIs
local TeleportQueue = loadstring(game:HttpGet(CONS_INFO.URLS.EXECUTOR_API_INIT_URL))()
if not TeleportQueue then return end --check if it loaded without problems


if CONS_INFO.instantQueuePrevent then 
  ServerApi.JoinRandomServer() 
  local WRONG_WATCH_REJOINER_SCRIPT = "loadstring(game:HttpGet('" .. CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL .. "'))()"  
  pcall(TeleportQueue, WRONG_WATCH_REJOINER_SCRIPT)
else
  loadstring(game:HttpGet(CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL))()
end 
