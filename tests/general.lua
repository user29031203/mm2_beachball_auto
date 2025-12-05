local constantsFile = "LegendZero/constants.lua"
local offlineModuleLoad = true

function GetContent(pathOrUrl)
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

function GetReadyLoadText(pathOrUrl)
	-- Check if path is valid
    if pathOrUrl == nil then
        error("[Loader] CRITICAL: pathOrUrl is nil! Check your config table keys.")
    end
	
	local content = GetContent(pathOrUrl)

	if content == nil then
        warn("Content returned nil, means its gonna use web method!")
    end
	
    if offlineModuleLoad then
		return "loadstring([=[" .. content .. "]=])()"
	else
		return "loadstring(game:HttpGet('" .. pathOrUrl .. "'))()"
	end
end

function Load(pathOrUrl)
	local content = GetContent(pathOrUrl)
	if not content then
		warn("Content is returned nil!")
	end
		
	if offlineModuleLoad then
		print("LOADING LOCALLY!")
		return loadstring(content)()
	else
		return loadstring(game:HttpGet(pathOrUrl))()
	end
end

local content = GetContent(constantsFile)

local onlineContentSource = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua"
--local onlineContent = loadstring(game:HttpGet(onlineContentSource))

local CONS_INFO = Load(constantsFile)
print("File", CONS_INFO.URLS.LEADERBOARD_LIB_URL)


local leaderboardcontent = CONS_INFO.GetContent(CONS_INFO.URLS.LEADERBOARD_LIB_URL)
--game:HttpGet("https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/leaderboard-lib.lua")
--CONS_INFO.GetContent(CONS_INFO.URLS.LEADERBOARD_LIB_URL)

local leaderboardapi = loadstring(leaderboardcontent)()
print("Result of leaderboard loading is", leaderboardapi)


-- CHECKED THINGS IS LEADERBOARD AND CONSTANTS ONLY!