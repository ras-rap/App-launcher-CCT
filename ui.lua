-- UI Module

local ui = {}

-- Define button attributes
local buttonColor = colors.blue
local buttonTextColor = colors.white
local buttonPadding = 1

-- Load icon from a PBM file
function ui.loadIcon(filename, width, height)
    local icon = {}
    local file = fs.open(filename, "r")
    if file then
        -- Read the header (first two lines) and discard them
        file.readLine()
        file.readLine()
        
        -- Read pixel data
        for y = 1, height do
            icon[y] = {}
            local line = file.readLine()
            if line then
                local i = 1
                for x = 1, width do
                    icon[y][x] = tonumber(line:sub(i, i)) or 0
                    i = i + 2  -- Skip spaces
                end
            else
                for x = 1, width do
                    icon[y][x] = 0
                end
            end
        end
        
        file.close()
    else
        -- If file doesn't exist, fill with default (empty) icon data
        for y = 1, height do
            icon[y] = {}
            for x = 1, width do
                icon[y][x] = 0
            end
        end
    end
    return icon
end

-- Load icon from raw PBM data
function ui.loadIconFromData(data, width, height)
    local icon = {}
    local lines = {}
    for line in string.gmatch(data, "[^\r\n]+") do
        table.insert(lines, line)
    end
    
    -- Skip header lines
    table.remove(lines, 1)
    table.remove(lines, 1)
    
    -- Read pixel data
    for y = 1, height do
        icon[y] = {}
        local line = lines[y] or ""
        local i = 1
        for x = 1, width do
            icon[y][x] = tonumber(line:sub(i, i)) or 0
            i = i + 2  -- Skip spaces
        end
    end
    
    return icon
end

-- Function to draw an icon at the specified position
function ui.drawIcon(x, y, icon)
    for dy = 1, #icon do
        for dx = 1, #icon[dy] do
            term.setCursorPos(x + dx - 1, y + dy - 1)
            if icon[dy][dx] == 1 then
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                term.write(" ")
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                term.write(" ")
            end
        end
    end
end

-- Function to calculate button dimensions based on text
function ui.calculateButtonDimensions(label)
    local width = #label + 2 * buttonPadding
    local height = 3  -- Fixed height for simplicity
    return width, height
end

-- Function to draw a button with text
function ui.drawButton(x, y, label)
    local width, height = ui.calculateButtonDimensions(label)
    paintutils.drawFilledBox(x, y, x + width - 1, y + height - 1, buttonColor)
    
    local textX = x + math.floor(width / 2 - #label / 2)
    local textY = y + math.floor(height / 2)
    
    term.setCursorPos(textX, textY)
    term.setTextColor(buttonTextColor)
    term.write(label)
end

-- Function to handle mouse clicks
function ui.handleMouseClick(buttons, mouseX, mouseY)
    for _, button in ipairs(buttons) do
        local x, y, width, height, onClick = table.unpack(button)
        if mouseX >= x and mouseX <= x + width - 1 and
           mouseY >= y and mouseY <= y + height - 1 then
            if onClick then onClick() end
        end
    end
end

-- Function to create and draw a UI
function ui.createUI(components)
    term.setBackgroundColor(colors.black)
    term.clear()
    
    local buttons = {}

    for _, component in ipairs(components) do
        local type, x, y, label, icon, onClick = table.unpack(component)
        if type == "button" then
            ui.drawButton(x, y, label)
            local width, height = ui.calculateButtonDimensions(label)
            table.insert(buttons, {x, y, width, height, onClick})
        elseif type == "icon" then
            if icon and #icon > 0 and #icon[1] > 0 then
                ui.drawIcon(x, y, icon)
                local width = #icon[1]
                local height = #icon
                table.insert(buttons, {x, y, width, height, onClick})
            else
                print("Warning: Missing or invalid icon data for icon at ("..x..","..y..")")
            end
        end
    end

    return buttons
end

-- Function to draw a header with centered text
function ui.drawHeader(text)
    local width, _ = term.getSize()
    local textX = math.floor((width - #text) / 2)
    
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(1, 1)
    term.clearLine()
    
    term.setCursorPos(textX, 1)
    term.setTextColor(colors.white)
    term.write(text)
end

-- Function to display the management menu using buttons
function ui.manageMenu()
    term.setBackgroundColor(colors.gray)
    term.clear()
    
    local menuComponents = {
        {"button", 2, 2, "Return to homepage", nil, function() return "homepage" end},
        {"button", 2, 6, "Close application", nil, function() return "close" end}
    }

    local menuButtons = ui.createUI(menuComponents)

    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()
        if event == "mouse_click" then
            for _, button in ipairs(menuButtons) do
                local x, y, width, height, onClick = table.unpack(button)
                if p2 >= x and p2 <= x + width - 1 and p3 >= y and p3 <= y + height - 1 then
                    local result = onClick()
                    if result then
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        return result
                    end
                end
            end
        end
    end
end

return ui
