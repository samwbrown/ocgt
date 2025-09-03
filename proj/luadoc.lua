
local cpt=component or require("component")
setmetatable(cpt, {__index=function(_,k)return cpt.proxy(cpt.list(k)()) end})
---@cast cpt component

local docs={}
local count=0
local BUFlen=8000

local function flushdoc()
    print(table.concat(docs, "\n"))
    docs={}
    count=0
end

local function doc(s)
    docs[#docs+1] = s
    count = count+ #s + 1
    if count > BUFlen then
        flushdoc()
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

local function doc_table(t, pre, include_mt)
    visited[t] = true
    local meta= getmetatable(t)
    if include_mt and meta and meta ~= _G then
        if type(meta)=="table" and next(meta) ~=nil then
            doc(pre.."_mt={")
            doc_table(meta, pre.."  ")
            doc(pre.."},")
        end
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
                -- local fundoc= cpt.doc(t[k].address, t[k].name)
                -- doc(pre.."F "..tostring(k).." "..fundoc)
            else
                doc(pre..ser_key(k).."={")
                doc_table(v, pre.."  ", include_mt)
                doc(pre.."},")
            end
        end
    end
end

local function doc_component(type)
    local addr,_=cpt.list(type)()

    doc("\n---@meta _")
    doc("\n---@class "..type..": BaseComponent")
    doc(  "---@field type "..type)
    doc(type.."={")
    doc_table(cpt.proxy(addr), "  ", false)
    doc("}\n")

    for funcname, direct in pairs(cpt.methods(addr)) do
        -- get documentation string
        local docstr= cpt.doc(addr, funcname)

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
            arg= string.gsub(arg, " or ", "|")

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

    flushdoc()
end

-- globals
-- doc("---@meta")
-- doc("_G={")
-- doc_table(_G, "", true)
-- doc("}")

-- components
for addr, type in pairs(cpt.list()) do
    doc_component(type)
end