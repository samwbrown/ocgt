-- openos --
local sides= require [[sides]]
local cmp= require [[computer]]
local cpt= require [[component]]

-- components --
local rb= cpt.robot
local ic= cpt.inventory_controller

-- package --
local robot_utils = {}

-- local --

local reserved_slots={}

local function inventory_name(side)
    local ok, name= pcall(ic.getInventoryName, side)
    return ok and name or "none"
end

-- public --
function robot_utils.reserve_slot()
    for i=rb.inventorySize(), 1, -1 do
        if not reserved_slots[i] then
            reserved_slots[i]=true
            return i
        end
    end

    return nil
end

function robot_utils.is_reserved(idx)
    checkArgs(1, "number")
    return reserved_slots[idx]
end

function robot_utils.face_block_matching(pattern)
    if string.find(inventory_name(sides.top), pattern) then
        return sides.top
    end

    if string.find(inventory_name(sides.bottom), pattern) then
        return sides.bottom
    end

    if string.find(inventory_name(sides.front), pattern) then
        return sides.front
    end

    rb.turn(true)
    if string.find(inventory_name(sides.front), pattern) then
        return sides.front
    end

    rb.turn(true)
    if string.find(inventory_name(sides.front), pattern) then
        return sides.front
    end

    rb.turn(true)
    if string.find(inventory_name(sides.front), pattern) then
        return sides.front
    end

    -- not found :(
    return nil
end

return robot_utils