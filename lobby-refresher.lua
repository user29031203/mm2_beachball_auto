local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs 
local ServerApi = loadstring(game:HttpGet(CONS_INFO.URLS.SERVER_MANAGER_URL))()

-- teleportatin support 
local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end

-- refresh lobby instantly
ServerApi.JoinRandomServer()
local WRONG_WATCH_REJOINER_SCRIPT = "loadstring(game:HttpGet('" .. CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL .. "'))()"  
pcall(TeleportQueue, WRONG_WATCH_REJOINER_SCRIPT)
