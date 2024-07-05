local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local Utility = {}

function Utility.IsAlive(entity)
    if not entity then
        return false
    end
    
    local health = entity:GetAttribute("Health")
    if health and health > 0 then
        return true
    end
    
    if entity:IsA("Player") then
        local character = entity.Character
        if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            return true
        end
    end
    
    return false
end

function Utility.getNearestEntity(maxDist, findNearestHealthEntity, teamCheck)
    if not Utility.IsAlive(lplr) then return end
    local targetData = {
        nearestEntity = nil,
        dist = math.huge,
        lowestHealth = math.huge
    }
    local teamAttribute = lplr.Character:GetAttribute("Team")
    
    local function updateTargetData(entity, mag, health)
        if findNearestHealthEntity and health < targetData.lowestHealth then
            targetData.lowestHealth = health
            targetData.nearestEntity = entity
        elseif mag < targetData.dist then
            targetData.dist = mag
            targetData.nearestEntity = entity
        end
    end
    
    for _, entity in next, game.CollectionService:GetTagged("entity") do
        if Utility.IsAlive(entity) then
            local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
            if humanoidRootPart and entity.Name ~= "BarrelEntity" then
                local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                local hum = entity:FindFirstChild("Humanoid")
                local health = (hum and hum.Health) or entity:GetAttribute("Health") or 1

                if mag < maxDist then
                    if not teamCheck or not entity:GetAttribute("Team") or entity:GetAttribute("Team") ~= teamAttribute then
                        updateTargetData(entity, mag, health)
                    end
                end
            end
        end
    end
    
    for _, entity in next, game.CollectionService:GetTagged("GolemBoss") do
        local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
        if humanoidRootPart then
            local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            local hum = entity:FindFirstChild("Humanoid")
            local health = (hum and hum.Health) or entity:GetAttribute("Health") or 1

            if mag < maxDist then
                if not teamCheck or not entity:GetAttribute("Team") or entity:GetAttribute("Team") ~= teamAttribute then
                    updateTargetData(entity, mag, health)
                end
            end
        end
    end

    return targetData.nearestEntity
end

function Utility.getNearestEntities(maxDist, findNearestHealthEntity, teamCheck)
    if not Utility.IsAlive(lplr) then return end
    local entities = {}
    local teamAttribute = lplr.Character:GetAttribute("Team")
    
    local function addEntityData(entity, mag, health)
        table.insert(entities, {entity = entity, distance = mag, health = health})
    end
    
    for _, entity in next, game.CollectionService:GetTagged("entity") do
        if Utility.IsAlive(entity) then
            local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
            if humanoidRootPart and entity.Name ~= "BarrelEntity"  then
                local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                local hum = entity:FindFirstChild("Humanoid")
                local health = (hum and hum.Health) or entity:GetAttribute("Health") or 1

                if mag < maxDist then
                    if not teamCheck or not entity:GetAttribute("Team") or entity:GetAttribute("Team") ~= teamAttribute then
                        addEntityData(entity, mag, health)
                    end
                end
            end
        end
    end
    
    for _, entity in next, game.CollectionService:GetTagged("GolemBoss") do
        local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
        if humanoidRootPart then
            local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            local hum = entity:FindFirstChild("Humanoid")
            local health = (hum and hum.Health) or entity:GetAttribute("Health") or 1

            if mag < maxDist then
                if not teamCheck or not entity:GetAttribute("Team") or entity:GetAttribute("Team") ~= teamAttribute then
                    addEntityData(entity, mag, health)
                end
            end
        end
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

function Utility.getNearestPlayerToMouse(teamCheck)
    local nearestPlayer, nearestDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lplr and (not teamCheck or player.Team ~= lplr.Team) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local pos = character.HumanoidRootPart.Position
                local screenPos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(pos)
                if onScreen then
                    local mousePos = game.Players.LocalPlayer:GetMouse()
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
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
