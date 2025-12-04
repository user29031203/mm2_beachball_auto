local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- Keep track of connections to clean them up if needed
local teleportConnection

local ServerManager = {
    RETRY_DELAY = 1
}

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId)
    -- 1. Set up the listener for async failures (Like "GameEnded" or "Full")
    if teleportConnection then teleportConnection:Disconnect() end
    
    teleportConnection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == Players.LocalPlayer then
            warn("[ServerManager] Teleport Init Failed: " .. tostring(errorMessage))
            warn("[ServerManager] Retrying in " .. ServerManager.RETRY_DELAY .. " seconds...")
            
            -- Disconnect to prevent memory leaks before retrying
            if teleportConnection then teleportConnection:Disconnect() end
            
            task.wait(ServerManager.RETRY_DELAY)
            ServerManager.JoinServerById(placeId, jobId) -- Retry
        end
    end)

    -- 2. Attempt the teleport
    local function attemptJoin()
        warn("[ServerManager] Attempting to join Place: " .. tostring(placeId) .. " | Job: " .. tostring(jobId))
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        -- This only catches immediate script errors (like invalid arguments)
        if not success then
            warn("[ServerManager] Immediate Script Error: " .. tostring(err))
            warn("[ServerManager] Retrying in " .. ServerManager.RETRY_DELAY .. " seconds...")
            task.wait(ServerManager.RETRY_DELAY)
            attemptJoin()
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
