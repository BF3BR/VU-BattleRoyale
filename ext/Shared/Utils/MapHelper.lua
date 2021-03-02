class "MapHelper"

-- Checks if the map contains a value
function MapHelper:Contains(p_Map, p_Value)
    for _, l_Value in pairs(p_Map) do
        if l_Value == p_Value then
            return true
        end
    end

    return false
end

-- Checks if the map is empty
function MapHelper:Empty(p_Map)
    return next(p_Map) == nil
end

-- Returns an array containing all of the keys as an array-like table
function MapHelper:Keys(p_Map)
    local l_Keys = {}
    for l_Key, _ in pairs(p_Map) do
        table.insert(l_Keys, l_Key)
    end

    return l_Keys
end

-- Returns an array containing all of the values as an array-like table
function MapHelper:Values(p_Map)
    local l_Values = {}
    for _, l_Value in pairs(p_Map) do
        table.insert(l_Values, l_Value)
    end

    return l_Values
end

-- Returns the number of entries in the map
function MapHelper:Size(p_Map)
    local l_Count = 0
    for _, _ in pairs(p_Map) do
        l_Count = l_Count + 1
    end

    return l_Count
end

-- Removes the first entry of the map where the value is equal to the specified one
function MapHelper:RemoveByValue(p_Map, p_Value)
    for l_Key, l_Value in pairs(p_Map) do
        if l_Value == p_Value then
            p_Map[l_Key] = nil
            return l_Key
        end
    end

    return nil
end

-- Returns an item of the Map if it's not empty, otherwise nil
function MapHelper:Item(p_Map)
    local l_Key = next(p_Map)
    if l_Key ~= nil then
        return p_Map[l_Key]
    end

    return nil
end
