local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/XzynAstralz/Aristois/main/MainScript.lua'))()
end)

if not success then
    warn("Failed to load the script: " .. tostring(result))
else
    return result
end
