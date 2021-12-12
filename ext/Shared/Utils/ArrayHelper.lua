---@class ArrayHelper
local ArrayHelper = class "ArrayHelper"

-- Returns the first index at which a given value can be found in the array
function ArrayHelper:IndexOf(p_Array, p_Value)
	for l_Index, l_Value in ipairs(p_Array) do
		if l_Value == p_Value then
			return l_Index
		end
	end

	return nil
end

-- Checks if the array contains a given value
function ArrayHelper:Contains(p_Array, p_Value)
	return ArrayHelper:IndexOf(p_Array, p_Value) ~= nil
end

-- Removes an entry of the array by its value
function ArrayHelper:RemoveByValue(p_Array, p_Value)
	local s_Index = ArrayHelper:IndexOf(p_Array, p_Value)

	-- check if the value doesn't exist
	if s_Index == nil then
		return false
	end

	table.remove(p_Array, s_Index)
	return true
end

-- Converts an array to a map using the values as the keys
function ArrayHelper:ToMap(p_Array, p_Value)
	p_Value = (p_Value == nil and true) or p_Value

	local s_Map = {}

	for _, l_Value in ipairs(p_Array) do
		s_Map[l_Value] = p_Value
	end

	return s_Map
end

-- insert many items into an array at once
function ArrayHelper:InsertMany(p_Array, p_Items)
	table.move(p_Items, 1, #p_Items, #p_Array + 1, p_Array)
end

-- creates a shallow copy of the array
function ArrayHelper:Clone(p_Array)
	return {table.unpack(p_Array)}
end

return ArrayHelper()
