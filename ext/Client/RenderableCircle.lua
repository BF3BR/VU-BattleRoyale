require "__shared/Utils/MathHelper"
require "__shared/Utils/RaycastHelper"
require "__shared/Configs/CircleConfig"
require "__shared/Types/Circle"

local s_TwoPi = 2 * math.pi
local m_SP_Valley_BackdropMatte_01 = DC(Guid("13B3ADD0-6311-E970-175F-DAE08111C1AB"), Guid("C6F52724-F9FC-1E44-A389-E4E9C03791FA"))

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

	-- KVN
	self.m_Entity = nil
	self.m_LastTransform = nil
end

function RenderableCircle:Update(p_Center, p_Radius, p_PhaseIndex, p_IgnoreRender)
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

	-- KVN
	if p_IgnoreRender then
		return
	end

	if self.m_Entity == nil then
		self:Spawn()
	end

	if self.m_Entity == nil then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil or s_LocalPlayer.soldier == nil then
		return
	end

	local s_Center = Vec3(
		p_Center.x,
		s_LocalPlayer.soldier.worldTransform.trans.y,
		p_Center.z
	)

	local s_Scale = 100 / 6785 * p_Radius / 100

	local s_LinearTransform = LinearTransform(
		Vec3(s_Scale, 0, 0),
		Vec3(0, s_Scale * 15, 0),
		Vec3(0, 0, s_Scale),
		s_Center
	)

	self.m_LastTransform = s_LinearTransform
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

	-- KVN
	if self.m_LastTransform == nil then
		return
	end

	local s_LinearTransform = self.m_LastTransform
	s_LinearTransform.trans.y = p_PlayerPos.y

	local s_Entity = SpatialEntity(self.m_Entity)
	s_Entity.transform = s_LinearTransform
	s_Entity:FireEvent("Disable")
	s_Entity:FireEvent("Enable")
end

function RenderableCircle:Render(p_Renderer, p_PlayerPos)
	local s_RadiusDrawDistance = 6 * (self.m_Radius * self.m_Radius)
	local s_DoubleDrawDistance = math.min(s_RadiusDrawDistance, CircleConfig.DrawDistance * CircleConfig.DrawDistance)

	if self.m_ShouldDrawPoints and #self.m_RenderPoints > 1 then
		for i = 2, #self.m_RenderPoints do
			p_Renderer(self.m_RenderPoints[i - 1], self.m_RenderPoints[i],
					MathHelper:SquaredDistance(p_PlayerPos, self.m_RenderPoints[i]), s_DoubleDrawDistance)
		end
	end
end

-- KVN
function RenderableCircle:Spawn(p_Center)
	if self.m_Entity ~= nil then
		return
	end

	local s_LinearTransform = LinearTransform(
		Vec3(0, 0, 0),
		Vec3(0, 0, 0),
		Vec3(0, 0, 0),
		Vec3(0, 0, 0)
	)

	local s_StaticModelEntityData = StaticModelEntityData()
	s_StaticModelEntityData.mesh = m_SP_Valley_BackdropMatte_01:GetInstance()

	local s_BusStaticModel = EntityManager:CreateEntity(s_StaticModelEntityData, s_LinearTransform)

	if s_BusStaticModel == nil then
		return
	end

	s_BusStaticModel:Init(Realm.Realm_Client, true, false)

	self.m_Entity = s_BusStaticModel
end

function RenderableCircle:Destroy()
	if self.m_Entity == nil then
		return
	end

	self.m_Entity:FireEvent("Disable")
	self.m_Entity:FireEvent("Destroy")
	self.m_Entity:Destroy()
	self.m_Entity = nil
end
