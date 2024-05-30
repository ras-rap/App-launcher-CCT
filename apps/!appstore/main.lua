-- Function to download a file from a URL and save it locally
local function downloadFile(url, path)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
    else
        error("Failed to download file from: " .. url)
    end
end

-- Check if the json module is available, if not, download it
if not fs.exists("apps/appstore/json.lua") then
    downloadFile("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua", "apps/appstore/json.lua")
end

-- Load the json module
local json = require("json")

-- Main program using the UI module
local ui = require("../../ui")

-- Function to fetch app list from remote server
local function fetchAppList()
    local response = http.get("https://elmsmp.ras-rap.click/apps")
    if response then
        local body = response.readAll()
        response.close()
        return json.decode(body).apps
    else
        error("Failed to fetch app list")
    end
end

-- Function to fetch logo for a specific app
local function fetchAppLogo(appName)
    local response = http.get("https://elmsmp.ras-rap.click/apps/" .. appName .. "/download/logo")
    if response then
        local body = response.readAll()
        response.close()
        return body
    else
        error("Failed to fetch logo for app: " .. appName)
    end
end

-- Function to fetch app info for a specific app
local function fetchAppInfo(appName)
    local response = http.get("https://elmsmp.ras-rap.click/apps/" .. appName)
    if response then
        local body = response.readAll()
        response.close()
        return json.decode(body)
    else
        error("Failed to fetch info for app: " .. appName)
    end
end

-- Function to create UI components arranged in a grid from fetched app data
local function createAppComponents(appList)
    local components = {}
    local appsPerRow = 2  -- Number of apps to display per row
    local x, y = 2, 4  -- Initial position (starting below the header)

    for i, appName in ipairs(appList) do
        local logo = fetchAppLogo(appName)
        
        local icon = ui.loadIconFromData(logo, 10, 5)  -- Assuming loadIconFromData can load icon from raw data
        table.insert(components, {"icon", x, y, nil, icon, function()
            local appInfo = fetchAppInfo(appName)
            showAppInfoMenu(appInfo, appName)
        end})
        
        -- Update position for next app
        x = x + 12
        if i % appsPerRow == 0 then
            x = 2
            y = y + 7  -- Move to the next row
        end
    end

    return components
end

-- Function to display app info menu
function showAppInfoMenu(appInfo, appname)
    term.setBackgroundColor(colors.gray)
    term.clear()

    -- Create a "Back" button to return to the main UI
    local backButton = {
        {"button", 2, 17, "Back", nil, function() return "back" end},
        {"button", 15, 17, "Download", nil, function() return "download" end}
    }

    local buttons = ui.createUI(backButton)
    term.setBackgroundColor(colors.gray)


    term.setCursorPos(2, 2)
    term.setTextColor(colors.white)
    term.write("App Name: " .. appInfo.name)

    -- Calculate description area width based on terminal size
    local termWidth, _ = term.getSize()
    local descriptionWidth = termWidth - 4 -- Leave some padding on each side
    local descriptionX = 2
    local descriptionY = 4

    -- Display description with word wrapping
    local description = appInfo.description
    local words = {}

    for word in description:gmatch("%S+") do
        table.insert(words, word)
    end

    local line = ""
    for _, word in ipairs(words) do
        if #line + #word + 1 > descriptionWidth then
            term.setCursorPos(descriptionX, descriptionY)
            term.write(line)
            descriptionY = descriptionY + 1
            line = ""
        end
        line = line .. word .. " "
    end

    -- Write the last line
    term.setCursorPos(descriptionX, descriptionY)
    term.write(line)

    term.setCursorPos(2, descriptionY + 2)
    term.write("Version: " .. appInfo.version)

    term.setCursorPos(2, descriptionY + 4)
    term.write("Developers: " .. table.concat(appInfo.developers, ", "))

    term.setCursorPos(2, descriptionY + 6)
    term.write("Official: " .. tostring(appInfo.official))

    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()
        if event == "mouse_click" then
            for _, button in ipairs(buttons) do
                local x, y, width, height, onClick = table.unpack(button)
                if p2 >= x and p2 <= x + width - 1 and p3 >= y and p3 <= y + height - 1 then
                    local result = onClick()
                    if result == "back" then
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        shell.run("/apps/appstore/main.lua")
                        break
                    elseif result == "download" then
                        shell.run("mkdir /apps/" .. appname)
                        downloadFile("https://elmsmp.ras-rap.click/apps/" .. appname .. "/download/lua", "apps/" .. appname .. "/main.lua")
                        downloadFile("https://elmsmp.ras-rap.click/apps/" .. appname .. "/download/logo", "apps/" .. appname .. "/logo.pbm")
                        print("App downloaded")
                    end
                end
            end
        end
    end
end


-- Fetch app list from remote server
local appList = fetchAppList()

-- Create UI components from the fetched app list
local components = createAppComponents(appList)

-- Create and draw UI, including the header
local buttons = ui.createUI(components)
ui.drawHeader("App Store")

-- Main event loop
while true do
    local event, p1, p2, p3, p4 = os.pullEvent()

    if event == "mouse_click" then
        ui.handleMouseClick(buttons, p2, p3)
        break
    elseif event == "key" then
        if p1 == keys.leftCtrl or p1 == keys.rightCtrl then
            local action = ui.manageMenu()
            if action == "homepage" then
                -- Code to return to homepage
                shell.run("main")
                break
            elseif action == "close" then
                -- Code to close application
                term.clear()
                term.setBackgroundColor(colors.black)
                term.setCursorPos(1, 1)
                break
            end
        else
            -- Other key handling can go here
        end
    end
end

-- Ensure the terminal is reset to black background on exit
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)