---@meta _
---@class eeprom: BaseComponent
---@field type "eeprom"
eeprom={}

---Get the checksum of the data on this EEPROM.
---direct (returns immediately)
---@return string
function eeprom.getChecksum() end

---Overwrite the currently stored byte array.
---@param data string
function eeprom.set(data) end

---Get the storage capacity of this EEPROM.
---direct (returns immediately)
---@return number
function eeprom.getSize() end


---Get the currently stored byte array.
---direct (returns immediately)
---@return string
function eeprom.getData() end

---Get the storage capacity of this EEPROM.
---direct (returns immediately)
---@return number
function eeprom.getDataSize() end

---Get the label of the EEPROM.
---direct (returns immediately)
---@return string
function eeprom.getLabel() end

---Get the currently stored byte array.
---direct (returns immediately)
---@return string
function eeprom.get() end

---Overwrite the currently stored byte array.
---@param data string
function eeprom.setData(data) end

---Set the label of the EEPROM.
---@param data string
---@return string
function eeprom.setLabel(data) end

---Make this EEPROM readonly if it isn't already. This process cannot be reversed!
---direct (returns immediately)
---@param checksum string
---@return boolean
function eeprom.makeReadonly(checksum) end