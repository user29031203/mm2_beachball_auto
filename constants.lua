local OWNER = "user29031203"
local REPO  = "LegendZero"      
local BRANCH = "main"         

local consInfo = {
    hosterName = "X0010010",
    joinerName = "306a2e5cd_2",
    hosterId = 7573604968, 
    joinerId = 9359470613,
    mySecretKey = "21bdef3f9b5a7e65db63ea9ac3d9f34a",
    duelsPlaceId = 12360882630,
    generalTimeout = 4.5,
    BackendBaseEndpointUrl = "http://192.168.1.128:5000",
    instantQueuePrevent = false,
    URLS = {
        TELEPORT_HANDLER_URL     = "teleport-handler.lua",
        DWEETR_LIB_URL           = "dweetr-lib.lua",
        SERVER_MANAGER_URL       = "server-manager.lua",
        LEADERBOARD_LIB_URL      = "leaderboard-lib.lua",
        MOVEMENT_LIB_URL         = "movement-lib.lua",
        WRONG_MATCH_HANDLER_URL  = "wrong-match-handler.lua",
        WRONG_MATCH_REJOINER_URL = "wrong-match-rejoiner.lua",
        LOBBY_REFRESHER_URL      = "lobby-refresher.lua",
        MAIN_CODE_URL            = "main.lua",
        EXECUTOR_API_INIT_URL    = "executor-specific-initialization.lua"
    }
} 

-- learn url which links to latest sha commit result of the script
local function raw(file)
    return ("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s"):format(OWNER, REPO, BRANCH, file)
end

-- hot reload
for key, fileName in pairs(consInfo.URLS) do
    consInfo.URLS[key] = raw(fileName)
end
