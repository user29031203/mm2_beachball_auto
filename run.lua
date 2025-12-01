-- Wait for the character (crucial for your reset function)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local duelsPlaceId = 12360882630
local COMMAND = "print('Hello World')" 
local SCRIPT_LOADER_URL = "https://raw.githubusercontent.com/user29031203/mm2_beachball_auto/refs/heads/main/run.lua"
local QUEUE_STRING = "loadstring(game:HttpGet('" .. SCRIPT_LOADER_URL .. "', true))()"
local MyId = LocalPlayer.UserId

-- teleportatin support 
local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end

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

reset()
print("RESET SCRIPT RUNNING!")
