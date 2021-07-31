require "__shared/Utils/MathHelper"
require "__shared/Utils/RaycastHelper"
require "__shared/Configs/CircleConfig"
require "__shared/Types/Circle"

local m_WindowsCircleSpawner = require "Visuals/WindowsCircleSpawner"

local s_TwoPi = 2 * math.pi

class ("RenderableCircle", Circle)

function RenderableCircle:__init(p_Center, p_Radius)
	Circle.__init(self, p_Center, p_Radius)

	self.m_Circumference = nil
	self.m_NumPointsToDraw = nil
	self.m_ThetaStep = nil
	self.m_DrawCircleClosed = false
	self.m_UseRaycasts = CircleConfig.UseRaycasts
	self.m_MaxArcLength = CircleConfig.ArcLen.Max

	self.m_RenderPoints = {}
	self.m_PrevStartingAngle = nil
	self.m_ShouldDrawPoints = false
end

function RenderableCircle:Update(p_Center, p_Radius, p_PhaseIndex)
	Circle.Update(self, p_Center, p_Radius)

	-- reduce max arc length based on current phase index
	if p_PhaseIndex ~= nil then
		self.m_MaxArcLength = (0.94 ^ p_PhaseIndex) * CircleConfig.ArcLen.Max
	end

	-- update step length
	self.m_Circumference = s_TwoPi * p_Radius
	local s_DrawArcLen = math.min(self.m_Circumference, self.m_MaxArcLength * CircleConfig.RenderPoints.Max)
	local s_ArcLength = s_DrawArcLen / CircleConfig.RenderPoints.Max

	-- check if we should draw the whole circle
	self.m_DrawCircleClosed = s_ArcLength <= self.m_MaxArcLength

	s_ArcLength = MathUtils:Clamp(s_ArcLength, CircleConfig.ArcLen.Min, self.m_MaxArcLength)
	local s_NumPointsToDraw = math.floor(s_DrawArcLen / s_ArcLength)

	-- calculate final points to draw and
	s_NumPointsToDraw = MathUtils:Clamp(s_NumPointsToDraw, CircleConfig.RenderPoints.Min, CircleConfig.RenderPoints.Max)
	s_ArcLength = s_DrawArcLen / s_NumPointsToDraw
	self.m_NumPointsToDraw = s_NumPointsToDraw

	-- convert to angle
	self.m_ThetaStep = s_ArcLength / p_Radius
end

function RenderableCircle:CalculateRenderPoints(p_PlayerPos)
	-- calculate angle to center
	local s_PlayerAngle = MathHelper:VectorAngle(self.m_Center, p_PlayerPos)
	local s_ClosestCircumPoint = self:CircumferencePoint(s_PlayerAngle, p_PlayerPos.y)

	-- check if it should draw the circle
	if s_ClosestCircumPoint:Distance(p_PlayerPos) >= CircleConfig.DrawDistance then
		self.m_ShouldDrawPoints = false
		return
	else
		self.m_ShouldDrawPoints = true
	end

	-- discritize starting angle
	local s_StartingAngle = s_PlayerAngle - math.floor(self.m_NumPointsToDraw / 2) * self.m_ThetaStep
	s_StartingAngle = math.floor(s_StartingAngle / self.m_ThetaStep) * self.m_ThetaStep

	-- check if starting angle is the same as before
	if s_StartingAngle == self.m_PrevStartingAngle then
		return
	end

	self.m_PrevStartingAngle = s_StartingAngle

	-- calculate points
	self.m_RenderPoints = {}

	for i = 0, self.m_NumPointsToDraw do
		local s_Angle = s_StartingAngle + i * self.m_ThetaStep
		local s_Point = self:CircumferencePoint(s_Angle, p_PlayerPos.y)

		-- update y using raycasts
		if self.m_UseRaycasts then
			s_Point.y = g_RaycastHelper:GetY(s_Point)
		end

		table.insert(self.m_RenderPoints, s_Point)
	end
end

function RenderableCircle:Render(p_Renderer, p_PlayerPos)
	local s_RadiusDrawDistance = 6 * (self.m_Radius * self.m_Radius)
	local s_DoubleDrawDistance = math.min(s_RadiusDrawDistance, CircleConfig.DrawDistance * CircleConfig.DrawDistance)

	if self.m_ShouldDrawPoints and #self.m_RenderPoints > 1 then

		-- remove previously spawned windows
		m_WindowsCircleSpawner:DestroyEntities()
		local s_Length = self.m_RenderPoints[1]:Distance(self.m_RenderPoints[2])

		for i = 2, #self.m_RenderPoints do
			-- p_Renderer(self.m_RenderPoints[i - 1], self.m_RenderPoints[i],
			-- 		MathHelper:SquaredDistance(p_PlayerPos, self.m_RenderPoints[i]), s_DoubleDrawDistance)
			m_WindowsCircleSpawner:SpawnWindow(self.m_RenderPoints[i - 1], self.m_RenderPoints[i], s_Length)
		end
	end
end
