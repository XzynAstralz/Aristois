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
local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local Whitelist = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))
local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end
shared.WhitelistFile = WhitelistModule
local staffound = false
getgenv().SecureMode = true

local debuggerMode = true
local ogPrint = print

local function getTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local print = function(...)
    if debuggerMode then
        local status, err = pcall(function(...)
            ogPrint(getTime(), ...)
        end, ...)
        
        if not status then
            ogPrint(getTime(), "Error detected:", err)
        end
    end
end

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
    queueType = "",
    matchState = 0,
    customatch = false,
    Attacking = false,
    BedWarsMeta = {
        __index = function(t, k)
            return rawget(t, k)
        end,
    
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    },
    createBoxAdornment = function()
        local boxHandleAdornment = Instance.new("BoxHandleAdornment")
        boxHandleAdornment.Size = Vector3.new(4, 6, 4)
        boxHandleAdornment.Color3 = Color3.new(1, 0, 0)
        boxHandleAdornment.Transparency = 0.6
        boxHandleAdornment.AlwaysOnTop = true
        boxHandleAdornment.ZIndex = 10
        boxHandleAdornment.Parent = workspace
        return boxHandleAdornment
    end
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
local Exploits = Window:CreateTab("Exploits", "17155691785")

local function runcode(func) func() end

local bedwars = setmetatable({
    ItemTable = ItemTable, 
    sprintTable = KnitClient.Controllers.SprintController,
    SwordController = KnitClient.Controllers.SwordController,
    ViewmodelController = KnitClient.Controllers.ViewmodelController,
    KnockbackUtil = require(ReplicatedStorage.TS.damage["knockback-util"]).KnockbackUtil,
    DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
    AnimationType = require(ReplicatedStorage.TS.animation["animation-type"]).AnimationType,
    SoundList = require(ReplicatedStorage.TS.sound["game-sound"]).GameSound,
    NotificationController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/notification-controller@NotificationController"),
    PickupRemote = ReplicatedStorage["rbxts_include"]["node_modules"]["@rbxts"].net.out["_NetManaged"].PickupItemDrop,
    SwordHit = ReplicatedStorage["rbxts_include"]["node_modules"]["@rbxts"].net.out["_NetManaged"].SwordHit,
    ConsumeItem = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ConsumeItem,
    PlayGuitar = ReplicatedStorage["rbxts_include"]["node_modules"]["@rbxts"].net.out["_NetManaged"].PlayGuitar,
    ProjectileFire = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileFire,
    ClientHandlerStore = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
    ReportPlayer = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ReportPlayer,
    BlockController = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
    PlaceBlock = ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged.PlaceBlock,
    CombatConstant = require(ReplicatedStorage.TS.combat["combat-constant"]).CombatConstant,
    Inventory = function()
        return InventoryUtil.getInventory(lplr)
    end,
    getIcon = function(item, showinv)
        return (ItemTable[item.itemType] and ItemTable[item.itemType].image)
    end,
    inventory = nil,
    inventoryFolder = nil
}, newData.BedWarsMeta)

local function updateGameData(previousState, currentState)
    local gameState = bedwars.ClientHandlerStore:getState().Game
    if previousState.Game ~= currentState.Game then
        newData.matchState = gameState.matchState
        newData.queueType = gameState.queueType or "bedwars_test"
        newData.customMatch = gameState.customMatch
    end
    if previousState.Inventory ~= currentState.Inventory then
        local observedInventory = previousState.Inventory.observedInventory or { inventory = {} }
        local handItem = observedInventory.inventory.hand
        if handItem then
            local itemType = handItem.itemType
            local itemDetails = bedwars.ItemTable[itemType]

            local handItemCategory = itemDetails.block and "block" or (itemType:find("bow") and "bow" or nil)

            newData.Hand = {
                tool = handItem.tool,
                Type = handItemCategory,
                amount = handItem.amount or 0
            }
        end
    end
end

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

RunLoops:BindToHeartbeat("inventory", function()
    if PlayerUtility.IsAlive(lplr) and lplr.Character:FindFirstChild("InventoryFolder") then
        if not bedwars.inventoryFolder then
            bedwars.inventoryFolder = lplr.Character.InventoryFolder
            local newInventory = lplr.Character.InventoryFolder.Value
            if newInventory ~= bedwars.inventory then
                bedwars.inventory = newInventory
            end
            bedwars.inventoryFolder:GetPropertyChangedSignal("Value"):Connect(function()
                if newInventory ~= bedwars.inventory then
                    bedwars.inventory = newInventory
                end
            end)
        end
    else
        bedwars.inventoryFolder = nil
    end
end)

bedwars.ClientHandlerStore.changed:connect(updateGameData)
updateGameData(bedwars.ClientHandlerStore:getState(), {})

local function getSword()
    local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
    for slot, item in next, bedwars.Inventory(lplr).items do
        local swordMeta = bedwars.ItemTable[item.itemType].sword
        if swordMeta then
            local swordDamage = swordMeta.damage or 0
            if swordDamage > bestSwordDamage then
                bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
            end
        end
    end
    return bestSword, bestSwordSlot
end

local function getserverpos(Position)
    local x = math.round(Position.X/3)
    local y = math.round(Position.Y/3)
    local z = math.round(Position.Z/3)
    return Vector3.new(x,y,z)
end

local function getItem(itm)
    if PlayerUtility.IsAlive(lplr) then
        local inventoryFolder = lplr.Character:FindFirstChild("InventoryFolder")
        if inventoryFolder and inventoryFolder:FindFirstChild(itm) then
            return true
        end
    end
    return false
end

local function createNotification(title, content, duration, image, actions)
    local notification = {
        Title = title or "Notification Title",
        Content = content or "Notification Content",
        Duration = duration or 6.5,
        Image = image or 4483362458,
        Actions = {}
    }

    if actions then
        for actionName, actionDetails in pairs(actions) do
            notification.Actions[actionName] = {
                Name = actionDetails.Name or actionName,
                Callback = actionDetails.Callback or function() end
            }
        end
    end

    GuiLibrary:Notify(notification)
end

local function switchItem(tool)
    if lplr.Character.HandInvItem.Value ~= tool then
        local args = { hand = tool }
        local remote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem")
        
        remote:InvokeServer(args)

        local startTime = tick()
        local timeout = 0.3
        local function checkCondition()
            return lplr.Character.HandInvItem.Value == tool
        end
        
        RunService.Heartbeat:Connect(function()
            if tick() - startTime > timeout or checkCondition() then
                return
            end
        end)

        repeat
            RunService.RenderStepped:Wait()
        until checkCondition() or tick() - startTime > timeout
    end
end

local function SpeedMultiplier(flight)
    local baseMultiplier = 0
    local multiplier = 1
    local funny = false
    local characterAttributes = lplr.Character:GetAttributes()

    if characterAttributes.StatusEffect_speed then
        multiplier = multiplier * 1.55
        funny = true
    end

    if characterAttributes.SpeedBoost then
        local speedBoostMultiplier = characterAttributes.SpeedBoost
        multiplier = multiplier * speedBoostMultiplier
        funny = true
    end

    if characterAttributes.GrimReaperChannel then
        multiplier = multiplier + 1.86
        funny = true
    end

    if funny then
        baseMultiplier = baseMultiplier + (multiplier - 1) * 0.985
    elseif flight then
        baseMultiplier = 0.93
    else
        baseMultiplier = 0.985
    end
    
    return baseMultiplier
end

runcode(function()
    local Section = Combat:CreateSection("Reach", false)
    local Reach = {["Value"] = 14.4}
    local oldRaycastDistance, oldRegionDistance

    newData.toggles.Reach = Combat:CreateToggle({
        Name = "Reach",
        CurrentValue = false,
        Flag = "Reach",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                oldRaycastDistance = bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE
                oldRegionDistance = bedwars.CombatConstant.REGION_SWORD_CHARACTER_DISTANCE
                bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = Reach.Value
                bedwars.CombatConstant.REGION_SWORD_CHARACTER_DISTANCE = Reach.Value
            else
                bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = oldRaycastDistance
                bedwars.CombatConstant.REGION_SWORD_CHARACTER_DISTANCE = oldRegionDistance
            end
        end
    })
    newData.toggles.ReachSlider = Combat:CreateSlider({
        Name = "Amount",
        Range = {1, 21},
        Increment = 1,
        Suffix = "MaxDistance",
        CurrentValue = Reach.Value,
        Flag = "ReachValue",
        SectionParent = Section,
        Callback = function(Value)
            Reach.Value = Value
            if newData.toggles.Reach.CurrentValue then
                bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = Reach.Value
                bedwars.CombatConstant.REGION_SWORD_CHARACTER_DISTANCE = Reach.Value
            end
        end
    })
end)

