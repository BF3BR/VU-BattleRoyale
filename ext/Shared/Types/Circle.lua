class "Circle"

function Circle:__init(p_Center, p_Radius)
	self.m_Center = p_Center or Vec3(0, 0, 0)
	self.m_Radius = p_Radius or 1
end

-- Updates circle's data
function Circle:Update(p_Center, p_Radius)
	self.m_Center = p_Center
	self.m_Radius = p_Radius
end

-- Returns circle's diameter
function Circle:Diameter()
	return self.m_Radius * 2
end

-- Returns a circumference point at a certain angle
function Circle:CircumferencePoint(p_Angle, p_Y, p_Radius)
	p_Y = p_Y or 0
	p_Radius = p_Radius or self.m_Radius

	local s_X = self.m_Center.x + p_Radius * math.cos(p_Angle)
	local s_Z = self.m_Center.z + p_Radius * math.sin(p_Angle)

	return Vec3(s_X, p_Y, s_Z)
end

-- Checks if a point is inside the circle
function Circle:IsInnerPoint(p_Point)
	local s_Dx = self.m_Center.x - p_Point.x
	local s_Dz = self.m_Center.z - p_Point.z

	return self.m_Radius * self.m_Radius > ((s_Dx * s_Dx) + (s_Dz * s_Dz))
end

-- Returns a random point inside the circle
function Circle:RandomInnerPoint(p_MaxDistance, p_Y)
	p_MaxDistance = math.min(p_MaxDistance or self.m_Radius, self.m_Radius)
	p_Y = p_Y or 0

	local s_Radius = p_MaxDistance * math.sqrt(MathUtils:GetRandom(0, 1))
	local s_Theta = MathUtils:GetRandom(0, 1) * 2 * math.pi

	local s_X = self.m_Center.x + s_Radius * math.cos(s_Theta)
	local s_Z = self.m_Center.z + s_Radius * math.sin(s_Theta)

	return Vec3(s_X, p_Y, s_Z)
end

-- Returns circle's data as a table
function Circle:AsTable()
	return {Center = self.m_Center, Radius = self.m_Radius}
end

-- Creates a Circle instance from table data
function Circle:FromTable(p_Table)
	return Circle(p_Table.Center, p_Table.Radius)
end

-- Returns a copy of this circle
function Circle:Clone()
	return Circle(self.m_Center:Clone(), self.m_Radius)
end
