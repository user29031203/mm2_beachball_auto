local TeleportQueue = queue_on_teleport 
if not TeleportQueue then
    TeleportQueue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end
if not TeleportQueue then
    warn("Executor TeleportQueue function not found. Cannot queue command for next server.")
    return
end


--pcall(TeleportQueue, "_G.test = 5")
if _G.test then
	print(_G.test)
else
	print("No time machine proof?!")
end

print("DONE!")