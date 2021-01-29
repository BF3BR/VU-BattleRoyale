class "TableHelper"

-- Checks if a table contains a value
function TableHelper:Contains(p_Table, p_Val)
    for i = 1, #p_Table do
        if p_Table[i] == p_Val then
            return true
        end
    end
    return false
end

-- Checks if a table is empty
function TableHelper:Empty(p_Table)
    for _, _ in pairs(p_Table) do
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
