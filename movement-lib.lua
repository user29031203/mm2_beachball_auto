local PathfindingService = game:GetService("PathfindingService")
local Movement = {
    HosterPos = Vector3.new(196, 437, -1080),
    JoinerPos = Vector3.new(189, 437, -1080)
}

-- Helper function to format Vector3 strings nicely (2 decimal places)
function Movement.fmt(vec)
    return string.format("(%.2f, %.2f, %.2f)", vec.X, vec.Y, vec.Z)
end

-- 1. THE DEBUGGER (Runs in background)
-- Displays position in console (F9) every 1 second
function Movement.StartPositionDebug()
    task.spawn(function()
        while true do
            task.wait(1) -- Update every 1 second
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                -- Format numbers to 1 decimal place for cleaner reading
                print(string.format("[POS DEBUG] X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z))
            end
        end
    end)
end


function Movement.SmartWalkTo(targetPosition)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return end

    print("\n------------------------------------------------")
    print("CALCULATING PATH TO: " .. fmt(targetPosition))

    -- 1. Create a path
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentCanJump = true
    })

    -- 2. Compute
    path:ComputeAsync(root.Position, targetPosition)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()

        for i, waypoint in ipairs(waypoints) do
            local targetVec = waypoint.Position
            
            -- Jump if needed
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                hum.Jump = true
            end
            
            hum:MoveTo(targetVec)
            
            -- PRECISION LOOP: Wait until we are physically close to the waypoint
            local reached = false
            local timeout = 0
            
            repeat 
                task.wait()
                timeout = timeout + 1
                
                -- Calculate Horizontal Distance (Ignoring Y/Height)
                local currentPos = root.Position
                local distXZ = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetVec.X, 0, targetVec.Z)).Magnitude
                
                -- Consider "Arrived" if within 1.5 studs
                if distXZ < 1.5 then reached = true end
                
            until reached or timeout > 200 -- Timeout after ~3-4 seconds
            
            -- --- DEBUG LOGGING BLOCK ---
            local actualPos = root.Position
            local diff = actualPos - targetVec
            
            print(string.format("\n[WAYPOINT %d]", i))
            print("Target (Pathfinder): " .. fmt(targetVec))
            print("Actual (RootPart)  : " .. fmt(actualPos))
            print(string.format("Difference         : X:%.2f | Y:%.2f | Z:%.2f", diff.X, diff.Y, diff.Z))
            
            -- Explanation for the Y difference
            if math.abs(diff.Y) > 1.5 then
                print("   ^ Note: The Y-Diff is your Avatar's HipHeight (Floating above floor)")
            end
            -- ---------------------------
        end
        print("\nPATH COMPLETE")
    else
        warn("Pathfinding failed!")
    end
end

return Movement
