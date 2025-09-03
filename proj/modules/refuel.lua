-- lib --
local utils= require [[robot_utils]]

-- openos --
local cmp= require [[computer]]
local cpt= require [[component]]

-- component --
local gen= cpt.generator
local me= cpt.upgrade_me
local db= cpt.database
local rb= cpt.robot

-- package --
local refuel={
    -- config
    ENERGY_MIN= cmp.maxEnergy()/2,
    REFUEL_COUNT= 4,
}

-- local --
local init=false
local fuel_slot=nil

local function need_fuel()
    local empty= gen.count() == 0
    local low_energy= cmp.energy() > refuel.ENERGY_MIN
    return low_energy and empty
end

local function load_fuel()
    rb.select(fuel_slot)
    local count= me.requestItems(db.address, 1, refuel.REFUEL_COUNT)
    gen.insert(count)

    local remaining= rb.count()
    if remaining>0 then
        me.sendItems()
    end

    print("refuel: "..(refuel.REFUEL_COUNT-remaining).." items")
end

-- public --
function refuel.init()
    fuel_slot= utils.reserve_slot()
    if fuel_slot then init=true end
end

function refuel.tick()
    assert(init, "Not initialised!")
    if not need_fuel() then
        return
    end

    load_fuel()
end

return refuel