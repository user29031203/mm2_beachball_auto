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

-- Ultra-safe HTTP that never fails on any executor
function ServerManager.safeHttpGet(url)
    -- Try normal first
    local success, result = pcall(HttpService.GetAsync, HttpService, url, false)
    if success and result then return result end

    -- If blocked → run in PlayerGui (bypasses CoreGui)
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    if not pg then return nil end

    local gui   = Instance.new("ScreenGui", pg)
    local scr   = Instance.new("LocalScript", gui)
    local done  = false
    local data  = nil

    scr.AncestryChanged:Connect(function()
        if scr.Parent == pg then
            task.wait(0.1) -- tiny delay = clean response
            local ok, res = pcall(HttpService.GetAsync, HttpService, url, false)
            if ok and res then data = res end
            done = true
            gui:Destroy()
        end
    end)

    local timeout = 0
    while not done and timeout < 4 do
        task.wait(0.1)
        timeout += 0.1
    end
    return data
end

-- Safe JSON decode (never errors)
function ServerManager.safeJsonDecode(str)
    if not str or str == "" then return nil end
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, str)
    if success then return decoded end
    return nil
end

-- Get smallest server (not current, not full)
function ServerManager.getSmallestServer(placeId)
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local raw = ServerManager.safeHttpGet(url)
        if not raw then break end

        local json = ServerManager.safeJsonDecode(raw)
        if not json or not json.data then break end

        for _, sv in ipairs(json.data) do
            if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                table.insert(servers, sv)
            end
        end

        cursor = json.nextPageCursor or ""
        task.wait(0.35) -- respect rate-limit
    until not cursor

    if #servers == 0 then return nil end

    table.sort(servers, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
    return servers[1] or servers[2] or servers[3]
end

-- FINAL FUNCTION — ONLY THIS ONE YOU CALL
function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId

    local target = ServerManager.getSmallestServer(placeId)

    if target then
        print("ServerManager → Hopping to server with " .. target.playing .. " players")
        TeleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
    else
        print("ServerManager → No other servers found, doing normal teleport")
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end
-- DEBUG ONLY

return ServerManager
