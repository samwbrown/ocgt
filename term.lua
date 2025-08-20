--
-- might need to remove with robot
-- local computer=require("computer")
-- local component=require("component")

-- config
local ADDR="103.115.209.188"
local PORT=20223
local READmax=1400

local inet=component.proxy(component.list("internet")())

-- replace global print
print=print or function (...) end

-- global
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
    computer.pullSignal(1)
    computer.pullSignal(1)
    print("Connecting...")
end

print("Connected.")
socket.write("Connected.\n>> ")

local function err(...)
    print(...)
    socket.write(...)
end


local function get_cmd()
    local data, read_fail = socket.read(READmax)
    if read_fail then
        err("!read error: "..read_fail)
        return
    end

    if #data > 0 then
        return string.sub(data, 0, #data-1)
    end

    return data
end

local function run_cmd(str)
    -- if string.match(str, "=") == nil then 
    --     str="return "..str
    -- end

    local program, load_fail=load(str)
    if load_fail then
        err("!read error: "..load_fail)
        return
    end
    
    local ok, result =pcall(program)
    return tostring(result)
end

while true do
    -- wait for signal
    local sig, sock_id= computer.pullSignal(1)
    if sig == "internet_ready" then
        local cmd= get_cmd()
        if cmd then
            print(cmd)
            if cmd=="exit" then break end

            local res= run_cmd(cmd)
            if res then
                print(res)
                socket.write(res.."\n")
            end

            socket.write(">> ")
        end
    end
end

socket.close()


