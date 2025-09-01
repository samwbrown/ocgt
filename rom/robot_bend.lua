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
local NC_NAME="gt.integrated_circuit"


-- MAIN --

local queued={}

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


while true do
  -- wait for signal
  local sig, inv_slot= computer.pullSignal(10)
  if sig == "inventory_changed" then
    print(inv_slot)

    local item=ic.getStackInInternalSlot(inv_slot)
    if item["name"] == NC_NAME then

    push_queue()

    if ic.getStackInSlot(MACHINE_SIDE, 2) then
      -- Empty and ready for next NC
      check_load()
    end
  end

  if gen then
    check_fuel()
  end

end