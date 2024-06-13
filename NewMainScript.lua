local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end

local folders = {"Aristois", "Aristois/Games", "Aristois/Librarys", "Aristois/assets"}
for _, folder in ipairs(folders) do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

local function fetchLatestCommit()
    local response = game:HttpGet("https://api.github.com/repos/XzynAstralz/Aristois/commits")
    local commits = game:GetService("HttpService"):JSONDecode(response)
    if commits and #commits > 0 then
        return commits[1].sha
    end
    return nil
end

local betterisfile = function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil
end

local function downloadFile(url, filePath)
    local response = game:HttpGet(url, true)
    if response then
        writefile(filePath, response)
    end
end

local function updateAvailable()
    local latestCommit = fetchLatestCommit()
    if latestCommit then
        local lastCommitFile = "Aristois/commithash.txt"
        if not isfile(lastCommitFile) then
            return true, latestCommit
        end
        local lastCommit = readfile(lastCommitFile)
        return lastCommit ~= latestCommit or latestCommit == "main", latestCommit
    end
    return false, nil
end

local function updateFiles(commitHash)
    local baseUrl = "https://raw.githubusercontent.com/XzynAstralz/Aristois/" .. commitHash .. "/"
    local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Games/11630038968.lua"}
    for _, filePath in ipairs(filesToUpdate) do
        local localFilePath = "Aristois/" .. filePath
        if not betterisfile(localFilePath) or updateAvailable() then
            local fileUrl = baseUrl .. filePath
            downloadFile(fileUrl, localFilePath)
        end
    end
    writefile("Aristois/commithash.txt", commitHash)
end

if not betterisfile("Aristois/assets/cape.png") then
    local req = requestfunc({
        Url = "https://github.com/XzynAstralz/Aristois/raw/main/assets/cape.png",
        Method = "GET"
    })
    writefile("Aristois/assets/cape.png", req.Body)
end

local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Games/11630038968.lua"}
for _, filePath in ipairs(filesToUpdate) do
    if not betterisfile("Aristois/" .. filePath) then
        local fileUrl = "https://raw.githubusercontent.com/XzynAstralz/Aristois/main/" .. filePath
        downloadFile(fileUrl, "Aristois/" .. filePath)
    end
end

local updateAvailable, latestCommit = updateAvailable()
if updateAvailable then
    updateFiles(latestCommit)
end

return loadstring(readfile("Aristois/MainScript.lua"))()
