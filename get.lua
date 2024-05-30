-- Lua script for ComputerCraft tweaked
term.clear()
term.setCursorPos(1,1)

-- Function to download a file from pastebin
local function downloadFile(url, filename)
    local response = http.get(url)
    if response then
        local file = fs.open(filename, "w")
        file.write(response.readAll())
        file.close()
        response.close()
        print("File downloaded as " .. filename)
    else
        print("Failed to download file from " .. url)
    end
end

print("Downloading files")
downloadFile("https://elmsmp.ras-rap.click/get?file=ui", "/ui.lua")
downloadFile("https://elmsmp.ras-rap.click/get?file=main", "/main.lua")
print("UI and homepage installed")
print("Downloading appstore")
shell.run("mkdir /apps/appstore")
downloadFile("https://elmsmp.ras-rap.click/apps/appstore/download/lua", "/apps/appstore/main.lua")
downloadFile("https://elmsmp.ras-rap.click/apps/appstore/download/logo", "/apps/appstore/logo.pbm")
print("Appstore installed")

-- Prompt the user if they want the program to run on startup
print("Do you want the homepage to run on startup? (y/n)")
local input = read()
if input == "y" then
    -- Download the startup file
    downloadFile("https://elmsmp.ras-rap.click/get?file=startup", "startup.lua")
    print("Startup file downloaded.")
elseif input == "n" then
else
    print("Invalid input. Please enter 'y' or 'n'.")
end

print("")
print("CCTUI Installed, press CTRL in most apps to open the menu. To start the homepage run 'main'")