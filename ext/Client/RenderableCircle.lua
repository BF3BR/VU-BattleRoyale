require('__shared/Configs/CircleConfig')
require('__shared/Circle')

local TWO_PI = 2 * math.pi

class ('RenderableCircle', Circle)

function RenderableCircle:__init(p_Center, p_Radius)
    Circle.__init(self, p_Center, p_Radius)

    self.m_Circumference = nil
    self.m_NumPointsToDraw = nil
    self.m_ThetaStep = nil
    self.m_DrawCircleClosed = false
    self.m_UseRaycasts = true

    self.m_RenderPoints = {}
    self.m_PrevStartingAngle = nil
    self.m_ShouldDrawPoints = false
end

-- 
function RenderableCircle:Update(p_Center, p_Radius)
    Circle.Update(self, p_Center, p_Radius)

    -- update step length
    self.m_Circumference = TWO_PI * p_Radius
    local drawArcLen = math.min(self.m_Circumference, g_Config.circle.maxArcLen * g_Config.circle.maxRenderPoints)
    local arcLength = drawArcLen / g_Config.circle.maxRenderPoints
    self.m_DrawCircleClosed = arcLength <= g_Config.circle.maxArcLen
    arcLength = math.max(g_Config.circle.minArcLen, math.min(g_Config.circle.maxArcLen, arcLength))
    local m_NumPointsToDraw = math.floor(drawArcLen / arcLength)

    -- calculate final points to draw and
    m_NumPointsToDraw = math.max(g_Config.circle.minRenderPoints, math.min(g_Config.circle.maxRenderPoints, m_NumPointsToDraw))
    arcLength = drawArcLen / m_NumPointsToDraw
    self.m_NumPointsToDraw = m_NumPointsToDraw

    -- convert to angle
    self.m_ThetaStep = arcLength / p_Radius
end

-- 
function RenderableCircle:CalculateRenderPoints(p_PlayerPos)
    -- calculate angle to center
    local l_PlayerAngle = VectorAngle(self.center, p_PlayerPos)
    local closestCircumPoint = self:CircumferencePoint(l_PlayerAngle, p_PlayerPos.y)

    -- check if it should draw the circle
    if closestCircumPoint:Distance(p_PlayerPos) >= g_Config.circle.maxDrawDistance then
        self.m_ShouldDrawPoints = false
        return
    else
        self.m_ShouldDrawPoints = true
    end

    -- discritize starting angle
    local l_StartingAngle = l_PlayerAngle - math.floor(self.m_NumPointsToDraw/2) * self.m_ThetaStep
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
        local l_Point = self:CircumferencePoint(l_Angle, playerPos.y)

        -- update y using raycasts
        if m_UseRaycasts then
            l_Point.y = GetYFromRaycast(l_Point)
        end

        table.insert(self.m_RenderPoints, l_Point)
    end
end

-- 
function RenderableCircle:Render(p_Renderer, p_PlayerPos)
    -- DebugRenderer:DrawSphere(self.center + Vec3(0, 180, 0), 1, Vec4(1, 0, 0, 0.5), false, false)

    if self.m_ShouldDrawPoints and #self.m_RenderPoints > 1 then
        for i = 2, #self.m_RenderPoints do
            p_Renderer(self.m_RenderPoints[i-1], self.m_RenderPoints[i], DoubleDistance(p_PlayerPos, self.m_RenderPoints[i]))
        end
    end
end

return RenderableCircle
