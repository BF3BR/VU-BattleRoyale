class('Circle')

function Circle:__init(p_Center, p_Radius)
    self:Update(p_Center or Vec3(0, 0, 0), p_Radius or 1)
end

-- Updates circle's data
function Circle:Update(p_Center, p_Radius)
    self.m_Center = p_Center
    self.m_Radius = p_Radius
end

-- Returns a circumference point at a certain angle
function Circle2d:CircumferencePoint(p_Angle, p_Y, p_Radius)
    p_Y = p_Y or 0
    p_Radius = p_Radius or self.m_Radius

    local l_X = self.center.x + p_Radius * math.cos(p_Angle)
    local l_Z = self.center.z + p_Radius * math.sin(p_Angle)

    return Vec3(l_X, p_Y, l_Z)
  end

-- Checks if a point is inside the circle
function Circle:IsInnerPoint(p_Point)
    local l_Dx = self.m_Center.x - p_Point.x
    local l_Dz = self.m_Center.z - p_Point.z

    return self.m_Radius * self.m_Radius > ((l_Dx * l_Dx) + (l_Dz * l_Dz))
end

-- Returns a random point inside the circle
function Circle:RandomInnerPoint(p_MaxDistance, p_Y)
    p_MaxDistance = p_MaxDistance or self.radius
    p_Y = p_Y or 0

    local l_Angle = MathUtils:GetRandom(0, 2 * math.pi)
    local l_Distance = MathUtils:GetRandom(0, p_MaxDistance)

    return self:CircumferencePoint(l_Angle, p_Y, l_Distance)
end

-- Returns circle's data as a table
function Circle:AsTable()
    return {
        center = self.m_Center,
        radius = self.m_Radius
    }
end

-- Returns a copy of this circle
function Circle:Clone()
    return Circle(self.m_Center, self.m_Radius)
end
