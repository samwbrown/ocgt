local visited={}

local function print_table(t, pre)
    visited[t] = true
    -- local meta= getmetatable(t)
    -- if meta and meta ~= _G then
    --     print(pre.."-- tab meta")
    --     print_table(meta, pre.." |")
    -- end

    for k,v in pairs(t) do
        if type(v)=="function" then
            print(pre.."-- func "..k)
        end
    end

    for k,v in pairs(t) do
        if type(v)=="object" then
            print(pre.."-- obj "..k)
        end
    end

    for k,v in pairs(t) do
        if type(v)~="table" and type(v)~="function" and type(v)~="object" then
            print(pre.."-- val "..k.. "="..tostring(v))
        end
    end

    for k,v in pairs(t) do
        if type(v)=="table" and not visited[v] then
            print(pre.."-- tab "..k)
            print_table(v, pre.." |")
        end
    end
end

print_table(_G, "|")