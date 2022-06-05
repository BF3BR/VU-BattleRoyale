---@class RaycastHelper
RaycastHelper = class "RaycastHelper"

function RaycastHelper:__init()
	---`[tostring(x .. y)] -> height`
	---@type table<string, number>
	self.m_RaycastMemo = {}

	Events:Subscribe("Level:Destroy", self, self.Clear)
	Events:Subscribe(PhaseManagerEvent.Update, self, self.Clear)

	-- Memoize Functions https://www.lua.org/pil/17.1.html
	setmetatable(self.m_RaycastMemo, { __mode = "kv" })
end

-- Returns the ground height (Y) value of a certain position
---@param p_Pos Vec3
---@param p_Height number
---@return number
function RaycastHelper:GetY(p_Pos, p_Height)
	p_Height = p_Height or 100.0

	-- used math.floor to reduce raycasts number
	-- local s_X = math.floor(p_Pos.x)
	-- local s_Z = math.floor(p_Pos.z)
	local s_X = p_Pos.x
	local s_Z = p_Pos.z
	local s_Key = string.format("%.2f:%.2f", s_X, s_Z)

	-- check for cache hit
	if self.m_RaycastMemo[s_Key] ~= nil then
		return self.m_RaycastMemo[s_Key]
	end

	local s_From = p_Pos + Vec3(0, p_Height, 0)
	local s_To = p_Pos - Vec3(0, p_Height, 0)
	---@diagnostic disable-next-line: undefined-global
	local s_Hit = RaycastManager:Raycast(s_From, s_To, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter |
	RayCastFlags.DontCheckRagdoll)

	-- return initial y if there's no hit
	if s_Hit == nil then
		return p_Pos.y
	end

	-- save result and return
	self.m_RaycastMemo[s_Key] = s_Hit.position.y
	return s_Hit.position.y
end

-- Clears the result cache
function RaycastHelper:Clear()
	self.m_RaycastMemo = {}
end

return RaycastHelper()
