local t

function start(path)
    local outfile,_=string.gsub(path, ".lua", ".out")

    local env={}
    function env.print(...)
        local fd=io.open(outfile, "a")
        fd:write(table.concat(table.pack(...),"\t").."\n")
        fd:close()
    end
    function log(...)
        local fd=io.open(logpath, "a")
        local log_str=table.concat(table.pack(...),"\t")
        fd:write(os.date()..": "..log_str.."\n")
        fd:close()
    end

    log("Starting")
    local env = setmetatable({log=log, logpath=logpath}, {__index = _G})
    t=require("thread").create(function() loadfile(path, 't', env)() end)
    t:detach()
end

function stop()
    log("Stopping")
    t:kill()
end