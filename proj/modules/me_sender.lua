-- lib --
local utils= require [[robot_utils]]

-- openos --
local cpt= require [[component]]

-- components --
local me= cpt.upgrade_me
local rb= cpt.robot

-- package --
local me_sender={}

-- local  --
local init= false
local slots={}

-- callback
function me_sender.inventory_changed(sig, slot)
    assert(init, "Not initialised!")
    if rb.count(slot)>0 and not utils.is_reserved(slot) then
        slots[slot]=true
    end
end

function me_sender.init()
    -- do nothing
    init=true
end

function me_sender.tick()
    assert(init, "Not initialised!")
    for slot, _ in pairs(slots) do
        slots[slot]=nil
        rb.select(slot)
        me.sendItems()
    end
end

return me_sender