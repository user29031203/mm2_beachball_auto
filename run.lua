-- Auto-restarting wrapper for your GitHub script
-- Place this code in your executor instead of the full script

local SCRIPT_URL = "https://raw.githubusercontent.com/user29031203/LuaRobloxExec/refs/heads/main/beachball-auto.lua" -- 🔧 change this to your real repo link

task.spawn(function()
    local lastCoinTime = tick()
    local lastCoinCount = 0

    while true do
        local ok, err = pcall(function()
            -- Load and execute your main script
            local scriptFunc, loadErr = loadstring(game:HttpGet(SCRIPT_URL))
            if not scriptFunc then
                error("Failed to load script: " .. tostring(loadErr))
            end

            -- Run the loaded script in a protected call
            local success, innerErr = pcall(function()
                -- Run in a subthread to monitor activity
                task.spawn(function()
                    while true do
                        task.wait(30)
                        local coinCount = 0
                        local success, val = pcall(function()
                            local plr = game:GetService("Players").LocalPlayer
                            local label = plr.PlayerGui:FindFirstChild("MainGUI")
                                and plr.PlayerGui.MainGUI.Game
                                and plr.PlayerGui.MainGUI.Game.CoinBags
                                and plr.PlayerGui.MainGUI.Game.CoinBags.Container
                                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall
                                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.CurrencyFrame
                                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.CurrencyFrame.Icon
                                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.CurrencyFrame.Icon:FindFirstChild("Coins")
                            if label and label:IsA("TextLabel") then
                                return tonumber(string.match(label.Text, "%d+")) or 0
                            end
                            return 0
                        end)
                        if success then coinCount = val end

                        if coinCount > 0 then
                            lastCoinTime = tick()
                            lastCoinCount = coinCount
                        end

                        if tick() - lastCoinTime > 180 then -- 3 minutes no coins
                            error("[AutoRestart] No coins detected for over 3 minutes")
                        end
                    end
                end)

                -- Actually run your repo script
                scriptFunc()
            end)

            if not success then
                error(innerErr or "Unknown error inside script")
            end
        end)

        if not ok then
            warn("[AutoRestart] Script crashed or frozen: " .. tostring(err))
            warn("[AutoRestart] Restarting in 5 seconds...")
            task.wait(5)
        end
    end
end)
