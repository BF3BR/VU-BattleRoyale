class "MathHelper"

function MathHelper:VectorAngle(p_VectorA, p_VectorB)
    return math.atan(p_VectorB.z - p_VectorA.z, p_VectorB.x - p_VectorA.x)
end

function MathHelper:SquaredDistance(p_PointA, p_PointB)
    local l_Dx = p_PointA.x - p_PointB.x
    local l_Dz = p_PointA.z - p_PointB.z

    return l_Dx * l_Dx + l_Dz * l_Dz
end

function MathHelper:LerpRadians(p_PointA, p_PointB, p_Time)
    local s_Result = 0.0;

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
