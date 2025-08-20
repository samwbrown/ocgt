--
-- prep.lua
--
-- prepare a robot for further testing
--

-- REQUIRES and OVERLOADS
computer=computer or require("computer")
component=component or require("component")

print=print or function (...) end

-- LIB

local sides = {
  bottom = 0,
  top = 1,
  back = 2,
  front = 3,
  right = 4,
  left = 5,
  unknown = 6
}

-- CONFIG

BUS_NC_SLOT=0
BUS_SIDE=sides.front
ME_SIDE=sides.top
NC_SIDE=sides.top

-- MAIN

rb=component.proxy(component.list("robot")())
ic=component.proxy(component.list("inventory_controller")())


print("AAAAA\n")

