class 'MathHelper'

function MathHelper:VectorAngle(p_VectorA, p_VectorB)
    return math.atan(p_VectorB.z - p_VectorA.z, p_VectorB.x - p_VectorA.x)
end

function MathHelper:SquaredDistance(p_PointA, p_PointB)
    local l_Dx = p_PointA.x - p_PointB.x
    local l_Dz = p_PointA.z - p_PointB.z

    return l_Dx * l_Dx + l_Dz * l_Dz
end

return MathHelper
