local ownId = os.getComputerID()
local run = true
local running = false

term.clear()
term.setCursorPos(1,1)
print("Connecting with Modem...")
  
peripheral.find("modem", rednet.open)
print("Connected.")


while run do
term.clear()
term.setCursorPos(1,1)
print(" _____                   ")
    print([[|  __ \                  ]])
    print("| |  | | ___  _ __ _ __  ")
    print([[| |  | |/ _ \| '__| '_ \ ]])
    print("| |__| | (_) | |  | | | |")
    print([[|_____/ \___/|_|  |_| |_|]])
print("")

print("Welcome to the Online-Banking Menu")
print("")
print("attempting automatic login...")

if(fs.exists("xyzautolog")) then

    local file = fs.open("xyzautolog", "r")
    local username = file.readLine()
    local password = file.readLine()
    file.close()
    rednet.broadcast("login," .. username .. "," .. password, "paymentProtocol")
    local id, message, protocol = rednet.receive("paymentProtocol")
    if(message == "login:true") then
        print("Login Successful.")
          
        running = true
        while running do
        term.clear()
        term.setCursorPos(1,1)
print(" _____                   ")
    print([[|  __ \                  ]])
    print("| |  | | ___  _ __ _ __  ")
    print([[| |  | |/ _ \| '__| '_ \ ]])
    print("| |__| | (_) | |  | | | |")
    print([[|_____/ \___/|_|  |_| |_|]])
        print("")
        print("Welcome, " .. username)
        print("")
        --get balance
        rednet.broadcast("getBalance," .. username, "paymentProtocol")
        local id, message, protocol = rednet.receive("paymentProtocol")
        local currentData = {}
        for word in string.gmatch(message, '([^,]+)') do
            table.insert(currentData, word)
        end
                
        print("Current Balance: " .. currentData[2])
        print("")
        print("Please select an option:")
        print("1. Send Money, 2. History, 3. Refresh Balance 4. Exit")
        print("5. Logout")
        print("")
        local choice = read()

        if(choice == "1") then

            print("Please enter the username of the person you want to send money to:")
            local receiver = read()
            print("Please enter the amount you want to send:")
            local amount = read()
            rednet.broadcast("pay," .. username .. "," .. password .. "," .. amount, "paymentProtocol")
            local id, message, protocol = rednet.receive("paymentProtocol")
            if(message == "pay:true") then
                print("Withdraw Successful")

                --add money to reciever
                rednet.broadcast("addMoney," .. receiver .. "," .. "nil" .. "," .. amount, "paymentProtocol")
                local id, message, protocol = rednet.receive("paymentProtocol")
                if(message == "addMoney:true") then
                    print("Deposit Successful")

                else
                    print("Deposit failed, refunding money...")
                    rednet.broadcast("addMoney," .. username .. "," .. "nil" .."," .. amount, "paymentProtocol")
                end
            else
                print("Money could not be sent, Check your balance.")
                 os.sleep(0.5)
            end

        end
        if(choice == "2") then
            print("This feature is not yet implemented.")
            os.sleep(1)
            print("Press any key to continue...")
            read()
        end
        if(choice == "3") then
            print("Refreshing Balance...")

        end
        if(choice == "4") then
            print("Exiting...")

            running = false
            run = false
        end
        if(choice == "5") then
            print("Logging out...")

            running = false
            fs.delete("xyzautolog")
        end
        



end
else

    print("Login failed, please login manually:")
    print("Username:")
    local username = read()
    print("Password:")
    local password = read()
    rednet.broadcast("login," .. username .. "," .. password, "paymentProtocol")
    local id, message, protocol = rednet.receive("paymentProtocol")
    if(message == "login:true") then
        print("Login Successful.")
        
            local file = fs.open("xyzautolog", "w")
            file.writeLine(username)
            file.writeLine(password)
            file.close()
        

    else
        print("Login failed, please try again.")
        os.sleep(0.5)
    end


end
else

    print("No autologin found.")
    print("Create account? (y/n)")
    local choice = read()
    if(choice == "y") then
        print("Username:")
        local username = read()
        print("Password:")
        local password = read()
        rednet.broadcast("createAccount," .. username .. "," .. password, "paymentProtocol")
        local id, message, protocol = rednet.receive("paymentProtocol")
        if(message == "createAccount:true") then
            print("Account created successfully.")
            os.sleep(1)
            local file = fs.open("xyzautolog", "w")
            file.writeLine(username)
            file.writeLine(password)
            file.close()
        else
            print("Account creation failed.")
            os.sleep(1)
        end
    else
        print("Please login manually:")
        print("Username:")
        local username = read()
        print("Password:")
        local password = read()
        rednet.broadcast("login," .. username .. "," .. password, "paymentProtocol")
        local id, message, protocol = rednet.receive("paymentProtocol")
        if(message == "login:true") then
            print("Login Successful.")
            os.sleep(0.4)
            local file = fs.open("xyzautolog", "w")
            file.writeLine(username)
            file.writeLine(password)
            file.close()
        else
            print("Login failed, please try again.")
            os.sleep(0.4)
        end
    end

end
end