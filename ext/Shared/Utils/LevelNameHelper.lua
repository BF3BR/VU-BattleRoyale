class "LevelNameHelper"

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
