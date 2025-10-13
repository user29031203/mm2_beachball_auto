pcall(function()
    repeat wait() until game:IsLoaded()
    local TeleportService = cloneref(game:GetService("TeleportService"))
    local Players = game:GetService("Players")
    local GuiService = cloneref(game:GetService("GuiService"))
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local placeId = game.PlaceId
    local plr = Players.LocalPlayer
    local char = plr.Character
    local GC = getconnections or get_signal_cons

    local REF_POINT = Vector3.new(-12, 140, 15)

    local function getCoinCount()
        local success, coinLabel = pcall(function()
            return plr.PlayerGui:FindFirstChild("MainGUI")
                and plr.PlayerGui.MainGUI:FindFirstChild("Game")
                and plr.PlayerGui.MainGUI.Game:FindFirstChild("CoinBags")
                and plr.PlayerGui.MainGUI.Game.CoinBags:FindFirstChild("Container")
                and plr.PlayerGui.MainGUI.Game.CoinBags.Container:FindFirstChild("BeachBall")
                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall:FindFirstChild("CurrencyFrame")
                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.CurrencyFrame:FindFirstChild("Icon")
                and plr.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.CurrencyFrame.Icon:FindFirstChild("Coins")
        end)
        if success and coinLabel and coinLabel:IsA("TextLabel") then
            local number = tonumber(string.match(coinLabel.Text, "%d+")) or tonumber(coinLabel.Text)
            return number or 0
        end
        return 0
    end

    if GC then
        for _, v in pairs(GC(plr.Idled)) do
            if v.Disable then v:Disable() elseif v.Disconnect then v:Disconnect() end
        end
    else
        local vu = cloneref(game:GetService("VirtualUser"))
        plr.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end

    GuiService.ErrorMessageChanged:Connect(function()
        while true do 
            local suc, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, plr)
            end)
            if suc then break else task.wait(2) end
        end
    end)

    plr.CharacterAdded:Connect(function(newChar)
        char = newChar
        print("Character respawned, script continuing")
    end)

    local map = nil
    game.Workspace.DescendantAdded:Connect(function(m)
        if m:IsA("Model") and m:GetAttribute("MapID") then
            map = m
        end
    end)
    game.Workspace.DescendantRemoving:Connect(function(m)
        if m == map then
            map = nil
        end
    end)

    local coinsCollected = getCoinCount()
    local lastPosition = nil
    local afkMode = false

    while true do
        if afkMode then
            task.wait(5)
            continue -- stay afk forever
        end

        -- Save last position before reaching 40
        if char and char:FindFirstChild("HumanoidRootPart") then
            lastPosition = char.HumanoidRootPart.CFrame
        end

        -- Ensure valid character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            repeat
                char = plr.Character
                task.wait(0.5)
            until char and char:FindFirstChild("HumanoidRootPart")
        end

        -- Wait for map and coins
        while not map or not map:FindFirstChild("CoinContainer") do
            task.wait(1)
        end

        -- Find a coin to collect
        local coinToCollect = nil
        for _, coin in ipairs(map:FindFirstChild("CoinContainer"):GetChildren()) do
            if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                local cv = coin:FindFirstChild("CoinVisual")
                if cv and cv.Transparency ~= 1 then
                    coinToCollect = coin
                    break
                end
            end
        end

        -- Collect coin
        if coinToCollect and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = coinToCollect.CFrame
            task.wait(0.2)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
            task.wait(0.5)
            print("Coin collected: " .. currentCoins)
            task.wait(2)
        else
            task.wait(0.5)
        end
    end

    task.spawn(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua'))()
    end)
end)
