local function fetchLatestCommit()
    local response = game:HttpGet("https://api.github.com/repos/XzynAstralz/Aristois/commits")
    local commits = game:GetService("HttpService"):JSONDecode(response)
    if commits and #commits > 0 then
        return commits[1].sha
    end
    return nil
end

local function downloadFileAsync(url, filePath)
    local success, response = pcall(game.HttpGetAsync, game, url)
    if success then
        writefile(filePath, response)
    end
end

local AristoisUpdater = {
    requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end,

    betterisfile = function(file)
        local suc, res = pcall(readfile, file)
        return suc and res ~= nil
    end,

    updateFiles = function(self, commitHash)
        local baseUrl = "https://raw.githubusercontent.com/XzynAstralz/Aristois/" .. commitHash .. "/"

        local filesToUpdate = {
            "NewMainScript.lua",
            "MainScript.lua",
            "GuiLibrary.lua",
            "Universal.lua",
            "Librarys/Whitelist.lua",
            "Librarys/Utility.lua",
            "Games/11630038968.lua",
            "Games/6872274481.lua",
            "Games/support.lua"
        }

        for _, filePath in ipairs(filesToUpdate) do
            local localFilePath = "Aristois/" .. filePath
            if not self.betterisfile(filePath) or self:updateAvailable(commitHash) then
                if self.betterisfile(filePath) then
                    delfile(filePath)
                end
                downloadFileAsync(baseUrl .. filePath, localFilePath)
            end
        end

        local allFilesDownloaded = true
        for _, filePath in ipairs(filesToUpdate) do
            if not self.betterisfile("Aristois/" .. filePath) then
                allFilesDownloaded = false
                break
            end
        end

        if allFilesDownloaded and self.betterisfile("Aristois/MainScript.lua") then
            loadstring(readfile("Aristois/MainScript.lua"))()
        end

        writefile("Aristois/commithash.txt", commitHash)
    end,

    updateAvailable = function(self, latestCommitHash)
        if self.betterisfile("Aristois/commithash.txt") then
            return readfile("Aristois/commithash.txt") ~= latestCommitHash
        end
        return true
    end,

    downloadIfNotExists = function(self, url, filePath)
        if not self.betterisfile(filePath) then
            writefile(filePath, self.requestfunc({ Url = url, Method = "GET" }).Body)
        end
    end,
}

local foldersToCreate = {
    "Aristois",
    "Aristois/Games",
    "Aristois/Librarys",
    "Aristois/assets"
}

for _, folder in ipairs(foldersToCreate) do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

AristoisUpdater:downloadIfNotExists(
    "https://github.com/XzynAstralz/Aristois/raw/main/assets/cape.png", 
    "Aristois/assets/cape.png"
)

local latestCommit = fetchLatestCommit()
if latestCommit then
    AristoisUpdater:updateFiles(latestCommit)
end

return loadstring(readfile("Aristois/MainScript.lua"))()
