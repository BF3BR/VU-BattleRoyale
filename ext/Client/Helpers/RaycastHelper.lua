class 'RaycastHelper'

function RaycastHelper:__init()
    self.m_RaycastMemo = {}

    -- Memoize Functions https://www.lua.org/pil/17.1.html
    setmetatable(self.m_RaycastMemo, {__mode = 'kv'})
end

-- Returns the ground height (Y) value of a certain position
function RaycastHelper:GetY(p_Pos)
    local l_X = p_Pos.x
    local l_Z = p_Pos.z
    local l_Key = string.format('%.2f:%.2f', l_X, l_Z)

    -- check for cache hit
    if self.m_RaycastMemo[l_Key] ~= nil then
        return self.m_RaycastMemo[l_Key]
    end

    local l_From = p_Pos + Vec3(0, 100, 0)
    local l_To = p_Pos - Vec3(0, 100, 0)
    local l_Hit = RaycastManager:Raycast(l_From, l_To, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

    -- return initial y if there's no hit
    if l_Hit == nil then
        return p_Pos.y
    end

    -- save result and return
    self.m_RaycastMemo[l_Key] = l_Hit.position.y
    return l_Hit.position.y
end

-- Clears the result cache
function RaycastHelper:Clear()
    self.m_RaycastMemo = {}
end

g_RaycastHelper = RaycastHelper()
