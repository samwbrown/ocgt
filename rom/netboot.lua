--
-- run from net
--

-- REQUIRES and OVERLOADS
local cpt=component or require("component")
local cmp=computer or require("computer")

local function try_proxy(name, nil_ok) 
    local l=cpt.list(name)()
    if not l and nil_ok then return nil end
    return cpt.proxy(l)
end

local rb = try_proxy("robot")

print=print or function (...) end

-- LIB --

local colours={
    red=0xFF0000,
    blue=0x0000FF,
    green=0x00FF00,
    yellow=0x00FFFF,
    white=0xFFFFFF,
}

local function set_light(colour)
    if rb then rb.setLightColor(colour) end
end

-- CONFIG --

local FILE="rom/robot_craft_plates.lua"
local ADDR="103.115.209.188"
local PORT=20222

-- MAIN --

set_light(colours.white)

-- Connect socket
print("Connecting...")
local ip=cpt.proxy(cpt.list("internet")())

local socket
while true do
    socket,_ = ip.connect(ADDR..":"..PORT)
    if socket.finishConnect() or socket.finishConnect() then
        set_light(colours.blue)
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
    socket.write("Load failed: "..load_fail"\n")
    set_light(colours.yellow)
    error(load_fail)
end

socket.close()
set_light(colours.green)

-- overwrite print
local function net_print(...)
    local out=table.concat(table.pack(...), "\t")
    local cpt=component or require("component")
    local s, _ = cpt.proxy(cpt.list("internet")()).connect("103.115.209.188:20222")
    if s.finishConnect() or s.finishConnect() then
        s.write(out)
        s.close()
    end

    io.write(out.."\n")
    io.flush()
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
    set_light(colours.red)
end