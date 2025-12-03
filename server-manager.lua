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
-- This is the key: run the HTTP request from PlayerGui, not CoreGui
local HttpService = game:GetService("HttpService")

-- Safe HTTP that bypasses CoreGui block
function ServerManager.safeHttpGet(url)
    local success, result = pcall(HttpService.GetAsync, HttpService, url, false)
    if success then return result end

    -- Blocked? Run in PlayerGui
    local pg = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not pg then return nil end

    local gui = Instance.new("ScreenGui", pg)
    local scr = Instance.new("LocalScript", gui)
    local finished = false

    scr.AncestryChanged:Connect(function()
        if scr.Parent == pg then
            local ok, res = pcall(HttpService.GetAsync, HttpService, url, false)
            if ok then result = res end
            finished = true
            gui:Destroy()
        end
    end)

    local waited = 0
    while not finished and waited < 3 do
        task.wait(0.1)
        waited += 0.1
    end
    return result
end

-- Get smallest available server (not current, not full)
function ServerManager.getSmallestServer(placeId)
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local response = ServerManager.safeHttpGet(url)
        if not response then break end

        local data = HttpService:JSONDecode(response)
        for _, server in ipairs(data.data or {}) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        cursor = data.nextPageCursor or ""
        task.wait(0.3)
    until not cursor

    table.sort(servers, function(a, b) return a.playing < b.playing end)
    return servers[1] or servers[2] or servers[3]
end

-- MAIN FUNCTION - CALL THIS
function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId

    -- Quick hop if same place
    if placeId == game.PlaceId then
        TeleportService:Teleport(placeId, LocalPlayer)
        return
    end

    local target = ServerManager.getSmallestServer(placeId)

    if target then
        print("Hopping to server with " .. target.playing .. " players")
        TeleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
    else
        warn("No other servers found, using default teleport")
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end
-- DEBUG ONLY

return ServerManager
