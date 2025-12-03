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
function ServerManager.safeHttpGet(url)
    print("[ServerManager] Trying HTTP request:", url)

    local success, result = pcall(function()
        return HttpService:GetAsync(url, false)
    end)

    if success and result then
        print("[ServerManager] HTTP success! Got response.")
        return result
    else
        print("[ServerManager] Normal HTTP failed →", result or "unknown error")
        print("[ServerManager] Falling back to PlayerGui bypass...")
    end

    -- PlayerGui bypass with FULL error visibility
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    if not pg then
        print("[ServerManager] ERROR: PlayerGui not found!")
        return nil
    end

    local resultData = nil
    local finished = false

    local gui = Instance.new("ScreenGui")
    gui.Name = "HttpBypass"
    gui.Parent = pg

    local scr = Instance.new("LocalScript", gui)
    scr.Source = [[
        task.wait(0.2)
        local HttpService = game:GetService("HttpService")
        local url = "]] .. url .. [["
        local ok, res = pcall(HttpService.GetAsync, HttpService, url, false)
        if ok then
            getfenv(0).RESULT = res
            print("[ServerManager] PlayerGui HTTP SUCCESS!")
        else
            print("[ServerManager] PlayerGui HTTP FAILED:", res)
        end
    ]]

    -- Wait for result
    repeat
        task.wait(0.1)
        if scr:FindFirstChild("RESULT") then
            resultData = scr.RESULT.Value
            finished = true
        end
    until finished or not gui.Parent

    task.wait(0.1)
    gui:Destroy()

    if resultData then
        print("[ServerManager] PlayerGui bypass worked!")
        return resultData
    else
        print("[ServerManager] Both HTTP methods failed.")
        return nil
    end
end

-- Get and PRINT all valid servers
function ServerManager.getSmallestServer(placeId)
    print("[ServerManager] Fetching servers for PlaceId:", placeId)
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local raw = ServerManager.safeHttpGet(url)
        if not raw then
            print("[ServerManager] Failed to get server list. Stopping.")
            break
        end

        local success, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not success or not data.data then
            print("[ServerManager] JSON decode failed or no data!")
            break
        end

        print(string.format("[ServerManager] Found %d servers on this page", #data.data))

        for i, sv in ipairs(data.data) do
            if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                table.insert(servers, sv)
                print(string.format("   [%d] %d/%d players | JobId: %s", #servers, sv.playing, sv.maxPlayers, sv.id:sub(1,12).."..."))
            end
        end

        cursor = data.nextPageCursor or ""
        task.wait(0.4)
    until not cursor

    if #servers == 0 then
        print("[ServerManager] No valid servers found (all full or current server)")
        return nil
    end

    table.sort(servers, function(a,b) return a.playing < b.playing end)
    print("[ServerManager] Smallest server has " .. servers[1].playing .. " players")
    return servers[1]
end

-- MAIN FUNCTION
function ServerManager.ChangeServer(placeId)
    placeId = placeId or CONS_INFO.duelsPlaceId
    print("[ServerManager] Starting server hop to PlaceId:", placeId)

    local target = ServerManager.getSmallestServer(placeId)

    if target then
        print("[ServerManager] Teleporting in 2 seconds to server with " .. target.playing .. " players...")
        task.wait(2)  -- You can read console
        TeleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
    else
        print("[ServerManager] No alternative server found. Doing normal teleport in 2 seconds...")
        task.wait(2)
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end
-- DEBUG ONLY

return ServerManager
