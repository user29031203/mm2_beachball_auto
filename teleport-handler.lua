
--DEBUGCONSOLE
game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MyId = LocalPlayer.UserId

local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- external libs 
local ServerApi = CONS_INFO.Load(CONS_INFO.URLS.SERVER_MANAGER_URL)

-- initialize executor specific required APIs
local TeleportQueue = CONS_INFO.Load(CONS_INFO.URLS.EXECUTOR_API_INIT_URL)
print("INIT!")
if not TeleportQueue then return end --check if it loaded without problems
print("INIT! DONE!")

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

    --[[task.spawn(function()
        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.1)
        workspace.CurrentCamera.CFrame = camCF
    end)]]
end

-- character load and wait func

local function characterChecker() 
    LocalPlayer.CharacterAdded:Connect(function(char)
        -- We wait for the humanoid to exist
        local hum = char:WaitForChild("Humanoid", CONS_INFO.generalTimeout)
        local root = char:WaitForChild("HumanoidRootPart", CONS_INFO.generalTimeout)

        -- CHECK: If the character is already dead, it's the old one. Ignore it.
        if hum and hum.Health <= 0 then
            return 
        end

        if root and hum then
            print("RESPAWNED — FULLY LOADED & ALIVE (HP:", hum.Health, ")")
            -- do the method
            ServerApi.JoinRandomServer()
            Connect:Disconnect()
        else
            ServerApi.JoinRandomServer()
            warn("Respawn failed or character missing parts")
            Connect:Disconnect()
        end
    end)
end 

print("CALLING WRONG MATCH HANDLER!")
--local WrongMatchHandler = CONS_INFO.Load(CONS_INFO.URLS.WRONG_MATCH_HANDLER_URL)
local WrongMatchHandler = true
if WrongMatchHandler == true then
    print("GONNA RESET!")
    reset()
    characterChecker()
else 
    print("WHY DIDNT WORK?", WrongMatchHandler)
end

