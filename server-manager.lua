local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- Keep track of connections to clean them up if needed
local teleportConnection

local ServerManager = {
    RETRY_DELAY = 2, -- Seconds between retries
    TIMEOUT_WAIT = 10 -- How long to wait for a failure signal before assuming success
}

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId, shouldRepeat, attemptCount)
    attemptCount = attemptCount or 0
    local MAX_RETRIES = 5

    -- ==========================================
    -- MODE 1: REPEAT ENABLED (Recursive Retry)
    -- ==========================================
    if shouldRepeat then
        if attemptCount >= MAX_RETRIES then
            warn("[ServerManager] FAILED: Max retries (5) reached.")
            if teleportConnection then teleportConnection:Disconnect() teleportConnection = nil end
            return false, "Max retries reached"
        end

        -- Setup Listener for Async Failures
        if teleportConnection then teleportConnection:Disconnect() end
        
        teleportConnection = TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
            if player == Players.LocalPlayer then
                warn("[ServerManager] Async Teleport Failed: " .. tostring(errorMessage))
                
                if teleportConnection then teleportConnection:Disconnect() teleportConnection = nil end
                
                warn("[ServerManager] Retrying... (Attempt " .. (attemptCount + 1) .. "/" .. MAX_RETRIES .. ")")
                task.wait(ServerManager.RETRY_DELAY)
                
                -- Recursive retry
                ServerManager.JoinServerById(placeId, jobId, true, attemptCount + 1)
            end
        end)

        warn("[ServerManager] Attempting to join (Attempt " .. attemptCount .. ")...")
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        if not success then
            warn("[ServerManager] Immediate Error: " .. tostring(err))
            task.wait(ServerManager.RETRY_DELAY)
            return ServerManager.JoinServerById(placeId, jobId, true, attemptCount + 1)
        end

        return true -- Request sent (Retries handled in background)
    
    -- ==========================================
    -- MODE 2: REPEAT DISABLED (Return Async Result)
    -- ==========================================
    else
        local asyncResult = nil -- Will become false if event fires, true if timeout passes
        local asyncError = nil

        -- 1. Setup temporary listener
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
            if player == Players.LocalPlayer then
                asyncResult = false
                asyncError = errorMessage
            end
        end)

        -- 2. Attempt Teleport
        warn("[ServerManager] Attempting to join (Single Try)...")
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        -- 3. Handle Immediate pcall Error
        if not success then
            connection:Disconnect()
            warn("[ServerManager] Immediate Fail: " .. tostring(err))
            return false, err
        end

        -- 4. Wait for the Async Event (The "Pause")
        -- We wait until a result is found OR time runs out
        local timer = 0
        while asyncResult == nil and timer < ServerManager.TIMEOUT_WAIT do
            task.wait(0.1)
            timer = timer + 0.1
        end
        
        connection:Disconnect()

        -- 5. Return Result
        if asyncResult == false then
            -- The listener fired! We caught the "GameEnded" error.
            warn("[ServerManager] Async Fail Caught: " .. tostring(asyncError))
            return false, asyncError
        else
            -- Timer finished, no error appeared. Teleport probably successful.
            return true, "Request sent, no immediate/future failure detected."
        end
    end
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
