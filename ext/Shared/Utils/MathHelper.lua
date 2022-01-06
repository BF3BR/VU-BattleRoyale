---@class MathHelper
MathHelper = class "MathHelper"

---@param p_VectorA Vec3
---@param p_VectorB Vec3
---@return number
function MathHelper:VectorAngle(p_VectorA, p_VectorB)
	return math.atan(p_VectorB.z - p_VectorA.z, p_VectorB.x - p_VectorA.x)
end

-- Returns the squared 2D distance between two points
---@param p_PointA Vec3
---@param p_PointB Vec3
---@return number
function MathHelper:SquaredDistance(p_PointA, p_PointB)
	local s_Dx = p_PointA.x - p_PointB.x
	local s_Dz = p_PointA.z - p_PointB.z

	return s_Dx * s_Dx + s_Dz * s_Dz
end

---@param p_TrianglePoints Vec2[] @length 3
---@return Vec2
function MathHelper:RandomTrianglePoint(p_TrianglePoints)
	local s_A = p_TrianglePoints[1]
	local s_B = p_TrianglePoints[2]
	local s_C = p_TrianglePoints[3]

	local s_R1 = MathUtils:GetRandom(0, 1)
	local s_R2 = MathUtils:GetRandom(0, 1)

	local s_SqrtR1 = math.sqrt(s_R1)

	local s_X = (1 - s_SqrtR1) * s_A.x + (s_SqrtR1 * (1 - s_R2)) * s_B.x + (s_SqrtR1 * s_R2) * s_C.x
	local s_Y = (1 - s_SqrtR1) * s_A.y + (s_SqrtR1 * (1 - s_R2)) * s_B.y + (s_SqrtR1 * s_R2) * s_C.y

	return Vec2(s_X, s_Y)
end

---@param p_PointA Vec3
---@param p_PointB Vec3
---@param p_Time number
---@return number
function MathHelper:LerpRadians(p_PointA, p_PointB, p_Time)
	local s_Result = 0.0
	local s_Diff = p_PointB - p_PointA

	if s_Diff < -math.pi then
		-- lerp upwards past math.pi * 2
		p_PointB = p_PointB + math.pi * 2
		s_Result = MathUtils:Lerp(p_PointA, p_PointB, p_Time)

		if s_Result >= math.pi * 2 then
			s_Result = s_Result - math.pi * 2
		end
	elseif s_Diff > math.pi then
		-- lerp downwards past 0
		p_PointB = p_PointB - math.pi * 2
		s_Result = MathUtils:Lerp(p_PointA, p_PointB, p_Time)

		if s_Result < 0.0 then
			s_Result = s_Result + math.pi * 2
		end
	else
		-- straight lerp
		s_Result = MathUtils:Lerp(p_PointA, p_PointB, p_Time)
	end

	return s_Result
end

return MathHelper()
