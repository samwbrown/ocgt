-- modules
local refuel=  require [[refuel]]
local me_sender= require [[me_sender]]
local inv_watcher= require [[inv_watcher]]

-- lib
local signals= require [[signals]]

-- openos
local event= require [[event]]

-- local
local tasks, fds={},{}

function start()
    -- modules
    inv_watcher.init()
    me_sender.init()
    refuel.init()

    -- callbacks
    fds[#fds+1]= event.listen(signals.inventory_changed, me_sender.inventory_changed)

    -- tasks
    tasks[1.0]=function()
        inv_watcher.tick()
        me_sender.tick()
    end

    tasks[60.0]=function()
        refuel.tick()
    end

    for k,v in pairs(tasks) do
        fds[#fds+1]= event.timer(k, v, math.huge)
    end
end

function stop()
    tasks, fds={},{}
    for _, fd in ipairs(fds) do
        event.cancel(fd)
    end
end

-- debug
start()