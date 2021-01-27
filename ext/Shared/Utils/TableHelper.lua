class 'TableHelper'

function TableHelper:contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function TableHelper:empty(table)
    for _, _ in pairs(table) do
        return false
    end
    return true
end

-- Converts an array to a Map
function TableHelper:ToMap(p_Array, p_Value)
    local l_Map = {}
    for _, l_Name in ipairs(p_Array) do
        l_Map[l_Name] = p_Value
    end

    return l_Map
end

return TableHelper
