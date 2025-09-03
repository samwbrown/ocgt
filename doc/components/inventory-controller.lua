---@meta _

---@class inventory_controller: BaseComponent
---@field type "inventory_controller"
local inventory_controller = {}

---Get a description of all stacks in the inventory on the specified side of the device.
---@param side number
---@return userdata
function inventory_controller.getAllStacks(side) end

---Compare an item in the specified slot with one in the database with the specified address.
---@param slot number
---@param dbAddress string
---@param dbSlot number
---@param checkNBT boolean=false?
---@return boolean
function inventory_controller.compareToDatabase(slot, dbAddress, dbSlot, checkNBT) end

---Get a description of the stack in the inventory on the specified side of the device.
---@param side number
---@param slot number
---@return ItemStack|nil # `nil` if there is no items in the slot
function inventory_controller.getStackInSlot(side, slot) end

---Swaps the equipped tool with the content of the currently selected inventory slot.
---@return boolean
function inventory_controller.equip() end

---Store an item stack description in the specified slot of the database with the specified address.
---@param slot number
---@param dbAddress string
---@param dbSlot number
---@return boolean
function inventory_controller.storeInternal(slot, dbAddress, dbSlot) end

---Swaps the installed upgrade in the slot (1 by default) with the content of the currently selected inventory slot.
---@param slot number?
---@return boolean
function inventory_controller.installUpgrade(slot) end

---Compare an item in the specified slot in the inventory on the specified side with one in the database with the specified address.
---@param side number
---@param slot number
---@param dbAddress string
---@param dbSlot number
---@param checkNBT boolean=false?
---@return boolean
function inventory_controller.compareStackToDatabase(side, slot, dbAddress, dbSlot, checkNBT) end

---The size of an item inventory in the specified slot.
---Only works with OC servers and databases.
---@param slot number
---@return number
function inventory_controller.getItemInventorySize(slot) end

---Drops an item into the specified slot in the item inventory.
---Only works with OC servers and databases.
---@param inventorySlot number
---@param slot number
---@param count number=64?
---@return number
function inventory_controller.dropIntoItemInventory(inventorySlot, slot, count) end

---Sucks an item out of the specified slot in the item inventory.
---Only works with OC servers and databases.
---@param inventorySlot number
---@param slot number
---@param count number=64?
---@return number
function inventory_controller.suckFromItemInventory(inventorySlot, slot, count) end

---Sucks items from the specified slot of an inventory.
---@param facing number
---@param slot number
---@param count number?
---@param fromSide number?
---@return boolean
function inventory_controller.suckFromSlot(facing, slot, count, fromSide) end

---Get whether the items in the two specified slots of the inventory on the specified side of the device are equivalent (have shared OreDictionary IDs).
---@param side number
---@param slotA number
---@param slotB number
---@return boolean
function inventory_controller.areStacksEquivalent(side, slotA, slotB) end

---Store an item stack description in the specified slot of the database with the specified address.

---@param side number
---@param slot number
---@param dbAddress string
---@param dbSlot number
---@return boolean
function inventory_controller.store(side, slot, dbAddress, dbSlot) end

---Get number of items in the specified slot of the inventory on the specified side of the device.
---@param side number
---@param slot number
---@return number
function inventory_controller.getSlotStackSize(side, slot) end

---Get whether the stack in the selected slot is equivalent to the item in the specified slot (have shared OreDictionary IDs).
---@param otherSlot number
---@return boolean
function inventory_controller.isEquivalentTo(otherSlot) end

---Change the display name of the stack in the inventory on the specified side of the device.
---@param side number
---@param slot number
---@param label string
---@return boolean
function inventory_controller.setStackDisplayName(side, slot, label) end

---Get the maximum number of items in the specified slot of the inventory on the specified side of the device.

---@param side number
---@param slot number
---@return number
function inventory_controller.getSlotMaxStackSize(side, slot) end

---Get the the name of the inventory on the specified side of the device.
---@param side number
---@return string
function inventory_controller.getInventoryName(side) end

---Get a description of the stack in the specified slot or the selected slot.
---@param slot number?
---@return ItemStack|nil # `nil` if there is no items in the slot
function inventory_controller.getStackInInternalSlot(slot) end

---Get the number of slots in the inventory on the specified side of the device.
---@param side number
---@return number
function inventory_controller.getInventorySize(side) end

---Get whether the items in the two specified slots of the inventory on the specified side of the device are of the same type.

---@param side number
---@param slotA number
---@param slotB number
---@param checkNBT boolean=false?
---@return boolean
function inventory_controller.compareStacks(side, slotA, slotB, checkNBT) end

---get upgrade container tier at the given slot.
---@param slot number
---@return number
function inventory_controller.getUpgradeContainerTier(slot) end

---Drops the selected item stack into the specified slot of an inventory.
---@param facing number
---@param slot number
---@param count number?
---@param fromSide number?
---@return boolean
function inventory_controller.dropIntoSlot(facing, slot, count, fromSide) end

---get upgrade container type at the given slot.
---@param slot number
---@return string
function inventory_controller.getUpgradeContainerType(slot) end