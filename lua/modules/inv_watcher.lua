-- lib --
local utils= require [[robot_utils]]

-- openos --
local sides= require [[sides]]
local cmp= require [[computer]]
local cpt= require [[component]]

-- components --
local rb= cpt.robot

-- package --
local inv_watcher={
    -- config
    IN_NAME="chest"
}

-- local --
local init=false
local filter=nil
local in_side=sides.front

-- public --
function inv_watcher.init()
    local result= utils.face_block_matching(inv_watcher.IN_NAME)
    assert(result, "Could not find inventory!")
    in_side=result
    init=true
end

function inv_watcher.tick()
    assert(init, "Not initialised!")
    if filter then
        print("not implemented")
        return
    end

    for i=1, rb.inventorySize() do
        if not utils.is_reserved(i) and rb.count(i)==0 then
            rb.select(i)
            rb.suck(in_side)
            return
        end
    end
end


return inv_watcher