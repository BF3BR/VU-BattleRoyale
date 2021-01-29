require "__shared/Configs/CircleConfig"
require "__shared/Helpers/MathHelper"
require "__shared/Circle"
require "Helpers/RaycastHelper"

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

-- 
function RenderableCircle:Update(p_Center, p_Radius, p_PhaseIndex)
    Circle.Update(self, p_Center, p_Radius)

    -- reduce max arc length based on current phase index
    if p_PhaseIndex ~= nil then
        self.m_MaxArcLength = (0.9 ^ p_PhaseIndex) * CircleConfig.ArcLen.Max
    end

    -- update step length
    self.m_Circumference = s_TwoPi * p_Radius
    local drawArcLen = math.min(self.m_Circumference, self.m_MaxArcLength * CircleConfig.RenderPoints.Max)
    local arcLength = drawArcLen / CircleConfig.RenderPoints.Max

    -- check if we should draw the whole circle
    self.m_DrawCircleClosed = arcLength <= self.m_MaxArcLength

    arcLength = MathUtils:Clamp(arcLength, CircleConfig.ArcLen.Min, self.m_MaxArcLength)
    local m_NumPointsToDraw = math.floor(drawArcLen / arcLength)

    -- calculate final points to draw and
    m_NumPointsToDraw = MathUtils:Clamp(m_NumPointsToDraw, CircleConfig.RenderPoints.Min, CircleConfig.RenderPoints.Max)
    arcLength = drawArcLen / m_NumPointsToDraw
    self.m_NumPointsToDraw = m_NumPointsToDraw

    -- convert to angle
    self.m_ThetaStep = arcLength / p_Radius
end

-- 
function RenderableCircle:CalculateRenderPoints(p_PlayerPos)
    -- calculate angle to center
    local l_PlayerAngle = MathHelper:VectorAngle(self.m_Center, p_PlayerPos)
    local closestCircumPoint = self:CircumferencePoint(l_PlayerAngle, p_PlayerPos.y)

    -- check if it should draw the circle
    if closestCircumPoint:Distance(p_PlayerPos) >= CircleConfig.DrawDistance then
        self.m_ShouldDrawPoints = false
        return
    else
        self.m_ShouldDrawPoints = true
    end

    -- discritize starting angle
    local l_StartingAngle = l_PlayerAngle - math.floor(self.m_NumPointsToDraw / 2) * self.m_ThetaStep
    l_StartingAngle = math.floor(l_StartingAngle / self.m_ThetaStep) * self.m_ThetaStep

    -- check if starting angle is the same as before
    if l_StartingAngle == self.m_PrevStartingAngle then
        return
    end
    self.m_PrevStartingAngle = l_StartingAngle

    -- calculate points
    self.m_RenderPoints = {}
    for i = 0, self.m_NumPointsToDraw do
        local l_Angle = l_StartingAngle + i * self.m_ThetaStep
        local l_Point = self:CircumferencePoint(l_Angle, p_PlayerPos.y)

        -- update y using raycasts
        if self.m_UseRaycasts then
            l_Point.y = g_RaycastHelper:GetY(l_Point)
        end

        table.insert(self.m_RenderPoints, l_Point)
    end
end

-- 
function RenderableCircle:Render(p_Renderer, p_PlayerPos)
    -- DebugRenderer:DrawSphere(self.m_Center + Vec3(0, 180, 0), 1, Vec4(1, 0, 0, 0.5), false, false)
    local l_RadiusDrawDistance = 6 * (self.m_Radius * self.m_Radius)
    local l_DoubleDrawDistance = math.min(l_RadiusDrawDistance, CircleConfig.DrawDistance * CircleConfig.DrawDistance)

    if self.m_ShouldDrawPoints and #self.m_RenderPoints > 1 then
        for i = 2, #self.m_RenderPoints do
            p_Renderer(self.m_RenderPoints[i - 1], self.m_RenderPoints[i],
                       MathHelper:SquaredDistance(p_PlayerPos, self.m_RenderPoints[i]), l_DoubleDrawDistance)
        end
    end
end
