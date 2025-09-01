--
-- non-consumeable item inputs
--

local tb= table

local function part(name)
  return component.proxy(component.list(name)())
end

local rb=   part( "robot")
local chat= part( "chat")
local gen=  part( "gen")
local ic=  part( "inventory_controller")


-- override print
chat.setName("Robot shoot")
local print= function (...) chat.say(tb.concat(tb.pack(...), "\t"), 10) end

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

print("OK")

-- ic.equip(1)

rb.use(sides.front)