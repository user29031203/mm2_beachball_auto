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

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- debug purposes only
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local function getServers(placeId)
    local cursor = ""
    local servers = {}
    repeat
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId)
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        
        local success, result = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if success then
            local data = HttpService:JSONDecode(result)
            for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            cursor = data.nextPageCursor
        end
    until not cursor
    
    return servers
end

-- debug only
function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    local servers = getServers(placeId)
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, Players.LocalPlayer)
    else
        warn("No available servers found")
    end
end
