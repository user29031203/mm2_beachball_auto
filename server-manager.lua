local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerManager = {
    RETRY_DELAY = 10
}
-- Setup Global Error Listener for Teleports
-- We listen here because TeleportToPlaceInstance might succeed initially but fail 2 seconds later
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == LocalPlayer then
        warn("[ServerManager] Teleport Failed (Async): " .. tostring(errorMessage))
        warn("[ServerManager] Retrying in " .. ServerManager.RETRY_DELAY .. " seconds...")
        
        task.wait(ServerManager.RETRY_DELAY)
        
        -- Check if we have a stored pending join, or just let the user call logic handle it.
        -- Ideally, the specific join function should handle the retry to keep context of PlaceId/JobId
    end
end)

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId)
    task.spawn(function()
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
        
        -- Create a specific connection for this join attempt to handle Async failures (GameEnded, etc.)
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
            if player == LocalPlayer then
                warn("[ServerManager] TeleportInitFailed: " .. tostring(errorMessage))
                
                -- Disconnect to prevent memory leaks or double stacking if we change targets
                if connection then connection:Disconnect() end
                
                warn("[ServerManager] Retrying in " .. ServerManager.RETRY_DELAY .. " seconds...")
                task.wait(ServerManager.RETRY_DELAY)
                attemptJoin()
            end
        end)
        
        attemptJoin()
    end)
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
