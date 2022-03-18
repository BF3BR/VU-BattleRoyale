---@class Circle
Circle = class "Circle"

---@param p_Center Vec3|nil
---@param p_Radius number|nil
function Circle:__init(p_Center, p_Radius)
	---@type Vec3
	self.m_Center = p_Center or Vec3(0.0, 0.0, 0.0)
	self.m_Radius = p_Radius or 1.0
end

-- Updates circle's data
---@param p_Center Vec3
---@param p_Radius number
function Circle:Update(p_Center, p_Radius)
	self.m_Center = p_Center
	self.m_Radius = p_Radius
end

-- Returns circle's diameter
---@return number
function Circle:Diameter()
	return self.m_Radius * 2
end

-- Returns a circumference point at a certain angle
---@param p_Angle number
---@param p_Y number
---@param p_Radius number
---@return Vec3
function Circle:CircumferencePoint(p_Angle, p_Y, p_Radius)
	p_Y = p_Y or 0.0
	p_Radius = p_Radius or self.m_Radius

	local s_X = self.m_Center.x + p_Radius * math.cos(p_Angle)
	local s_Z = self.m_Center.z + p_Radius * math.sin(p_Angle)

	return Vec3(s_X, p_Y, s_Z)
end

-- Checks if a point is inside the circle
---@param p_Point Vec3
---@return boolean
function Circle:IsInnerPoint(p_Point)
	local s_Dx = self.m_Center.x - p_Point.x
	local s_Dz = self.m_Center.z - p_Point.z

	return self.m_Radius * self.m_Radius > ((s_Dx * s_Dx) + (s_Dz * s_Dz))
end

-- Returns a random point inside the circle
---@param p_MaxDistance number|nil
---@param p_Y number|nil
---@return Vec3
function Circle:RandomInnerPoint(p_MaxDistance, p_Y)
	p_MaxDistance = math.min(p_MaxDistance or self.m_Radius, self.m_Radius)
	p_Y = p_Y or 0.0

	local s_Radius = p_MaxDistance * math.sqrt(MathUtils:GetRandom(0, 1))
	local s_Theta = MathUtils:GetRandom(0, 1) * 2 * math.pi

	local s_X = self.m_Center.x + s_Radius * math.cos(s_Theta)
	local s_Z = self.m_Center.z + s_Radius * math.sin(s_Theta)

	return Vec3(s_X, p_Y, s_Z)
end

-- Returns circle's data as a table
function Circle:AsTable()
	return { Center = self.m_Center, Radius = self.m_Radius }
end

-- Creates a Circle instance from table data
---@param p_Table table
---@return Circle
function Circle:FromTable(p_Table)
	return Circle(p_Table.Center, p_Table.Radius)
end

-- Returns a copy of this circle
---@return Circle
function Circle:Clone()
	return Circle(self.m_Center:Clone(), self.m_Radius)
end
