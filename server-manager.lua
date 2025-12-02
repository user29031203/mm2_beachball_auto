local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local ServerManager = {
    duelsPlaceId = 12360882630
}

function ServerManager.GetCurrentServerInfo()
    return { PlaceId = game.PlaceId, JobId = game.JobId }
end

function ServerManager.JoinServerById(placeId, jobId, player)
    player = player or Players.LocalPlayer
    if not player then return end
    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end

function ServerManager.JoinRandomServer(placeId, player)
    player = player or Players.LocalPlayer
    placeId = placeId or ServerManager.duelsPlaceId
    if not player then return end
    TeleportService:Teleport(placeId, player)
end

return ServerManager
