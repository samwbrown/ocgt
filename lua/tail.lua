-- openos --
local shell = require [[shell]]
local term = require [[term]]
local fs = require [[filesystem]]

-- args --
local args, ops = shell.parse(...)
if #args ~= 1 then
  io.write("Usage: ", os.getenv("_"):match("/([^/]+)%.lua$"), " <filename>\n")
  return 1
end

local width, height = term.getViewport()
local max_chars= width * height

local filename= shell.resolve(args[1])
local size= fs.size(filename)

local fd=assert(io.open(filename, "r"))

print(max_chars)
print(size)
error()

fd:seek("end", math.max(max_chars, size))

-- skip partial line
local _= fd:read("*l")

for line in fd:read("*L") do
    io.write(line)
end