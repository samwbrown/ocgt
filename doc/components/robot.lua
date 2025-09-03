---@meta _

---@class robot: BaseComponent
---@field type "robot"
local robot = {}

---@alias Side
---| 0 # sides.bottom
---| 1 # sides.top
---| 2 # sides.back
---| 3 # sides.front
---| 6 # sides.right
---| 5 # sides.left

---@alias InteractSide
---| 3 # sides.front
---| 2 # sides.back
---| 1 # sides.top

---@alias MoveDirection
---| 3 # sides.front
---| 2 # sides.back
---| 1 # sides.top
---| 0 # sides.bottom

---Gets the durability of the currently equipped tool.
---@return number # Durability percentage (0-100).
function robot.durability() end

---Moves the robot in the specified direction.
---@param direction MoveDirection # One of the valid movement sides (front, back, top, bottom).
---@return boolean # True if movement was successful, false otherwise.
function robot.move(direction) end

---Rotates the robot left or right.
---@param clockwise boolean # True for clockwise, false for counterclockwise.
---@return boolean # True if rotation was successful, false otherwise.
function robot.turn(clockwise) end

---Gets the name of the robot.
---@return string # The robot's name.
function robot.name() end

---Uses the currently equipped tool against a block or entity.
---@param side InteractSide # The side to interact with.
---@param face Side|nil # The face of the target block.
---@param sneaky boolean|nil # Whether to simulate shift-right-click.
---@return boolean, string|nil # True if successful, false with a failure reason.
function robot.swing(side, face, sneaky) end

---Attempts to use an item as a player would (e.g., right-click).
---@param side InteractSide # The side to use the item on.
---@param face Side|nil # The face of the target block.
---@param sneaky boolean|nil # Whether to simulate shift-right-click.
---@param duration number|nil # How long the item is used (e.g., charging a bow).
---@return boolean, string|nil # True if successful, false with a reason.
function robot.use(side, face, sneaky, duration) end

---Places a block from the currently selected inventory slot.
---@param side InteractSide # The side to place on.
---@param face Side|nil # The face of the target block.
---@param sneaky boolean|nil # Whether to simulate shift placement.
---@return boolean, string|nil # True if successful, false with a reason.
function robot.place(side, face, sneaky) end

---Gets the current color of the robot's light.
---@return number # RGB color as an integer (0xRRGGBB).
function robot.getLightColor() end

---Sets the color of the robot's light.
---@param value number # RGB color as an integer (0xRRGGBB).
---@return number # The new light color.
function robot.setLightColor(value) end

---Gets the size of the robot's internal inventory.
---@return number # Number of slots.
function robot.inventorySize() end

---Gets or sets the currently selected inventory slot.
---@param slot number|nil # The slot to select.
---@return number # The currently selected slot.
function robot.select(slot) end

---Gets the number of items in the selected or specified slot.
---@param slot number|nil # The slot to check.
---@return number # Number of items in the slot.
function robot.count(slot) end

---Gets the remaining space in the selected or specified slot.
---@param slot number|nil # The slot to check.
---@return number # Remaining space.
function robot.space(slot) end

---Compares the currently selected slot with another slot.
---@param otherSlot number # The slot to compare with.
---@return boolean # True if items are identical.
function robot.compareTo(otherSlot) end

---Transfers items between internal inventory slots.
---@param toSlot number # The target slot.
---@param amount number|nil # Number of items to transfer (default: all).
---@return boolean # True if transfer was successful.
function robot.transferTo(toSlot, amount) end

---Gets the number of installed tanks.
---@return number # Number of tanks.
function robot.tankCount() end

---Selects the active tank.
---@param tank number # Tank number to select.
function robot.selectTank(tank) end

---Gets the fluid level in the selected or specified tank.
---@param tank number|nil # The tank to check.
---@return number # Fluid level in millibuckets (mB).
function robot.tankLevel(tank) end

---Gets the remaining capacity in the selected or specified tank.
---@param tank number|nil # The tank to check.
---@return number # Remaining space in mB.
function robot.tankSpace(tank) end

---Compares the fluid in the selected tank with another tank.
---@param tank number # The target tank.
---@return boolean # True if fluids are identical.
function robot.compareFluidTo(tank) end

---Transfers fluid between tanks.
---@param tank number # The target tank.
---@param count number|nil # Amount to transfer (default: 1000 mB).
---@return boolean # True if transfer was successful.
function robot.transferFluidTo(tank, count) end

---Detects a block in front of the robot.
---@param side InteractSide # The side to check.
---@return boolean # True if a block is detected.
function robot.detect(side) end

---Compares fluid in the selected tank to the world or another tank.
---@param side InteractSide # The side to check.
---@return boolean # True if fluids match.
function robot.compareFluid(side) end

---Drains fluid from the world or a tank.
---@param side InteractSide # The side to drain from.
---@param count number|nil # Amount to drain (default: 1000 mB).
---@return boolean # True if successful.
function robot.drain(side, count) end

---Fills fluid into the world or a tank.
---@param side number # The side to fill.
---@param count number|nil # Amount to fill (default: 1000 mB).
---@return boolean # True if successful.
function robot.fill(side, count) end

---Compares a block with the item in the selected slot.
---@param side InteractSide # The side to compare with.
---@param fuzzy boolean|nil # Whether to allow slight variations.
---@return boolean # True if blocks are identical.
function robot.compare(side, fuzzy) end

---Drops items from the selected slot.
---@param side InteractSide # The side to drop onto.
---@param count number|nil # Number of items to drop (default: all).
---@return boolean # True if successful.
function robot.drop(side, count) end

---Picks up items from the world or an inventory.
---@param side InteractSide # The side to pick up from.
---@param count number|nil # Number of items to pick up (default: all).
---@return boolean # True if successful.
function robot.suck(side, count) end

return robot
