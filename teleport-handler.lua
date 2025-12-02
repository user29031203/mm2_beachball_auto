local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local altsInfo = {
    hosterName = "306a2e5cd_2",
    joinerName = "306a2e5cd_1",
    hosterId = 9359470613, -- A2
    joinerId = 9359433164 -- CD
}

local TELEPORT_HANDLER_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/teleport-handler.lua"
local QUEUE_STRING = "loadstring(game:HttpGet('" .. TELEPORT_HANDLER_URL .. "'))()"

--[[local DWEETR_LIB_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/dweetr-lib.lua" -- Make sure this matches your github link
local DweetLib = loadstring(game:HttpGet(DWEETR_LIB_URL))()
local Comm = DweetLib.new(mySecretKey)]]

local LEADERBOARD_LIB_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/leaderboard-lib.lua"
local LeaderboardApi = loadstring(game:HttpGet(LEADERBOARD_LIB_URL))()

local MOVEMENT_LIB_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/movement-lib.lua"
local MovementApi = loadstring(game:HttpGet(MOVEMENT_LIB_URL))()

local SERVER_MANAGER_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/server-manager.lua"
local ServerManager = loadstring(game:HttpGet(SERVER_MANAGER_URL))()

-- teleportatin support 
local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end


-- Wait for the character (crucial for your reset function
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

print("Environment Ready! Running Sequence...")
-- Your existing functions should now be defined above this line

-- CLEAR OLD LISTENERS FIRST
for _, connection in pairs(getconnections(game.Players.LocalPlayer.CharacterAdded)) do
    connection:Disconnect()
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

LocalPlayer.CharacterAdded:Connect(function(char)
    -- We wait for the humanoid to exist
    local hum = char:WaitForChild("Humanoid", 10)
    local root = char:WaitForChild("HumanoidRootPart", 10)

    -- CHECK: If the character is already dead, it's the old one. Ignore it.
    if hum and hum.Health <= 0 then
        return 
    end

    if root and hum then
        print("RESPAWNED — FULLY LOADED & ALIVE (HP:", hum.Health, ")")
        -- do the method
        task.wait(0.1)
        JoinRandomServer(duelsPlaceId)
		Connect:Disconnect()
    else
        warn("Respawn failed or character missing parts")
		Connect:Disconnect()
    end
end)


-- Lobby matcher
local newCodeArgs = {}

local argString = ""
for i, v in pairs(newCodeArgs) do
    if type(v) == "string" then v = '"'..v..'"' end
    argString = argString .. (i>1 and ", " or "") .. tostring(v)
end

local CODE = [[
    local args = {]]..argString..[[}
    print("Teleported with args:", table.unpack(args))
    -- use args[1], args[2], etc.
]]


-- Check matchmaking
local status = LeaderboardApi.isDuoMatched(altsInfo.hosterName, altsInfo.joinerName)
if status then
    --
else
	pcall(TeleportQueue, CODE)
    ServerManager.JoinRandomServer()
end
