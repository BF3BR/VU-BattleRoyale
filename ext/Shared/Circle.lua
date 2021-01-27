class 'Circle'

function Circle:__init(p_Center, p_Radius)
    self.m_Center = p_Center or Vec3(0, 0, 0)
    self.m_Radius = p_Radius or 1
end

-- Updates circle's data
function Circle:Update(p_Center, p_Radius)
    self.m_Center = p_Center
    self.m_Radius = p_Radius
end

-- Returns a circumference point at a certain angle
function Circle:CircumferencePoint(p_Angle, p_Y, p_Radius)
    p_Y = p_Y or 0
    p_Radius = p_Radius or self.m_Radius

    local l_X = self.m_Center.x + p_Radius * math.cos(p_Angle)
    local l_Z = self.m_Center.z + p_Radius * math.sin(p_Angle)

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
    p_Y = p_Y or 0

    local l_Radius = p_MaxDistance * math.sqrt(MathUtils:GetRandom(0, 1))
    local l_Theta = MathUtils:GetRandom(0, 1) * 2 * math.pi

    local l_X = self.m_Center.x + l_Radius * math.cos(l_Theta)
    local l_Z = self.m_Center.z + l_Radius * math.sin(l_Theta)

    return Vec3(l_X, p_Y, l_Z)
end

-- Returns circle's data as a table
function Circle:AsTable()
    return {
        Center = self.m_Center,
        Radius = self.m_Radius
    }
end

-- Returns a copy of this circle
function Circle:Clone()
    return Circle(self.m_Center:Clone(), self.m_Radius)
end

return Circle
