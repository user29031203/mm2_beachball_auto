local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerManager = {
    RETRY_DELAY = 3, -- Seconds between retries
    TIMEOUT_WAIT = 4 -- How long to wait for a failure signal before assuming success
}

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId, shouldRepeat)
    -- If repeat is true, try 5 times. If false, try 1 time.
    local MAX_RETRIES = shouldRepeat and 3 or 1
    local attemptCount = 0

    while attemptCount < MAX_RETRIES do
        attemptCount = attemptCount + 1
        warn("[ServerManager] Attempt " .. attemptCount .. "/" .. MAX_RETRIES .. "...")

        -- Variables to track the outcome of THIS attempt
        local attemptFailed = false
        local failReason = nil
        
        -- 1. Setup Listener for this specific attempt
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
            if player == Players.LocalPlayer then
                attemptFailed = true
                failReason = errorMessage
            end
        end)

        -- 2. Fire Teleport
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        -- 3. Handle Immediate Script Errors (e.g., Invalid Arguments)
        if not success then
            attemptFailed = true
            failReason = err
        end

        -- 4. If pcall succeeded, we must WAIT to see if the Engine fails (Async check)
        if success then
            local timer = 0
            -- Wait loop: Stop if we detect failure OR if time runs out
            while not attemptFailed and timer < ServerManager.TIMEOUT_WAIT do
                task.wait(0.1)
                timer = timer + 0.1
            end
        end

        -- 5. Cleanup Connection
        if connection then connection:Disconnect() end

        -- 6. Decide what to do
        if attemptFailed then
            warn("[ServerManager] Attempt " .. attemptCount .. " Failed: " .. tostring(failReason))
            
            -- If we have attempts left, wait and loop again
            if attemptCount < MAX_RETRIES then
                warn("[ServerManager] Retrying in " .. ServerManager.RETRY_DELAY .. "s...")
                task.wait(ServerManager.RETRY_DELAY)
            else
                -- No attempts left, return Failure
                return false, "Max retries reached. Last error: " .. tostring(failReason)
            end
        else
            -- If attemptFailed is still false here, we assume Success!
            return true, "Teleport Initiated"
        end
    end
end

function ServerManager.JoinRandomServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    
    -- Basic retry logic for random server as well
    local function attemptRandom()
        local success, err = pcall(function()
            TeleportService:Teleport(placeId, Players.LocalPlayer)
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
