

local component=component or require "component"

local docs=""
local BUFlen=1000

local function doc(s)
    docs=docs.."\n"..s
    if #docs > BUFlen then
        print(docs)
        docs=""
    end
end

local visited={}

local function ser_key(k)
    if type(k)=="string" and not string.find(k, "[%.%}%{%[%]]") then
        return string.gsub(k, "/", "_")

    elseif string.find(type(k), "(number|boolean|nil)") then
        return "["..tostring(k).."]"

    else
        return "[\""..tostring(k).."\"]"
    end
end

local function doc_table(t, pre)
    visited[t] = true
    local meta= getmetatable(t)
    if meta and meta ~= _G and next(meta) ~= nil then
        doc(pre.."_mt={")
        doc_table(meta, pre.."  ")
        doc(pre.."},")
    end

    for k,v in pairs(t) do
        if type(v)=="function" then
            doc(pre..ser_key(k).."= function() end,")
        end
    end

    for k,v in pairs(t) do
        if type(v)=="string" then
            doc(string.format("%s%s=%q,", pre, ser_key(k), v))
        end
    end
    for k,v in pairs(t) do
        if string.find(type(v), "(number|boolean|nil|thread|userdata|object)") then
            doc(pre..ser_key(k).."="..tostring(v)..",")
        end
    end

    for k,v in pairs(t) do
        if type(v)=="table" and not visited[v] then
            if rawget(v, "address") and rawget(v, "name") then
                -- this is actually a component function
                -- local fundoc= component.doc(t[k].address, t[k].name)
                -- doc(pre.."F "..tostring(k).." "..fundoc)
            else
                doc(pre..ser_key(k).."={")
                doc_table(v, pre.."  ")
                doc(pre.."},")
            end
        end
    end
end

local function doc_component(type)
    local addr,_=component.list(type)()

    doc("\n---@meta \""..type.."\"")
    doc(  "---@class "..type)
    doc(type.."={")
    doc_table(component.proxy(addr), "  ")
    doc("}\n")

    for funcname, direct in pairs(component.methods(addr)) do
        -- get documentation string
        local docstr= component.doc(addr, funcname)

        -- function comment
        doc("---"..string.gmatch(docstr, "%).-[%-%;]+%s*(.*)")())

        -- direct flag
        if direct then
            doc("---direct (returns immediately)")
        end

        -- args including ()
        local args= string.gmatch(docstr,  "(%(.-%))")()

        -- accumulate arg list
        local argnames={}

        -- split arg list
        for arg in string.gmatch(args,  "([%[,()]+[^%]%[,]+)") do
            if arg=="()" then break end

            -- add just arg name to list
            argnames[#argnames+1] = string.gmatch(arg, "%W*(%w+)")()

            if string.find(arg, "%[") then
                -- optional
                arg= arg.."?"
            end

            -- lstrip, rstrip
            arg= string.gsub(arg, "^[ %(%)%[,%]]+", "")
            arg= string.gsub(arg,  "[ %(%)%[,%]]+$", "")

            -- replace
            arg= string.gsub(arg, ":", " ")
            arg= string.gsub(arg, "or", "|")

            doc("---@param "..arg)
        end

        -- return val
        local returns= string.gmatch(docstr, "%):(.-) [%-%;]")()
        if returns then
            doc("---@return "..returns)
        end

        -- def
        doc("function "..type.."."..funcname.."("..table.concat(argnames, ", ")..") end\n")
    end
end

-- globals
doc("---@meta")
doc("_G={")
doc_table(_G, "")
doc("}")

-- components
for addr, type in pairs(component.list()) do
    doc_component(type)
end

-- flush
print(docs)