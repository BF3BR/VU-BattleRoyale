class "MathHelper"

function MathHelper:VectorAngle(p_VectorA, p_VectorB)
	return math.atan(p_VectorB.z - p_VectorA.z, p_VectorB.x - p_VectorA.x)
end

-- Returns the squared 2D distance between two points
function MathHelper:SquaredDistance(p_PointA, p_PointB)
	local l_Dx = p_PointA.x - p_PointB.x
	local l_Dz = p_PointA.z - p_PointB.z

	return l_Dx * l_Dx + l_Dz * l_Dz
end

-- @param p_TrianglePoints Vec2[3]
function MathHelper:RandomTrianglePoint(p_TrianglePoints)
	local l_A = p_TrianglePoints[1]
	local l_B = p_TrianglePoints[2]
	local l_C = p_TrianglePoints[3]

	local l_R1 = MathUtils:GetRandom(0, 1)
	local l_R2 = MathUtils:GetRandom(0, 1)

	local l_SqrtR1 = math.sqrt(l_R1)

	local l_X = (1 - l_SqrtR1) * l_A.x + (l_SqrtR1 * (1 - l_R2)) * l_B.x + (l_SqrtR1 * l_R2) * l_C.x
	local l_Y = (1 - l_SqrtR1) * l_A.y + (l_SqrtR1 * (1 - l_R2)) * l_B.y + (l_SqrtR1 * l_R2) * l_C.y

	return Vec2(l_X, l_Y)
end

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
