-- Main program using the UI module

local ui = require("ui")

-- Function to scan /apps directory and create UI components arranged in a grid
local function scanAppsDirectory()
    local components = {}
    local appDirectories = fs.list("/apps")
    local appsPerRow = 2  -- Number of apps to display per row
    local x, y = 2, 2  -- Initial position

    for i, dir in ipairs(appDirectories) do
        local appPath = "/apps/" .. dir
        if fs.isDir(appPath) then
            local logoPath = appPath .. "/logo.pbm"
            local mainPath = appPath .. "/main.lua"
            if fs.exists(logoPath) and fs.exists(mainPath) then
                local icon = ui.loadIcon(logoPath, 10, 5)
                table.insert(components, {"icon", x, y, nil, icon, function()
                    shell.run(mainPath)
                end})
                
                -- Update position for next app
                x = x + 12
                if i % appsPerRow == 0 then
                    x = 2
                    y = y + 7  -- Move to the next row
                end
            end
        end
    end

    return components
end

-- Define UI components by scanning /apps directory
local components = scanAppsDirectory()

-- Create and draw UI
local buttons = ui.createUI(components)
ui.drawHeader("Homepage")

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
