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
                -- Filter: not full, not current server
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            cursor = data.nextPageCursor or ""
        else
            break
        end
    until cursor == ""
    
    return servers
end

function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    local player = Players.LocalPlayer
    
    -- Special case: If same place, quick hop (no HTTP needed)
    if placeId == game.PlaceId then
        TeleportService:Teleport(game.PlaceId, player)
        return
    end
    
    local servers = getServers(placeId)
    if #servers > 0 then
        -- Pick random (or change to servers[1] for lowest pop)
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, player)
    else
        -- Fallback: Normal teleport (might go to popular)
        warn("No low-pop servers found, falling back to default")
        JoinRandomServer()
    end
end
-- DEBUG ONLY
