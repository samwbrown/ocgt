---@meta

local function spcall(...)
  local result = table.pack(pcall(...))
  if not result[1] then
    error(tostring(result[2]), 0)
  else
    return table.unpack(result, 2, result.n)
  end
end

local function checkArg(n, have, ...)
  have = type(have)
  local function check(want, ...)
    if not want then
      return false
    else
      return have == want or check(...)
    end
  end
  if not check(...) then
    local msg = string.format("bad argument #%d (%s expected, got %s)",
                              n, table.concat({...}, " or "), have)
    error(msg, 3)
  end
end

string = {
    byte = string.byte,
    char = string.char,
    dump = string.dump,
    find = string.find,
    format = string.format,
    gmatch = string.gmatch,
    gsub = string.gsub,
    len = string.len,
    lower = string.lower,
    match = string.match,
    rep = string.rep,
    reverse = string.reverse,
    sub = string.sub,
    upper = string.upper,
    -- Lua 5.3.
    pack = string.pack,
    unpack = string.unpack,
    packsize = string.packsize
}

table = {
    concat = table.concat,
    insert = table.insert,
    pack = table.pack,
    remove = table.remove,
    sort = table.sort,
    unpack = table.unpack,
    -- Lua 5.3.
    move = table.move
}

math = {
    abs = math.abs,
    acos = math.acos,
    asin = math.asin,
    atan = math.atan,
    atan2 = math.atan2 or math.atan, -- Deprecated in Lua 5.3
    ceil = math.ceil,
    cos = math.cos,
    cosh = math.cosh, -- Deprecated in Lua 5.3
    deg = math.deg,
    exp = math.exp,
    floor = math.floor,
    fmod = math.fmod,
    frexp = math.frexp, -- Deprecated in Lua 5.3
    huge = math.huge,
    ldexp = math.ldexp or function(a, e) -- Deprecated in Lua 5.3
        return a*(2.0^e)
    end,
    log = math.log,
    max = math.max,
    min = math.min,
    modf = math.modf,
    pi = math.pi,
    pow = math.pow or function(a, b) -- Deprecated in Lua 5.3
        return a^b
    end,
    rad = math.rad,
    random = function(...)
        return spcall(math.random, ...)
    end,
    randomseed = function(seed)
        -- math.floor(seed) emulates pre-OC 1.8.0 behaviour
        spcall(math.randomseed, math.floor(seed))
    end,
    sin = math.sin,
    sinh = math.sinh, -- Deprecated in Lua 5.3
    sqrt = math.sqrt,
    tan = math.tan,
    tanh = math.tanh, -- Deprecated in Lua 5.3
    -- Lua 5.3.
    maxinteger = math.maxinteger,
    mininteger = math.mininteger,
    tointeger = math.tointeger,
    type = math.type,
    ult = math.ult
}

-- Deprecated in Lua 5.3.
bit32 = bit32 and {
    arshift = bit32.arshift,
    band = bit32.band,
    bnot = bit32.bnot,
    bor = bit32.bor,
    btest = bit32.btest,
    bxor = bit32.bxor,
    extract = bit32.extract,
    replace = bit32.replace,
    lrotate = bit32.lrotate,
    lshift = bit32.lshift,
    rrotate = bit32.rrotate,
    rshift = bit32.rshift
}

io = nil -- in lib/io.lua