local nearestEntities = {}
local Distance = {["Value"] = 22}
runcode(function()
    local Section = Blatant:CreateSection("Killaura", false)
    local FacePlayerEnabled = {Enabled = false}
    local BoxesEnabled = {Enabled = false}
    local AttackAnimEnabled = {Enabled = false}
    local SwingEnabled = {Enabled = false}
    local VMAnimActive = false
    local lastEndAnim = tick()
    local Animations = {
        Normal = {
            {CFrame = CFrame.new(-0.17, 0.14, -0.12) * CFrame.Angles(math.rad(-53), math.rad(50), math.rad(-64)), Time = 0.1}, 
            {CFrame = CFrame.new(-0.55, -0.59, -0.1) * CFrame.Angles(math.rad(-161), math.rad(54), math.rad(-6)), Time = 0.08},
            {CFrame = CFrame.new(-0.62, -0.68, -0.07) * CFrame.Angles(math.rad(-167), math.rad(47), math.rad(-1)), Time = 0.03}, 
            {CFrame = CFrame.new(-0.56, -0.86, 0.23) * CFrame.Angles(math.rad(-167), math.rad(49), math.rad(-1)), Time = 0.03}
        },
        Better = {
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.2},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
        },
        Slow = {
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
        },
        Good = {
            {CFrame = CFrame.new(0.80, -0.1, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
            {CFrame = CFrame.new(0.80, -0.71, 0.6) * CFrame.Angles(math.rad(360), math.rad(32), math.rad(1)), Time = 0.15},
        },
        Astral = {
            {CFrame = CFrame.new(0.69, -0.65, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
            {CFrame = CFrame.new(0.69, -0.66, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
            {CFrame = CFrame.new(-0.62, -0.63, -0.07) * CFrame.Angles(math.rad(-167), math.rad(47), math.rad(-1)), Time = 0.11},
            {CFrame = CFrame.new(-0.56, -0.81, 0.23) * CFrame.Angles(math.rad(-167), math.rad(49), math.rad(-1)), Time = 0.11}
        }
    }
    local EndAnimation = {
        {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
    }

    local boxHandleAdornment = newData.createBoxAdornment()
    local activeAdornments = {}
    local function updateBoxAdornments(root)    
        if BoxesEnabled.Enabled then
            local existingAdornment = root:FindFirstChild("BoxHandleAdornment")
            local boxHandleAdornment = activeAdornments[root]

            if not boxHandleAdornment then
                boxHandleAdornment = newData.createBoxAdornment()
                activeAdornments[root] = boxHandleAdornment
            end

            if not existingAdornment then
                boxHandleAdornment.Adornee = root
                if boxHandleAdornment.Adornee then
                    local cf = boxHandleAdornment.Adornee.CFrame
                    local x, y, z = cf:ToEulerAnglesXYZ()
                    boxHandleAdornment.CFrame = CFrame.new() * CFrame.Angles(-x, -y, -z)
                    boxHandleAdornment.Parent = root
                end
            end
        end
    end

    local function clearAdornments()
        if BoxesEnabled.Enabled then
            for _, boxHandleAdornment in pairs(activeAdornments) do
                boxHandleAdornment.Adornee = nil
                boxHandleAdornment.Parent = nil
            end
            activeAdornments = {}
        end
    end

    local oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
    local origC0 = ReplicatedStorage.Assets.Viewmodel.RightHand.RightWrist.C0
    bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
        if id == 15 and nearestEntities[1] and AttackAnimEnabled.Enabled and PlayerUtility.IsAlive(lplr) then
            return nil
        end
        return oldViewmodelAnimation(Self, id, ...)
    end

    newData.toggles.Killaura = Blatant:CreateToggle({
        Name = "Killaura",
        CurrentValue = false,
        Flag = "Killaura",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                local killauradelay = 0
                RunLoops:BindToHeartbeat("Killaura", function()
                    local sword = getSword()
                    if not sword then return end
                    if not PlayerUtility.IsAlive(lplr) then return end
    
                    nearestEntities = PlayerUtility.getNearestEntities(Distance["Value"], false, true, 5)
                    if #nearestEntities <= 0 then
                        clearAdornments()
                        newData.Attacking = false
                        return
                    end
                    local nearestEntityData = nearestEntities[1]
                    local entity = nearestEntityData.entity
                    local root = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
                    local swordmeta = bedwars.ItemTable[sword.tool.Name]
                    if root then
                        newData.Attacking = true
                        local distanceToEntity = (root.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                        if distanceToEntity <= Distance["Value"]  then
                            local selfPos = lplr.Character.HumanoidRootPart.Position + ((distanceToEntity > 14.3 or newData.toggles.Reach.CurrentValue and distanceToEntity > 21) and (CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, root.Position).LookVector * 4) or Vector3.new(0, 0, 0))
                            switchItem(sword.tool)
                            bedwars.SwordController.lastAttack = game:GetService("Workspace"):GetServerTimeNow() - 0.11
                            bedwars.SwordHit:FireServer({
                                weapon = sword.tool,
                                entityInstance = entity,
                                validate = {
                                    raycast = {},
                                    targetPosition = {value = root.Position},
                                    selfPosition = {value = selfPos},
                                },
                                chargedAttack = {chargeRatio = 0}
                            })
                            if SwingEnabled.Enabled and tick() - killauradelay >= (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or 0.24) then
                                bedwars.SwordController:playSwordEffect(sword, false)
                                killauradelay = tick()
                            end
                            if FacePlayerEnabled.Enabled then
                                lplr.Character:SetPrimaryPartCFrame(CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, Vector3.new(root.Position.X, lplr.Character.HumanoidRootPart.Position.Y, root.Position.Z)))
                            end
                            if AttackAnimEnabled.Enabled and distanceToEntity < Distance["Value"] and not VMAnimActive then
                                VMAnimActive = true
                                for _, anim in ipairs(Animations.Astral) do
                                    TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(anim.Time), {C0 = origC0 * anim.CFrame}):Play()
                                    task.wait(anim.Time - 0.01)
                                end
                                for _, endAnim in ipairs(EndAnimation) do
                                    TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(endAnim.Time), {C0 = origC0 * endAnim.CFrame}):Play()
                                end
                                VMAnimActive = false
                            elseif AttackAnimEnabled.Enabled and tick() - lastEndAnim > 0.13 then
                                VMAnimActive = true
                                for _, endAnim in ipairs(EndAnimation) do
                                    TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(endAnim.Time), {C0 = origC0 * endAnim.CFrame}):Play()
                                end
                                VMAnimActive = false
                                lastEndAnim = tick()
                            end
                            updateBoxAdornments(root)
                            lastEndAnim = tick()
                        else
                            clearAdornments()
                            newData.Attacking = false
                        end
                    else
                        clearAdornments()
                        newData.Attacking = false
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Killaura")
                clearAdornments()
                bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
                oldViewmodelAnimation = nil
            end
        end
    })
    newData.toggles.KillauraDistance = Blatant:CreateSlider({
        Name = "Distance",
        Range = {1, 21},
        Increment = 1,
        Suffix = "blocks",
        CurrentValue = 21,
        Flag = "KillAuraDistanceSlider",
        SectionParent = Section,
        Callback = function(Value)
            Distance.Value = Value
        end
    })
    newData.toggles.FacePlayer = Blatant:CreateToggle({
        Name = "FacePlayer",
        CurrentValue = false,
        Flag = "RotationsKillauraToggle",
        SectionParent = Section,
        Callback = function(callback)
            FacePlayerEnabled.Enabled = callback
        end
    })
    newData.toggles.Boxes = Blatant:CreateToggle({
        Name = "Boxes",
        CurrentValue = false,
        Flag = "Boxes",
        SectionParent = Section,
        Callback = function(callback)
            BoxesEnabled.Enabled = callback
        end
    })
    newData.toggles.Animations = Blatant:CreateToggle({
        Name = "Animations",
        CurrentValue = false,
        Flag = "AnimationsToggle",
        SectionParent = Section,
        Callback = function(callback)
            AttackAnimEnabled.Enabled = callback
        end
    })
    newData.toggles.Swing = Blatant:CreateToggle({
        Name = "Swing",
        CurrentValue = false,
        Flag = "Swing",
        SectionParent = Section,
        Callback = function(callback)
            SwingEnabled.Enabled = callback
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("AutoTrap", false)
    local trappedPlayers  = {}
    local trapSetupTime = 0.95
    local function IsTrapPlaceable(position, targetPosition)
        local direction = (targetPosition - position).unit
        local ray = Ray.new(position, direction * 5)
        local hitPart, hitPosition = game.Workspace:FindPartOnRay(ray, nil, false, true)
        if hitPart and (hitPart.CanCollide or hitPosition.Y > position.Y) then
            return false
        end
        local region = Region3.new(position - Vector3.new(0.5, 1, 0.5), position + Vector3.new(0.5, 0, 0.5))
        local parts = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
        return #parts == 0
    end

    local function RoundVector(vec)
        return Vector3.new(math.round(vec.X), math.round(vec.Y), math.round(vec.Z))
    end

    local previousVelocities = {}
    local TrapDistance = {["Value"] = 22}
    newData.toggles.AutoTrap = Utility:CreateToggle({
        Name = "AutoTrap",
        CurrentValue = false,
        Flag = "AutoTrap",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("AutoTrap", function(dt)
                    task.wait()
                    if getItem("snap_trap") then
                        switchItem("snap_trap")
                        local nearestPlayer = PlayerUtility.getNearestEntity(TrapDistance.Value, false, false)
                        if nearestPlayer and not nearestPlayer:FindFirstChild("BillboardGui") then
                            local distance = (nearestPlayer.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                            if distance <= 18 then
                                local velocity = nearestPlayer.Character.HumanoidRootPart.Velocity
                                local acceleration = (velocity - (previousVelocities[nearestPlayer] or velocity)) / dt
                                local predictedPosition = nearestPlayer.Character.HumanoidRootPart.Position + velocity * trapSetupTime + 0.5 * acceleration * trapSetupTime ^ 2
                                previousVelocities[nearestPlayer] = velocity

                                if nearestPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping or nearestPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                                    local timeToLand = math.sqrt((2 * predictedPosition.Y) / 196.2)
                                    predictedPosition = predictedPosition + nearestPlayer.Character.HumanoidRootPart.Velocity * timeToLand
                                end

                                local trapPosition = RoundVector(predictedPosition) + Vector3.new(0, -1, 0)
                                if IsTrapPlaceable(trapPosition, nearestPlayer.Character.HumanoidRootPart.Position) then
                                    bedwars.PlaceBlock:InvokeServer({
                                        blockType = "snap_trap",
                                        blockData = 0,
                                        position = getserverpos(trapPosition)
                                    })
                                end
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AutoTrap")
                previousVelocities = {}
            end
        end
    })
    newData.toggles.TrapDistance = Utility:CreateSlider({
        Name = "Distance",
        Range = {1, 23},
        Increment = 1,
        Suffix = "Distance",
        CurrentValue = 23,
        Flag = "TrapDistance",
        SectionParent = Section,
        Callback = function(Value)
            TrapDistance.Value = Value
        end
    })
end)

local SpeedSlider = {["Value"] = 23}
local slowdowntick = tick()
runcode(function()
    local Section = Blatant:CreateSection("Speed", false)
    local AutoJump = {Enabled = false}
    newData.toggles.Speed = Blatant:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "Speed",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Speed", function(dt)
                    if PlayerUtility.IsAlive(lplr) and newData.matchstate ~= 0 and lplr.Character.Humanoid.MoveDirection.Magnitude > 0 and lplr:GetAttribute("PlayerConnected") then
                        local speedMultiplier = SpeedMultiplier()
                        local speedIncrease = SpeedSlider.Value
                        local currentSpeed = lplr.Character.Humanoid.WalkSpeed
                        local moveDirection = lplr.Character.Humanoid.MoveDirection
                        local newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                    
                        if tick() < slowdowntick then
                            speedMultiplier = speedMultiplier - 0.5 -- did this so if you have anticheat bypass it slow down speed
                        end
                        lplr.Character:TranslateBy(newVelocity * dt)
                    end
                    if AutoJump.Enabled then
                        if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and lplr.Character.Humanoid.MoveDirection ~= Vector3.zero and newData.Attacking then
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 15, lplr.Character.HumanoidRootPart.Velocity.Z)
                        end
                    end
                    task.wait()
                end)
            else
                RunLoops:UnbindFromHeartbeat("Speed")
            end
        end
    })
    newData.toggles.SpeedSlider = Blatant:CreateSlider({
        Name = "Speed", 
        Range = {1, 30},
        Increment = 0.1,
        Suffix = "Speed.",
        CurrentValue = 23,
        Flag = "SpeedSlider",
        SectionParent = Section,
        Callback = function(Value)
            SpeedSlider.Value = Value
        end
    })
    newData.toggles.AutoJump = Blatant:CreateToggle({
        Name = "AutoJump",
        CurrentValue = false,
        Flag = "AutoJump",
        SectionParent = Section,
        Callback = function(callback)
            AutoJump.Enabled = callback
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Velocity", false)
    local old
    local playerHook

    local blacklistedStates = {
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.PlatformStanding
    }

    local disableStates = function(hum)
        for _, v in next, blacklistedStates do
            hum:SetStateEnabled(v, false)
        end
    end

    newData.toggles.Velocity = Blatant:CreateToggle({
        Name = "Velocity",
        CurrentValue = false,
        Flag = "Velocity",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                old = bedwars.KnockbackUtil.applyKnockback
                bedwars.KnockbackUtil.applyKnockback = function(...)
                    return nil
                end
                disableStates(lplr.Character.Humanoid)
                playerHook = lplr.CharacterAdded:Connect(function(chr)
                    disableStates(chr:WaitForChild("Humanoid"))
                end)
            else
                if playerHook then
                    playerHook:Disconnect()
                end
                if old then
                    bedwars.KnockbackUtil.applyKnockback = old
                end
                playerHook = nil
            end
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Nofall", false)
    newData.toggles.Nofall = Blatant:CreateToggle({
        Name = "Nofall",
        CurrentValue = false,
        Flag = "Nofall",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                repeat
                    task.wait(0.5)
                    Client:Get("GroundHit"):SendToServer()
                until not callback
            end
        end
    })
end)

runcode(function()
    local flying = false
    local targetY
    local flightTimer = 2.5
    local lastTick = tick()
    local originalTargetY
    local originalCFrame
    local onground = false
    local lastonground = false
    local groundtime = 0

    local Section = Blatant:CreateSection("Fly", false)
    newData.toggles.Fly = Blatant:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "Fly",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                targetY = lplr.Character.HumanoidRootPart.Position.Y
                originalTargetY = targetY
                originalCFrame = lplr.Character.HumanoidRootPart.CFrame
                lastTick = tick()
                flightTimer = 2.3

                RunLoops:BindToHeartbeat("Fly", function()
                    if PlayerUtility.IsAlive(lplr) then
                        local currentTick = tick()
                        local deltaTime = currentTick - lastTick
                        lastTick = currentTick
                        local newray = getPlacedBlock(lplr.Character.HumanoidRootPart.Position + Vector3.new(0, (lplr.Character.Humanoid.HipHeight * -2) - 1, 0))
                        onground = newray and true or false
                        
                        if lastonground ~= onground then
                            if not onground then
                                groundtime = tick() + 2.5
                            end
                            lastonground = onground
                        end

                        if onground then
                            flightTimer = 2.5
                        else
                            flightTimer = flightTimer - deltaTime
                        end

                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            targetY = targetY + 0.6
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            targetY = targetY - 0.6
                        end

                        if flightTimer <= 0 then
                        end

                        local currentCFrame = lplr.Character.HumanoidRootPart.CFrame
                        lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 0, lplr.Character.HumanoidRootPart.Velocity.Z)
                        lplr.Character.HumanoidRootPart.CFrame = CFrame.new(currentCFrame.Position.X, targetY, currentCFrame.Position.Z) * CFrame.Angles(currentCFrame:ToEulerAnglesXYZ())
                    end
                end)
            else
                lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 0, lplr.Character.HumanoidRootPart.Velocity.Z)
                RunLoops:UnbindFromHeartbeat("Fly")
            end
        end
    })
    newData.toggles.FlightKeybind = Blatant:CreateKeybind({
        Name = "Fly",
        CurrentKeybind = "R",
        HoldToInteract = false,
        Flag = "FlightKeybindToggle",
        SectionParent = Section,
        Callback = function(Keybind)
            newData.toggles.Fly:Set(not newData.toggles.Fly.CurrentValue)
        end,
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("AutoSprint", false)
    newData.toggles.AutoSprint = Blatant:CreateToggle({
        Name = "AutoSprint",
        CurrentValue = false,
        Flag = "AutoSprint",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                task.wait()
                RunLoops:BindToHeartbeat("AutoSprint", function(dt)
                    if PlayerUtility.IsAlive(lplr) then
                        bedwars.sprintTable:startSprinting()
                    end
                end)
                debug.setconstant(bedwars.sprintTable.startSprinting, 5, 'blockSprinting')
            else
                RunLoops:UnbindFromHeartbeat("AutoSprint")
                bedwars.sprintTable:stopSprinting()
                debug.setconstant(bedwars.sprintTable.startSprinting, 5, 'blockSprint')
            end
        end
    })
end)

local longJumpToggle
runcode(function()
    local projectilesData = {
        arrow = {
            cooldown = 0.6,
            predictionLifetimeSec = 2,
            launchVelocity = 400,
            gravitationalAcceleration = 0,
        },
        snowball = {
            cooldown = 0.2,
            predictionLifetimeSec = 2,
            launchVelocity = 150,
            gravitationalAcceleration = workspace.Gravity,
        }
    }

    local lastFiredTimes = {}
    local isShooting = false

    local function getAllBows()
        local bows = {}
        for _, item in ipairs(lplr.Character:FindFirstChild("InventoryFolder").Value:GetChildren()) do
            if item.Name:find("bow") or item.Name:find("snowball") then
                local itemName = item.Name
                bows[itemName] = bows[itemName] or {}
                if #bows[itemName] < 2 then
                    table.insert(bows[itemName], item)
                end
            end
        end
        local result = {}
        for _, items in pairs(bows) do
            for _, item in ipairs(items) do
                table.insert(result, item)
            end
        end
        return result
    end

    local function sortItems(items)
        local priority = {bow = 1, snowball = 2}
        table.sort(items, function(a, b)
            local aPriority = priority[a.Name:match("bow") and "bow" or "snowball"] or 3
            local bPriority = priority[b.Name:match("bow") and "bow" or "snowball"] or 3
            return aPriority < bPriority
        end)
    end

    local function setLastFiredTime(projectileType, currentTime)
        lastFiredTimes[projectileType] = currentTime
    end
    
    local function shootProjectileAtTarget(player, target, projectileType, predictedPosition, distance)
        local data = projectilesData[projectileType]
        local cooldown = data.cooldown
        local currentTime = os.clock()
        
        if lastFiredTimes[projectileType] and currentTime - lastFiredTimes[projectileType] < cooldown then
            return
        end
        
        local projectileTemplate = game:GetService("ReplicatedStorage").Assets.Projectiles:FindFirstChild(projectileType)
        if not projectileTemplate then 
            return 
        end
        
        local clonedProjectile = projectileTemplate:Clone()
        clonedProjectile.Parent = workspace
        
        local handle = clonedProjectile:FindFirstChild("Handle")
        if not handle then 
            return 
        end
        
        handle.Position = player.Character.PrimaryPart.Position
        
        local direction = (predictedPosition - handle.Position).unit
        
        local baseSpeed = data.launchVelocity
        local maxDistance = 50
        local adjustedSpeed = baseSpeed
        
        if distance > maxDistance then
            adjustedSpeed = baseSpeed * (maxDistance / distance)
        end
        
        local speed = adjustedSpeed
        
        handle.CFrame = CFrame.new(handle.Position, handle.Position + direction) * CFrame.Angles(math.rad(-90), 0, 0)
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = direction * speed
        bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyVelocity.Parent = handle
        
        local totalGravity = data.gravitationalAcceleration * handle:GetMass()
        local bodyForce = Instance.new("BodyForce")
        bodyForce.Force = Vector3.new(0, totalGravity, 0)
        bodyForce.Parent = handle
        
        handle.Touched:Connect(function(hit)
            if hit.Parent == target then
                bodyVelocity:Destroy()
                bodyForce:Destroy()
                game:GetService("Debris"):AddItem(clonedProjectile, data.predictionLifetimeSec)
            end
        end)
        
        handle.AncestryChanged:Connect(function()
            if not handle:IsDescendantOf(workspace) then
                setLastFiredTime(projectileType, currentTime)
            end
        end)
    end

    local function shootat(target)
        local currentTime = os.clock()
        local bows = getAllBows()
        local availableBows = {}
    
        for _, v in ipairs(bows) do
            local itemName = v.Name
            local data = projectilesData[itemName]
            local cooldown = data and data.cooldown or 0
            if not lastFiredTimes[itemName] or currentTime - lastFiredTimes[itemName] >= cooldown then
                table.insert(availableBows, v)
            end
        end
    
        sortItems(availableBows)
        local allBowsUsed = false
        local shotsFired = 0
        local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if #availableBows > 0 and not allBowsUsed then
            allBowsUsed = true
            for i, v in ipairs(availableBows) do
                local itemName = v.Name
                local data = projectilesData[itemName]
                local cooldown = data and data.cooldown or 0
                if not lastFiredTimes[itemName] or currentTime - lastFiredTimes[itemName] >= cooldown then
                    switchItem(v)
                    shotsFired = shotsFired + 1
                    local ping = lplr:GetNetworkPing()
                    local projectileType = (v.Name == "snowball" and "snowball") or "arrow"
                    local targetPosition = root.Position
                    local targetVelocity = root.Velocity
                    local predictedPosition = targetPosition + targetVelocity * ping
                    local distance = (predictedPosition - lplr.Character.PrimaryPart.Position).magnitude
                    
                    local travelTime = (predictedPosition - root.Position).magnitude / projectilesData[projectileType].launchVelocity
                    local predictedPositionAdjusted = predictedPosition + targetVelocity * travelTime
                    
                    if predictedPositionAdjusted then
                        local projectileFired = false
                        local args = {
                            [1] = v,
                            [2] = projectileType,
                            [3] = projectileType,
                            [4] = predictedPositionAdjusted,
                            [5] = predictedPositionAdjusted + Vector3.new(0, 2, 0),
                            [6] = Vector3.new(0, -5, 0),
                            [7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
                            [8] = {
                                ["drawDurationSeconds"] = distance < 21 and 0.55 or 1,
                                ["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
                            },
                            [9] = workspace:GetServerTimeNow() - 0.045
                        }
                        local result = bedwars.ProjectileFire:InvokeServer(unpack(args))
                        if result then
                            shootProjectileAtTarget(lplr, target, projectileType, predictedPositionAdjusted, distance)
                            projectileFired = true
                        end
                        if projectileFired then
                            table.remove(availableBows, i)
                            allBowsUsed = false
                        end
                    end
                end
            end
        end
    end

    local Section = Blatant:CreateSection("ProjectileAura", false)
    local notificationSent = false
    newData.toggles.ProjectileAura = Blatant:CreateToggle({
        Name = "ProjectileAura",
        CurrentValue = false,
        Flag = "ProjectileAura",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("ShootLoop", function()
                    local target = PlayerUtility.getNearestEntity(60, false, true)
                    local rangeCheck = PlayerUtility.getNearestEntity(Distance["Value"], false, true)
                    if target and not isShooting and not rangeCheck and not newData.toggles.LongJump.CurrentValue then
                        isShooting = true
                        shootat(target)
                    end
                    task.wait(0.15)
                    isShooting = false
                end)
            else
                RunLoops:UnbindFromHeartbeat("ShootLoop")
            end
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("InfiniteFly", false)
    local CameraTypes = {Enum.CameraType.Custom, Enum.CameraType.Scriptable, Enum.CameraType.Fixed}
    local MaxFlyDuration = 2.5
    local CtrlPressed = false
    local SpacePressed = false
    local InputBeganConnection
    local InputEndedConnection
    local TeleportEnabled = false
    local FlyRoot
    local FlyStartTime

    local function TextBoxFocused()
        return UserInputService:GetFocusedTextBox() ~= nil
    end

    local function setupFly()
        FlyRoot = Instance.new("Part")
        FlyRoot.Size = lplr.Character.HumanoidRootPart.Size
        FlyRoot.CFrame = lplr.Character.HumanoidRootPart.CFrame
        FlyRoot.Anchored = true
        FlyRoot.CanCollide = false
        FlyRoot.Color = Color3.fromRGB(255, 0, 0)
        FlyRoot.Material = Enum.Material.Neon
        FlyRoot.Parent = game.Workspace
        FlyRoot.Transparency = 0.6
        Camera.CameraSubject = FlyRoot
        Camera.CameraType = CameraTypes[1]
    end

    local function clearFly()
        if FlyRoot then
            FlyRoot:Destroy()
            FlyRoot = nil
        end
        TeleportEnabled = false
        Camera.CameraSubject = lplr.Character.Humanoid
        Camera.CameraType = CameraTypes[1]
    end

    newData.toggles.InfiniteFly = Blatant:CreateToggle({
        Name = "InfiniteFly",
        CurrentValue = false,
        Flag = "InfiniteFly",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                    if TextBoxFocused() then return end
                    if input.KeyCode == Enum.KeyCode.LeftShift then CtrlPressed = true end
                    if input.KeyCode == Enum.KeyCode.Space then SpacePressed = true end
                end)

                InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                    if TextBoxFocused() then return end
                    if input.KeyCode == Enum.KeyCode.LeftShift then CtrlPressed = false end
                    if input.KeyCode == Enum.KeyCode.Space then SpacePressed = false end
                end)
                setupFly()
                TeleportEnabled = true
                FlyStartTime = tick()
                RunLoops:BindToHeartbeat("InfiniteFly", function()
                    if FlyRoot and PlayerUtility.IsAlive(lplr) then
                        local Distance = (lplr.Character.HumanoidRootPart.Position - FlyRoot.Position).Magnitude
                        if Distance < 10000 and TeleportEnabled then
                            lplr.Character.HumanoidRootPart.CFrame = CFrame.new(FlyRoot.Position + Vector3.new(0, 200000, 0))
                            createNotification("Fly Teleport", "Teleported up", 2.5, 4483362458)
                        end
                        local newX = lplr.Character.HumanoidRootPart.Position.X
                        local newY = FlyRoot.Position.Y
                        local newZ = lplr.Character.HumanoidRootPart.Position.Z
                        if CtrlPressed then
                            newY = newY - 0.6
                        end
                        if SpacePressed then
                            newY = newY + 0.6
                        end
                        FlyRoot.Position = Vector3.new(newX, newY, newZ)
                    end
                end)
            else
                if InputBeganConnection then InputBeganConnection:Disconnect() end
                if InputEndedConnection then InputEndedConnection:Disconnect() end
                TeleportEnabled = false

                local RayStart = FlyRoot.Position
                local RayEnd = RayStart - Vector3.new(0, 10000, 0)
                local IgnoreList = {lplr, lplr.Character, FlyRoot, game.Workspace.CurrentCamera}
                local RayParams = RaycastParams.new()
                RayParams.FilterDescendantsInstances = IgnoreList
                RayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local RayResult = workspace:Raycast(RayStart, RayEnd - RayStart, RayParams)

                if RayResult then
                    local HitPosition = RayResult.Position
                    local newY = HitPosition.Y + (lplr.Character.HumanoidRootPart.Size.Y / 2) + lplr.Character.Humanoid.HipHeight
                    lplr.Character:SetPrimaryPartCFrame(CFrame.new(HitPosition.X, newY, HitPosition.Z))
                end

                clearFly()
                local FlyDuration = tick() - FlyStartTime
                if FlyDuration > MaxFlyDuration then
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, -1, 0)
                    local bodyVel = Instance.new("BodyVelocity", lplr.Character.HumanoidRootPart)
                    bodyVel.Velocity = Vector3.new(0, -1, 0)
                    bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
                    task.wait(1.2)
                    bodyVel:Destroy()
                end
                createNotification("Fly Teleport", "Teleported up", 2.5, 4483362458)
            end
        end
    })
    newData.toggles.Infflykeybind = Blatant:CreateKeybind({
        Name = "Keybind",
        CurrentKeybind = "Z",
        HoldToInteract = false,
        Flag = "Infflykeybind",
        SectionParent = Section,
        Callback = function(Keybind)
            if not RunLoops.Stafffound then
                newData.toggles.InfiniteFly:Set(not newData.toggles.InfiniteFly.CurrentValue)
            end
        end
    })
end)

runcode(function()
    local Section = Render:CreateSection("TargetHud", false)
    local DisplayNames = {Enabled = false}

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local Divider = Instance.new("Frame")
    local AvatarImage = Instance.new("ImageLabel")
    local UsernameLabel = Instance.new("TextLabel")
    local DistanceLabel = Instance.new("TextLabel")
    local HealthLabel = Instance.new("TextLabel")
    ScreenGui.Enabled = false
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(2, 5, 48)
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.256, 0, 0.783, 0)
    MainFrame.Size = UDim2.new(0, 245, 0, 106)

    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Position = UDim2.new(0.029, 0, 0, 0)
    TitleLabel.Size = UDim2.new(0, 122, 0, 26)
    TitleLabel.Font = Enum.Font.Ubuntu
    TitleLabel.Text = "Target"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    Divider.Name = "Divider"
    Divider.Parent = MainFrame
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Divider.BorderSizePixel = 0
    Divider.Position = UDim2.new(-0.004, 0, 0.232, 0)
    Divider.Size = UDim2.new(0, 246, 0, 2)

    AvatarImage.Name = "AvatarImage"
    AvatarImage.Parent = MainFrame
    AvatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
    AvatarImage.BorderSizePixel = 0
    AvatarImage.Position = UDim2.new(0.033, 0, 0.354, 0)
    AvatarImage.Size = UDim2.new(0, 73, 0, 53)
    AvatarImage.Image = ""

    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Parent = MainFrame
    UsernameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    UsernameLabel.BorderSizePixel = 0
    UsernameLabel.Position = UDim2.new(0.360, 0, 0.35, 0)
    UsernameLabel.Size = UDim2.new(0, 122, 0, 22)
    UsernameLabel.Font = Enum.Font.Ubuntu
    UsernameLabel.Text = ""
    UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameLabel.TextSize = 17
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Parent = MainFrame
    DistanceLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DistanceLabel.BorderSizePixel = 0
    DistanceLabel.Position = UDim2.new(0.360, 0, 0.642, 0)
    DistanceLabel.Size = UDim2.new(0, 132, 0, 22)
    DistanceLabel.Font = Enum.Font.Ubuntu
    DistanceLabel.Text = ""
    DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DistanceLabel.TextSize = 17
    DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left

    HealthLabel.Name = "HealthLabel"
    HealthLabel.Parent = MainFrame
    HealthLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HealthLabel.BackgroundTransparency = 1
    HealthLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    HealthLabel.BorderSizePixel = 0
    HealthLabel.Position = UDim2.new(0.360, 0, 0.5, 0)
    HealthLabel.Size = UDim2.new(0, 122, 0, 22)
    HealthLabel.Font = Enum.Font.Ubuntu
    HealthLabel.Text = ""
    HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthLabel.TextSize = 17
    HealthLabel.TextXAlignment = Enum.TextXAlignment.Left

    local DefaultImageUrl = "rbxthumb://type=AvatarHeadShot&id=1&w=180&h=180"
    local lastDistance = nil
    local lastHealth = nil

    local function UpdateHealthText(currentHealth)
        HealthLabel.Text = tostring(math.floor(currentHealth + 0.5)) .. "%"
    end

    local function SetPlayerIcon(player)
        local userId = player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size180x180
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        end)
        if success then
            AvatarImage.Image = content
        end
    end

    local function UpdateUsernameLabel(username)
        local maxTextSize = 17
        local minTextSize = 12
        local maxLength = 25
        local length = string.len(username)

        local textSize = maxTextSize - math.floor((length / maxLength) * (maxTextSize - minTextSize))
        textSize = math.clamp(textSize, minTextSize, maxTextSize)

        UsernameLabel.TextSize = textSize
        UsernameLabel.Text = username
    end

    local function UpdateStatsGui(entity)
        local humanoid = entity:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local currentHealth = humanoid.Health
            local player = Players:GetPlayerFromCharacter(entity)
            local currentDistance = math.floor((lplr.Character.HumanoidRootPart.Position - entity.PrimaryPart.Position).magnitude)

            if currentHealth ~= lastHealth or currentDistance ~= lastDistance then
                UpdateHealthText(currentHealth)
                if player then
                    SetPlayerIcon(player)
                    local username = DisplayNames.Enabled and player.DisplayName or player.Name
                    UpdateUsernameLabel(username)
                else
                    AvatarImage.Image = DefaultImageUrl
                    UpdateUsernameLabel(entity.Name or "Unknown")
                end
                DistanceLabel.Text = tostring(currentDistance) .. " studs"

                lastHealth = currentHealth
                lastDistance = currentDistance
            end
        end
    end

    if not isfile("guisaved.json") then
        local initialData = {
            X = 100, 
            Y = 100,
        }
        local jsonData = HttpService:JSONEncode(initialData)
        writefile("guisaved.json", jsonData)
    end

    local function loadPositionFromFile()
        if isfile("guisaved.json") then
            local jsonData = readfile("guisaved.json")
            local positionData = HttpService:JSONDecode(jsonData)
            if positionData then
                MainFrame.Position = UDim2.new(0, positionData.X, 0, positionData.Y)
            end
        end
    end

    local dragging = false
    local dragInput, mousePos, framePos

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    local positionData = {
                        X = MainFrame.Position.X.Offset,
                        Y = MainFrame.Position.Y.Offset
                    }
                    local jsonData = readfile("guisaved.json")
                    local savedData = HttpService:JSONDecode(jsonData)
                    savedData.X = positionData.X
                    savedData.Y = positionData.Y
                    jsonData = HttpService:JSONEncode(savedData)
                    writefile("guisaved.json", jsonData)
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    local TargetHudToggle = Render:CreateToggle({
        Name = "TargetHud",
        CurrentValue = false,
        Flag = "TargetHud",
        SectionParent = Section,
        Callback = function(enabled)
            if enabled then
                task.wait(0.01)
                RunLoops:BindToHeartbeat("TargetHudUpdate", function()
                    local nearestEntity = PlayerUtility.getNearestEntity(25, false, true)
                    if nearestEntity and PlayerUtility.IsAlive(lplr) then
                        ScreenGui.Enabled = true
                        UpdateStatsGui(nearestEntity)
                    else
                        AvatarImage.Image = ""
                        UsernameLabel.Text = ""
                        DistanceLabel.Text = ""
                        HealthLabel.Text = ""
                        ScreenGui.Enabled = false
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("TargetHudUpdate")
                for _, v in pairs(ScreenGui:GetChildren()) do
                    if v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("TextLabel") then
                        v:Destroy()
                    end
                end
            end
        end
    })

    local DisplayNamesToggle = Render:CreateToggle({
        Name = "DisplayNames",
        CurrentValue = false,
        Flag = "DisplayNames",
        SectionParent = Section,
        Callback = function(enabled)
            DisplayNames.Enabled = enabled
            if TargetHudToggle.CurrentValue then
                local nearestEntity = PlayerUtility.getNearestEntity(25, false, true)
                if nearestEntity then
                    UpdateStatsGui(nearestEntity)
                end
            end
        end
    })
    loadPositionFromFile()
end)

runcode(function()
    local section = Blatant:CreateSection("LongJump", false)
    local velocityInstance
    local jumpStartTime

    local function getFireballsFromInventory()
        local fireballs = {}
        for _, item in ipairs(bedwars.inventory:GetChildren()) do
            if item.Name:find("fireball") then
                table.insert(fireballs, item)
            end
        end
        return fireballs
    end
    newData.toggles.LongJump = Blatant:CreateToggle({
        Name = "LongJump",
        CurrentValue = false,
        Flag = "LongJumpToggle",
        SectionParent = section,
        Callback = function(isActive)
            if isActive then
                task.wait()
                local fireballs = getFireballsFromInventory()
                for _, fireball in pairs(fireballs) do
                    repeat
                        switchItem(fireball)
                    until lplr.Character.HandInvItem.Value ~= "fireball"

                    local characterPosition = lplr.Character.PrimaryPart.Position
                    velocityInstance = Instance.new("BodyVelocity")
                    velocityInstance.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    velocityInstance.Velocity = Vector3.new(0, 0.5, 0)
                    velocityInstance.Parent = lplr.Character:FindFirstChild("HumanoidRootPart")

                    jumpStartTime = tick()

                    local fireballArgs = {
                        [1] = fireball,
                        [2] = "fireball",
                        [3] = "fireball",
                        [4] = characterPosition,
                        [5] = characterPosition + Vector3.new(0, 2, 0),
                        [6] = Vector3.new(0, -5, 0),
                        [7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
                        [8] = {
                            ["drawDurationSeconds"] = 1,
                            ["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
                        },
                        [9] = workspace:GetServerTimeNow() - 0.045
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileFire"):InvokeServer(unpack(fireballArgs))
                    task.wait(0.45)
                    velocityInstance.Velocity = lplr.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 60 + Vector3.new(0, 1, 0)
                end
            else
                if velocityInstance then
                    velocityInstance:Destroy()
                end
                velocityInstance = nil
                jumpStartTime = nil
            end
        end
    })
    newData.toggles.longJumpKeybind = Blatant:CreateKeybind({
        Name = "LongJump Keybind",
        CurrentKeybind = "X",
        HoldToInteract = false,
        Flag = "LongJumpKeybind",
        SectionParent = section,
        Callback = function(keybind)
            if not RunLoops.stafffound then
                newData.toggles.LongJump:Set(not newData.toggles.LongJump.CurrentValue)
            end
        end
    })
    
    RunService.Heartbeat:Connect(function()
        if velocityInstance and tick() - jumpStartTime > 2.3 then
            velocityInstance.Velocity = velocityInstance.Velocity.unit * 22
        end
    end)
end)

runcode(function()
    local Section = Render:CreateSection("Cape", false)
    local function CreateCape(character, texture)
        local humanoid = character:WaitForChild("Humanoid")
        local torso = humanoid.RigType == Enum.HumanoidRigType.R15 and character:WaitForChild("UpperTorso") or character:WaitForChild("Torso")
        local cape = Instance.new("Part", torso.Parent)
        cape.Name = "Cape"
        cape.Anchored = false
        cape.CanCollide = false
        cape.TopSurface = Enum.SurfaceType.Smooth
        cape.BottomSurface = Enum.SurfaceType.Smooth
        cape.Size = Vector3.new(0.2, 0.2, 0.2)
        cape.Transparency = 0
        cape.BrickColor = BrickColor.new("Really black")
        local decal = Instance.new("Decal", cape)
        decal.Texture = texture
        decal.Face = Enum.NormalId.Back
        local mesh = Instance.new("BlockMesh", cape)
        mesh.Scale = Vector3.new(9, 17.5, 0.08)
        local motor = Instance.new("Motor", cape)
        motor.Part0 = cape
        motor.Part1 = torso
        motor.MaxVelocity = 0.01
        motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
        motor.C1 = CFrame.new(0, 1, 0.45) * CFrame.Angles(0, math.rad(90), 0)
        
        local wave = false
        repeat
            task.wait(1 / 44)
            decal.Transparency = torso.Transparency
            local angle = 0.1
            local oldMagnitude = torso.Velocity.Magnitude
            local maxVelocity = 0.002
            if wave then
                angle = angle + ((torso.Velocity.Magnitude / 10) * 0.05) + 0.05
                wave = false
            else
                wave = true
            end
            angle = angle + math.min(torso.Velocity.Magnitude / 11, 0.5)
            motor.MaxVelocity = math.min((torso.Velocity.Magnitude / 111), 0.04)
            motor.DesiredAngle = -angle
            if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
                motor.MaxVelocity = 0.04
            end
            repeat task.wait() until motor.CurrentAngle == motor.DesiredAngle or math.abs(torso.Velocity.Magnitude - oldMagnitude) >= (torso.Velocity.Magnitude / 10) + 1
            if torso.Velocity.Magnitude < 0.1 then
                task.wait(0.1)
            end
        until not cape or cape.Parent ~= torso.Parent
    end

    local function DestroyCape(character)
        local cape = character:FindFirstChild("Cape")
        if cape then
            cape:Destroy()
        end
    end
    
    local Connection
    local function AddCape(character)
        task.wait(1)
        if not character:FindFirstChild("Cape") then
            CreateCape(character, getcustomasset("Aristois/assets/cape.png"))
        end
    end
    
    newData.toggles.Cape = Render:CreateToggle({
        Name = "Cape",
        CurrentValue = false,
        Flag = "Cape",
        SectionParent = Section,
        Callback = function(enabled)
            if enabled then
                AddCape(lplr.Character)
                Connection = lplr.CharacterAdded:Connect(AddCape)
            else
                if Connection then
                    Connection:Disconnect()
                    Connection = nil
                end
                DestroyCape(lplr.Character)
            end
        end
    })
end)

runcode(function()
    local Section = Render:CreateSection("NameTags", false)
    local enabled = false
    local espdisplaynames = false
    local espnames = false
    local esphealth = false
    local nameTags = {}
    local originalDisplayDistanceTypes = {}

    local function createNameTag(player)
        if not nameTags[player] then
            local nameTag = Drawing.new("Text")
            nameTag.Outline = true
            nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
            nameTag.Transparency = 1
            nameTag.Size = 14
            nameTag.Center = true
            nameTag.Font = Drawing.Fonts.UI
            nameTag.Visible = false
            nameTag.Color = player.TeamColor.Color
            nameTags[player] = nameTag
        end
    end

    local function hideHumanoidDisplay(player, character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalDisplayDistanceTypes[player] = humanoid.DisplayDistanceType
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end

    local function restoreHumanoidDisplay(player)
        if originalDisplayDistanceTypes[player] and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = originalDisplayDistanceTypes[player]
            end
        end
        originalDisplayDistanceTypes[player] = nil
    end

    local function updateNameTags()
        for player, nameTag in pairs(nameTags) do
            if player and player:IsA("Player") and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local offset = Vector3.new(0, 3, 0)
                    local worldPosition = head.Position + offset
                    local vector, onScreen = Camera:WorldToViewportPoint(worldPosition)

                    if onScreen then
                        local part1 = player.Character:WaitForChild("HumanoidRootPart", math.huge).Position
                        local part2 = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
                        local dist = (part1 - part2).Magnitude

                        local displayName = player.DisplayName
                        local username = player.Name
                        local health = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health or 0

                        local text = ""
                        if espdisplaynames then
                            text = displayName
                        end
                        if espnames then
                            if text ~= "" then
                                text = text .. " (@" .. username .. ")"
                            else
                                text = "@" .. username
                            end
                        end
                        if esphealth then
                            text = text .. " [" .. tostring(math.floor(health)) .. "]"
                        end

                        nameTag.Position = Vector2.new(vector.X, vector.Y)
                        nameTag.Text = "(" .. tostring(math.floor(tonumber(dist))) .. ") " .. text
                        nameTag.Visible = true
                    else
                        nameTag.Visible = false
                    end
                else
                    nameTag.Visible = false
                end
            else
                nameTag.Visible = false
                nameTags[player] = nil
                restoreHumanoidDisplay(player)
            end
        end
    end

    RunService.RenderStepped:Connect(updateNameTags)

    local NameTagsToggle = Render:CreateToggle({
        Name = "NameTags",
        CurrentValue = false,
        Flag = "NameTags",
        SectionParent = Section,
        Callback = function(callback)
            enabled = callback
            if callback then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= lplr then
                        createNameTag(player)
                        if player.Character then
                            hideHumanoidDisplay(player, player.Character)
                        end
                        player.CharacterAdded:Connect(function(character)
                            hideHumanoidDisplay(player, character)
                            createNameTag(player)
                        end)
                    end 
                end

                Players.PlayerAdded:Connect(function(player)
                    if player ~= lplr then
                        if player.Character then
                            hideHumanoidDisplay(player, player.Character)
                        end
                        player.CharacterAdded:Connect(function(character)
                            hideHumanoidDisplay(player, character)
                            createNameTag(player)
                        end)
                    end
                end)

                Players.PlayerRemoving:Connect(function(player)
                    if nameTags[player] then
                        nameTags[player]:Remove()
                        nameTags[player] = nil
                    end
                    restoreHumanoidDisplay(player)
                end)
            else
                for player, tag in pairs(nameTags) do
                    if tag then
                        tag:Remove()
                    end
                end
                nameTags = {}
                for player in pairs(originalDisplayDistanceTypes) do
                    restoreHumanoidDisplay(player)
                end
            end
        end
    })
    local DisplayNamesToggle = Render:CreateToggle({
        Name = "DisplayNames",
        CurrentValue = false,
        Flag = "DisplayNames",
        SectionParent = Section,
        Callback = function(val)
            espdisplaynames = val
            updateNameTags()
        end
    })
    local NamesToggle = Render:CreateToggle({
        Name = "Names",
        CurrentValue = false,
        Flag = "espnames",
        SectionParent = Section,
        Callback = function(callback)
            espnames = callback
            updateNameTags()
        end
    })
    local HealthToggle = Render:CreateToggle({
        Name = "Health",
        CurrentValue = false,
        Flag = "esphealth",
        SectionParent = Section,
        Callback = function(callback)
            esphealth = callback
            updateNameTags()
        end
    })
end)

runcode(function()
    local Section = Render:CreateSection("ViewModel", false)
    local Connection
    local Size = {["Value"] = 3}
    
    local function resetHandleSize()
        for _, v in pairs(Camera.Viewmodel:GetChildren()) do
            if v:FindFirstChild("Handle") then
                pcall(function()
                    v:FindFirstChild("Handle").Size = v:FindFirstChild("Handle").Size * Size["Value"]
                end)
            end
        end
    end

    local function updateHandleSize()
        for _, v in pairs(Camera.Viewmodel:GetChildren()) do
            if v:FindFirstChild("Handle") then
                pcall(function()
                    v:FindFirstChild("Handle").Size = v:FindFirstChild("Handle").Size / Size["Value"]
                end)
            end
        end
    end

    local ViewModelToggle = Render:CreateToggle({
        Name = "ViewModel",
        CurrentValue = false,
        Flag = "ViewModel",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                updateHandleSize()
                if Connection then
                    Connection:Disconnect()
                end
                Connection = Camera.Viewmodel.ChildAdded:Connect(function(v)
                    if v:FindFirstChild("Handle") then
                        pcall(function()
                            v:FindFirstChild("Handle").Size = v:FindFirstChild("Handle").Size / Size["Value"]
                        end)
                    end
                end)
            else
                if Connection then
                    Connection:Disconnect()
                end
                resetHandleSize()
            end
        end
    })

    newData.toggles.swordSize = Render:CreateSlider({
        Name = "swordSize",
        Range = {1, 10},
        Increment = 1,
        Suffix = "Size",
        CurrentValue = 4,
        Flag = "swordSize",
        SectionParent = Section,
        Callback = function(Value)
            resetHandleSize() 
            Size["Value"] = Value
            updateHandleSize() 
        end
    })
end)


runcode(function()
    local Life = {["Value"] = 4}
    local character = lplr.Character or lplr.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local breadcrumbAttachmentTop = Instance.new("Attachment")
    breadcrumbAttachmentTop.Position = Vector3.new(0, 0.07 - 2.7, 0)
    breadcrumbAttachmentTop.Parent = humanoidRootPart

    local breadcrumbAttachmentBottom = Instance.new("Attachment")
    breadcrumbAttachmentBottom.Position = Vector3.new(0, -0.07 - 2.7, 0)
    breadcrumbAttachmentBottom.Parent = humanoidRootPart

    local breadcrumbTrail = Instance.new("Trail")
    breadcrumbTrail.Attachment0 = breadcrumbAttachmentTop
    breadcrumbTrail.Attachment1 = breadcrumbAttachmentBottom
    breadcrumbTrail.FaceCamera = true
    breadcrumbTrail.Lifetime = Life.Value
    breadcrumbTrail.LightEmission = 1
    breadcrumbTrail.Transparency = NumberSequence.new(0, 0.5)
    breadcrumbTrail.Enabled = false
    breadcrumbTrail.Parent = humanoidRootPart

    local color1 = Color3.new(253 / 255, 195 / 255, 47 / 255)
    local color2 = Color3.new(252 / 255, 67 / 255, 229 / 255)

    local function updateTrail()
        local t = tick() % 5 / 5
        local lerpedColor = color1:Lerp(color2, t)
        breadcrumbTrail.Color = ColorSequence.new(lerpedColor, lerpedColor)
        breadcrumbAttachmentTop.Position = Vector3.new(0, 0.07 - 2.7, 0)
        breadcrumbAttachmentBottom.Position = Vector3.new(0, -0.07 - 2.7, 0)
        breadcrumbTrail.Lifetime = Life.Value
    end

    local Section = Render:CreateSection("BreadCrumbs", false)
    newData.toggles.BreadCrumbs = Render:CreateToggle({
        Name = "BreadCrumbs",
        CurrentValue = false,
        Flag = "BreadCrumbs",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                breadcrumbTrail.Enabled = true
                RunLoops:BindToHeartbeat("BreadCrumbs", function()
                    updateTrail()
                end)
            else
                breadcrumbTrail.Enabled = false
                RunLoops:UnbindFromHeartbeat("BreadCrumbs")
            end
        end
    })
    newData.toggles.Lifetime = Render:CreateSlider({
        Name = "Lifetime",
        Range = {1, 10},
        Increment = 1,
        Suffix = "secs",
        CurrentValue = 4,
        Flag = "Lifetime",
        SectionParent = Section,
        Callback = function(Value)
            Life.Value = Value
        end
    })
    lplr.CharacterAdded:Connect(function(character)
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        breadcrumbAttachmentTop.Parent = humanoidRootPart
        breadcrumbAttachmentBottom.Parent = humanoidRootPart
        breadcrumbTrail.Parent = humanoidRootPart
    end)
end)

runcode(function()
    local Section = Utility:CreateSection("AnticheatBypass", false)
    local Notification = {Enabled = false}
    local speedcheck
    newData.toggles.AnticheatBypass = Utility:CreateToggle({
        Name = "AnticheatBypass",
        CurrentValue = false,
        Flag = "AnticheatBypass",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                speedcheck = lplr:GetAttributeChangedSignal("LastTeleported"):Connect(function()
                    if lplr:GetAttribute("LastTeleported") > 1 and not newData.toggles.InfiniteFly.CurrentValue then
                        slowdowntick = tick() + 3
                        if Notification.Enabled then
                            createNotification("AnticheatBypass", "Slowing down speed flag check", 3.5, 4483362458)
                        end
                    end
                end)
            else
                if speedcheck then
                    speedcheck:Disconnect()
                end
            end
        end
    })
    newData.toggles.Notification = Utility:CreateToggle({
        Name = "Notification",
        CurrentValue = false,
        Flag = "Notification",
        SectionParent = Section,
        Callback = function(callback)
            Notification.Enabled = callback
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("AutoConsume", false)
    
    local Consumeables = {
        { Name = "speed_potion", StatusCheck = "StatusEffect_speed" },
        { Name = "invisibility_potion", StatusCheck = nil },
        { Name = "forcefield_potion", StatusCheck = nil },
        { Name = "apple", StatusCheck = nil },
    }
    
    newData.toggles.AutoConsume = Utility:CreateToggle({
        Name = "AutoConsume",
        CurrentValue = false,
        Flag = "AutoConsume",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("AutoConsume", function()
                    local health = lplr.Character:GetAttribute("Health")
                    local maxHealth = lplr.Character:GetAttribute("MaxHealth")
                    task.wait(0.1)
                    for _, itemInfo in ipairs(Consumeables) do
                        local itemName = itemInfo.Name
                        local statusCheck = itemInfo.StatusCheck
                        local item = bedwars.inventory:FindFirstChild(itemName)
                        if item then
                            if itemName == "apple" and health < maxHealth then
                                bedwars.ConsumeItem:InvokeServer({ item = item })
                            elseif itemName ~= "apple" and (not statusCheck or not lplr.Character:GetAttribute(statusCheck)) then
                                bedwars.ConsumeItem:InvokeServer({ item = item })
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AutoConsume")
            end
        end
    })
    newData.toggles.Consumables = Utility:CreateDropdown({
        Name = "Select Consumables",
        Options = {"speed_potion", "invisibility_potion", "forcefield_potion", "apple"},
        CurrentOption = {"speed_potion"},
        MultiSelection = true,
        Flag = "SelectedConsumables",
        SectionParent = Section,
        Callback = function(selectedOptions)
            local updatedConsumeables = {}
            for _, option in ipairs(selectedOptions) do
                local found = false
                for _, item in ipairs(Consumeables) do
                    if item.Name == option then
                        found = true
                        table.insert(updatedConsumeables, item)
                        break
                    end
                end
                if not found then
                    table.insert(updatedConsumeables, { Name = option, StatusCheck = nil })
                end
            end
            Consumeables = updatedConsumeables
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("ChestStealer", false)
    newData.toggles.ChestStealer = Utility:CreateToggle({
        Name = "ChestStealer",
        CurrentValue = false,
        Flag = "ChestStealerToggle",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                repeat
                    task.wait(0.3)
                    if PlayerUtility.IsAlive(lplr) then
                        for _, chestTag in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
                            local chestPosition = chestTag.Position
                            local distance = (lplr.Character.HumanoidRootPart.Position - chestPosition).Magnitude
                            if distance < 22 and chestTag:FindFirstChild("ChestFolderValue") then
                                local chestFolder = chestTag:FindFirstChild("ChestFolderValue")
                                local chest = chestFolder and chestFolder.Value or nil
                                if chest then
                                    local chestItems = chest:GetChildren()
                                    if #chestItems > 0 then
                                        for _, item in pairs(chestItems) do
                                            if item:IsA("Accessory") then
                                                Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
                                                game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):FindFirstChild("@rbxts").net.out._NetManaged:FindFirstChild("Inventory/ChestGetItem"):InvokeServer(chestFolder.Value, item)
                                                Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
                                            end
                                        end
                                    else
                                        game:GetService("CollectionService"):RemoveTag(chestTag, "chest")
                                    end
                                end
                            end
                        end
                    end
                until not callback
            end
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("ChestEsp", false)

    local ChestESPList = {
        TrackedItems = {},
        BillboardGuis = {},
        Connection = nil,
        UpdateLoop = nil
    }

    local Folder = Instance.new("Folder")
    Folder.Name = "ChestESP"
    Folder.Parent = game:GetService("Workspace")

    local function chestcheck(v)
        local chestFolderValue = v:FindFirstChild("ChestFolderValue")
        local chestFolder = chestFolderValue and chestFolderValue.Value or nil
        if not chestFolder then return end
        
        local chestItems = chestFolder:GetChildren()
        local placeboard = false
        local itemName

        for _, item in pairs(chestItems) do
            if table.find(ChestESPList.TrackedItems, item.Name) then
                itemName = item.Name
                placeboard = true
                break
            end
        end

        if placeboard and newData.toggles.ChestEsp.CurrentValue then
            if not ChestESPList.BillboardGuis[v] then
                local BillboardGui = Instance.new("BillboardGui")
                local ImageButton = Instance.new("ImageButton")

                BillboardGui.Parent = Folder
                BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                BillboardGui.Active = true
                BillboardGui.AlwaysOnTop = true
                BillboardGui.LightInfluence = 1.000
                BillboardGui.MaxDistance = 1000.000
                BillboardGui.Size = UDim2.new(2.20000005, 0, 2.20000005, 0)
                BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
                BillboardGui.Adornee = v

                ImageButton.Parent = BillboardGui
                ImageButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                ImageButton.BackgroundTransparency = 0.600
                ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ImageButton.BorderSizePixel = 0
                ImageButton.Size = UDim2.new(1, 0, 1, 0)
                ImageButton.ImageTransparency = 0
                ImageButton.Image = bedwars.getIcon({itemType = itemName}, true)

                ChestESPList.BillboardGuis[v] = BillboardGui
            else
                local BillboardGui = ChestESPList.BillboardGuis[v]
                if BillboardGui and BillboardGui:FindFirstChildOfClass("ImageButton") then
                    local ImageButton = BillboardGui:FindFirstChildOfClass("ImageButton")
                    ImageButton.Image = bedwars.getIcon({itemType = itemName}, true)
                end
            end
        else
            if ChestESPList.BillboardGuis[v] then
                ChestESPList.BillboardGuis[v]:Destroy()
                ChestESPList.BillboardGuis[v] = nil
            end
        end
    end

    local dropdownOptions = {}
    for itemId, itemData in pairs(bedwars.ItemTable) do
        table.insert(dropdownOptions, itemId)
    end

    local function updateChests()
        for _, v in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
            chestcheck(v)
        end
    end

    local debounceTime = 0.5
    local lastUpdateTime = 0

    local function onStepped()
        if tick() - lastUpdateTime >= debounceTime then
            lastUpdateTime = tick()
            updateChests()
        end
    end

    newData.toggles.ChestEsp = Blatant:CreateToggle({
        Name = "ChestEsp",
        CurrentValue = false,
        Flag = "ChestEsp",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                updateChests()
                ChestESPList.Connection = game:GetService("CollectionService"):GetInstanceAddedSignal("chest"):Connect(chestcheck)
                ChestESPList.UpdateLoop = game:GetService("RunService").Stepped:Connect(onStepped)
            else
                for _, billboardGui in pairs(ChestESPList.BillboardGuis) do
                    billboardGui:Destroy()
                end
                ChestESPList.BillboardGuis = {}

                if ChestESPList.Connection then
                    ChestESPList.Connection:Disconnect()
                    ChestESPList.Connection = nil
                end

                if ChestESPList.UpdateLoop then
                    ChestESPList.UpdateLoop:Disconnect()
                    ChestESPList.UpdateLoop = nil
                end
            end
        end
    })
    newData.toggles.ItemSelection = Utility:CreateDropdown({
        Name = "Item Selection",
        Options = dropdownOptions,
        CurrentOption = {"speed_potion"},
        MultiSelection = true,
        Flag = "ItemSelection",
        SectionParent = Section,
        Callback = function(selectedOptions)
            ChestESPList.TrackedItems = selectedOptions
            updateChests()
        end,
    })
end)

runcode(function()
    local priorityList = {"emerald", "speed", "bow" ,"diamond", "telepearl", "arrow"}
    local Section = Utility:CreateSection("PickUprange", false)
    local pickedup = {}
    newData.toggles.PickUpRange = Utility:CreateToggle({
        Name = "PickUpRange",
        CurrentValue = false,
        Flag = "PickUprange",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                task.spawn(function()
                    local hrp, itemDrops
                    local priorityMap = {}
                    for index, name in ipairs(priorityList) do
                        priorityMap[name] = index
                    end
                    repeat
                        if PlayerUtility.IsAlive(lplr) then
                            hrp = lplr.character.HumanoidRootPart
                            itemDrops = game.Workspace.ItemDrops:GetChildren()
                            local itemsToPickup = {}
                            local prioritizedItems = {}
                            for _, v in pairs(itemDrops) do
                                if v:IsA("BasePart") and ((hrp.Position - v.Position).Magnitude <= 10.5) then
                                    if not pickedup[v] or pickedup[v] <= tick() then
                                        pickedup[v] = tick() + 0.2
                                        local itemName = string.lower(v.Name)
                                        local priority = priorityMap[itemName] or (#priorityList + 1)
                                        table.insert(prioritizedItems, {item = v, priority = priority})
                                    end
                                end
                            end
                            table.sort(prioritizedItems, function(a, b) return a.priority < b.priority end)
                            for _, itemData in ipairs(prioritizedItems) do
                                table.insert(itemsToPickup, itemData.item)
                            end
                            if #itemsToPickup > 0 then
                                for _, v in pairs(itemsToPickup) do
                                    v.CFrame = hrp.CFrame
                                    bedwars.PickupRemote:InvokeServer{itemDrop = v}
                                end
                            end
                        end
                        task.wait()
                    until not callback
                end)
            end
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("Fastdrop", false)
    local Connection
    local keyDown = false
    newData.toggles.Fastdrop = Utility:CreateToggle({
        Name = "FastDrop",
        CurrentValue = false,
        Flag = "Fastdrop",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                Connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                    if input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent and not keyDown then
                        keyDown = true
                        if not lplr.Character then return end
                        local item = lplr.Character.InventoryFolder.Value[lplr.Character.HandInvItem.Value.Name]
                        while keyDown and lplr.Character do
                            task.spawn(bedwars.DropItem)
                            task.wait()
                        end
                    end
                end)
                UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
                    if input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent then
                        keyDown = false
                    end
                end)
            else
                if Connection then
                    Connection:Disconnect()
                    Connection = nil
                end
            end
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("AntiAfk", false)
    local AntiAfkConnection
    newData.toggles.AnitAfk = Utility:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Flag = "AntiAfk",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                if AntiAfkConnection then
                    AntiAfkConnection:Disconnect()
                end
                AntiAfkConnection = lplr.Idled:Connect(function()
                    VirtualUserService:CaptureController()
                    VirtualUserService:ClickButton2(Vector2.new())
                end)
                Client:Get("AfkInfo"):SendToServer({
					afk = false
				})
            else
                if AntiAfkConnection then
                    AntiAfkConnection:Disconnect()
                    AntiAfkConnection = nil
                end
            end
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("ChatSpammer", false)
    local ChatSpammerDelay = {["Value"] = 5} 
    local lastSentTime = 0
    if not getgenv().ChatSpammer then
        getgenv().ChatSpammer = "Aristois on top"
    end
    newData.toggles.ChatSpammer = Utility:CreateToggle({
        Name = "ChatSpammer",
        CurrentValue = false,
        Flag = "ChatSpammer",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("ChatSpammer", function()
                    if ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
                        if tick() - lastSentTime >= ChatSpammerDelay.Value then
                            local message = getgenv().ChatSpammer or "Aristois on top"
                            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
                            lastSentTime = tick()
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("ChatSpammer")
            end
        end
    })
    newData.toggles.ChatSpammerDelay = Utility:CreateSlider({
        Name = "Speed",
        Range = {1, 60},
        Increment = 1,
        Suffix = "sec(s)",
        CurrentValue = 5, 
        Flag = "ChatSpammerDelay",
        SectionParent = Section,
        Callback = function(Value)
            ChatSpammerDelay.Value = Value
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("AutoHeal", false)
    local HealTeam = {Enabled = false}
    local oldAnimTypes = {}
    local oldSoundList = {}

    local function updateGuitarAssets()
        for key, value in pairs(bedwars.AnimationType) do
            if key:lower():find("guitar") then
                oldAnimTypes[key] = value
                bedwars.AnimationType[key] = "rbxassetid://00000000000"
            end
        end
        for key, value in pairs(bedwars.SoundList) do
            if key:lower():find("guitar") then
                oldSoundList[key] = value
                bedwars.SoundList[key] = "rbxassetid://00000000000"
            end
        end
    end

    local function restoreGuitarAssets()
        for key, value in pairs(bedwars.AnimationType) do
            if key:lower():find("guitar") then
                bedwars.AnimationType[key] = oldAnimTypes[key]
            end
        end
        for key, value in pairs(bedwars.SoundList) do
            if key:lower():find("guitar") then
                bedwars.SoundList[key] = oldSoundList[key]
            end
        end
    end
    newData.toggles.AutoHeal = Utility:CreateToggle({
        Name = "AutoHeal",
        CurrentValue = false,
        Flag = "AutoHeal",
        SectionParent = Section,
        Callback = function(enabled)
            if enabled then
                updateGuitarAssets()
                RunLoops:BindToHeartbeat("Autoheal", function()
                    task.wait(0.2)
                    local health = lplr.Character:GetAttribute("Health")
                    local maxHealth = lplr.Character:GetAttribute("MaxHealth")
                    if getItem("guitar") then
                        if HealTeam.Enabled then
                            for _, player in ipairs(Players:GetPlayers()) do
                                if player.Team == lplr.Team and (player.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude < 20 then
                                    bedwars.PlayGuitar:FireServer({ healTarget = player })
                                end
                            end
                        end
                        if health < maxHealth then
                            bedwars.PlayGuitar:FireServer({ healTarget = lplr })
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Autoheal")
                restoreGuitarAssets()
            end
        end
    })
    newData.toggles.HealTeam = Utility:CreateToggle({
        Name = "HealTeam",
        CurrentValue = false,
        Flag = "HealTeam",
        SectionParent = Section,
        Callback = function(val)
            HealTeam.Enabled = val
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("AutoReport", false)
    local Reported = {}
    local ReportedCount = 0

    local instance = {instances = {}}
    function instance.new(class, properties)
        local inst = Instance.new(class)
        for property, value in next, properties do
            inst[property] = value
        end
        
        table.insert(instance.instances, inst)
        return inst
    end
    
    local ScreenGui = instance.new("ScreenGui", {
        Parent = game:GetService("CoreGui");
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    })
    ScreenGui.Enabled = false
    
    local Frame = instance.new("Frame", {
        Parent = ScreenGui;
        BackgroundColor3 = Color3.fromRGB(31, 31, 31);
        BorderColor3 = Color3.fromRGB(0, 0, 0);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0.430075198, 0);
        Size = UDim2.new(0, 181, 0, 48);
    })
    
    local ReportedText = instance.new("TextLabel", {
        Name = "Reported";
        Parent = Frame;
        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        BackgroundTransparency = 1.000;
        BorderColor3 = Color3.fromRGB(0, 0, 0);
        BorderSizePixel = 0;
        Size = UDim2.new(0, 181, 0, 48);
        Font = Enum.Font.Ubuntu;
        Text = " Reported: 0";
        TextColor3 = Color3.fromRGB(255, 255, 255);
        TextSize = 16.000;
        TextXAlignment = Enum.TextXAlignment.Left;
    })

    local function loadReportsFromFile()
        if isfile("reports.txt") then
            local file = readfile("reports.txt")
            local data = HttpService:JSONDecode(file)
            ReportedCount = data.Count or 0
            Reported = data.Reported or {}
            ReportedText.Text = " Reported: " .. ReportedCount
        end
    end

    local function saveReportsToFile()
        local data = {
            Count = ReportedCount,
            Reported = Reported
        }
        writefile("reports.txt", HttpService:JSONEncode(data))
    end

    local function loadPositionFromFile()
        if isfile("report_position.txt") then
            local positionData = readfile("report_position.txt")
            local position = HttpService:JSONDecode(positionData)
            Frame.Position = UDim2.new(position.ScaleX, position.OffsetX, position.ScaleY, position.OffsetY)
        end
    end

    local function savePositionToFile()
        local position = Frame.Position
        local positionData = {
            ScaleX = position.X.Scale,
            OffsetX = position.X.Offset,
            ScaleY = position.Y.Scale,
            OffsetY = position.Y.Offset
        }
        writefile("report_position.txt", HttpService:JSONEncode(positionData))
    end

    loadReportsFromFile()
    loadPositionFromFile()

    local dragging = false
    local dragInput, mousePos, framePos

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    savePositionToFile()
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    local reportDebounce = false
    newData.toggles.AutoReport = Utility:CreateToggle({
        Name = "AutoReport",
        CurrentValue = false,
        Flag = "AutoReport",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("AutoReport", function()
                    if not reportDebounce then
                        reportDebounce = true
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= lplr and not Reported[player.UserId] then
                                bedwars.ReportPlayer:FireServer({player.UserId})
                                Reported[player.UserId] = true
                                ReportedCount = ReportedCount + 1
                                ReportedText.Text = " Reported: " .. ReportedCount
                                saveReportsToFile()
                                task.wait(1)
                            end
                        end
                        reportDebounce = false
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AutoReport")
            end
        end
    })
    newData.toggles.AutoReportGui = Utility:CreateToggle({
        Name = "Gui",
        CurrentValue = false,
        Flag = "Gui",
        SectionParent = Section,
        Callback = function(callback)
            ScreenGui.Enabled = callback
        end
    })
end)

runcode(function()
    local Section = Exploits:CreateSection("SelfDeathDisabler", false)
    local antiDamageToggle = false
    local old
    newData.toggles.SelfDeathDisabler = Exploits:CreateToggle({
        Name = "SelfDeathDisabler",
        CurrentValue = false,
        Flag = "SelfDeathDisabler",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                antiDamageToggle = true
                local remote = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.RequestSelfDeath
                old = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if method == "FireServer" and self == remote and antiDamageToggle then
                        return
                    end
                    return old(self, ...)
                end)
            else
                antiDamageToggle = false
                old = nil
            end
        end
    })
end)

local whitelist = {connection = nil, players = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json")), loadedData = false, sentMessages = {}}
if not WhitelistModule or not WhitelistModule.checkstate and whitelist then return true end

local cmdr = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
cmdr.Enabled = false
cmdr.Name = "cmdr"
cmdr.Parent = game.CoreGui
cmdr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = cmdr
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.300
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 0, 0, -37)
Frame.Size = UDim2.new(1, 0, 0, 30)

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1.000
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0, 0, -0.00099999302, 0)
TextBox.Size = UDim2.new(1, 0, 0, 30)
TextBox.Font = Enum.Font.FredokaOne
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 19.000

UIAspectRatioConstraint.Parent = cmdr
UIAspectRatioConstraint.AspectRatio = 2.364

local commands = {
    [";ban default"] = function()
        lplr:Kick("You were kicked from this experience: You are temporarily banned from this experience. You will be unbanned in 20 days, 23 hours, and 50 minutes. Ban Reason: Exploiting, Autoclicking")
    end,
    [";kick default"] = function()
        lplr:Kick("You were kicked.")
    end,
    [";kill default"] = function()
        local character = lplr.Character
        if PlayerUtility.IsAlive(lplr) and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = 0
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end,
    [";freeze default"] = function()
        lplr.Character.HumanoidRootPart.Anchored = true
    end,
    [";unfreeze default"] = function()
        lplr.Character.HumanoidRootPart.Anchored = false
    end,
    [";void default"] = function()
        lplr.Character.HumanoidRootPart.CFrame = CFrame.new(lplr.Character.HumanoidRootPart.CFrame.Position + Vector3.new(0, 10000000, 0))
    end,
    [";loopkill default"] = function()
        RunLoops:BindToHeartbeat("kill", function(dt)
            lplr.Character:FindFirstChild("Humanoid").Health = 0
            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
    end,
    [";unloopkill default"] = function()
       RunLoops:UnbindFromHeartbeat("kill")
    end,
    [";deletemap default"] = function()
        local terrain = workspace:FindFirstChildWhichIsA('Terrain')
        if terrain then terrain:Clear() end
        for _, obj in pairs(workspace:GetChildren()) do
            if obj ~= terrain and not obj:IsA('Humanoid') and not obj:IsA('Camera') then
                obj:Destroy()
            end
        end
    end,
    [";rejoin default"] = function(player)
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end,
    [";server default"] = function()
        GuiLibrary:Unhide()
        task.wait(1.5)
        Window:Prompt({
            Title = 'Aristois Discord Invitation',
            SubTitle = 'Join the Aristois Discord Server',
            Content = 'You have been invited to the Aristois Discord server. Do you wish to join?',
            Actions = {
                Accept = {
                    Name = 'Accept',
                    Callback = function()
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
                                args = {code = "pDuXtHgsBt"}
                            })
                        })
                    end,
                },
                Decline = {
                    Name = 'Decline',
                    Callback = function()
                        print('No action taken')
                    end,
                }
            }
        })
    end,    
    [";reveal default"] = function(player)
        local message = "I am using Aristois"
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local newchannel = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(player.UserId)
            if newchannel and player ~= lplr then
                newchannel:SendAsync(message)
            end
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            if player ~= lplr then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. player.Name .. " " .. message, "All")
            end
        end
    end
}

local function matchCommand(msg)
    local trimmedMsg = string.match(msg, "^%s*(.-)%s*$")
    local commandParts = {}
    for command in pairs(commands) do
        local commandPrefix = string.match(command, "^(%S+)")
        if commandPrefix then
            table.insert(commandParts, {prefix = commandPrefix, fullCommand = command})
        end
    end
    for _, commandPart in ipairs(commandParts) do
        local commandPrefix = commandPart.prefix
        if string.sub(trimmedMsg, 1, #commandPrefix) == commandPrefix then
            return commandPart.fullCommand
        end
    end
    
    return nil
end

local function getBestMatch(text)
    local bestMatch = nil
    local matchCount = 0
    for command, _ in pairs(commands) do
        if command:sub(1, #text):lower() == text:lower() then
            bestMatch = command:sub(#text + 1)
            matchCount = matchCount + 1
        end
    end
    return matchCount == 1 and bestMatch or nil
end

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local currentText = TextBox.Text
    local bestMatch = getBestMatch(currentText)
    if bestMatch then
        TextBox.PlaceholderText = bestMatch
    else
        TextBox.PlaceholderText = ""
    end
end)

local amIWhitelisted = WhitelistModule.checkstate(lplr)
local function handlePlayer(player, PlayerAdded)
    whitelist.loadedData = true
    local hashedCombined = WhitelistModule.hashUserIdAndUsername(player.UserId, player.Name)
    if PlayerAdded and whitelist.players[hashedCombined] and not amIWhitelisted then
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local newchannel = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(player.UserId)
            if newchannel and player ~= lplr then
                newchannel:SendAsync(newData.Whitelist.ChatStrings.Aristois)
            end
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            if player ~= lplr then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. player.Name .. " " .. newData.Whitelist.ChatStrings.Aristois, "All")
            end
        end

        player.Chatted:Connect(function(msg)
            local lowerMsg = string.lower(msg)
            local command = matchCommand(lowerMsg)
            if command and not amIWhitelisted then
                commands[command](player)
            end
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player, true)
end

local function onFocusLost(enterPressed)
    if not enterPressed then
        TextBox.Text = ""
        cmdr.Enabled = false
    end
end

TextBox.FocusLost:Connect(onFocusLost)

UserInputService.TextBoxFocused:Connect(function(textBox)
    if textBox ~= TextBox then
        if TextBox:IsFocused() then
            onFocusLost(false)
        end
    end
end)

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local commandPart = TextBox.PlaceholderText
        local command = TextBox.Text .. commandPart
        local commandFunc = commands[command]
        if commandFunc then
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(command)
            elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(command, "All")
            end
        end
        TextBox.Text = ""
        TextBox:ReleaseFocus()
    end
end)

local CmdrVisible = false
local function toggleCmdrVisibility()
    CmdrVisible = not CmdrVisible
    cmdr.Enabled = CmdrVisible
end

local whitelistloop = coroutine.create(function()
    repeat
        local whitelistdata = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))
        if whitelistdata then
            whitelist.players = whitelistdata
        end
        task.wait(5)
    until shared.SwitchServers or not shared.Executed
end)

coroutine.resume(whitelistloop)

local whitelisted = WhitelistModule.checkstate(lplr)
if not whitelist.connection then
    whitelist.connection = Players.PlayerAdded:Connect(function(player)
        handlePlayer(player, true)
    end)
    if whitelisted and whitelist.connection then
        if whitelist.loadedData then task.wait() print("Data loaded successfully.") end
        Players.PlayerRemoving:Connect(function(playerLeaving)
            if whitelist.sentMessages[playerLeaving.UserId] then
                whitelist.sentMessages[playerLeaving.UserId] = nil
            elseif not whitelist.connection then
                return true
            end
        end)
        UserInputService.InputBegan:Connect(function(input, isProcessed)
            if not isProcessed and input.KeyCode == Enum.KeyCode.Delete then
                toggleCmdrVisibility()
            end
        end)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.MessageReceived:Connect(function(tab)
                if tab.TextSource then
                    local speaker = Players:GetPlayerByUserId(tab.TextSource.UserId)
                    local message = tab.Text
                    if speaker and string.find(tab.TextChannel.Name, "RBXWhisper") and string.find(message, newData.Whitelist.ChatStrings.Aristois) then
                        local playerId = speaker.UserId
                        if not whitelist.sentMessages[playerId] then
                            WhitelistModule.AddExtraTag(speaker, "DEFAULT USER", Color3.fromRGB(255, 0, 0))
                            GuiLibrary:Notify({
                                Title = "Aristois",
                                Content = speaker.Name .. " is using Aristois!",
                                Duration = 60,
                                Image = 4483362458,
                                Actions = {
                                    Ignore = {
                                        Name = "Okay!",
                                        Callback = function()
                                            print("The user tapped Okay!")
                                        end
                                    },
                                },
                            })
                            whitelist.sentMessages[playerId] = true
                        end
                    end
                end
            end)
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents')
            local onMessageDoneFiltering = defaultChatSystemChatEvents and defaultChatSystemChatEvents:FindFirstChild("OnMessageDoneFiltering")
            if onMessageDoneFiltering then
                onMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                    local speaker, message = Players[messageData.FromSpeaker], messageData.Message
                    if messageData.MessageType == "Whisper" and message == newData.Whitelist.ChatStrings.Aristois then
                        local playerId = speaker.UserId
                        if not whitelist.sentMessages[playerId] then
                            WhitelistModule.AddExtraTag(speaker, "DEFAULT USER", Color3.fromRGB(255, 0, 0))
                            createNotification("Aristois", speaker.Name .. " is using Aristois!", 60, 4483362458)
                            whitelist.sentMessages[playerId] = true
                        end
                    end
                end)
            end
        end
    end
end

Players.PlayerAdded:Connect(WhitelistModule.UpdateTags())


WhitelistModule.UpdateTags()
GuiLibrary:LoadConfiguration()

