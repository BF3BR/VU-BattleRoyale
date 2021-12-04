class ("RenderableCircle", Circle)

local m_Logger = Logger("RenderableCircle", false)
local m_WindowsCircleSpawner = require "Visuals/WindowsCircleSpawner"
local m_2PI = 2 * math.pi

function RenderableCircle:__init(p_Center, p_Radius)
	Circle.__init(self, p_Center, p_Radius)

	-- number of rectangles that need to be rendered
	self.m_RectsToRender = nil

	-- the edge points for the rectangles
	-- they are precalculated during presim in case some
	-- raycasts would be needed (depends on the implementation)
	self.m_RenderPoints = {}

	-- current arc theta
	self.m_ThetaStep = nil

	-- flag used reduce calculations and renders
	self.m_HasCalculatedPoints = false
	self.m_HasRenderedPoints = false
end

function RenderableCircle:Update(p_Center, p_Radius)
	Circle.Update(self, p_Center, p_Radius)
	self.m_HasCalculatedPoints = false
end

function RenderableCircle:CalculateRenderPoints(p_PlayerPos)
	-- check if circle was updated since previous call
	if self.m_HasCalculatedPoints then
		return
	end

	self.m_RenderPoints = {}

	-- calculate rectangle edge points to render
	-- start from 0 index to include the extra rect that is needed
	-- to fill the circle
	for l_Index = 0, self.m_RectsToRender do
		local s_Angle = l_Index * self.m_ThetaStep
		local s_Point = self:CircumferencePoint(s_Angle, p_PlayerPos.y)

		table.insert(self.m_RenderPoints, s_Point)
	end

	-- update flags
	self.m_HasCalculatedPoints = true
	self.m_HasRenderedPoints = false
end

function RenderableCircle:UpdateRenderParameters()
	local s_Circumference = m_2PI * self.m_Radius
	local s_RectsNum = CircleConfig.RenderPoints.Max
	local s_ArcLen = s_Circumference / CircleConfig.RenderPoints.Max

	-- update arc length if it's less that the specified minimum
	-- this reduces the number of rects to render as the circle gets smaller
	if s_ArcLen < CircleConfig.ArcLen.Min then
		s_ArcLen = CircleConfig.ArcLen.Min
		s_RectsNum = math.floor(s_Circumference / s_ArcLen)
	end

	-- set updated values
	self.m_RectsToRender = math.max(s_RectsNum, CircleConfig.RenderPoints.Min)
	self.m_ThetaStep = (s_Circumference / self.m_RectsToRender) / self.m_Radius
end

function RenderableCircle:Render()
	if #self.m_RenderPoints > 1 and not self.m_HasRenderedPoints then
		-- calculate the length between two edges
		local s_Length = self.m_RenderPoints[1]:Distance(self.m_RenderPoints[2])

		-- spawn the windows
		for l_Index = 2, #self.m_RenderPoints do
			m_WindowsCircleSpawner:SpawnWindow(self.m_RenderPoints[l_Index - 1], self.m_RenderPoints[l_Index], s_Length, l_Index - 1)
		end

		-- destroy unused window entities
		m_WindowsCircleSpawner:DestroyEntities(self.m_RectsToRender + 1)

		self.m_HasRenderedPoints = true
	end
end
