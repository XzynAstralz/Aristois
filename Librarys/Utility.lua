local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local lplr = Players.LocalPlayer

local Utility = {}

local function getCharacterRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end

local function getHealth(entity)
    local health = entity:GetAttribute("Health")
    if entity:IsA("Player") then
        local humanoid = entity.Character and entity.Character:FindFirstChild("Humanoid")
        health = humanoid and humanoid.Health or health
    end
    return health
end

function Utility.IsAlive(entity)
    if not entity then return false end

    local health = getHealth(entity)
    if health and health > 0 then return true end

    return false
end

function Utility.getNearestEntities(maxDist, findNearestHealthEntity, teamCheck)
    if not Utility.IsAlive(lplr) then return end

    local lplrCharacter = lplr.Character
    local lplrHumanoidRootPart = getCharacterRootPart(lplrCharacter)
    local lplrTeam = lplrCharacter:GetAttribute("Team")

    local entities = {}

    local function addEntityData(entity, mag, health)
        table.insert(entities, {entity = entity, distance = mag, health = health})
    end

    local function processEntity(entity)
        if Utility.IsAlive(entity) then
            local humanoidRootPart = getCharacterRootPart(entity)
            if humanoidRootPart and entity.Name ~= "BarrelEntity" and entity.Name ~= lplr.Name then
                local mag = (humanoidRootPart.Position - lplrHumanoidRootPart.Position).Magnitude
                local health = getHealth(entity) or 1

                if mag < maxDist and (not teamCheck or entity:GetAttribute("Team") ~= lplrTeam) then
                    addEntityData(entity, mag, health)
                end
            end
        end
    end

    for _, entity in ipairs(CollectionService:GetTagged("entity")) do
        if entity ~= lplr.Character then
            processEntity(entity)
        end
    end

    for _, entity in ipairs(CollectionService:GetTagged("GolemBoss")) do
        processEntity(entity)
    end

    table.sort(entities, function(a, b)
        if findNearestHealthEntity then
            return a.health < b.health
        else
            return a.distance < b.distance
        end
    end)

    return entities
end

function Utility.getNearestEntity(maxDist, findNearestHealthEntity, teamCheck)
    local nearestEntities = Utility.getNearestEntities(maxDist, findNearestHealthEntity, teamCheck)
    return nearestEntities and nearestEntities[1] and nearestEntities[1].entity or nil
end

function Utility.getNearestPlayerToMouse(teamCheck)
    local nearestPlayer, nearestDistance = nil, math.huge
    local mousePos = lplr:GetMouse()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lplr and (not teamCheck or player.Team ~= lplr.Team) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local pos = character.HumanoidRootPart.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distance < nearestDistance then
                        nearestPlayer, nearestDistance = player, distance
                    end
                end
            end
        end
    end

    return nearestPlayer
end

return Utility
