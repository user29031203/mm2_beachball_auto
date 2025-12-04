
--DEBUGCONSOLE
game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)

print("DEBUGGER A1")

local Players = game:GetService("Players") 
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs
local ServerApi = CONS_INFO.Load(CONS_INFO.URLS.SERVER_MANAGER_URL)
local LeaderboardApi = CONS_INFO.Load(CONS_INFO.URLS.LEADERBOARD_LIB_URL)
local DweetLib = CONS_INFO.Load(CONS_INFO.URLS.DWEETR_LIB_URL)
local Comm = DweetLib.new(CONS_INFO.mySecretKey)

-- initialize executor specific required APIs
local TeleportQueue = loadstring(game:HttpGet(CONS_INFO.URLS.EXECUTOR_API_INIT_URL))()
if not TeleportQueue then return end --check if it loaded without problems


--[[ general timeout to wait for loser to join back 
	also u can make a loop to call everytime this func and wait for max 5 seconds]]
local timer = 0
_G.status = false
while not _G.status and timer < CONS_INFO.generalTimeout do
	task.wait(0.5)
	_G.status = LeaderboardApi.IsDuoMatched(CONS_INFO.hosterName, CONS_INFO.joinerName)
	timer = timer + 0.5
end

local function SendJobId()
    print("Sending data to dweetr.io...")
    return Comm:Send({
        status = "Working",
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

if MyId == CONS_INFO.hosterId and _G.status == false then       -- ← CHANGE THIS TO ALT1'S USERID
    -- send jobid through dweetr
    print("IM HOST!")
    local success, msg = SendJobId()
	print("Send Result:", msg) 
	CONS_INFO.Load(CONS_INFO.URLS.MAIN_CODE_URL)
elseif MyId == CONS_INFO.joinerId and _G.status == false then
    -- receive jobid through dweetr 
    print("IM JOINER!")
	local MAIN_SCRIPT = CONS_INFO.GetReadyLoadText(CONS_INFO.URLS.MAIN_CODE_URL)
	pcall(TeleportQueue, MAIN_SCRIPT)
    local ReadedData, msg = ReadJobId() 
	if ReadedData then 
		local success, result = ServerApi.JoinServerById(CONS_INFO.duelsPlaceId, ReadedData.JobId, true)
		if success then
		    print("Success Joiner Worked: " .. result)
		else
		    warn("Final/Final!! Failure!!: " .. result)
			CONS_INFO.Load(CONS_INFO.URLS.WRONG_MATCH_REJOINER_URL)
		end
	else
		ServerApi.JoinRandomServer()
	end
elseif _G.status == true then 
	loadstring(game:HttpGet(CONS_INFO.URLS.MAIN_CODE_URL))()
end 
