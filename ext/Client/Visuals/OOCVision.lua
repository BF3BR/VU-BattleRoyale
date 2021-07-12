class "OOCVision"

local m_Logger = Logger("OOCVision", true)

-- Out of Circle Vision
function OOCVision:__init()
	self.m_IsEnabled = false

	self.m_SoundEntity = nil
	self.m_VisualsEntity = nil

	self:RegisterEvents()
end

function OOCVision:RegisterEvents()
	Events:Subscribe("Level:Loaded", self, self.CreateEntities)
	Events:Subscribe("Extension:Unloading", self, self.Destroy)
	Events:Subscribe("Level:Destroy", self, self.Destroy)
end

function OOCVision:CreateSound()
	if self.m_SoundEntity ~= nil then
		return
	end

	-- oob sound resource
	local s_EntityData = ResourceManager:SearchForInstanceByGuid(Guid("0047C675-053C-4D84-860E-661555D20D27"))

	-- create sound entity
	if s_EntityData ~= nil then
		local s_EntityPos = LinearTransform()
		s_EntityPos.trans = Vec3(0.0, 0.0, 0.0)

		local s_Entity = EntityManager:CreateEntity(s_EntityData, s_EntityPos)

		if s_Entity ~= nil then
			s_Entity:Init(Realm.Realm_Client, true)
			self.m_SoundEntity = SoundEntity(s_Entity)
		end
	end
end

function OOCVision:CreateVisuals()
	if self.m_VisualsEntity ~= nil then
		return
	end

	local s_VeData = VisualEnvironmentEntityData()
	s_VeData.enabled = true
	s_VeData.visibility = 1
	s_VeData.priority = 999999

	local s_Original = ResourceManager:SearchForInstanceByGuid(MapsConfig[LevelNameHelper:GetLevelName()].SkyComponentDataGuid)
	if s_Original == nil then
		m_Logger:Write("Could not find original SkyComponentData")
		return nil
	end

	local s_SkyComponent = SkyComponentData(s_Original:Clone())
	s_SkyComponent.enable = true
	s_SkyComponent.brightnessScale = 16
	s_SkyComponent.sunSize = 0

	s_VeData.components:add(s_SkyComponent)
	s_VeData.runtimeComponentCount = s_VeData.runtimeComponentCount + 1

	local s_OutdoorLight = OutdoorLightComponentData()
	s_OutdoorLight.enable = true
	s_OutdoorLight.sunColor = Vec3(7.35, 4.34, 0)
	s_OutdoorLight.skyColor = Vec3(0.83, 0.59, 1)
	s_OutdoorLight.groundColor = Vec3(0.74, 0.44, 0)
	s_OutdoorLight.sunSpecularScale = 1

	s_VeData.components:add(s_OutdoorLight)
	s_VeData.runtimeComponentCount = s_VeData.runtimeComponentCount + 1

	local s_ColorCorrection = ColorCorrectionComponentData()
	s_ColorCorrection.enable = true
	s_ColorCorrection.brightness = Vec3(1.0, 0.69, 0.0)
	s_ColorCorrection.contrast = Vec3(1.0, 1.0, 1.0)
	s_ColorCorrection.saturation = Vec3(0.85, 0.34, 0.0)
	s_ColorCorrection.hue = 0.0

	s_VeData.components:add(s_ColorCorrection)
	s_VeData.runtimeComponentCount = s_VeData.runtimeComponentCount + 1

	local s_FogComponent = FogComponentData()
	s_FogComponent.enable = true
	s_FogComponent.fogGradientEnable = true
	s_FogComponent.fogColorEnable = true
	s_FogComponent.fogColor = Vec3(0.06, 0.03, 0.0)
	s_FogComponent.fogColorStart = 0
	s_FogComponent.fogColorEnd = 45
	s_FogComponent.fogColorCurve = Vec4(-0.87, 10, 0.73, -0.33)
	s_FogComponent.curve = Vec4(0.67, -0.49, 1.17, -0.02)
	s_FogComponent.transparencyFadeStart = 0
	s_FogComponent.transparencyFadeEnd = 1110
	s_FogComponent.start = 7.0
	s_FogComponent.endValue = 1305

	s_VeData.components:add(s_FogComponent)
	s_VeData.runtimeComponentCount = s_VeData.runtimeComponentCount + 1

	--[[
	local s_VignetteComponent = VignetteComponentData()
	s_VignetteComponent.enable = true
	s_VignetteComponent.scale = Vec2(2.54, 1.86)
	s_VignetteComponent.color = Vec3(0.35, 0.27, 0.0)
	s_VignetteComponent.opacity = 0.26

	s_VeData.components:add(s_VignetteComponent)
	s_VeData.runtimeComponentCount = s_VeData.runtimeComponentCount + 1]]

	local s_TonemapComponent = TonemapComponentData()
	s_TonemapComponent.middleGray = 0.8
	s_TonemapComponent.minExposure = 0.05
	s_TonemapComponent.bloomScale = Vec3(0.67, 0.54, 0.07)
	s_TonemapComponent.maxExposure = 9

	s_VeData.components:add(s_TonemapComponent)
	s_VeData.runtimeComponentCount = s_VeData.runtimeComponentCount + 1

	-- create entity
	local s_Entity = EntityManager:CreateEntity(s_VeData, LinearTransform())

	if s_Entity ~= nil then
		s_Entity:Init(Realm.Realm_Client, true)
		self.m_VisualsEntity = s_Entity

		-- disable after creation
		self.m_IsEnabled = true
		self:Disable()
	end
end

function OOCVision:CreateEntities()
	self:CreateSound()
	self:CreateVisuals()
end

function OOCVision:Enable()
	if self.m_IsEnabled or self.m_SoundEntity == nil or self.m_VisualsEntity == nil then
		return
	end

	self.m_SoundEntity:FireEvent("Start")
	self.m_VisualsEntity:FireEvent("Enable")
	self.m_IsEnabled = true
end

function OOCVision:Disable()
	if (not self.m_IsEnabled) or self.m_SoundEntity == nil or self.m_VisualsEntity == nil then
		self.m_IsEnabled = false
		return
	end

	self.m_SoundEntity:FireEvent("Stop")
	self.m_VisualsEntity:FireEvent("Disable")
	self.m_IsEnabled = false
end

function OOCVision:Destroy()
	self:Disable()

	-- destroy sound entity
	if self.m_SoundEntity ~= nil then
		self.m_SoundEntity:Destroy()
		self.m_SoundEntity = nil
	end

	-- destroy visuals entity
	if self.m_VisualsEntity ~= nil then
		self.m_VisualsEntity:Destroy()
		self.m_VisualsEntity = nil
	end
end

-- define global
if g_OOCVision == nil then
	g_OOCVision = OOCVision()
end

return g_OOCVision
