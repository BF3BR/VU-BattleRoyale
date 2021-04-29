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
	local l_EntityData = ResourceManager:SearchForInstanceByGuid(Guid("0047C675-053C-4D84-860E-661555D20D27"))

	-- create sound entity
	if l_EntityData ~= nil then
		local l_EntityPos = LinearTransform()
		l_EntityPos.trans = Vec3(0.0, 0.0, 0.0)

		local l_Entity = EntityManager:CreateEntity(l_EntityData, l_EntityPos)

		if l_Entity ~= nil then
			l_Entity:Init(Realm.Realm_Client, true)
			self.m_SoundEntity = SoundEntity(l_Entity)
		end
	end
end

function OOCVision:CreateVisuals()
	if self.m_VisualsEntity ~= nil then
		return
	end

	local veData = VisualEnvironmentEntityData()
	veData.enabled = true
	veData.visibility = 1
	veData.priority = 999999

	local original = ResourceManager:SearchForInstanceByGuid(MapsConfig[LevelNameHelper:GetLevelName()].SkyComponentDataGuid)
	if original == nil then
		m_Logger:Write("Could not find original SkyComponentData")
		return nil
	end

	local skyComponent = SkyComponentData(original:Clone())
	skyComponent.enable = true
	skyComponent.brightnessScale = 16
	skyComponent.sunSize = 0

	veData.components:add(skyComponent)
	veData.runtimeComponentCount = veData.runtimeComponentCount + 1

	local outdoorLight = OutdoorLightComponentData()
	outdoorLight.enable = true
	outdoorLight.sunColor = Vec3(7.35, 4.34, 0)
	outdoorLight.skyColor = Vec3(0.83, 0.59, 1)
	outdoorLight.groundColor = Vec3(0.74, 0.44, 0)
	outdoorLight.sunSpecularScale = 1

	veData.components:add(outdoorLight)
	veData.runtimeComponentCount = veData.runtimeComponentCount + 1

	local colorCorrection = ColorCorrectionComponentData()
	colorCorrection.enable = true
	colorCorrection.brightness = Vec3(1.0, 0.69, 0.0)
	colorCorrection.contrast = Vec3(1.0, 1.0, 1.0)
	colorCorrection.saturation = Vec3(0.85, 0.34, 0.0)
	colorCorrection.hue = 0.0

	veData.components:add(colorCorrection)
	veData.runtimeComponentCount = veData.runtimeComponentCount + 1

	local fogComponent = FogComponentData()
	fogComponent.enable = true
	fogComponent.fogGradientEnable = true
	fogComponent.fogColorEnable = true
	fogComponent.fogColor = Vec3(0.06, 0.03, 0.0)
	fogComponent.fogColorStart = 0
	fogComponent.fogColorEnd = 45
	fogComponent.fogColorCurve = Vec4(-0.87, 10, 0.73, -0.33)
	fogComponent.curve = Vec4(0.67, -0.49, 1.17, -0.02)
	fogComponent.transparencyFadeStart = 0
	fogComponent.transparencyFadeEnd = 1110
	fogComponent.start = 7.0
	fogComponent.endValue = 1305

	veData.components:add(fogComponent)
	veData.runtimeComponentCount = veData.runtimeComponentCount + 1

	--[[
	local vignetteComponent = VignetteComponentData()
	vignetteComponent.enable = true
	vignetteComponent.scale = Vec2(2.54, 1.86)
	vignetteComponent.color = Vec3(0.35, 0.27, 0.0)
	vignetteComponent.opacity = 0.26

	veData.components:add(vignetteComponent)
	veData.runtimeComponentCount = veData.runtimeComponentCount + 1]]

	local tonemapComponent = TonemapComponentData()
	tonemapComponent.middleGray = 0.8
	tonemapComponent.minExposure = 0.05
	tonemapComponent.bloomScale = Vec3(0.67, 0.54, 0.07)
	tonemapComponent.maxExposure = 9

	veData.components:add(tonemapComponent)
	veData.runtimeComponentCount = veData.runtimeComponentCount + 1

	-- create entity
	local l_Entity = EntityManager:CreateEntity(veData, LinearTransform())

	if l_Entity ~= nil then
		l_Entity:Init(Realm.Realm_Client, true)
		self.m_VisualsEntity = l_Entity

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
