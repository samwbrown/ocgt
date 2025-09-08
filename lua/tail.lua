-- openos --
local shell = require [[shell]]
local term = require [[term]]

-- args --
local args, ops = shell.parse(...)
if #args ~= 1 then
  io.write("Usage: ", os.getenv("_"):match("/([^/]+)%.lua$"), " <filename>\n")
  return 1
end

local width, height = term.getViewport()
local max= width * height

local filename= args[1]
local fd=assert(io.open(filename, "r"))

fd:seek("end", -max)

-- skip partial line
local _= fd:read("*l")

for line in fd:read("*L") do
    io.write(line)
end