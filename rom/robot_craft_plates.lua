--
-- non-consumeable item inputs
--

-- REQUIRES AND COMPONENTS
local cmp=computer or require("computer")
local cpt=component or require("component")
local tb=table
local function part(name)
  return cpt.proxy(cpt.list(name)())
end

local rb=   part( "robot")
local gen=  part( "gen")
local ic=  part( "inventory_controller")
local craft=  part( "crafting")


-- local ic= component.inventory_controller()
-- local rb= component.robot()

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

local ME_SIDE=sides.front


-- MAIN --


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
    if inv_slot ~= 1 or rb.count(1)==0 then
      print(inv_slot)
      goto continue
    end

    -- load hammer into bottom left
    rb.select(9)
    ic.equip()

    -- move n-1 items to middle left
    rb.select(1)
    rb.transferTo(5, rb.count()-1)
    
    -- craft
    while craft.craft() do
      -- print("Crafted "..ic.getStackInInternalSlot(1).name)
    end

    -- done
    print("Done")
    rb.drop(ME_SIDE)

    -- clear queue
    while computer.pullSignal(0) do end

    -- unload hammer
    rb.select(9)
    ic.equip()
    
  end

  ::continue::

  if gen then
    check_fuel()
  end

end