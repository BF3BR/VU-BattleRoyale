class "LevelNameHelper"

-- Returns "mp_001" from "levels/mp_001/mp_001"
function LevelNameHelper:GetLevelName()
	local l_LevelName = nil
	local l_tempLevelName = SharedUtils:GetLevelName()

	if l_tempLevelName == nil then
		return nil
	end

	for l_Word in string.gmatch(l_tempLevelName, "([^/]+)") do
		l_LevelName = l_Word
	end

	return l_LevelName
end
