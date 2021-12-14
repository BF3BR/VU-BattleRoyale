---@class CommonSpatialRaycast
CommonSpatialRaycast = class 'CommonSpatialRaycast'

local m_Logger = Logger("CommonSpatialRaycast", true)
local m_Hud = require "UI/Hud"
local m_BRLooting = require "Types/BRLooting"

function CommonSpatialRaycast:__init()
	self:RegisterVars()
end

function CommonSpatialRaycast:RegisterVars()
	self.m_Timer = 0.0
end

-- =============================================
-- Events
-- =============================================

---Called from VEXT UpdateManager:Update Event
---UpdatePass.UpdatePass_PreSim
---@param p_DeltaTime number
function CommonSpatialRaycast:OnUpdatePassPreSim(p_DeltaTime)
	self.m_Timer = self.m_Timer + p_DeltaTime

	if self.m_Timer <= ServerConfig.RaycastUpdateRate then
		return
	end

	self.m_Timer = 0.0

	self:OnSpatialRaycast()
end

-- =============================================
-- Functions
-- =============================================

---Called from self:OnUpdatePassPreSim
function CommonSpatialRaycast:OnSpatialRaycast()
	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil or s_Player.soldier == nil then
		return
	end

	local s_CameraTransform = ClientUtils:GetCameraTransform()

	if s_CameraTransform == nil or s_CameraTransform.trans == Vec3(0.0, 0.0, 0.0) then
		return
	end

	local s_From = Vec3(s_CameraTransform.trans)
	---@type Vec3
	local s_Direction = s_CameraTransform.forward * -1
	---@type Vec3
	local s_Target = s_CameraTransform.trans + (s_Direction * InventoryConfig.CloseItemSearchRadiusClient)

	local s_Entities = RaycastManager:SpatialRaycast(s_From, s_Target, SpatialQueryFlags.AllGrids)

	m_Hud:OnSpatialRaycast(s_Entities)
	m_BRLooting:OnSpatialRaycast(s_Entities)
end

return CommonSpatialRaycast()
