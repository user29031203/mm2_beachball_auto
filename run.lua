-- Wait for the character (crucial for your reset function)
if not LocalPlayer.Character then
    player.CharacterAdded:Wait()
end

print("Environment Ready! Running Sequence...")
-- Your existing functions should now be defined above this line

-- CLEAR OLD LISTENERS FIRST
for _, connection in pairs(getconnections(game.Players.LocalPlayer.CharacterAdded)) do
    connection:Disconnect()
end

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

local function reset()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end

    local camCF = workspace.CurrentCamera.CFrame
    LocalPlayer.Character = nil
    LocalPlayer.Character = char -- This line triggers the first (dead) CharacterAdded event

    task.spawn(function()
        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.1)
        workspace.CurrentCamera.CFrame = camCF
    end)
end
