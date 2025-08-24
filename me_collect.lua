local cpt=require("component")
local sides= require("sides")

local me= cpt.me_controller
local tp= cpt.transposer

local is_craftable={}
setmetatable(is_craftable, {
	__index= function(table, key)
		print("Checking "..key)
		local v= #me.getCraftables({label=key})>0
		rawset(table, key, v) -- memoise
		return v
	end
})

while true do
	local items=tp.getAllStacks(sides.down)
	for slot=1, items.count() do
		if items[slot] and is_craftable[items[slot].label] then
			tp.transferItem(sides.down, sides.front, 64, slot)
			print("Imported "..items[slot].label)
		end
	end
	os.sleep(1)
end
