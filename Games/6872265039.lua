if identifyexecutor and ({identifyexecutor()})[1] == "Solara" then
    return 
end
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextChatService = game:GetService("TextChatService")
local getcustomasset = getsynasset or getcustomasset
local HttpService = game:GetService("HttpService")
local VirtualUserService = game:GetService("VirtualUser")
local GuiLibrary = loadstring(readfile("Aristois/GuiLibrary.lua"))()
local PlayerUtility = loadstring(readfile("Aristois/Librarys/Utility.lua"))()
local WhitelistModule = loadstring(readfile("Aristois/Librarys/Whitelist.lua"))()
local weaponMeta = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/test/main/sword.json"))
local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local Whitelist = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))
local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end
shared.WhitelistFile = WhitelistModule
local staffound = false

local newData = {
    whitelist = {
        ChatStrings = {
            Aristois = "I'm using Aristois",
        }
    },
    statistics = {
        Reported = {},
        ReportedCount = 0,
    },
    toggles = {},
}

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(ReplicatedStorage.TS.remotes).default.Client
local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
local InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
local ItemTable = debug.getupvalue(require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta, 1)
repeat task.wait() until Flamework.isInitialized

local Window = GuiLibrary:CreateWindow({
    Name = "Aristois",
    LoadingTitle = "Aristois Interface",
    LoadingSubtitle = "by Xzyn and Wynnech",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "Aristois/configs",
       FileName = tostring(shared.AristoisPlaceId) and (tostring(shared.AristoisPlaceId) .. ".lua") 
    },
    Discord = {
       Enabled = false,
       Invite = "",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
 })

local function BindToLoop(loopTable, loopEvent, name, func)
    if loopTable[name] == nil then
        loopTable[name] = loopEvent:Connect(func)
    end
end

local function UnbindFromLoop(loopTable, name)
    if loopTable[name] then
        loopTable[name]:Disconnect()
        loopTable[name] = nil
    end
end

function RunLoops:BindToRenderStep(name, func)
    BindToLoop(self.RenderStepTable, RunService.RenderStepped, name, func)
end

function RunLoops:UnbindFromRenderStep(name)
    UnbindFromLoop(self.RenderStepTable, name)
end

function RunLoops:BindToStepped(name, func)
    BindToLoop(self.StepTable, RunService.Stepped, name, func)
end

function RunLoops:UnbindFromStepped(name)
    UnbindFromLoop(self.StepTable, name)
end

function RunLoops:BindToHeartbeat(name, func)
    BindToLoop(self.HeartTable, RunService.Heartbeat, name, func)
end

function RunLoops:UnbindFromHeartbeat(name)
    UnbindFromLoop(self.HeartTable, name)
end

local Combat = Window:CreateTab("Combat", "17155691785")
local Blatant = Window:CreateTab("Blatant", "17155691785")
local Render = Window:CreateTab("Render", "17155691785")
local Utility = Window:CreateTab("Utility", "17155691785")
local Word = Window:CreateTab("Word", "17155691785")

local function runcode(func) func() end

local bedwars = setmetatable({
    QueueMeta = require(game:GetService("ReplicatedStorage").TS.game["queue-meta"]).QueueMeta,
}, newData.BedWarsMeta)