os = {
    clock = os.clock,
    date = function(format, time)
        return spcall(os.date, format, time)
    end,
    difftime = function(t2, t1)
        return t2 - t1
    end,
    execute = nil, -- in boot/*_os.lua
    exit = nil, -- in boot/*_os.lua
    remove = nil, -- in boot/*_os.lua
    rename = nil, -- in boot/*_os.lua
    time = function(table)
        checkArg(1, table, "table", "nil")
        return os.time(table)
    end,
    tmpname = nil, -- in boot/*_os.lua
}

debug = {
    getinfo = function(...)
        local result = debug.getinfo(...)
        if result then
        -- Only make primitive information available in the sandbox.
        return {
            source = result.source,
            short_src = result.short_src,
            linedefined = result.linedefined,
            lastlinedefined = result.lastlinedefined,
            what = result.what,
            currentline = result.currentline,
            nups = result.nups,
            nparams = result.nparams,
            isvararg = result.isvararg,
            name = result.name,
            namewhat = result.namewhat,
            istailcall = result.istailcall
        }
        end
    end,
    traceback = debug.traceback,
    -- using () to wrap the return of debug methods because in Lua doing this
    -- causes only the first return value to be selected
    -- e.g. (1, 2) is only (1), the 2 is not returned
    -- this is critically important here because the 2nd return value from these
    -- debug methods is the value itself, which opens a door to exploit the sandbox
    getlocal = function(...) return (debug.getlocal(...)) end,
    getupvalue = function(...) return (debug.getupvalue(...)) end,
}

-- Lua 5.3.
utf8 = utf8 and {
    char = utf8.char,
    charpattern = utf8.charpattern,
    codes = utf8.codes,
    codepoint = utf8.codepoint,
    len = utf8.len,
    offset = utf8.offset
}



local libcomponent

-- Caching proxy objects for lower memory use.
local proxyCache = setmetatable({}, {__mode="v"})

-- Short-term caching of callback directness for improved performance.
local directCache = setmetatable({}, {__mode="k"})
local function isDirect(address, method)
  local cacheKey = address..":"..method
  local cachedValue = directCache[cacheKey]
  if cachedValue ~= nil then
    return cachedValue
  end
  local methods, reason = spcall(component.methods, address)
  if not methods then
    return false
  end
  for name, info in pairs(methods) do
    if name == method then
      directCache[cacheKey] = info.direct
      return info.direct
    end
  end
  error("no such method", 1)
end

local componentProxy = {
  __index = function(self, key)
    if self.fields[key] and self.fields[key].getter then
      return libcomponent.invoke(self.address, key)
    else
      rawget(self, key)
    end
  end,
  __newindex = function(self, key, value)
    if self.fields[key] and self.fields[key].setter then
      return libcomponent.invoke(self.address, key, value)
    elseif self.fields[key] and self.fields[key].getter then
      error("field is read-only")
    else
      rawset(self, key, value)
    end
  end,
  __pairs = function(self)
    local keyProxy, keyField, value
    return function()
      if not keyField then
        repeat
          keyProxy, value = next(self, keyProxy)
        until not keyProxy or keyProxy ~= "fields"
      end
      if not keyProxy then
        keyField, value = next(self.fields, keyField)
      end
      return keyProxy or keyField, value
    end
  end
}

local componentCallback = {
  __call = function(self, ...)
    return libcomponent.invoke(self.address, self.name, ...)
  end,
  __tostring = function(self)
    return libcomponent.doc(self.address, self.name) or "function"
  end
}

libcomponent = {
  doc = function(address, method)
    checkArg(1, address, "string")
    checkArg(2, method, "string")
    local result, reason = spcall(component.doc, address, method)
    if not result and reason then
      error(reason, 2)
    end
    return result
  end,
  invoke = function(address, method, ...)
    checkArg(1, address, "string")
    checkArg(2, method, "string")
    return invoke(component, isDirect(address, method), address, method, ...)
  end,
  list = function(filter, exact)
    checkArg(1, filter, "string", "nil")
    local list = spcall(component.list, filter, not not exact)
    local key = nil
    return setmetatable(list, {__call=function()
      key = next(list, key)
      if key then
        return key, list[key]
      end
    end})
  end,
  methods = function(address)
    local result, reason = spcall(component.methods, address)
    -- Transform to pre 1.4 format to avoid breaking scripts.
    if type(result) == "table" then
      for k, v in pairs(result) do
        if not v.getter and not v.setter then
          result[k] = v.direct
        else
          result[k] = nil
        end
      end
      return result
    end
    return result, reason
  end,
  fields = function(address)
    local result, reason = spcall(component.methods, address)
    if type(result) == "table" then
      for k, v in pairs(result) do
        if not v.getter and not v.setter then
          result[k] = nil
        end
      end
      return result
    end
    return result, reason
  end,
  proxy = function(address)
    local type, reason = spcall(component.type, address)
    if not type then
      return nil, reason
    end
    local slot, reason = spcall(component.slot, address)
    if not slot then
      return nil, reason
    end
    if proxyCache[address] then
      return proxyCache[address]
    end
    local proxy = {address = address, type = type, slot = slot, fields = {}}
    local methods, reason = spcall(component.methods, address)
    if not methods then
      return nil, reason
    end
    for method, info in pairs(methods) do
      if not info.getter and not info.setter then
        proxy[method] = setmetatable({address=address,name=method}, componentCallback)
      else
        proxy.fields[method] = info
      end
    end
    setmetatable(proxy, componentProxy)
    proxyCache[address] = proxy
    return proxy
  end,
  type = function(address)
    return spcall(component.type, address)
  end,
  slot = function(address)
    return spcall(component.slot, address)
  end
}
component = libcomponent

local libcomputer = {
  isRobot = computer.isRobot,
  address = computer.address,
  tmpAddress = computer.tmpAddress,
  freeMemory = computer.freeMemory,
  totalMemory = computer.totalMemory,
  uptime = computer.uptime,
  energy = computer.energy,
  maxEnergy = computer.maxEnergy,

  getBootAddress = computer.getBootAddress,
  setBootAddress = function(...)
    return spcall(computer.setBootAddress, ...)
  end,

  users = computer.users,
  addUser = function(...)
    return spcall(computer.addUser, ...)
  end,
  removeUser = function(...)
    return spcall(computer.removeUser, ...)
  end,

  shutdown = function(reboot)
    coroutine.yield(not not reboot)
  end,
  pushSignal = function(...)
    return spcall(computer.pushSignal, ...)
  end,
  pullSignal = function(timeout)
    local deadline = computer.uptime() +
      (type(timeout) == "number" and timeout or math.huge)
    repeat
      local signal = table.pack(coroutine.yield(deadline - computer.uptime()))
      if signal.n > 0 then
        return table.unpack(signal, 1, signal.n)
      end
    until computer.uptime() >= deadline
  end,

  beep = function(...)
    return libcomponent.invoke(computer.address(), "beep", ...)
  end,
  getDeviceInfo = function()
    return libcomponent.invoke(computer.address(), "getDeviceInfo")
  end,
  getProgramLocations = function()
    return libcomponent.invoke(computer.address(), "getProgramLocations")
  end,

  getArchitectures = function(...)
    return spcall(computer.getArchitectures, ...)
  end,
  getArchitecture = function(...)
    return spcall(computer.getArchitecture, ...)
  end,
  setArchitecture = function(...)
    local result, reason = spcall(computer.setArchitecture, ...)
    if not result then
      if reason then
        return result, reason
      end
    else
      coroutine.yield(true) -- reboot
    end
  end
}
computer = libcomputer

local libunicode = {
  char = function(...)
    return spcall(unicode.char, ...)
  end,
  len = function(s)
    return spcall(unicode.len, s)
  end,
  lower = function(s)
    return spcall(unicode.lower, s)
  end,
  reverse = function(s)
    return spcall(unicode.reverse, s)
  end,
  sub = function(s, i, j)
    if j then
      return spcall(unicode.sub, s, i, j)
    end
    return spcall(unicode.sub, s, i)
  end,
  upper = function(s)
    return spcall(unicode.upper, s)
  end,
  isWide = function(s)
    return spcall(unicode.isWide, s)
  end,
  charWidth = function(s)
    return spcall(unicode.charWidth, s)
  end,
  wlen = function(s)
    return spcall(unicode.wlen, s)
  end,
  wtrunc = function(s, n)
    return spcall(unicode.wtrunc, s, n)
  end
}
unicode = libunicode
