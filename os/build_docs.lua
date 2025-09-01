
local visited={}
local docs={}
local count=0

local MAX=1000

local function doc(str)
    docs[#docs+1]=str

    if #str + count > MAX then
        print( table.concat(docs, "\n") )
        docs={}
    end
end

local function doc_table(t, pre)
    visited[t] = true
    -- local meta= getmetatable(t)
    -- if meta and meta ~= _G then
    --     print(pre.."-- tab meta")
    --     print_table(meta, pre.." |")
    -- end

    for k,v in pairs(t) do
        if type(v)=="function" then
            doc(pre.."F "..k)
        end
    end

    for k,v in pairs(t) do
        if type(v)=="object" then
            doc(pre.."O "..k)
        end
    end

    for k,v in pairs(t) do
        if type(v)~="table" and type(v)~="function" and type(v)~="object" then
            doc(pre.."V "..k.. "="..tostring(v))
        end
    end

    for k,v in pairs(t) do
        if type(v)=="table" and not visited[v] then
            doc(pre.."T "..k)
            doc_table(v, pre.."|")
        end
    end
end

doc_table(_G, "|")