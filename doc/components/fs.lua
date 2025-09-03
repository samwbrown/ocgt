---@meta _
---@class filesystem: BaseComponent
---@field type "filesystem"
filesystem={}

---Closes an open file descriptor with the specified handle.
---direct (returns immediately)
---@param handle File
function filesystem.close(handle) end

---Returns a list of names of objects in the directory at the specified absolute path in the file system.
---@param path string
---@return table
function filesystem.list(path) end

---Opens a new file descriptor and returns its handle.
---direct (returns immediately)
---@param path string
---@param mode string='r'?
---@return File
function filesystem.open(path, mode) end

---Removes the object at the specified absolute path in the file system.
---@param path string
---@return boolean
function filesystem.remove(path) end

---Returns whether the object at the specified absolute path in the file system is a directory.
---direct (returns immediately)
---@param path string
---@return boolean
function filesystem.isDirectory(path) end

---Seeks in an open file descriptor with the specified handle. Returns the new pointer position.
---direct (returns immediately)
---@param handle File
---@param whence string
---@param offset number
---@return number
function filesystem.seek(handle, whence, offset) end

---Reads up to the specified amount of data from an open file descriptor with the specified handle. Returns nil when EOF is reached.
---direct (returns immediately)

---@param handle File
---@param count number
---@return string or nil
function filesystem.read(handle, count) end

---Renames/moves an object from the first specified absolute path in the file system to the second.
---@param from string
---@param to string
---@return boolean
function filesystem.rename(from, to) end

---Returns the size of the object at the specified absolute path in the file system.
---direct (returns immediately)
---@param path string
---@return number
function filesystem.size(path) end

---Creates a directory at the specified absolute path in the file system. Creates parent directories, if necessary.
---@param path string
---@return boolean
function filesystem.makeDirectory(path) end

---Writes the specified data to an open file descriptor with the specified handle.
---direct (returns immediately)
---@param handle File
---@param value string
---@return boolean
function filesystem.write(handle, value) end

---The currently used capacity of the file system, in bytes.

---direct (returns immediately)
---@return number
function filesystem.spaceUsed() end

---Returns whether the file system is read-only.
---direct (returns immediately)
---@return boolean
function filesystem.isReadOnly() end

---Get the current label of the drive.
---direct (returns immediately)
---@return string
function filesystem.getLabel() end

---The overall capacity of the file system, in bytes.
---direct (returns immediately)
---@return number
function filesystem.spaceTotal() end

---Returns the (real world) timestamp of when the object at the specified absolute path in the file system was modified.
---direct (returns immediately)
---@param path string
---@return number
function filesystem.lastModified(path) end

---Returns whether an object exists at the specified absolute path in the file system.
---direct (returns immediately)
---@param path string
---@return boolean
function filesystem.exists(path) end

---Sets the label of the drive. Returns the new value, which may be truncated.
---@param value string
---@return string
function filesystem.setLabel(value) end