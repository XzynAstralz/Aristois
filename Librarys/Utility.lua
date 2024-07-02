local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local Utility = {}

function Utility.IsAlive(plr)
    local plr = plr or lplr
    return plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

function Utility.getNearestEntity(maxDist, findNearestHealthEntity, teamCheck)
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
