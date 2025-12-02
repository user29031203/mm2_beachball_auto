local leaderstats = LocalPlayer:WaitForChild("leaderstats", generalTimeout)
local function RejoinIfNoDuo()
    if leaderstats then
        print("leaderstats loaded — checking duo status...")
        local status = LeaderboardApi.IsDuoMatched(altsInfo.hosterName, altsInfo.joinerName)
        -- true was status, it changed to true for testing purposes only
        if status then
            return true
        else 
            print("Matched with a random!")
            ServerApi.JoinRandomServer()
        end
    else
        warn("leaderstats NEVER loaded → Hopping anyway (safe fallback)")
        task.wait(0.1)
        ServerApi.JoinRandomServer()
    end
end
