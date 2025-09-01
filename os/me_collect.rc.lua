-- config

SCRIPT_PATH= "/home/me_collect.lua"
OUT_PATH,_= string.gsub(SCRIPT_PATH, ".lua", ".out")

-- local

local function output(...)
    local fd=io.open(OUT_PATH, "a")
    fd:write(table.concat(table.pack(...),"\t").."\n")
    fd:close()
end

local thread

-- rc api

function start()
    output(os.date().." rc starting")
    local env= setmetatable({print=output}, {__index=_G})
    thread=require("thread").create(loadfile(SCRIPT_PATH, 't', env))
    thread:detach()
end

function stop()
    output(os.date().." rc stopping")
    thread:kill()
end

function status()
    local sts= thread and thread:status() or "nil" 
    output(os.date().." rc status: "..sts)
end