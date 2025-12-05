local Players = game:GetService("Players")
local Leaderboard = {
    NotMatched = "NOT_MATCHED",
    lobbyColumnName = "Solo Rank",
    duelColumnName = "Rank"
}

function Leaderboard.GetRanks(targetUsernames)
    local results = {}

    for _, username in pairs(targetUsernames) do
        -- 1. Check if player is currently in the server
        local player = Players:FindFirstChild(username)

        if player then
            -- 2. Look for leaderstats
            local stats = player:FindFirstChild("leaderstats")
            
            -- 3. Look for the specific "Solo Rank" value
            -- We use FindFirstChild because the name has a space in it
            local lobbyRankStat = stats and Leaderboard.lobbyColumnName and stats:FindFirstChild(Leaderboard.lobbyColumnName)
            local duelRankStat  = stats and Leaderboard.duelColumnName  and stats:FindFirstChild(Leaderboard.duelColumnName)

            if lobbyRankStat then
                -- Success: Store the value (number or string)
                results[username] = lobbyRankStat.Value
            elseif duelRankStat then
                -- Player exists, but stats haven't loaded or stat name is wrong
                results[username] = duelRankStat.Value
            else
                results[username] = "Stat Not Found"
            end
        else
            -- Player is not in this server
            results[username] = "Not In Server"
        end
    end

    return results
end


function Leaderboard.ShouldHosterLose(hosterName, joinerName)
    local usersToCheck = { hosterName, joinerName }
    
    -- Get the data struct
    local playerStats = Leaderboard.GetRanks(usersToCheck)
    
    local hostRank = playerStats[hosterName]
    local joinerRank = playerStats[joinerName]

    -- CRITICAL STEP: Check if both are actually numbers before comparing!
    if type(hostRank) == "number" and type(joinerRank) == "number" then
        
        print("Comparing Ranks: Host("..hostRank..") vs Joiner("..joinerRank..")")
        
        -- Logic: If Host is higher or equal, they should lose (to lower MMR?)
        return hostRank >= joinerRank  
        
    else
        -- If one person is missing or stats are "Stat Not Found"
        warn("Cannot compare ranks! One player is missing or loading.")
        warn("Host Status:", hostRank, " | Joiner Status:", joinerRank)
        
        -- Return a default value (e.g., false) so script continues safely
        return Leaderboard.NotMatched
    end
end -- <--- This 'end' was missing in your code


function Leaderboard.IsDuoMatched(hosterName, joinerName, ShouldHosterLose)
    ShouldHosterLose = ShouldHosterLose or Leaderboard.ShouldHosterLose(hosterName, joinerName)
    return if ShouldHosterLose == Leaderboard.NotMatched then false else true
end
    
return Leaderboard
