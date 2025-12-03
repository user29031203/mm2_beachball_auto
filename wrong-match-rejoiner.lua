print("DEBUGGER A1")

local Players = game:GetService("Players") 
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs
local LeaderboardApi = loadstring(game:HttpGet(CONS_INFO.URLS.LEADERBOARD_LIB_URL))()
local ServerApi = loadstring(game:HttpGet(CONS_INFO.URLS.SERVER_MANAGER_URL))()
local DweetLib = loadstring(game:HttpGet(CONS_INFO.URLS.DWEETR_LIB_URL))()
local Comm = DweetLib.new(CONS_INFO.mySecretKey)

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

local function SendJobId()
    print("Sending data to dweetr.io...")
    return Comm:Send({
        Status = "Working",
        JobId = game.JobId,
        Time = 0
    })
end

local function ReadJobId()
	--task.wait(2.5) -- fix it by perfect 30 seconds limited waiting
    local data, createdTime = Comm:GetLatest()

    if data then
        print("SUCCESS! Read back JobId:", data.JobId, "\nCreated Time:", createdTime)
	else
        warn("Failed to read data.")
    end
    
    return data, createdTime
end

if MyId == CONS_INFO.hosterId and status == false then       -- ← CHANGE THIS TO ALT1'S USERID
    -- send jobid through dweetr
    print("IM HOST!")
    local success, msg = SendJobId()
	print("Send Result:", msg) 
	task.wait(2.5)
	loadstring(game:HttpGet(CONS_INFO.URLS.MAIN_CODE_URL))()
elseif MyId == CONS_INFO.joinerId and status == false then
    -- receive jobid through dweetr 
    print("IM JOINER!")
    task.wait(2)
	local MAIN_SCRIPT = "loadstring(game:HttpGet('" .. CONS_INFO.URLS.MAIN_CODE_URL .. "'))()"
	pcall(TeleportQueue, MAIN_SCRIPT)
    local ReadedData, msg = ReadJobId() 
	if ReadedData then 
		ServerApi.JoinServerById(CONS_INFO.duelsPlaceId, ReadedData.JobId)
	else
		ServerManager.JoinRandomServer()
		-- add error handling, join randomserver if cant read data then pcall main script
	end
elseif status == true then 
	if MyId == CONS_INFO.hosterId then
		--task.wait(4)
		loadstring(game:HttpGet(CONS_INFO.URLS.MAIN_CODE_URL))()
	else
		loadstring(game:HttpGet(CONS_INFO.URLS.MAIN_CODE_URL))()
	end
end 
