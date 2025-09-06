-- openos --
local fs = require [[filesystem]]
local shell = require [[shell]]
local internet = require [[internet]]

-- config --
local ADDR="https://raw.githubusercontent.com/samwbrown/ocgt/refs/heads/main/lua/"
local FOLDERS={"","lib/","modules/"}

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
    local result, response
    for i, folder in ipairs(FOLDERS) do
        result, response = pcall(internet.request, ADDR..folder..filename)
        if result then break end
    end
    assert(result, "File does not exist: "..filename)

    local rc=0
    local fd=fs.open(DIR..filename, "w")

    for chunk in response do
        fd:write(chunk)
        rc = rc + #chunk
    end
    
    fd:close()
    print(string.format("%s: %d bytes", DIR..filename, rc))
    return rc
end

local function read_dependencies(filename)
    local fd=fs.open(DIR..filename, "r")
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
            local dep_path=DIR..dep..".lua"

            pull_file(dep_path)
            local new_deps= read_dependencies(dep_path)
            for _,v in ipairs(new_deps) do table.insert(v) end
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


