class "LevelNameHelper"

-- Returns "mp_001" from "levels/mp_001/mp_001"
function LevelNameHelper:GetLevelName()
	local s_LevelName = nil
	local s_TempLevelName = SharedUtils:GetLevelName()

	if s_TempLevelName == nil then
		return nil
	end

	for l_Word in string.gmatch(s_TempLevelName, "([^/]+)") do
		s_LevelName = l_Word
	end

	return s_LevelName
end
