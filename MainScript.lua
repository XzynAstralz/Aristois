local queueonteleport = syn and syn.queue_on_teleport or queue_for_teleport or queue_on_teleport or queueonteleport

local games = {
    [6872274481] = "BedWars",
    [8444591321] = "BedWars",
    [8560631822] = "BedWars",
    [6872265039] = "lobby"
}

shared.AristoisPlaceId = game.PlaceId

if games[game.PlaceId] == "BedWars" then
    shared.AristoisPlaceId = 6872274481
elseif games[game.PlaceId] == "lobby" then
    shared.AristoisPlaceId = 6872265039
end

assert(not shared.Executed, "Already Injected")
shared.Executed = true

local scriptPath = shared.AristoisPlaceId == 6872274481 and identifyexecutor and ({identifyexecutor()})[1] == "Solara" and "https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Games/support.lua" or ("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua")

if not games[game.PlaceId] or not pcall(function() game:HttpGet(scriptPath) end) then
    scriptPath = "https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Aristois/Universal.lua"
end

loadstring(game:HttpGet(scriptPath))()

game.Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State and queueonteleport then
        queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/XzynAstralz/Aristois/main/NewMainScript.lua'))()")
    end
end)

print(shared.WhitelistFile)
