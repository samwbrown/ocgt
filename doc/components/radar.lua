
---@meta _
---@class radar: BaseComponent
---@field type "radar"
radar={
}

---Returns a list of all mobs detected within the specified or the maximum range
---direct (returns immediately)
---@param distance number?
function radar.getMobs(distance) end

---Returns a list of all entities detected within the specified or the maximum range
---direct (returns immediately)
---@param distance number?
function radar.getEntities(distance) end

---Returns a list of all items detected within the specified or the maximum range
---direct (returns immediately)
---@param distance number?
function radar.getItems(distance) end

---Returns a list of all players detected within the specified or the maximum range
---direct (returns immediately)
---@param distance number?
function radar.getPlayers(distance) end