local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs 
local ServerApi = CONS_INFO.Load(CONS_INFO.URLS.SERVER_MANAGER_URL)

-- initialize executor specific required APIs
local TeleportQueue = CONS_INFO.Load(CONS_INFO.URLS.EXECUTOR_API_INIT_URL)
if not TeleportQueue then return end --check if it loaded without problems


if CONS_INFO.instantQueuePrevent then 
  local WRONG_WATCH_REJOINER_SCRIPT = CONS_INFO.GetReadyLoadText(CONS_INFO.URLS.WRONG_WATCH_REJOINER_SCRIPT) 
  pcall(TeleportQueue, WRONG_WATCH_REJOINER_SCRIPT)
  ServerApi.JoinRandomServer() 
else
  CONS_INFO.Load(CONS_INFO.URLS.WRONG_WATCH_REJOINER_SCRIPT)
end 
