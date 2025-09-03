--
-- run from net
--
-- REQUIRES and OVERLOADS
local cmp=computer or require("computer")
local cpt=component or require("component")
setmetatable(cpt, {__index=function(_,k)return cpt.proxy(cpt.list(k)()) end})
---@cast cpt component

print=print or function (...) end

-- COMPONENTS

local ip= cpt.internet

-- CONFIG --

local FILE="debug"
local ADDR="103.115.209.188"
local PORT=20222

-- MAIN --

-- Connect socket
print("Connecting...")


local socket
while true do
    socket,_ = ip.connect(ADDR..":"..PORT)
    if socket.finishConnect() or socket.finishConnect() then
        print("Connected.")
        break
    end

    socket.close()
    cmp.pullSignal(1)
    print(".")
end


-- Ask for the file
socket.write("FILE "..FILE)

-- Get data
local buffer = {}
while true do
    local data, read_err = socket.read(1400)
    assert(read_err==nil, read_err)

    if not data and not read_err then
        -- EOF!
        break
    end

    buffer[#buffer + 1] = data
end

-- Load data as program
local program, load_fail= load(table.concat(buffer), "="..FILE)
if not program or load_fail then
    socket.write("Load failed: "..load_fail.."\n")
    error(load_fail)
end

socket.close()

-- overwrite print
local function net_print(...)
    local out=table.concat(table.pack(...), "\t")
    local cpt=component or require("component")
    local s, _ = cpt.proxy(cpt.list("internet")()).connect("103.115.209.188:20222")
    if s.finishConnect() or s.finishConnect() then
        s.write(out)
        s.close()
    end
end

print=net_print
local ok, result =xpcall(program, debug.traceback)

-- give it a sec
cmp.pullSignal(1)

result=result or ""
if ok then
    print("OK:"..result.."\n")
else
    print("Failed:"..result.."\n")
end