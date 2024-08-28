local queueonteleport = syn and syn.queue_on_teleport or queue_for_teleport or queue_on_teleport or queueonteleport

local games = {
    [6872274481] = "BedWars",
    [8444591321] = "BedWars",
    [8560631822] = "BedWars",
    [6872265039] = "lobby"
}

shared.AristoisPlaceId = game.PlaceId
local currentGame = games[game.PlaceId]
if games[game.PlaceId] == "BedWars" then
    shared.AristoisPlaceId = 6872274481
elseif games[game.PlaceId] == "lobby" then
    shared.AristoisPlaceId = 6872265039
end

assert(not shared.Executed, "Already Injected")
shared.Executed = true

if shared.AristoisPlaceId == 6872274481 and identifyexecutor and ({identifyexecutor()})[1] == "Solara" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Games/support.lua"))()
else
    scriptPath = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
    if not currentGame or not pcall(function() game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/" .. scriptPath) end) then
        scriptPath = "Aristois/Universal.lua"
    end
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/" .. scriptPath))()
end

local ServerSwitchScript = [[
    if shared.dev then
        print("waza")
    else
        loadstring(game:HttpGet('https://raw.githubusercontent.com/XzynAstralz/Aristois/main/MainScript.lua'))()
    end
]]

game.Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State and queueonteleport then
        queueonteleport(ServerSwitchScript)
    end
end)
