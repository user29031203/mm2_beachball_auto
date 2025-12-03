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
function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    local player = Players.LocalPlayer

    local teleportOptions = Instance.new("TeleportOptions")
    -- This random data helps Roblox's load balancer put you in different servers
    teleportOptions:SetTeleportData({
        ServerRandomizer = math.random(1, 1000000000) + tick()
    })

    TeleportService:TeleportAsync(placeId, {player}, teleportOptions)
end

return ServerManager
