local queueonteleport = (syn and syn.queue_on_teleport) or queue_for_teleport or queue_on_teleport or queueonteleport

local games = {
    [6872274481] = "BedWars",
    [8444591321] = "BedWars",
    [8560631822] = "BedWars",
    [6872265039] = "lobby"
}

local currentGame = games[game.PlaceId]
shared.AristoisPlaceId = game.PlaceId

if currentGame == "BedWars" then 
    shared.AristoisPlaceId = 6872274481
elseif currentGame == "lobby" then
    shared.AristoisPlaceId = 6872265039
end

assert(not shared.Executed, "Already Injected")
shared.Executed = true

local scriptPath = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
if not currentGame or not isfile(scriptPath) then
    scriptPath = "Aristois/Universal.lua"
end

loadstring(readfile(scriptPath))()

local ServerSwitchScript = [[
    loadstring(readfile("Aristois/MainScript.lua"))()
]]

game.Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State and queueonteleport then
        queueonteleport(ServerSwitchScript)
    end
end)
