local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local HashLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/sha.lua", true))()
local Whitelist = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))

local function hashUserIdAndUsername(userId, username)
    local combinedString = tostring(userId) .. tostring(username)
    return HashLib.sha512(combinedString .. "SelfReport")
end

local ChatTagModule = {}
local player = Players.LocalPlayer
local hashedCombined = hashUserIdAndUsername(player.UserId, player.Name)
ChatTagModule.hashedCombined = hashedCombined
ChatTagModule.hashUserIdAndUsername = hashUserIdAndUsername

function ChatTagModule.checkstate(player)
    local hashedCombined = hashUserIdAndUsername(player.UserId, player.Name)
    return Whitelist[hashedCombined] ~= nil
end

function ChatTagModule.getCustomTag(player)
    local hashedCombined = hashUserIdAndUsername(player.UserId, player.Name)
    if Whitelist[hashedCombined] and Whitelist[hashedCombined].tags and Whitelist[hashedCombined].tags[1] then
        local tag = Whitelist[hashedCombined].tags[1]
        return tag.text, Color3.fromRGB(unpack(tag.color)), Whitelist[hashedCombined].PlayerType
    end
    return nil, nil, nil
end

function ChatTagModule.Isattack(player)
    local hashedCombined = hashUserIdAndUsername(player.UserId, player.Name)
    if Whitelist[hashedCombined] then
        return Whitelist[hashedCombined].attackable
    end
    return true
end

function rgbToHex(r, g, b)
    local hex = string.format("#%02x%02x%02x", r, g, b)
    return hex
end

local ChatTag = {}
function ChatTagModule.UpdateTags()
    local tagText, tagColor, playerType = ChatTagModule.getCustomTag(player)
    if tagText and tagColor then
        ChatTag[player.UserId] = {
            TagColor = tagColor,
            TagText = tagText,
            PlayerType = playerType or "PRIVATE"
        }
    end

    local oldchanneltabs = {}
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")

    if chatEvents then
        for i, v in pairs(getconnections(chatEvents.OnNewMessage.OnClientEvent)) do
            if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
                local oldchanneltab = getmetatable(debug.getupvalues(v.Function)[1])
                local oldchannelfunc = getmetatable(debug.getupvalues(v.Function)[1]).GetChannel
                getmetatable(debug.getupvalues(v.Function)[1]).GetChannel = function(Self, Name)
                    local tab = oldchannelfunc(Self, Name)
                    if tab and tab.AddMessageToChannel then
                        local addmessage = tab.AddMessageToChannel
                        if oldchanneltabs[tab] == nil then
                            oldchanneltabs[tab] = tab.AddMessageToChannel
                        end
                        tab.AddMessageToChannel = function(Self2, MessageData)
                            if MessageData.FromSpeaker and Players[MessageData.FromSpeaker] then
                                if ChatTag[Players[MessageData.FromSpeaker].UserId] then
                                    MessageData.ExtraData = {
                                        NameColor = Players[MessageData.FromSpeaker].Team == nil and Color3.new(135, 206, 235) or Players[MessageData.FromSpeaker].TeamColor.Color,
                                        Tags = {{
                                            TagColor = ChatTag[Players[MessageData.FromSpeaker].UserId].TagColor,
                                            TagText = ChatTag[Players[MessageData.FromSpeaker].UserId].TagText,
                                        }},
                                    }
                                end
                            end
                            return addmessage(Self2, MessageData)
                        end
                    end
                    return tab
                end
            end
        end
    elseif TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            local properties = Instance.new("TextChatMessageProperties")
            if message.TextSource then
                local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
                if sender and ChatTag[sender.UserId] then
                    local r, g, b = ChatTag[sender.UserId].TagColor.r * 255, ChatTag[sender.UserId].TagColor.g * 255, ChatTag[sender.UserId].TagColor.b * 255
                    local hexColor = rgbToHex(r, g, b)
                    properties.PrefixText = "<font color='" .. hexColor .. "'>[" .. ChatTag[sender.UserId].TagText .. "]</font> " .. message.PrefixText
                end
            end
            return properties
        end
    end
    return ChatTag
end

for i, player in pairs(game.Players:GetPlayers()) do
    if ChatTagModule.checkstate(player) then
        local tagText, tagColor, playerType = ChatTagModule.getCustomTag(player)
        if tagText and tagColor then
            ChatTag[player.UserId] = {
                TagColor = tagColor,
                TagText = tagText,
                PlayerType = playerType or "PRIVATE"
            } 
        end
    end
end

function ChatTagModule.AddExtraTag(player, tagText, tagColor)
    ChatTag[player.UserId] = {
        TagColor = tagColor,
        TagText = tagText,
        PlayerType = "PRIVATE"
    } 
end

Players.PlayerRemoving:Connect(function(v)
    if ChatTag[v.UserId] then
        ChatTag[v.UserId] = nil
    end
end)

return ChatTagModule
