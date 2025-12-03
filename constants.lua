local OWNER = "user29031203"
local REPO  = "LegendZero"      
local BRANCH = "main"         

-- get latest commit sha
local BASE_RAW_URL
do
    local api = ("https://api.github.com/repos/%s/%s/commits/%s"):format(OWNER, REPO, BRANCH)
    local sha = game:HttpGet(api, true):match('"sha":"([a-f0-9]+)"') or BRANCH
    BASE_RAW_URL = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(OWNER, REPO, sha)
end

local consInfo = {
    hosterName = "306a2e5cd_2",
    joinerName = "306a2e5cd_1",
    hosterId = 9359470613, -- A2
    joinerId = 9359433164,
    mySecretKey = "21bdef3f9b5a7e65db63ea9ac3d9f34a",
    duelsPlaceId = 12360882630,
    generalTimeout = 4.5,
    BackendBaseEndpointUrl = "http://192.168.1.128:5000",
    URLS = {
        TELEPORT_HANDLER_URL     = "teleport-handler.lua",
        DWEETR_LIB_URL           = "dweetr-lib.lua",
        SERVER_MANAGER_URL       = "server-manager.lua",
        LEADERBOARD_LIB_URL      = "leaderboard-lib.lua",
        MOVEMENT_LIB_URL         = "movement-lib.lua",
        WRONG_MATCH_HANDLER_URL  = "wrong-match-handler.lua",
        WRONG_MATCH_REJOINER_URL = "wrong-match-rejoiner.lua",
        LOBBY_REFRESHER_URL      = "lobby-refresher.lua",
        MAIN_CODE_URL            = "main.lua"
    }
} 

-- learn url which links to latest sha commit result of the script
local function raw(file)
    local sha = game:HttpGet(("https://api.github.com/repos/%s/%s/commits/%s"):format(OWNER, REPO, BRANCH), true)
                :match('"sha":"([a-f0-9]+)"') or BRANCH
    
    return ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(OWNER, REPO, sha, file:gsub("^/*", ""))
end

-- hot reload
for key, fileName in pairs(consInfo.URLS) do
    consInfo.URLS[key] = BASE_RAW_URL .. fileName
end

return consInfo
