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
getgenv().SecureMode = true
local GuiLibrary = loadstring(readfile("Aristois/GuiLibrary.lua"))()
print("a")
local PlayerUtility = loadstring(readfile("Aristois/Librarys/Utility.lua"))()
local WhitelistModule = loadstring(readfile("Aristois/Librarys/Whitelist.lua"))()
local weaponMeta = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/test/main/sword.json"))
local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local Whitelist = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))
local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end
shared.WhitelistFile = WhitelistModule

local Table = {
    ChatStrings = {
        Aristois = "I'm using Aristois",
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
local Window = GuiLibrary:CreateWindow({
    Name = "Aristois",
    LoadingTitle = "Aristois Interface",
    LoadingSubtitle = "by Xzyn and Wynnech",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "Aristois/configs",
       FileName = tostring(shared.AristoisPlaceId) .. ".lua"
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

do
    function RunLoops:BindToRenderStep(name, func)
        if RunLoops.RenderStepTable[name] == nil then
            RunLoops.RenderStepTable[name] = RunService.RenderStepped:Connect(func)
        end
    end

    function RunLoops:UnbindFromRenderStep(name)
        if RunLoops.RenderStepTable[name] then
            RunLoops.RenderStepTable[name]:Disconnect()
            RunLoops.RenderStepTable[name] = nil
        end
    end

    function RunLoops:BindToStepped(name, func)
        if RunLoops.StepTable[name] == nil then
            RunLoops.StepTable[name] = RunService.Stepped:Connect(func)
        end
    end

    function RunLoops:UnbindFromStepped(name)
        if RunLoops.StepTable[name] then
            RunLoops.StepTable[name]:Disconnect()
            RunLoops.StepTable[name] = nil
        end
    end

    function RunLoops:BindToHeartbeat(name, func)
        if RunLoops.HeartTable[name] == nil then
            RunLoops.HeartTable[name] = RunService.Heartbeat:Connect(func)
        end
    end

    function RunLoops:UnbindFromHeartbeat(name)
        if RunLoops.HeartTable[name] then
            RunLoops.HeartTable[name]:Disconnect()
            RunLoops.HeartTable[name] = nil
        end
    end
end

local Combat = Window:CreateTab("Combat", "17155691785")
local Blatant = Window:CreateTab("Blatant", "17155691785")
local Render = Window:CreateTab("Render", "17155691785")
local Utility = Window:CreateTab("Utility", "17155691785")
local Word = Window:CreateTab("Word", "17155691785")

local function runcode(func) func() end

local bedwars = {
    PickupRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("PickupItemDrop"),
    SwordHit = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SwordHit"),
    ConsumeItem = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ConsumeItem,
    PlayGuitar = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("PlayGuitar"),
    StopPlayingGuitar = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("StopPlayingGuitar"),
}

local networkownerswitch = tick()
local inventory
local connection

connection = RunService.Heartbeat:Connect(function()
    local lplr = Players.LocalPlayer 
    if lplr and lplr.Character and lplr.Character:FindFirstChild("InventoryFolder") then
        inventory = lplr.Character:FindFirstChild("InventoryFolder").Value
    end
end)

-- took this from vape yupp
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end

local function getSword()
    if not inventory or not weaponMeta then
        return nil
    end

    local bestSword
    local bestSwordMeta = 0
    for i, sword in ipairs(weaponMeta.weapons or {}) do
        local name = sword.name
        local meta = sword.meta
        if meta > bestSwordMeta and inventory:FindFirstChild(name) then
            bestSword = name
            bestSwordMeta = meta
        end
    end

    if bestSword then
        return inventory:FindFirstChild(bestSword)
    else
        return nil 
    end
end

local function getserverpos(Position)
    local x = math.round(Position.X/3)
    local y = math.round(Position.Y/3)
    local z = math.round(Position.Z/3)
    return Vector3.new(x,y,z)
end

local function getItem(itm)
    if lplr.Character:FindFirstChild("InventoryFolder").Value:FindFirstChild(itm) and PlayerUtility.IsAlive(lplr) then
        return true
    end
    return false
end

local function switchItem(tool, lol)
    if lplr.Character.HandInvItem.Value ~= tool then
        local args = {
            hand = tool
        }
        if lol then
            args.hand = inventory:WaitForChild(tool)
        end
        ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(args)
        local started = tick()
        repeat 
            task.wait() 
        until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
    end
end

local function SpeedMultiplier(flight)
    local baseMultiplier = 0.985
    local multiplier = baseMultiplier
    if lplr.Character:GetAttribute("StatusEffect_speed") then
        multiplier = multiplier + 0.6
    end
    if flight  then
        multiplier = multiplier - 0.5
    end     
    return multiplier
end

local nearest
local Distance = {["Value"] = 22}
runcode(function()
    local Section = Blatant:CreateSection("Killaura", false)
    local FacePlayerEnabled = {Enabled = false}
    local BoxesEnabled = {Enabled = false}
    local AttackAnimEnabled = {Enabled = false}
    local Swing = {Enabled = false}
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

    local boxHandleAdornment = Table.createBoxAdornment()
    local function updateBoxAdornment(root)
        if BoxesEnabled.Enabled then
            if boxHandleAdornment.Parent ~= root then
                boxHandleAdornment.Adornee = root
                if boxHandleAdornment.Adornee then
                    local cf = boxHandleAdornment.Adornee.CFrame
                    local x, y, z = cf:ToEulerAnglesXYZ()
                    boxHandleAdornment.CFrame = CFrame.new() * CFrame.Angles(-x, -y, -z)
                    boxHandleAdornment.Parent = root
                end
            end
        else
            boxHandleAdornment.Adornee = nil
            boxHandleAdornment.Parent = nil
        end
    end

    local function resetBoxAdornment()
        boxHandleAdornment.Adornee = nil
        boxHandleAdornment.Parent = nil
    end
    
    local function playanimation(id) 
        if PlayerUtility.IsAlive(lplr) then 
            local animation = Instance.new("Animation")
            animation.AnimationId = id
            local animatior = lplr.Character.Humanoid.Animator
            animatior:LoadAnimation(animation):Play()
        end
    end

    local origC0 = ReplicatedStorage.Assets.Viewmodel.RightHand.RightWrist.C0
    local Killaura = Blatant:CreateToggle({
        Name = "Killaura",
        CurrentValue = false,
        Flag = "Killaura",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Killaura", function()
                    if not PlayerUtility.IsAlive(lplr) then return end
                    nearest = PlayerUtility.getNearestEntity(Distance["Value"], false, true)
                    if not nearest or ((nearest:FindFirstChild("Humanoid") and nearest:FindFirstChild("Humanoid").Health) or nearest:GetAttribute("Health") or 1) <= 0 then
                        nearest = nil
                        if BoxesEnabled.Enabled then
                            boxHandleAdornment.Adornee = nil
                            boxHandleAdornment.Parent = nil
                        end
                        return 
                    end                    
                    local sword = getSword()
                    local root = nearest:FindFirstChild("HumanoidRootPart") or nearest.PrimaryPart
                    if root then
                        local distanceToNearest = (root.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                        switchItem(sword.Name, true)
                        if sword then
                            local selfPos = lplr.Character.HumanoidRootPart.Position + ((distanceToNearest > 14.3) and (CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, root.Position).LookVector * 4) or Vector3.new(0, 0, 0))
                            bedwars.SwordHit:FireServer({
                                weapon = sword,
                                entityInstance = nearest,
                                validate = {
                                    raycast = {},
                                    targetPosition = {value = root.Position},
                                    selfPosition = {value = selfPos},
                                },
                                chargedAttack = {chargeRatio = 0}
                            })
                        end
                        if FacePlayerEnabled.Enabled then
                            lplr.Character:SetPrimaryPartCFrame(CFrame.new(lplr.Character.HumanoidRootPart.Position, Vector3.new(root.Position.X, lplr.Character.HumanoidRootPart.Position.Y, root.Position.Z)))
                        end
                        if Swing.Enabled then
                            playanimation("rbxassetid://4947108314")
                        end
                        updateBoxAdornment(root)
                        if AttackAnimEnabled.Enabled and distanceToNearest < 18 and not VMAnimActive then
                            VMAnimActive = true
                            for _, anim in ipairs(Animations.Astral) do
                                TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(anim.Time), {C0 = origC0 * anim.CFrame}):Play()
                                task.wait(anim.Time)
                            end
                            for _, endAnim in ipairs(EndAnimation) do
                                TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(endAnim.Time), {C0 = origC0 * endAnim.CFrame}):Play()
                            end
                            VMAnimActive = false
                        elseif AttackAnimEnabled.Enabled and tick() - lastEndAnim > 0.07 then
                            VMAnimActive = true
                            for _, endAnim in ipairs(EndAnimation) do
                                TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(endAnim.Time), {C0 = origC0 * endAnim.CFrame}):Play()
                            end
                            VMAnimActive = false
                            lastEndAnim = tick()
                        end
                        lastEndAnim = tick()
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Killaura")
                resetBoxAdornment()
            end
        end
    })
    local KillauraDistance = Combat:CreateSlider({
        Name = "Distance",
        Range = {1, 32},
        Increment = 1,
        Suffix = "blocks",
        CurrentValue = 26,
        Flag = "KillAuraDistanceSlider",
        SectionParent = Section,
        Callback = function(Value)
            Distance["Value"] = Value
        end
    })
    local FacePlayer = Combat:CreateToggle({
        Name = "FacePlayer",
        CurrentValue = false,
        Flag = "RotationsKillauraToggle",
        SectionParent = Section,
        Callback = function(val)
            FacePlayerEnabled.Enabled = val
        end
    })
    local Boxes = Combat:CreateToggle({
        Name = "Boxes",
        CurrentValue = false,
        Flag = "Boxes",
        SectionParent = Section,
        Callback = function(val)
            BoxesEnabled.Enabled = val
            if not val then
                resetBoxAdornment()
            end
        end
    })
    local AnimationToggle = Combat:CreateToggle({
        Name = "Animations",
        CurrentValue = false,
        Flag = "AnimationsToggle",
        SectionParent = Section,
        Callback = function(val)
            AttackAnimEnabled.Enabled = val
        end
    })
    local KISwing = Combat:CreateToggle({
        Name = "Swing",
        CurrentValue = false,
        Flag = "Swing",
        SectionParent = Section,
        Callback = function(val)
            Swing.Enabled = val
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("AutoTrap", false)
    local trappedPlayers = {}
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

    local AutoTrap = Utility:CreateToggle({
        Name = "AutoTrap",
        CurrentValue = false,
        Flag = "AutoTrap",
        SectionParent = Section,
        Callback = function(val)
            if val then
                RunLoops:BindToHeartbeat("AutoTrap", function(dt)
                    if getItem("snap_trap") then
                        switchItem("snap_trap")
                        local nearestCharacter = PlayerUtility.getNearestEntity(TrapDistance["Value"], false, false)
                        if nearestCharacter and nearestCharacter ~= lplr.Character and not nearestCharacter:FindFirstChild("BillboardGui") then
                            local root = nearestCharacter:FindFirstChild("HumanoidRootPart") or nearestCharacter.PrimaryPart
                            if root then
                                local distance = (root.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                                if distance <= 18 then
                                    local velocity = root.Velocity
                                    local acceleration = (velocity - (previousVelocities[nearestCharacter] or velocity)) / dt
                                    local predictedPosition = root.Position + velocity * trapSetupTime + 0.5 * acceleration * trapSetupTime ^ 2
                                    previousVelocities[nearestCharacter] = velocity

                                    if nearestCharacter.Humanoid:GetState() == Enum.HumanoidStateType.Jumping or nearestCharacter.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                                        local timeToLand = math.sqrt((2 * predictedPosition.Y) / 196.2)
                                        predictedPosition = predictedPosition + root.Velocity * timeToLand
                                    end

                                    local trapPosition = RoundVector(predictedPosition) + Vector3.new(0, -1, 0)
                                    if IsTrapPlaceable(trapPosition, root.Position) then
                                        local trapData = {
                                            ["blockType"] = "snap_trap",
                                            ["blockData"] = 0,
                                            ["position"] = getserverpos(trapPosition)
                                        }
                                        game:GetService("ReplicatedStorage").rbxts_include.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged.PlaceBlock:InvokeServer(trapData)
                                    end
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
    local TrapDistance = Utility:CreateSlider({
        Name = "Distance",
        Range = {1, 22},
        Increment = 1,
        Suffix = "Distance",
        CurrentValue = 32,
        Flag = "TrapDistance",
        SectionParent = Section,
        Callback = function(Value)
            TrapDistance["Value"] = Value
        end
    })
end)

local SpeedSlider = {["Value"] = 23}
runcode(function()
    local Section = Blatant:CreateSection("Speed", false)
    local lastMoveTime = tick()
    local AutoJump = false
    local AutoJump = {Enabled = false}
    local HeatSeeker = {Enabled = false}
    local IdleThreshold = {["Value"] = 0.97}
    local SpeedDuration = {["Value"] = 0.62}
    local SpeedToggle = Blatant:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "Speed",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Speed", function(dt)
                    local lastMoveTime = tick()
                    if PlayerUtility.IsAlive(lplr) and isnetworkowner(lplr.Character.HumanoidRootPart) then
                        local speedMultiplier = SpeedMultiplier()
                        local speedIncrease = SpeedSlider.Value
                        local currentSpeed = lplr.Character.Humanoid.WalkSpeed
                        local moveDirection = lplr.Character.Humanoid.MoveDirection
                        local newVelocity = Vector3.new(0, 0, 0)
                        if HeatSeeker.Enabled then
                            if moveDirection.magnitude < 0.01 then
                                lastMoveTime = tick()
                            elseif tick() - lastMoveTime > SpeedDuration.Value then
                                if tick() - lastMoveTime > SpeedDuration.Value + IdleThreshold.Value then
                                    lastMoveTime = tick()
                                else
                                    newVelocity = moveDirection * (1.1 * speedMultiplier - currentSpeed)
                                end
                            else
                                newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                            end
                        else
                            newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                        end
                        lplr.Character:TranslateBy(newVelocity * dt)
                        if nearest and AutoJump.Enabled then
                           local root = nearest:FindFirstChild("HumanoidRootPart") or nearest.PrimaryPart
                            local distanceToNearest = (root.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                            if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and lplr.Character.Humanoid.MoveDirection ~= Vector3.zero then
                                if distanceToNearest <= 18  then
                                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 15, lplr.Character.HumanoidRootPart.Velocity.Z)
                                end
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Speed")
            end
        end
    })
    local DistanceSlider = Blatant:CreateSlider({
        Name = "Speed", 
        Range = {1, 23},
        Increment = 0.1,
        Suffix = "Speed.",
        CurrentValue = 23,
        Flag = "DistanceSlider",
        SectionParent = Section,
        Callback = function(Value)
            SpeedSlider.Value = Value
        end
    })
    local HeatSeekerToggle = Blatant:CreateToggle({
        Name = "HeatSeeker",
        CurrentValue = HeatSeeker.Enabled,
        Flag = "HeatSeeker",
        SectionParent = Section,
        Callback = function(callback)
            HeatSeeker.Enabled = callback
        end
    })
    local SpeedDurationSlider = Blatant:CreateSlider({
        Name = "SpeedDuration (HeatSeeker)",
        Range = {0.01, 0.62},
        Increment = 0.01,
        Suffix = "seconds",
        CurrentValue = 0.62,
        Flag = "SpeedDuration",
        SectionParent = Section,
        Callback = function(Value)
            SpeedDuration.Value = Value
        end
    })
    local IdleThresholdSlider = Blatant:CreateSlider({
        Name = "IdleThreshold (HeatSeeker)",
        Range = {0.01, 0.97},
        Increment = 0.01,
        Suffix = "seconds",
        CurrentValue = 0.97,
        Flag = "IdleThreshold",
        SectionParent = Section,
        Callback = function(Value)
            IdleThreshold.Value = Value
        end
    })
    local AutoJumpToggle = Blatant:CreateToggle({
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
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = false
    
    local Section = Blatant:CreateSection("Flight", false)
    
    local FlightSpeedSlider = {["Value"] = 15} 
    local FlightVerticalSpeedSlider = {["Value"] = 50}
    
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 0.5
    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
    Frame.Size = UDim2.new(0.277, 0, 0, 20)
    
    local SecondLeft = Instance.new("TextLabel")
    SecondLeft.Name = "SecondLeft"
    SecondLeft.Parent = Frame
    SecondLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SecondLeft.BackgroundTransparency = 1
    SecondLeft.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SecondLeft.BorderSizePixel = 0
    SecondLeft.Position = UDim2.new(0.5, 0, 0.4, 0)
    SecondLeft.AnchorPoint = Vector2.new(0.5, 0.5)
    SecondLeft.Size = UDim2.new(0, 340, 0, 19)
    SecondLeft.Font = Enum.Font.Gotham
    SecondLeft.Text = "0s" 
    SecondLeft.TextColor3 = Color3.fromRGB(0, 0, 0)
    SecondLeft.TextSize = 20
    SecondLeft.ZIndex = 2 
    
    local TweenFrame = Instance.new("Frame")
    TweenFrame.Name = "TweenFrame"
    TweenFrame.Parent = Frame
    TweenFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TweenFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TweenFrame.BorderSizePixel = 0
    TweenFrame.Position = UDim2.new(0, 0, 0, 0)
    TweenFrame.Size = UDim2.new(0, 340, 0, 20)
    TweenFrame.ZIndex = 1
    
    local function UpdateSecondLeft(seconds)
        SecondLeft.Text = seconds .. "s"
        
        local maxWidth = 340 
        local remainingRatio = seconds / 2.5 
        local newWidth = maxWidth * remainingRatio
        
        local endSize = UDim2.new(remainingRatio, 0, 1, 0)
        local endPosition = UDim2.new(0, 0, 0, 0)
        local tweenDuration = 0.5 
        
        TweenService:Create(TweenFrame, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = endSize,
            Position = endPosition
        }):Play()
    end
    
    local function round(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end
    
    local originalGravity = workspace.Gravity
    local FlightToggle = Blatant:CreateToggle({
        Name = "Flight",
        CurrentValue = false,
        Flag = "Flight",
        SectionParent = Section,
        Callback = function(callback)
            local character = lplr.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

            local lastTick = tick()
            local airTimer = 0
            local i = 0
            local verticalVelocity = 0
            if callback then
                TweenFrame.Visible = true
                ScreenGui.Enabled = true
                RunService:BindToRenderStep("Fly", Enum.RenderPriority.Camera.Value, function()
                    local currentTick = tick()
                    local deltaTime = currentTick - lastTick
                    lastTick = currentTick
                    airTimer = airTimer + deltaTime
                    local remainingTime = math.max(2.5 - airTimer, 0)
                    remainingTime = round(remainingTime, 1)
                    
                    UpdateSecondLeft(remainingTime)
                    
                    local speedMultiplier = 0.95
                    workspace.Gravity = 0  
                    if lplr.Character:GetAttribute("StatusEffect_speed") then
                        speedMultiplier = speedMultiplier + 0.6
                    end
                    if callback then
                        speedMultiplier = speedMultiplier - 0.208
                    end
                    
                    local flySpeed = FlightSpeedSlider.Value * speedMultiplier
                    local flyVelocity = humanoid.MoveDirection * flySpeed
                    
                    i = i + deltaTime
                    local bounceVelocity = math.sin(i * math.pi) * 0.1
                    
                    local flyUp = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                    local flyDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                    
                    if flyUp then
                        verticalVelocity = FlightVerticalSpeedSlider.Value
                    elseif flyDown then
                        verticalVelocity = -FlightVerticalSpeedSlider.Value
                    else
                        verticalVelocity = bounceVelocity
                    end
                    
                    if humanoidRootPart then
                        humanoidRootPart.Velocity = flyVelocity + Vector3.new(0, verticalVelocity, 0)
                        local playerMass = humanoidRootPart:GetMass()
                        local gravityForce = playerMass * Workspace.Gravity
                        local counteractingForce = -gravityForce * deltaTime
                        humanoidRootPart.Velocity = humanoidRootPart.Velocity + Vector3.new(0, counteractingForce, 0)
                    end
                    if airTimer > 2.35 then
                        workspace.Gravity = originalGravity
                        local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, -1000, 0))
                        local ignoreList = {lplr, character}
                        local hitPart, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
                        if hitPart then
                            local originalPosition = humanoidRootPart.Position
                            humanoidRootPart.CFrame = CFrame.new(originalPosition.X, hitPosition.Y + 0, originalPosition.Z)
                            airTimer = 0
                            wait(0.2)
                            humanoidRootPart.CFrame = CFrame.new(originalPosition.X, originalPosition.Y, originalPosition.Z)
                            airTimer = 0
                            TweenService:Create(TweenFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                                Position = UDim2.new(1, 0, 0, 0) 
                            }):Play()
                        end
                    end
                end)
            else
                TweenService:Create(TweenFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, 0, 0, 0) 
                }):Play()
                ScreenGui.Enabled = false
                RunService:UnbindFromRenderStep("Fly")
                if humanoidRootPart then
                    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
                Workspace.Gravity = 193.1999969482422  
            end
        end
    })
    local FlightSpeedSliderInstance = Blatant:CreateSlider({
        Name = "FlightSpeed",
        Range = {1, 23},
        Increment = 0.1,
        Suffix = "Speed",
        CurrentValue = 15,
        Flag = "FlightSpeedSlider",
        SectionParent = Section,
        Callback = function(Value)
            FlightSpeedSlider["Value"] = Value
        end
    })
    local FlightVerticalSpeedSliderInstance = Blatant:CreateSlider({
        Name = "FlyVerticalSpeed",
        Range = {1, 100},
        Increment = 1,
        Suffix = "Vertical Speed",
        CurrentValue = 50,
        Flag = "FlightVerticalSpeedSlider",
        SectionParent = Section,
        Callback = function(Value)
            FlightVerticalSpeedSlider["Value"] = Value
        end
    })
    local FlightKeybind = Blatant:CreateKeybind({
        Name = "Flight Keybind",
        CurrentKeybind = "R",
        HoldToInteract = false,
        Flag = "FlightKeybindToggle",
        SectionParent = Section,
        Callback = function(Keybind)
            FlightToggle:Set(not FlightToggle.CurrentValue)
        end,
    })
    TweenFrame.Visible = true
end)

local LongJumpToggle
local ClickTP
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
        for _, item in ipairs(inventory:GetChildren()) do
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
        
        local hitDetected = false
    
        handle.Touched:Connect(function(hit)
            if hit.Parent == target then
                bodyVelocity:Destroy()
                bodyForce:Destroy()
                game:GetService("Debris"):AddItem(clonedProjectile, data.predictionLifetimeSec)
                hitDetected = true
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
                        local result = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileFire:InvokeServer(unpack(args))
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
    local ProjectileAura = Blatant:CreateToggle({
        Name = "ProjectileAura",
        CurrentValue = false,
        Flag = "ProjectileAura",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("ShootLoop", function()
                    local target = PlayerUtility.getNearestEntity(60, false, true)
                    local rangeCheck = PlayerUtility.getNearestEntity(Distance["Value"], false, true)
                    if LongJumpToggle.CurrentValue or ClickTP.CurrentValue then
                        if not notificationSent then
                            GuiLibrary:Notify({
                                Title = "Aristois",
                                Content = "Long Jump or Click TP is active. ProjectileAura will not work!",
                                Duration = 15,
                                Image = 4483362458,
                                Actions = {
                                    Ignore = {Name = "Okay!", Callback = function() print("The user tapped Okay!") end},
                                },
                            })
                            notificationSent = true
                        end
                    else
                        notificationSent = false
                    end
                    if not target or ((target:FindFirstChild("Humanoid") and target:FindFirstChild("Humanoid").Health) or target:GetAttribute("Health") or 1) <= 0 then
                        return 
                    end
                    if target and not isShooting then
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

--[[runcode(function()
    local cooldowns = {
        arrow = 0.6,
        snowball = 0.2
    }

    local lastFiredTimes = {}
    local isShooting = false

    local function getAllBows()
        local bows = {}
        for _, item in ipairs(inventory:GetChildren()) do
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

    local function shoot(target)
        local currentTime = os.clock()
        local bows = getAllBows()
        local availableBows = {}

        for _, v in ipairs(bows) do
            local itemName = v.Name
            local cooldown = cooldowns[itemName] or 0
            if not lastFiredTimes[itemName] or currentTime - lastFiredTimes[itemName] >= cooldown then
                table.insert(availableBows, v)
            end
        end

        sortItems(availableBows)

        local allBowsUsed = false
        while #availableBows > 0 and not allBowsUsed do
            allBowsUsed = true
            for i, v in ipairs(availableBows) do
                local itemName = v.Name
                local cooldown = cooldowns[itemName] or 0
                if not lastFiredTimes[itemName] or currentTime - lastFiredTimes[itemName] >= cooldown then
                    switchItem(v)
                    if PlayerUtility.IsAlive(target) then
                        local ping = lplr:GetNetworkPing()
                        local targetPosition = target.Character.PrimaryPart.Position
                        local targetVelocity = target.Character.PrimaryPart.Velocity
                        local predictedPosition = targetPosition + targetVelocity * ping
                        local args = {
                            [1] = v,
                            [2] = (v.Name == "snowball" and "snowball") or "arrow",
                            [3] = (v.Name == "snowball" and "snowball") or "arrow",
                            [4] = predictedPosition,
                            [5] = predictedPosition + Vector3.new(0, 2, 0),
                            [6] = Vector3.new(0, -5, 0),
                            [7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
                            [8] = {
                                ["drawDurationSeconds"] = 1,
                                ["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
                            },
                            [9] = workspace:GetServerTimeNow() - 0.045
                        }
                        game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileFire:InvokeServer(unpack(args))
                        lastFiredTimes[itemName] = currentTime
                        table.remove(availableBows, i)
                        allBowsUsed = false
                        break
                    end
                end
            end
        end
    end

    local Section = Blatant:CreateSection("ProjectileExploit", false)
    local notificationSent = false 
    local ProjectileExploit = Blatant:CreateToggle({
        Name = "ProjectileExploit",
        CurrentValue = false,
        Flag = "ProjectileExploit",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("ShootLoop22", function(dt)
                    if not isShooting then
                        isShooting = true
                        local target = PlayerUtility.getNearestEntity(1000, false, true)
                        local rangeCheck = PlayerUtility.getNearestEntity(Distance["Value"], false, true)
                        if LongJumpToggle.CurrentValue or ClickTP.CurrentValue then
                            if not notificationSent then
                                GuiLibrary:Notify({
                                    Title = "Aristois",
                                    Content = "Long Jump or Click TP is active. ProjectileExploit will not work!",
                                    Duration = 15,
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
                                notificationSent = true
                            end
                        else
                            notificationSent = false
                        end
                        if target and target.Team ~= lplr.Team and PlayerUtility.IsAlive(target) and PlayerUtility.IsAlive(lplr) and not target.Character:FindFirstChild("ForceField") and not rangeCheck and not LongJumpToggle.CurrentValue and not ClickTP.CurrentValue then
                            shoot(target)
                            task.wait(0.03)
                        end
                        isShooting = false
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("ShootLoop2")
            end
        end
    })
end)--]]

runcode(function()
    local Section = Blatant:CreateSection("InfiniteFly", false)
    local CameraTypes = {Enum.CameraType.Custom, Enum.CameraType.Scriptable, Enum.CameraType.Fixed}
    local MaxFlyDuration = {["Value"] = 2.5}
    local CtrlPressed = false
    local SpacePressed = false
    local InputBeganConnection
    local InputEndedConnection
    local TeleportEnabled = false
    local FlyRoot
    local FlyStartTime
    local function TextBoxFocused()
        for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextBox") and gui:IsFocused() then
                return true
            end
        end
        return false
    end
    local InfiniteFlyToggle = Blatant:CreateToggle({
        Name = "InfiniteFly",
        CurrentValue = false,
        Flag = "InfiniteFly",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                    if TextBoxFocused() then
                        return
                    end
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        CtrlPressed = true
                    elseif input.KeyCode == Enum.KeyCode.Space then
                        SpacePressed = true
                    end
                end)
                
                InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                    if TextBoxFocused() then
                        return
                    end
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        CtrlPressed = false
                    elseif input.KeyCode == Enum.KeyCode.Space then
                        SpacePressed = false
                    end
                end)                          
                lplr.CharacterAdded:Connect(function(character)
                    lplr.Character = character
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    TeleportEnabled = true
                end)
                lplr.CharacterRemoving:Connect(function()
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    TeleportEnabled = true
                end)
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
                FlyStartTime = tick()
                TeleportEnabled = true
                RunLoops:BindToHeartbeat("InfiniteFly", function()
                    if FlyRoot then
                        if not FlyRoot or not FlyRoot.Parent then
                            if FlyRoot then
                                FlyRoot:Destroy()
                                FlyRoot = nil
                            end
                            TeleportEnabled = true
                            return
                        end
                        local Distance = (lplr.Character.HumanoidRootPart.Position - FlyRoot.Position).Magnitude
                        if Distance < 10000 and TeleportEnabled then
                            lplr.Character.HumanoidRootPart.CFrame = CFrame.new(FlyRoot.Position + Vector3.new(0, 200000, 0))
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
                if InputBeganConnection then
                    InputBeganConnection:Disconnect()
                end
                if InputEndedConnection then
                    InputEndedConnection:Disconnect()
                end
                TeleportEnabled = false
                local RayStart = FlyRoot.Position
                local RayEnd = RayStart - Vector3.new(0, 10000, 0)
                local IgnoreList = {lplr, lplr.Character, FlyRoot, game.Workspace.CurrentCamera}
                local HitPart, HitPosition = workspace:FindPartOnRayWithIgnoreList(Ray.new(RayStart, RayEnd - RayStart), IgnoreList, true, true)
                if HitPart then
                    local newY
                    newY = HitPosition.Y + (lplr.Character.HumanoidRootPart.Size.Y / 2) + lplr.Character.Humanoid.HipHeight
                    game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.GroundHit:FireServer()
                    lplr.Character:SetPrimaryPartCFrame(CFrame.new(HitPosition.X, newY, HitPosition.Z))
                end
                local FlyDuration = tick() - FlyStartTime
                if FlyDuration > MaxFlyDuration["Value"] then
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, -1, 0)
                    local CurrentCamera = game.Workspace.CurrentCamera
                    CurrentCamera.CameraSubject = lplr.Character.Humanoid
                    CurrentCamera.CameraType = CameraTypes[1]
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    task.wait(0.3)
                    local bodyVel = Instance.new("BodyVelocity",  lplr.Character.HumanoidRootPart)
                    bodyVel.Velocity = Vector3.new(0, -1, 0)
                    bodyVel.MaxForce = Vector3.new(0, 18446743523953735354, 0)
                    task.wait(1.2)
                    bodyVel:Destroy()
                else
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, -1, 0)
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    Camera.CameraSubject = lplr.Character.Humanoid
                    if workspace.CurrentCamera and lplr.Character then
                        local humanoid = lplr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            workspace.CurrentCamera.CameraSubject = humanoid
                        end
                    end
                end
            end
        end
    })
    local Infflykeybind = Blatant:CreateKeybind({
        Name = "Flight Keybind",
        CurrentKeybind = "Z",
        HoldToInteract = false,
        Flag = "Infflykeybind",
        SectionParent = Section,
        Callback = function(Keybind)
            InfiniteFlyToggle:Set(not InfiniteFlyToggle.CurrentValue)
        end,
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("LongJump", false)
    local LongJumpbindCheck = false
    local velo
    local startTime
    local function CheckForFireballs()
        local fireball = {}
        for _, item in ipairs(inventory:GetChildren()) do
            if item.Name:find("fireball") then
                table.insert(fireball, item)
            end
        end
            
        return fireball
    end

    LongJumpToggle = Blatant:CreateToggle({
        Name = "LongJump",
        CurrentValue = false,
        Flag = "LongJump",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                task.wait()
                local Fireballs = CheckForFireballs()
                for i, v in pairs(Fireballs) do
                    repeat
                        switchItem(v)
                    until lplr.Character.HandInvItem.Value ~= "fireball"
                    local pos = lplr.Character.PrimaryPart.Position
                    velo = Instance.new("BodyVelocity")
                    velo.MaxForce = Vector3.new(9e9,9e9,9e9)
                    velo.Velocity = Vector3.new(0,0.5,0)
                    velo.Parent = lplr.Character:FindFirstChild("HumanoidRootPart")
                    startTime = tick()
                    local args = {
                        [1] = v,
                        [2] = "fireball",
                        [3] = "fireball",
                        [4] = pos,
                        [5] = pos + Vector3.new(0, 2, 0),
                        [6] = Vector3.new(0, -5, 0),
                        [7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
                        [8] = {
                            ["drawDurationSeconds"] = 1,
                            ["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
                        },
                        [9] = workspace:GetServerTimeNow() - 0.045
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileFire"):InvokeServer(unpack(args))
                    task.wait(0.45)
                    velo.Velocity = lplr.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 60 + Vector3.new(0,1,0)
                end                    
            else
                if velo then
                    velo:Destroy()
                end
                velo = nil
                startTime = nil
            end
        end
    })
    local Flight = Blatant:CreateKeybind({
        Name = "LongJump Keybind",
        CurrentKeybind = "X",
        HoldToInteract = false,
        Flag = "LongJump",
        SectionParent = Section,
        Callback = function(Keybind)
            LongJumpToggle:Set(not LongJumpToggle.CurrentValue)
        end
    })
    game:GetService("RunService").Heartbeat:Connect(function()
        if velo and tick() - startTime > 2.3 then
            velo.Velocity = velo.Velocity.unit * 22
        end
    end)
end)

runcode(function()
    local Section = Blatant:CreateSection("Nofall", false)
    local NofallToggle = Blatant:CreateToggle({
        Name = "Nofall",
        CurrentValue = false,
        Flag = "Nofall",
        SectionParent = Section,
        Callback = function(callback)
            local Fall = false
            local Client
            if callback then
                repeat
                    task.wait(0.5)
                    if not Fall then
                        local success, err = pcall(function()
                            if not Client then
                                Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
                            end
                            Client:Get("GroundHit"):SendToServer()
                        end)
                        if not success then
                            Fall = true
                        end
                    end
                    if Fall then
                        game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.GroundHit:FireServer()
                    end
                until not callback
            end
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
    local AutoConsume = Utility:CreateToggle({
        Name = "AutoConsume",
        CurrentValue = false,
        Flag = "AutoConsume",
        SectionParent = Section,
        Callback = function(enabled)
            if enabled then
                RunLoops:BindToHeartbeat("AutoConsume", function()
                    local health = lplr.Character:GetAttribute("Health")
                    local maxHealth = lplr.Character:GetAttribute("MaxHealth")
                    for _, itemInfo in ipairs(Consumeables) do
                        local itemName = itemInfo.Name
                        local statusCheck = itemInfo.StatusCheck
                        if itemName == "apple" and health < maxHealth then
                            local item = inventory:FindFirstChild(itemName)
                            if item then
                                bedwars.ConsumeItem:InvokeServer({
                                    ["item"] = item
                                })
                            end
                        elseif itemName ~= "apple" then
                            local item = inventory:FindFirstChild(itemName)
                            if item then
                                if not statusCheck or not lplr.Character:GetAttribute(statusCheck) then
                                    bedwars.ConsumeItem:InvokeServer({
                                        ["item"] = item
                                    })
                                end
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AutoConsume")
            end
        end
    }) 
    local Dropdown = Utility:CreateDropdown({
        Name = "Select Consumables",
        Options = {"speed_potion", "invisibility_potion", "forcefield_potion", "apple"},
        CurrentOption = {"speed_potion", "invisibility_potion", "forcefield_potion", "apple"},
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
    local Section = Render:CreateSection("ViewModel", false)
    local SwordSizeEnabled = false
    local FovEnabled = false
    local Fov = {["Value"] = 70}
    local SwordScale = {["Value"] = 3}
    local SwordScaleConnection
    local FovConnection
    
    local ViewModelToggle = Render:CreateToggle({
        Name = "ViewModelAdjustments",
        CurrentValue = false,
        Flag = "ViewModelToggle",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("ViewModel", function()
                    if SwordSizeEnabled then
                        local function scaleChildren(obj, scale)
                            for _, child in ipairs(obj:GetChildren()) do
                                if child:IsA("BasePart") then
                                    child.Size = child.Size / (1.5 ^ SwordScale.Value)
                                end
                                scaleChildren(child, scale)
                            end
                        end
                        for _, viewModel in ipairs(Camera.Viewmodel:GetChildren()) do
                            if viewModel:FindFirstChild("Handle") then
                                pcall(function()
                                    scaleChildren(viewModel, 1.5 ^ SwordScale.Value)
                                end)
                            end
                        end
                    end
                    if FovEnabled then
                        Camera.FieldOfView = Fov.Value
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("ViewMode")
            end
        end
    })
    local SwordSizeToggle = Render:CreateToggle({
        Name = "Enable Sword Size Adjustment",
        CurrentValue = false,
        Flag = "SwordSizeToggle",
        SectionParent = Section,
        Callback = function(enabled)
            SwordSizeEnabled = enabled
        end
    })
    local SwordScaleSlider = Render:CreateSlider({
        Name = "Sword Scale",
        Range = {1, 10},
        Increment = 1,
        Suffix = "x",
        CurrentValue = 3,
        Flag = "SwordScaleSlider",
        SectionParent = Section,
        Callback = function(value)
            SwordScale.Value = value
        end
    })
    local FovToggle = Render:CreateToggle({
        Name = "Enable FOV Adjustment",
        CurrentValue = false,
        Flag = "FovToggle",
        SectionParent = Section,
        Callback = function(callback)
            FovEnabled = callback
        end
    })
    local FovSlider = Render:CreateSlider({
        Name = "Field of View",
        Range = {1, 120},
        Increment = 1,
        Suffix = "°",
        CurrentValue = 70,
        Flag = "FovSlider",
        SectionParent = Section,
        Callback = function(value)
            Fov.Value = value
        end
    })
end)

runcode(function()
    local character = lplr.Character or lplr.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local previousPositions = {}
    local breadCrumbsLines = {}
    local firstLine = true

    local function createLineSegment(startPos, endPos)
        local line = Drawing.new("Line")
        line.Visible = true
        line.Thickness = 4
        line.Transparency = 1
        local t = tick() % 5 / 5
        local color1 = Color3.new(253 / 255, 195 / 255, 47 / 255)
        local color2 = Color3.new(252 / 255, 67 / 255, 229 / 255)
        local lerpedColor = color1:Lerp(color2, t)
        line.Color = lerpedColor
        line.From = startPos
        line.To = endPos
        return line
    end

    local Section = Render:CreateSection("BreadCrumbs", false)
    local BreadCrumbsToggle = Render:CreateToggle({
        Name = "BreadCrumbs",
        CurrentValue = false,
        Flag = "BreadCrumbs",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("BreadCrumbs", function()
                    local feetOffset = Vector3.new(0, -humanoidRootPart.Size.Y / 0.7, 0)
                    local characterPos = humanoidRootPart.Position + feetOffset
                    table.insert(previousPositions, 1, characterPos)
                    if #previousPositions > 150 then
                        table.remove(previousPositions)
                    end
                    for i = 1, #previousPositions - 1 do
                        local start, endPos
                        if firstLine or i > 1 then
                            start = Camera:WorldToViewportPoint(previousPositions[i])
                        else
                            start = Camera:WorldToViewportPoint(previousPositions[i + 1])
                        end
                        endPos = Camera:WorldToViewportPoint(previousPositions[i + 1])
                        if start.Z > 0 and endPos.Z > 0 then
                            if breadCrumbsLines[i] then
                                breadCrumbsLines[i].From = Vector2.new(start.X, start.Y)
                                breadCrumbsLines[i].To = Vector2.new(endPos.X, endPos.Y)
                            else
                                breadCrumbsLines[i] = createLineSegment(Vector2.new(start.X, start.Y), Vector2.new(endPos.X, endPos.Y))
                            end
                        else
                            if breadCrumbsLines[i] then
                                breadCrumbsLines[i]:Remove()
                                breadCrumbsLines[i] = nil
                            end
                        end
                    end
                    for i = #previousPositions, #breadCrumbsLines + 1, -1 do
                        if breadCrumbsLines[i] then
                            breadCrumbsLines[i]:Remove()
                            breadCrumbsLines[i] = nil
                        end
                    end
                    firstLine = false
                end)
            else
                RunLoops:UnbindFromHeartbeat("BreadCrumbs")
                for _, line in pairs(breadCrumbsLines) do
                    line:Remove()
                end
                breadCrumbsLines = {}
            end
        end
    })
    lplr.CharacterAdded:Connect(function(character)
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    end)
end)

runcode(function()
    local Section = Render:CreateSection("TargetHub", false)
    local StatsGuiTemplate = game:GetObjects("rbxassetid://18225109963")[1]
    local clonedStatsGui = nil

    local function UpdateHealthBar(fill, currentHealth, maxHealth)
        fill.Size = UDim2.new(currentHealth / maxHealth, 0, 1, 0)
    end

    local function UpdateHpText(Hp, currentHealth)
        Hp.Text = tostring(math.floor(currentHealth + 0.5)) .. "%"
    end

    local function SetPlayerIcon(Playericon, player)
        local userId = player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        if isReady then
            Playericon.Image = content
        end
    end

    local DisplayNames = {Enabled = false}

    local function updateStatsGui(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and clonedStatsGui then
            local Health = clonedStatsGui.CanvasGroup.Content.Health
            local bar = Health.bar
            local fill = bar.fill
            local Hp = clonedStatsGui.CanvasGroup.Content.Hp
            local maxHealth = humanoid.MaxHealth
            local currentHealth = humanoid.Health
            UpdateHpText(Hp, currentHealth)
            UpdateHealthBar(fill, currentHealth, maxHealth)
            local Playericon = clonedStatsGui.CanvasGroup.Content.Health.Playericon
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                SetPlayerIcon(Playericon, player)
                local username = clonedStatsGui.CanvasGroup.Content.username
                username.Text = DisplayNames.Enabled and player.DisplayName or player.Name
            end
        end
    end

    local function setupStatsGui(character)
        clonedStatsGui = StatsGuiTemplate:Clone()
        clonedStatsGui.StudsOffset = Vector3.new(0.4, 0, 0)
        clonedStatsGui.Parent = character:FindFirstChild("HumanoidRootPart")
        clonedStatsGui.Size = UDim2.new(0, 1000, 0, 100)
        clonedStatsGui.CanvasGroup.Content.Position = UDim2.new(0, 0, 0, 0)
        updateStatsGui(character)
    end

    local TargethubToggle = Render:CreateToggle({
        Name = "TargetHub",
        CurrentValue = false,
        Flag = "TargetHub",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                task.wait(0.01)
                RunLoops:BindToHeartbeat("TargetHub", function()
                    if nearest then
                        local root = nearest:FindFirstChild("HumanoidRootPart") or nearest.PrimaryPart
                        if PlayerUtility.IsAlive(lplr) and root then
                            local distanceToNearest = (root.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                            if distanceToNearest <= 25 then
                                if not clonedStatsGui then
                                    setupStatsGui(nearest)
                                else
                                    clonedStatsGui.Parent = root
                                    updateStatsGui(nearest)
                                end
                            else
                                if clonedStatsGui then
                                    clonedStatsGui:Destroy()
                                    clonedStatsGui = nil
                                end
                            end
                        else
                            if clonedStatsGui then
                                clonedStatsGui:Destroy()
                                clonedStatsGui = nil
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("TargetHub")
                if clonedStatsGui then
                    clonedStatsGui:Destroy()
                    clonedStatsGui = nil
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
            DisplayNames.Enabled = val
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
        if player.Team ~= lplr.Team then
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

            local function updateNameTag()
                if enabled and player.Character and player.Character:FindFirstChild("Head") then
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
                end
            end

            RunService.RenderStepped:Connect(updateNameTag)
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

    local function initializeNameTags()
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
    end

    local function updateAllNameTags()
        for player, nameTag in pairs(nameTags) do
            if player.Character then
                nameTag:Remove()
                createNameTag(player)
            end
        end
    end

    local NameTagsToggle = Render:CreateToggle({
        Name = "NameTags",
        CurrentValue = false,
        Flag = "NameTags",
        SectionParent = Section,
        Callback = function(callback)
            enabled = callback
            if callback then
                initializeNameTags()
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
            updateAllNameTags()
        end
    })
    local NamesToggle = Render:CreateToggle({
        Name = "Names",
        CurrentValue = false,
        Flag = "espnames",
        SectionParent = Section,
        Callback = function(val)
            espnames = val
            updateAllNameTags()
        end
    })
    local HealthToggle = Render:CreateToggle({
        Name = "Health",
        CurrentValue = false,
        Flag = "esphealth",
        SectionParent = Section,
        Callback = function(val)
            esphealth = val
            updateAllNameTags()
        end
    })
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
    
    local CapeToggle = Render:CreateToggle({
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
    local Section = Utility:CreateSection("ChestStealer", false)
    local ChestStealer = Utility:CreateToggle({
        Name = "ChestStealer",
        CurrentValue = false,
        Flag = "ChestStealerToggle",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                spawn(function()
                    repeat
                        task.wait(0.3)
                        if PlayerUtility.IsAlive(lplr) then
                            for i,v in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
                                if (lplr.Character.HumanoidRootPart.Position - v.Position).Magnitude < 22 and v:FindFirstChild("ChestFolderValue") then
                                    local chest = v:FindFirstChild("ChestFolderValue")
                                    chest = chest and chest.Value or nil
                                    local chestitems = chest and chest:GetChildren() or {}
                                    if #chestitems > 0 then
                                        for i3, v3 in pairs(chestitems) do
                                            if v3:IsA("Accessory") then
                                                spawn(function()
                                                    pcall(function()
                                                        game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):FindFirstChild("@rbxts").net.out._NetManaged:FindFirstChild("Inventory/ChestGetItem"):InvokeServer(v.ChestFolderValue.Value, v3)
                                                    end)
                                                end)
                                            end
                                        end
                                    else
                                        game:GetService("CollectionService"):RemoveTag(v, "chest")
                                    end
                                end
                            end
                        end
                    until not callback
                end)  
            end
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("ClickTP", false)
    local ClickTPRaycast = RaycastParams.new()
    ClickTPRaycast.RespectCanCollide = true
    ClickTPRaycast.FilterType = Enum.RaycastFilterType.Blacklist
    local ClickTPbind = false
    local function CheckForTelepearls()
        local fireball = {}
        
        for _, item in ipairs(inventory:GetChildren()) do
            if item.Name:find("telepearl") then
                table.insert(fireball, item)
            end
        end
            
        return fireball
    end
    ClickTP = Utility:CreateToggle({
        Name = "ClickTP",
        CurrentValue = false,
        Flag = "ClickTP",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                if PlayerUtility.IsAlive(lplr) then 
                    ClickTPRaycast.FilterDescendantsInstances = {lplr.Character, Camera}
                    local ray = workspace:Raycast(Camera.CFrame.p, lplr:GetMouse().UnitRay.Direction * 1000, ClickTPRaycast)
                    local selectedPosition = ray and ray.Position + Vector3.new(0, lplr.Character.Humanoid.HipHeight + (lplr.Character.HumanoidRootPart.Size.Y / 2), 0)
                    local bows = CheckForTelepearls()
                    for i, v in pairs(bows) do
                        repeat
                            switchItem(v)
                        until lplr.Character.HandInvItem.Value ~= "fireball"
                        local pos = lplr.Character.PrimaryPart.Position
                        local args = {
                            [1] = v,
                            [2] = "telepearl",
                            [3] = "telepearl",
                            [4] = selectedPosition,
                            [5] = selectedPosition,
                            [6] = Vector3.new(0, -5, 0),
                            [7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
                            [8] = {
                                ["drawDurationSeconds"] = 1,
                                ["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
                            },
                            [9] = workspace:GetServerTimeNow() - 0.045
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileFire"):InvokeServer(unpack(args))
                    end
                end
            end
        end
    })
    local ClickTPKeybind = Utility:CreateKeybind({
        Name = "ClickTP Keybind",
        CurrentKeybind = "V",
        HoldToInteract = false,
        Flag = "ClickTP",
        SectionParent = Section,
        Callback = function(Keybind)
            ClickTP:Set(not ClickTP.CurrentValue)
        end
    })
end)

runcode(function()
    local priorityList = {
        "emerald",
        "speed",
        "bow",
        "diamond",
        "telepearl",
        "arrow"
    }

    local Section = Utility:CreateSection("PickUprange", false)
    local pickedup = {}
    local PickUpRange = Utility:CreateToggle({
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
                                if v:IsA("BasePart") and isnetworkowner(v) and ((hrp.Position - v.Position).Magnitude <= 10.5) then
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
    local Section = Utility:CreateSection("ChatSpammer", false)
    local ChatSpammerDelay = {["Value"] = 5} 
    local lastSentTime = 0
    if not getgenv().ChatSpammer then
        getgenv().ChatSpammer = "Aristois on top"
    end

    local ChatSpammer = Utility:CreateToggle({
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
    local ChatSpammerDelaySlider = Blatant:CreateSlider({
        Name = "Speed",
        Range = {1, 60},
        Increment = 1,
        Suffix = "sec(s)",
        CurrentValue = 5, 
        Flag = "ChatSpammerDelay",
        SectionParent = Section,
        Callback = function(Value)
            ChatSpammerDelay["Value"] = Value
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("AntiAfk", false)
    local AntiAfkConnection
    local AnitAfk = Utility:CreateToggle({
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
    local Section = Utility:CreateSection("AutoHeal", false)
    local HealTeam = {Enabled = false}

    local AutoHeal = Utility:CreateToggle({
        Name = "AutoHeal",
        CurrentValue = false,
        Flag = "AutoHeal",
        SectionParent = Section,
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Autoheal", function()
                    task.wait(0.2)
                    if getItem("guitar") then
                        if HealTeam.Enabled then
                            for _, player in ipairs(Players:GetPlayers()) do
                                local distance = (player.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                                if player.Team == lplr.Team and distance < 20 and player.Character.Humanoid.Health < player.Character.Humanoid.MaxHealth then
                                    bedwars.PlayGuitar:FireServer({
                                        ["healTarget"] = player
                                    })
                                    bedwars.StopPlayingGuitar:FireServer()
                                end
                            end
                        end
                        if lplr.Character.Humanoid.Health < lplr.Character.Humanoid.MaxHealth then
                            bedwars.PlayGuitar:FireServer({
                                ["healTarget"] = lplr
                            })
                            bedwars.StopPlayingGuitar:FireServer()
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Autoheal")
            end
        end
    })
    local HealTeamToggle = Utility:CreateToggle({
        Name = "HealTeam",
        CurrentValue = false,
        Flag = "HealTeam",
        SectionParent = Section,
        Callback = function(val)
            HealTeam.Enabled = val
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
        if character and character:FindFirstChild("Humanoid") then
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
                newchannel:SendAsync(Table.ChatStrings.Aristois)
            end
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            if player ~= lplr then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. player.Name .. " " .. Table.ChatStrings.Aristois, "All")
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
        local newData = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))
        if newData then
            whitelist.players = newData
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
                    if speaker and string.find(tab.TextChannel.Name, "RBXWhisper") and string.find(message, Table.ChatStrings.Aristois) then
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
                    if messageData.MessageType == "Whisper" and message == Table.ChatStrings.Aristois then
                        local playerId = speaker.UserId
                        if not whitelist.sentMessages[playerId] then
                            WhitelistModule.AddExtraTag(speaker, "DEFAULT USER", Color3.fromRGB(255, 0, 0))
                            GuiLibrary:Notify({
                                Title = "Aristois",
                                Content = messageData.FromSpeaker .. " is using Aristois!",
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
                end)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    WhitelistModule.UpdateTags()
end)

WhitelistModule.UpdateTags()
GuiLibrary:LoadConfiguration()
