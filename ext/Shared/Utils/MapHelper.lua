---@class MapHelper
MapHelper = class "MapHelper"

-- Checks if the map contains a value
---@param p_Map table
---@param p_Value any
---@return boolean
function MapHelper:Contains(p_Map, p_Value)
	for _, l_Value in pairs(p_Map) do
		if l_Value == p_Value then
			return true
		end
	end

	return false
end

-- Checks if the map is empty
---@param p_Map table
---@return boolean
function MapHelper:Empty(p_Map)
	return next(p_Map) == nil
end

-- Returns an array containing all of the keys as an array-like table
---@param p_Map table
---@return table
function MapHelper:Keys(p_Map)
	local s_Keys = {}

	for l_Key, _ in pairs(p_Map) do
		table.insert(s_Keys, l_Key)
	end

	return s_Keys
end

-- Returns an array containing all of the values as an array-like table
---@param p_Map table
---@return table
function MapHelper:Values(p_Map)
	local s_Values = {}

	for _, l_Value in pairs(p_Map) do
		table.insert(s_Values, l_Value)
	end

	return s_Values
end

-- Returns the number of entries in the map
---@param p_Map table
---@return integer
function MapHelper:Size(p_Map)
	local s_Count = 0

	for _, _ in pairs(p_Map) do
		s_Count = s_Count + 1
	end

	return s_Count
end

-- Removes the first entry of the map where the value is equal to the specified one
---@param p_Map table
---@param p_Value any
---@return any
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
---@param p_Map table
---@return any
function MapHelper:Item(p_Map)
	local s_Key = next(p_Map)

	if s_Key ~= nil then
		return p_Map[s_Key]
	end

	return nil
end

-- Returns an item of the Map if it's not empty, otherwise nil
---@param p_Map table
---@param p_PrevKey any
---@return any
function MapHelper:NextItem(p_Map, p_PrevKey)
	return p_Map[next(p_Map, p_PrevKey)]
end

-- Checks if map size equals the target. Difference with :Size
-- is that it doesn't need to iterate the whole map
---@param p_Map table
---@param p_TargetSize integer
---@return boolean
function MapHelper:SizeEquals(p_Map, p_TargetSize)
	for _, _ in pairs(p_Map) do
		p_TargetSize = p_TargetSize - 1

		if p_TargetSize < 0 then
			return false
		end
	end

	return true
end


-- Check if the Map has exactly one item
---@param p_Map table
---@return boolean
function MapHelper:HasSingleItem(p_Map)
	return self:SizeEquals(p_Map, 1)
end

return MapHelper()
