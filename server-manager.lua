local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ServerManager = {
    duelsPlaceId = 12360882630
}

function ServerManager.getCurrentServerInfo()
    return {
        PlaceId = game.PlaceId,
        JobId = game.JobId
    }
end

function ServerManager.JoinServerById(placeId: number, jobId: string)
    TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
end

function ServerManager.JoinRandomServer(placeId: number?)
    placeId = placeId or ServerManager.duelsPlaceId
    TeleportService:Teleport(placeId, LocalPlayer)
end

return ServerManager  -- ← THIS IS CRITICAL
