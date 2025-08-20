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
},

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