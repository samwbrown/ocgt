-- lib --
local utils= require [[robot_utils]]

-- openos --
local sides= require [[sides]]
local cmp= require [[computer]]
local cpt= require [[component]]

-- components --
local rb= cpt.robot
local ic= cpt.inventory_controller

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

    local inv_slot=1
    local inv_size=rb.inventorySize()
    for item in ic.getAllStacks(in_side) do
        if item.size then
            for i=inv_slot, inv_size do
                if not utils.is_reserved(i) and rb.count(i)==0 then
                    inv_slot=i
                    rb.select(inv_slot)
                    rb.suck(in_side)
                end
            end
        end
    end

    return
end


return inv_watcher