local shell = require("shell")
local fs = require("filesystem")
local computer = require("computer")
local component = require("component")

-- args

local args, options = shell.parse(...)
if #args == 0 then
    io.write("Usage: edit <filename>")
    return
end

local filename = shell.resolve(args[1])

-- config
local ADDR="103.115.209.188"
local PORT=20222
local READmax=1400
local TIMEOUT=10

local inet=component.internet
socket=nil

while true do
    local reason
    socket = inet.connect(ADDR..":"..PORT)
    if not socket then
        error(reason)
    end
    
    socket.finishConnect()
    if socket.finishConnect() then
        break
    end

    socket.close()
    os.sleep(1)
    print("Connecting...")
end

-- ask for the file
socket.write("FILE "..filename)

local fd
local rc=0
local start= computer.uptime()

while true do
    if computer.uptime()-start > TIMEOUT then
        error("timeout")
    end

    local data, err = socket.read(READmax)
    if not data and err then
        error(err)
    end

    if not data and not err then
        -- EOF!
        break
    end

    -- got data
    if not fd then
        fd=fs.open(filename, "w")
    end
    fd:write(data)
    rc = rc + #data
end

socket.close()
if fd then fd:close() end

assert(rc>0, "No file received!")
io.write(string.format("Done! Read %d bytes in %2.1f seconds\n",
        rc, computer.uptime()-start))

