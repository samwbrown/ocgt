--
-- run from net
--

-- EXTERNAL
local cmp=computer or require("computer")
local cpt=component or require("component")
setmetatable(cpt, {__index=function(_,k)return cpt.proxy(cpt.list(k)()) end})
---@cast cpt component

local print= print or function (...) end
local string= string
local debug= debug

-- COMPONENTS

local ip= cpt.internet

-- CONFIG --

local ADDR="103.115.209.188"
local PORT=20222

-- MAIN --

local function input(timeout)
    local socket, _ = ip.connect(ADDR..":"..PORT)

    socket.finishConnect()
    local signal= computer.pullSignal(timeout)
    if not socket.finishConnect() then
        return
    end

    local signal= computer.pullSignal(timeout)
    if signal == "internet_ready" then
        local data, read_err = socket.read(1400)
        socket.close()
        return data
    end

    socket.close()
    return
end

-- Don't modify current env
local command_env= setmetatable({}, {__index=_G})

while true do
    local cmd= input(10)
    if not cmd then
        goto continue
    end

    if not string.find(cmd, "=") then
        cmd="return "..cmd
    end

    -- load
    local chunk, load_fail= load(cmd, "=cmd", 't', command_env)
    if not chunk or load_fail then
        print("Load failed: "..load_fail"\n")
        goto continue
    end

    -- run
    local ok, result =xpcall(chunk, debug.traceback)
    computer.pullSignal(1)
    print(result or "")

    ::continue::
end

-- Load data as program

-- give it a sec
computer.pullSignal(1)

result=result or ""
if ok then
    output("OK:"..result.."\n")
else
    output("Failed:"..result.."\n")
end