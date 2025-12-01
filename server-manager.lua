local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local duelsPlaceId = 12360882630

local function JoinServerById(player: Player, placeId: number, jobId: string)
    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end

-- Function to get the current server's PlaceId and JobId
local function getCurrentServerInfo()
    return {
        PlaceId = game.PlaceId,  -- The ID of the place (map/environment) currently running<grok-card data-id="399a2f" data-type="citation_card"></grok-card><grok-card data-id="b7bb03" data-type="citation_card"></grok-card>
        JobId = game.JobId       -- Unique UUID for this specific server instance<grok-card data-id="51a253" data-type="citation_card"></grok-card><grok-card data-id="ffaeb5" data-type="citation_card"></grok-card>
    }
end

-- Function to join a specific server instance by its unique JobId
local function JoinServerById(player: Player, placeId: number, jobId: string)
    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end

local function JoinRandomServer(placeId: number)
    -- Teleport() will automatically find the best available server 
    -- (or create a new one) for the given PlaceId.
    if LocalPlayer then
        TeleportService:Teleport(placeId, LocalPlayer)
    else
        warn("LocalPlayer not available to teleport.")
    end
end
