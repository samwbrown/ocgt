local shell = require("shell")
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

-- Connect socket
print("Connecting...")
local ip=component.proxy(component.list("internet")())

local socket
while true do
    socket,_ = ip.connect(ADDR..":"..PORT)
    if socket.finishConnect() or socket.finishConnect() then
        print("Connected.")
        break
    end

    socket.close()
    computer.pullSignal(1)
    print(".")
end

-- Ask for the file
socket.write("FILE "..filename)

-- Get data
local script = ""
while true do
    local data, read_err = socket.read(1400)
    assert(read_err==nil, read_err)

    if not data and not read_err then
        -- EOF!
        break
    end

    script=script..data
end

-- override
function output(...)
    local out=table.concat(table.pack(...), "\t")
    local cpt=component or require("component")
    local s, _ = cpt.proxy(cpt.list("internet")()).connect("103.115.209.188:20222")
    if s.finishConnect() or s.finishConnect() then
        s.write(out)
        s.close()
    end
end

-- set env
local env= setmetatable({print=output, socket=socket}, {__index=_G})

-- Load data as program
local program, load_fail= load(script, "="..filename, 't', env)
if not program or load_fail then
    output("Load failed: "..load_fail.."\n")
    error(load_fail)
end

-- run
local ok, result =xpcall(program, debug.traceback)

-- give it a sec
computer.pullSignal(1)

result=result or ""
if ok then
    output("OK:"..result.."\n")
else
    output("Failed:"..result.."\n")
end