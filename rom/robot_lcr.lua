--
-- non-consumeable item inputs
--

-- REQUIRES AND COMPONENTS
local cmp=computer or require("computer")
local cpt=component or require("component")
local tb=table

local function try_proxy(name, nil_ok) 
    local l=cpt.list(name)()
    if not l and nil_ok then return nil end
    return cpt.proxy(l)
end

local rb = try_proxy("robot")
local ic = try_proxy("inventory_controller")
local chat = try_proxy("chat", true)
local gen = try_proxy("generator", true)

if not io then io={write=function (...) end, flush= function() end} end

if chat and not print then
  chat.setName("Robot NC")
  print= function (...) chat.say(tb.concat(tb.pack(...), "\t"), 10) end
  chat.say("Configured", 10)
end

print=print or function (...) end


-- set lighting
rb.setLightColor(0x00FF00)

-- LIB --

local sides = {
  bottom = 0,
  top = 1,
  back = 2,
  front = 3,
  right = 4,
  left = 5,
  unknown = 6
}

-- CONFIG --

local MACHINE_SIDE=sides.front
local ME_SIDE=sides.top
local NC_SIDE=sides.bottom


-- MAIN --

local queued={}
local nc={
  waiting_slot=nil,
  loaded_slot=nil,
  slots={},
  name=nil,
}

local function build_index()
  nc.slots={}
  for i=1, ic.getInventorySize(NC_SIDE) do
    local item= ic.getStackInSlot(NC_SIDE, i)
    if item and item["name"] then
      nc.name= nc.name or item["name"]
      nc.slots[item["damage"]] = i
      print(string.format("NC at slot %03d: %s %d", 
          i, item["label"], item["damage"]))
    end
  end
end

local function push_queue()
  while #queued > 0 do
    local slot= queued[#queued]
    local item=ic.getStackInInternalSlot(slot)
    if item then
      rb.select(slot)
      if rb.drop(MACHINE_SIDE) then
        print("Pushed "..item["label"])
      else
        print("Can't push into machine")
        break
      end
    end

    table.remove(queued)
  end
end

local function check_load()
  if nc.active then
    -- retrieve current nc and put it away
    print("Retrieving NC "..nc.loaded_slot)
    ic.suckFromSlot(MACHINE_SIDE, 1, 1)
    ic.dropIntoSlot(NC_SIDE, nc.loaded_slot, 1)
  end

  -- grab new nc and load
  print("Loading NC "..nc.waiting_slot)
  ic.suckFromSlot(NC_SIDE, nc.waiting_slot, 1)
  ic.dropIntoSlot(MACHINE_SIDE, 1, 1)
  nc.loaded_slot=nc.waiting_slot
  nc.waiting_slot= nil
  nc.active=true
end

local function check_slot(slot)
  local item= ic.getStackInInternalSlot(slot)
  if not item or not item["name"] then
    return
  end

  -- Get status
  local nc_slot
  if item["name"] == nc.name then
    nc_slot= nc.slots[item["damage"]]
  end

  if not nc_slot then
    -- normal item, do it later
    table.insert(queued, slot)
    return
  end

  -- at this point we have a non-consumable item.
  -- always push it back into me system.
  rb.select(slot)
  local ok, drop_fail= ic.dropIntoSlot(ME_SIDE, 1)
  if not ok then
    print("Failed to push NC to ME: "..drop_fail)
    return
  end

  if nc_slot == nc.loaded_slot then
    -- nothing to do.
    print("NC already loaded")
    return
  end

  nc.waiting_slot= nc_slot
end

local function check_fuel()
  if gen.count() > 0 or cmp.energy() > (cmp.maxEnergy()/2)  then
    return
  end

  rb.select(16)
  if not ic.suckFromSlot(ME_SIDE, 9, 4) then
    print("Failed to get fuel")
    return
  end

  local gen_ok, gen_reason = gen.insert()
  if not gen_ok then
    print("Failed to insert fuel"..gen_reason)
  end

  if rb.count() > 0 then
    ic.dropIntoSlot(ME_SIDE, 1)
  end

  print("Re-fueled")
end

build_index()

while true do
  -- wait for signal
  local sig, inv_slot= computer.pullSignal(10)
  if sig == "inventory_changed" then
    print(inv_slot)
    check_slot(inv_slot)

    if nc.active then
      -- Push all items from the queue
      push_queue()
    end

    if nc.waiting_slot and not ic.getStackInSlot(MACHINE_SIDE, 2) then
      -- Empty and ready for next NC
      check_load()
    end
  end

  if gen then
    check_fuel()
  end

end