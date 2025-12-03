local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

local ServerManager = {}

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId)
    TeleportService:TeleportToPlaceInstance(placeId, jobId)
end

function ServerManager.JoinRandomServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- DEBUG ONLY
-- This is the key: run the HTTP request from PlayerGui, not CoreGui
function ServerManager.runInPlayerGui(func)
    local gui = player:WaitForChild("PlayerGui")
    local dummy = Instance.new("ScreenGui", gui)
    local script = Instance.new("LocalScript", dummy)
    
    local connection
    connection = script.AncestryChanged:Connect(function()
        if script.Parent == gui then
            connection:Disconnect()
            func()
            dummy:Destroy()
        end
    end)
end

function ServerManager.getServers(placeId)
    local servers = {}
    local cursor = ""
    
    repeat
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local success, result = pcall(function()
            return HttpService:GetAsync(url, false)
        end)

        if not success then
            warn("HTTP failed (blocked?), retrying in PlayerGui context...")
            -- Retry once in safe context
            local retrySuccess = false
            ServerManager.runInPlayerGui(function()
                local ok, res = pcall(HttpService.GetAsync, HttpService, url, false)
                if ok then
                    result = res
                    retrySuccess = true
                end
            end)
            -- Wait a moment for retry
            task.wait(1)
            if not retrySuccess then break end
        end

        local data = HttpService:JSONDecode(result)
        for _, server in ipairs(data.data or {}) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        cursor = data.nextPageCursor or ""
        task.wait(0.2) -- Avoid rate-limit
    until not cursor

    table.sort(servers, function(a, b) return a.playing < b.playing end)
    return servers
end

function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId

    if placeId == game.PlaceId then
        -- Same place? Just quick hop (usually works)
        TeleportService:Teleport(game.PlaceId, player)
        return
    end

    local servers = ServerManager.getServers(placeId)
    
    if #servers > 0 then
        local target = servers[1]  -- smallest
        if target.id == game.JobId and #servers > 1 then
            target = servers[2]
        end
        print("Joining smallest server:", target.playing .. " players")
        TeleportService:TeleportToPlaceInstance(placeId, target.id, player)
    else
        warn("No alternative servers found, using default teleport")
        --TeleportService:Teleport(placeId, player)
    end
end
-- DEBUG ONLY

return ServerManager
