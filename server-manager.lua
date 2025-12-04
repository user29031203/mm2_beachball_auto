local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerManager = {
    RETRY_DELAY = 10
}

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId)
    local function attemptJoin()
        warn("[ServerManager] Attempting to join Place: " .. tostring(placeId) .. " | Job: " .. tostring(jobId))
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId)
        end)

        if not success then
            warn("[ServerManager] Immediate Teleport Error: " .. tostring(err))
            warn("[ServerManager] Retrying in " .. ServerManager.RETRY_DELAY .. " seconds...")
            task.wait(ServerManager.RETRY_DELAY)
            attemptJoin() -- Recursive retry
        end
    end
    attemptJoin()
end

function ServerManager.JoinRandomServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    
    -- Basic retry logic for random server as well
    local function attemptRandom()
        local success, err = pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
        
        if not success then
            warn("Random Join Failed: " .. err)
            task.wait(ServerManager.RETRY_DELAY)
            attemptRandom()
        end
    end
    
    attemptRandom()
end

return ServerManager
