local request = syn and syn.request or http and http.request or http_request or request
local lplr = game:GetService("Players").LocalPlayer

local Aristois = {
    PlaceId = game.PlaceId,
    queueonteleport = queue_for_teleport or queue_on_teleport or queueonteleport,
    Paths = {
        SupportScript = "https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Games/support.lua",
        UniversalScript = "https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Aristois/Universal.lua",
        BaseUrl = "https://raw.githubusercontent.com/XzynAstralz/Aristois/main/"
    },
    ExecutorCheck = identifyexecutor and ({identifyexecutor()})[1] == "Solara",
}

assert(not shared.Executed, "Already Injected")
shared.Executed = true

local scriptPath
local success, errorMessage

success, errorMessage = pcall(function()
    if Aristois.PlaceId == 6872274481 or Aristois.PlaceId == 8444591321 or Aristois.PlaceId == 8560631822 then
        Aristois.PlaceId = 6872274481
        if Aristois.ExecutorCheck then
            loadstring(game:HttpGet(Aristois.Paths.SupportScript))()
        else
            scriptPath = "Aristois/Games/" .. tostring(Aristois.PlaceId) .. ".lua"
        end
    elseif Aristois.PlaceId == 6872265039 then
        Aristois.PlaceId = 6872265039
        scriptPath = "Aristois/Games/" .. tostring(Aristois.PlaceId) .. ".lua"
    else
        scriptPath = "Aristois/Universal.lua"
    end
end)

if scriptPath then
    loadstring(game:HttpGet(Aristois.Paths.BaseUrl .. scriptPath))()
end

local ServerSwitchScript = [[
    loadstring(game:HttpGet('https://raw.githubusercontent.com/XzynAstralz/Aristois/main/MainScript.lua'))()
]]

lplr.OnTeleport:Connect(function(State)
    if State and Aristois.queueonteleport then
        Aristois.queueonteleport(ServerSwitchScript)
    end
end)

if not success then
    request({
        Url = 'http://127.0.0.1:6463/rpc?v=1',
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json',
            Origin = 'https://discord.com'
        },
        Body = game:GetService("HttpService"):JSONEncode({
            cmd = 'INVITE_BROWSER',
            nonce = game:GetService("HttpService"):GenerateGUID(false),
            args = { code = "pvVKJNqZsS" }
        })
    })
end
