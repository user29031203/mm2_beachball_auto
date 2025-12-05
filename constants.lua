local offlineModuleLoad = true  -- <== SET THIS TO TRUE FOR LOCAL DEV -- The folder name in your Executor's Workspace
local OWNER = "user29031203"
local REPO  = "LegendZero"      
local BRANCH = "main"         
local localFolder = "LegendZero"


local consInfo = {
    hosterName = "X0010010",
    joinerName = "306a2e5cd_2",
    hosterId = 7573604968, 
    joinerId = 9359470613,
    mySecretKey = "21bdef3f9b5a7e65db63ea9ac3d9f34a",
    duelsPlaceId = 12360882630,
    generalTimeout = 4.5,
    BackendBaseEndpointUrl = "http://192.168.1.128:5000",
    instantQueuePrevent = true,
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

-- Helper to format paths
local function getPath(file)
    if offlineModuleLoad then
        -- Returns local path: "MyProject/main.lua"
        return localFolder .. "/" .. file
    else
        -- Returns GitHub URL
        return raw(file)
    end
end

-- Update the table with the correct paths/urls
for key, fileName in pairs(consInfo.URLS) do
    consInfo.URLS[key] = getPath(fileName)
end

---------------------------------------------------------------------
-- NEW FUNCTION: Handles the loading logic based on mode
---------------------------------------------------------------------

function consInfo.GetContent(pathOrUrl)
	print("[Loader] Preparing to read: " .. tostring(pathOrUrl))
	
    if not pathOrUrl then 
        return warn("Module Key not found:", key) 
    end

    if offlineModuleLoad then
        -- LOCAL MODE: Use readfile()
        -- Most executors support isfile() to check existence
        if isfile and not isfile(pathOrUrl) then
            error("[Local Dev] File not found in workspace: " .. pathOrUrl)
        end
        
        print("[Local Dev] Loading:", pathOrUrl)
        local content = readfile(pathOrUrl) -- Executor API
        return content
    else
        -- ONLINE MODE: Use game:HttpGet()
        -- print("[Online] Fetching:", pathOrUrl)
        return content
    end
end

function consInfo.GetReadyLoadText(pathOrUrl)
	-- Check if path is valid
    if pathOrUrl == nil then
        error("[Loader] CRITICAL: pathOrUrl is nil! Check your config table keys.")
    end
	
	local content = consInfo.GetContent(pathOrUrl)

	if content == nil then
        warn("Content returned nil, means its gonna use web method!")
    end
	
    if offlineModuleLoad then
		return "loadstring([=[" .. content .. "]=])()"
	else
		return "loadstring(game:HttpGet('" .. pathOrUrl .. "'))()"
	end
end

function consInfo.Load(pathOrUrl)
	local content = consInfo.GetContent(pathOrUrl)
	if not content then
		warn("Content is returned nil!")
	end
		
	if offlineModuleLoad then
		return loadstring(content)()
	else
		return loadstring(game:HttpGet(pathOrUrl))()
	end
end

return consInfo
