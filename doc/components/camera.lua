---@meta _

---@class camera: BaseComponent
---@field type "camera"
local camera = {}

---Calculates the distance to the block in the direction the camera is facing.
---@param x number|nil # The x-offset of the ray. Defaults to 0 (directly in front).
---@param y number|nil # The y-offset of the ray. Defaults to 0 (directly in front).
---@return number distance # The distance to the block the ray intersects.
function camera.distance(x, y) end

---Returns the distance to the block the ray is shot at with the specified x-y offset facing downwards, or of the block directly below
---direct (returns immediately)
---@param x number?
---@param y number
function camera.distanceDown(x, y) end

---Returns the distance to the block the ray is shot at with the specified x-y offset facing upwards, or of the block directly above
---direct (returns immediately)
---@param x number?
---@param y number
function camera.distanceUp(x, y) end