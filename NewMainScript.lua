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
    
    foldersToCreate = {
        "Aristois",
        "Aristois/Games",
        "Aristois/Librarys",
        "Aristois/assets"
    },
    
    filesToUpdate = {
        "NewMainScript.lua",
        "MainScript.lua",
        "GuiLibrary.lua",
        "Universal.lua",
        "Librarys/Whitelist.lua",
        "Librarys/Utility.lua",
        "Games/11630038968.lua",
        "Games/6872274481.lua"
    },
    
    assetsToDownload = {
        {
            url = "https://github.com/XzynAstralz/Aristois/raw/main/assets/cape.png",
            filePath = "Aristois/assets/cape.png"
        }
    },
    
    updateFiles = function(self, commitHash)
        local baseUrl = "https://raw.githubusercontent.com/XzynAstralz/Aristois/" .. commitHash .. "/"
        local threads = {}
        
        for _, filePath in ipairs(self.filesToUpdate) do
            local localFilePath = "Aristois/" .. filePath
            if not self.betterisfile(localFilePath) or self.updateAvailable() then
                local fileUrl = baseUrl .. filePath
                table.insert(threads, coroutine.create(function()
                    downloadFileAsync(fileUrl, localFilePath)
                end))
            end
        end
        
        for _, thread in ipairs(threads) do
            coroutine.resume(thread)
        end
        
        for _, thread in ipairs(threads) do
            while coroutine.status(thread) ~= "dead" do
                wait()
            end
        end
        
        writefile("Aristois/commithash.txt", commitHash)
    end,
    
    downloadIfNotExists = function(self, url, filePath)
        if not self.betterisfile(filePath) then
            local req = self.requestfunc({
                Url = url,
                Method = "GET"
            })
            writefile(filePath, req.Body)
        end
    end,
}

for _, folder in ipairs(AristoisUpdater.foldersToCreate) do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

for _, asset in ipairs(AristoisUpdater.assetsToDownload) do
    AristoisUpdater:downloadIfNotExists(asset.url, asset.filePath)
end

local latestCommit = fetchLatestCommit()
if latestCommit then
    AristoisUpdater:updateFiles(latestCommit)
end

if not shared.Executed then
    loadstring(readfile("Aristois/MainScript.lua"))()
else
    warn("Already executed, cannot run again.")
end
