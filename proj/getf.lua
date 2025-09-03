local shell = require("shell")
local fs = require("filesystem")
local component = require("component")

-- args
local args, options = shell.parse(...)
if #args == 0 then
    io.write("Usage: getf <filename> [-r]")
    return
end

local path = shell.resolve(args[1])
local pull_dependencies= options.r

-- config
local ADDR="103.115.209.188"
local PORT=20222
local READmax=1400
local DIR=shell.getWorkingDirectory()
local SYSTEM_LIBS={
    component=true,
    computer=true,
    bit32=true,
    buffer=true,
    colors=true,
    devfs=true,
    event=true,
    filesystem=true,
    internet=true,
    io=true,
    keyboard=true,
    note=true,
    package=true,
    pipe=true,
    process=true,
    rc=true,
    serialization=true,
    sh=true,
    shell=true,
    sides=true,
    term=true,
    text=true,
    thread=true,
    transforms=true,
    tty=true,
    uuid=true,
    vt100=true,
}

local function get_file(filename)
    while true do
        socket, _ = component.internet.connect(ADDR..":"..PORT)
        if socket.finishConnect() or socket.finishConnect() then
            break
        end
    
        print("Connecting...")
        socket.close()
        os.sleep(1)
    end

    socket.write("FILE "..filename)

    local rc=0
    local fd=fs.open(DIR.."/"..filename, "w")
    while true do
        local data, err = socket.read(READmax)
        assert(not err, "Failed to read")
        if not data then
            -- EOF!
            assert(rc>0, "No data")
            print(string.format("%s: %d bytes", DIR.."/"..filename, rc))
            if fd then fd:close() end
            socket.close()
            return rc
        end

        -- got data
        fd:write(data)
        rc = rc + #data
    end
end

local function get_dependencies(path)
    local fd=fs.open(path, "r")
    local data=fd:read(300)

    local deps={}
    for dep in string.gmatch(data, "require%s*%[%[([%w_]+)%]%]") do
        if not SYSTEM_LIBS[dep] then
            deps[#deps+1]=dep
        end
    end

    return deps
end

local basename= string.gmatch(path, "/([^/]*)$")()
get_file(basename)

if pull_dependencies then
    local seen={}
    local deps= get_dependencies(DIR.."/"..basename)
    while #deps > 0 do
        local dep=table.remove(deps)
        if not seen[dep] then
            seen[dep]=true

            get_file(dep..".lua")
            local more= get_dependencies(DIR.."/"..dep..".lua")
            for i,v in ipairs(more) do deps[#deps+1] = v end
        end

    end
end


