-- Terminal app using the UI module

local ui = require("../../ui")

-- Initialize terminal app components
local function drawTerminal()
    term.clear()
    term.setCursorPos(1, 1)
    print("Welcome, run 'menu' to open the menu.")
    term.setCursorPos(1, 3)
end

local function runTerminalApp()
    drawTerminal()
    while true do
        term.setCursorBlink(true)
        term.write("> ")
        local command = read(nil, nil, function(char) end)
        if not command then break end
        if command == "menu" then
            local action = ui.manageMenu()
                if action == "homepage" then
                    -- Return to homepage
                    shell.run("main")
                    break
                elseif action == "close" then
                    -- Close terminal app
                    break
                end
        elseif command == "clear" then
            drawTerminal()
        else
            term.setCursorBlink(false)
            local ok, err = shell.run(command)
            if not ok then
                if err ~= nil then
                    print("Error: " .. err)                    
                end
            end
        end
        term.setCursorPos(1, select(2, term.getCursorPos()) + 1)
    end
    term.setCursorBlink(false)
end

-- Main function
local function main()
    runTerminalApp()
    -- Ensure the terminal is reset to black background on exit
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
end

main()
