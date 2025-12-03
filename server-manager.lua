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
local HttpService = game:GetService("HttpService")

local function getServers(placeId)
    local servers = {}
    local cursor = ""
    repeat
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId)
        if cursor ~= "" then
            url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
        end
        
        local success, result = pcall(HttpService.GetAsync, HttpService, url)
        if success then
            local data = HttpService:JSONDecode(result)
            for _, server in ipairs(data.data) do
                -- Exclude full servers and current server (safe for cross-place)
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            cursor = data.nextPageCursor or ""
        else
            warn("Failed to fetch servers:", result)
            break
        end
    until cursor == ""
    
    -- Explicitly sort by ascending player count (API already does, but safe)
    table.sort(servers, function(a, b)
        return a.playing < b.playing
    end)
    
    return servers
end

function ServerManager.ChangeServer(placeId)  -- Now JoinSmallestServer really
    placeId = placeId or CONS_INFO.duelsPlaceId
    local player = Players.LocalPlayer
    
    local servers = getServers(placeId)
    if #servers > 0 then
        -- Pick SMALLEST available server (servers[1] after sort)
        local smallestServer = servers[1]
        -- Double-check not current (paranoia)
        if smallestServer.id == game.JobId then
            smallestServer = servers[2] or servers[1]
        end
        TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, player)
        print("Hopping to smallest server:", smallestServer.playing .. "/" .. smallestServer.maxPlayers, "ID:", smallestServer.id)
    else
        -- Fallback: Roblox picks a viable server (usually different for same-place)
        warn("No low-pop servers available, using default teleport")
        --TeleportService:Teleport(placeId, player)
    end
end
-- DEBUG ONLY

return ServerManager
