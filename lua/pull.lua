-- openos --
local shell = require [[shell]]
local internet = require [[internet]]
local fs = require [[filesystem]]

-- config --
local ADDR="https://raw.githubusercontent.com/samwbrown/ocgt/refs/heads/dev/lua/"
local FOLDERS={"","lib/","modules/"}
local HEADERS={
    ["Cache-Control"]={"no-cache", "no-store", "must-revalidate"},
    ["Pragma"]="no-cache",
    ["Expires"]=0,
}


local b=1

local DIR=shell.getWorkingDirectory().."/"
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


-- local --
local function pull_file(filename)
    local size=fs.exists(DIR..filename) and fs.size(DIR..filename) or 0

    for _, folder in ipairs(FOLDERS) do
        local response= internet.request(ADDR..folder..filename, nil, HEADERS)
        local ok, result = pcall( function()
            local fd
            local rc=0
            for chunk in response do
                fd=fd or io.open(DIR..filename, "w")
                fd:write(chunk)
                rc = rc + #chunk
            end

            fd:close()
            print(string.format("%s: %d -> %d bytes", DIR..filename, size, rc))
            return rc
        end)

        if ok then return result end
    end

    error("Could not read file")
end

local function read_dependencies(filename)
    local fd=io.open(DIR..filename)
    local data=fd:read(300)
    fd:close()

    local deps={}
    for dep in string.gmatch(data, "require%s*%[%[([%w_]+)%]%]") do
        if not SYSTEM_LIBS[dep] then
            deps[#deps+1]=dep
        end
    end
    return deps
end

local function pull_dependencies(filename)
    local checked={}
    local deps= read_dependencies(filename)
    while #deps > 0 do
        local dep=table.remove(deps)
        if not checked[dep] then
            checked[dep]=true
            pull_file(dep..".lua")
            local new_deps= read_dependencies(dep..".lua")
            for _,v in ipairs(new_deps) do table.insert(deps, v) end
        end
    end
end

-- run --
local args, options = shell.parse(...)
if #args == 0 then
    io.write("Usage: pull <filename> [-r]")
    return
end

local filename = args[1]
pull_file(filename)

if options.r then
    pull_dependencies(filename)
end


