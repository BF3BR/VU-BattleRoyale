---@class LevelNameHelper
LevelNameHelper = class "LevelNameHelper"

-- Returns "mp_001" from "levels/mp_001/mp_001"
---@return string|nil
function LevelNameHelper:GetLevelName()
	local s_LevelName = SharedUtils:GetLevelName()

	if s_LevelName == nil then
		return nil
	end

	return s_LevelName:gsub(".*/", "")
end
